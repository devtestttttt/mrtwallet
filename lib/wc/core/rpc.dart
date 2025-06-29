part of 'package:on_chain_wallet/wc/wc.dart';

enum WcRpcSocketStatus {
  connect("connect"),
  disconnect("disconnect"),
  pending("pending"),
  dispose("disable"),
  noNetwork("no_network");

  final String tr;
  const WcRpcSocketStatus(this.tr);

  bool get isConnect => this == connect;
  bool get isDispose => this == dispose;

  bool get allowReconnect => this == disconnect;
}

typedef ONGENERATEURL = Future<String> Function();

class JsonRpcWebSocketService {
  JsonRpcWebSocketService(this.generateUrl);
  final ONGENERATEURL generateUrl;
  final Cancelable _cancelable = Cancelable();
  final StreamController<RelayClientResponse> _controller =
      StreamController.broadcast(sync: true);
  final StreamValue<WcRpcSocketStatus> status =
      StreamValue(WcRpcSocketStatus.dispose);
  Stream<RelayClientResponse> get stream {
    return _controller.stream;
  }

  final Map<int, SocketRequestCompleter> _requests = {};
  final _lock = SynchronizedLock();
  PlatformWebScoket? _socket;
  // WcRpcSocketStatus _status = WcRpcSocketStatus.dispose;
  StreamSubscription<String>? _subscription;

  void _add(List<int> message) {
    _socket?.sink(message);
  }

  void _onClose() {
    _cancelable.cancel();
    _lock.synchronized(() {
      if (status.value == WcRpcSocketStatus.connect) {
        status.value = WcRpcSocketStatus.disconnect;
      }
      _subscription?.cancel().catchError((e) {});
      _socket?.close();
      _subscription = null;
      _socket = null;
      _controller.add(RelayClientDisconnectResponse());
      _connect();
    });
  }

  void _onMessge(String event) {
    final Map<String, dynamic> decode = StringUtils.toJson(event);
    final response = RelayClientResponse.fromJson(decode);
    if (response is RelayClientErrorResponse) {
      final request = _requests.remove(response.id);
      request?.completer.completeError(
          RPCError(message: response.message, errorCode: response.code));
      return;
    }
    if (response is RelayClientRequestResponse) {
      final request = _requests.remove(response.id);
      request?.completer.complete(response.result);
    } else {
      _controller.add(response);
    }
  }

  Future<void> _connectInternal(String url,
      {Duration waitAtError = Duration.zero}) async {
    status.value = WcRpcSocketStatus.pending;
    final result = await MethodUtils.call(() async {
      final socket = await PlatformWebScoket.connect(
          url: url, timeout: const Duration(seconds: 30));
      return socket;
    }, cancelable: _cancelable, waitAtError: waitAtError);
    if (result.hasResult) {
      status.value = WcRpcSocketStatus.connect;
      _socket = result.result;
      _subscription =
          _socket?.stream.cast<String>().listen(_onMessge, onDone: () {
        _onClose();
      });
    } else {
      if (result.isCancel || status.value.isDispose) return;
      status.value = WcRpcSocketStatus.disconnect;
    }
  }

  Future<void> _connect() async {
    await _lock.synchronized(() async {
      if (!status.value.allowReconnect) return;

      final url = await MethodUtils.call(() async => await generateUrl());
      assert(url.hasResult, "somthing wrong when generate url");
      if (url.hasError) return;
      int reconnectAttempts = 0;
      while (status.value.allowReconnect) {
        final waitOnError = Duration(seconds: reconnectAttempts);
        await _connectInternal(url.result, waitAtError: waitOnError);
        if (reconnectAttempts < 30) {
          reconnectAttempts++;
        }
        if (status.value.isConnect) {
          _controller.add(RelayClientConnectResponse());
        }
      }
    }, lockId: LockId.two);
  }

  Future<dynamic> send(RelayClientRequest request) async {
    await _connect();
    if (!status.value.isConnect) {
      throw WalletConnectExceptionConst.connectionTerminated;
    }
    final data = request.toJson();
    final toBytes = StringUtils.encode(StringUtils.fromJson(data));
    final message = SocketRequestCompleter(toBytes, request.id);
    _requests[request.id] = message;
    _add(toBytes);
    final result = await message.completer.future.timeout(
        const Duration(minutes: 1),
        onTimeout: () =>
            throw WalletConnectExceptionConst.connectionTerminated);
    return result;
  }

  StreamSubscription<bool>? _connectivityStream;
  void _onConectivityChange(bool isOnline) {
    if (isOnline) {
      if (status.value == WcRpcSocketStatus.noNetwork) {
        status.value = WcRpcSocketStatus.disconnect;
        _connect();
      }
    } else {
      if (status.value != WcRpcSocketStatus.dispose) {
        status.value = WcRpcSocketStatus.noNetwork;
      }
      _onClose();
    }
  }

  Future<void> init() async {
    return _lock.synchronized(() {
      if (status.value != WcRpcSocketStatus.dispose) return;
      status.value = WcRpcSocketStatus.disconnect;
      _connectivityStream?.cancel();
      _connectivityStream = null;
      _connectivityStream = PlatformInterface.instance.onNetworkStatus
          .listen(_onConectivityChange);
      _connect();
    });
  }

  Future<void> dispose() {
    return _lock.synchronized(() {
      _connectivityStream?.cancel();
      _connectivityStream = null;
      status.value = WcRpcSocketStatus.dispose;
      _onClose();
    });
  }

  Future<void> close() {
    return _lock.synchronized(() {
      _connectivityStream?.cancel();
      _connectivityStream = null;
      _onClose();
      _controller.close();
      for (final i in [..._requests.values]) {
        i.completer
            .completeError(WalletConnectExceptionConst.connectionTerminated);
      }
    });
  }
}
