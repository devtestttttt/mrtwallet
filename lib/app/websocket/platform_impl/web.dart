import 'dart:async';
import 'dart:js_interop';
import 'package:on_chain_bridge/web/web.dart';
import 'package:on_chain_wallet/app/error/exception/exception.dart';
import 'package:on_chain_wallet/app/websocket/websocket.dart';

Future<PlatformWebScoket> connectSoc(
        {required String url,
        required Duration timeout,
        List<String>? protocols}) async =>
    await WebsocketWeb.connect(url: url, timeout: timeout);

class WebsocketWeb implements PlatformWebScoket {
  final JSWebSocket _socket;
  int? _closeCode;
  String? _closeReason;
  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => _closeReason;
  late final StreamController<String> _streamController =
      StreamController<String>()..onCancel = _onCloseStream;
  void _onCloseStream() {
    if (!_socket.isClosed) {
      _socket.close(1000, "closed by client.");
      _closeCode = 1000;
      _closeReason = "closed by client.";
    }
    _socket.onopen = null;
    _socket.onclose = null;
    _socket.onmessage = null;
    _socket.onopen = null;
  }

  Completer<WebsocketWeb>? _connectedCompleter = Completer<WebsocketWeb>();
  WebsocketWeb._(this._socket) {
    _socket.onopen = () {
      _connectedCompleter?.complete(this);
      _connectedCompleter = null;
    }.toJS;
    _socket.onmessage = (JSWebScoketMessageEvent msg) {
      _streamController.add(msg.data.toDart);
    }.toJS;
    _socket.onclose = (JSWebScoketCloseEvent event) {
      _closeCode = event.code;
      _closeReason = event.reason;
      _streamController.close();
      _connectedCompleter
          ?.completeError(ApiProviderExceptionConst.connectionClosed);
      _connectedCompleter = null;
    }.toJS;
  }

  @override
  void close() {
    _streamController.close();
  }

  @override
  bool get isConnected => _socket.isOpen;
  @override
  Stream<String> get stream => _streamController.stream;

  static Future<WebsocketWeb> connect(
      {required String url,
      required Duration timeout,
      List<String> protocols = const []}) async {
    final socket =
        WebsocketWeb._(JSWebSocket.create(url, protocols: protocols));
    try {
      return await socket._connectedCompleter!.future.timeout(timeout);
    } on ApiProviderException {
      rethrow;
    } catch (_) {
      socket.close();
      rethrow;
    }
  }

  @override
  void sink(List<int> message) {
    _socket.send_(message);
  }
}
