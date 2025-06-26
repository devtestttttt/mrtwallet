import 'dart:async';
import 'dart:io';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/synchronized/basic_lock.dart';
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/wallet/api/services/core/tracker.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/socket/core/socket_provider.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models/protocols.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models/request_completer.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models/socket_status.dart';

class SSLService<T extends APIProvider> extends BaseSocketService<T> {
  SSLService({required this.provider});
  @override
  final T provider;
  @override
  final APIServiceTracker tracker = APIServiceTracker();

  final _lock = SynchronizedLock();
  SecureSocket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<List<int>>? _subscription;
  @override
  bool get isConnected => _status == SocketStatus.connect;
  List<int> _toRequest(List<int> params) {
    return params + "\n".codeUnits;
  }

  final Map<int, SocketRequestCompleter> _requests = {};
  void _add(List<int> message) {
    _socket?.add(message);
  }

  void _onClose() {
    _status = SocketStatus.disconnect;
    _socket?.close().catchError((e) => null);
    _subscription?.cancel().catchError((e) {});
    _subscription = null;
    _socket = null;
  }

  @override
  void disposeService() => _onClose();
  List<int> _remainBytes = [];
  void _onMessge(List<int> event) {
    assert(event.isNotEmpty, "data is empty");
    if (event.isEmpty) return;
    assert(event[0] == 0x7b || _remainBytes.isNotEmpty, "unexpected bytes.");
    if (event[0] != 0x7b && _remainBytes.isEmpty) return;
    List<int> bytes = [];

    if (event.last == 0xa) {
      bytes = [..._remainBytes, ...event.sublist(0, event.length - 1)];
      _remainBytes = [];
    } else {
      _remainBytes = [..._remainBytes, ...event];
      return;
    }
    List<String>? str = StringUtils.tryDecode(bytes)?.split("\n");
    if (str == null) {
      _remainBytes = [];
      assert(false, "unexpected response");
      return;
    }
    for (final i in str) {
      if (i.isEmpty) continue;
      Map<String, dynamic>? decode = StringUtils.tryToJson(i);
      if (decode == null) {
        _remainBytes = [];
        assert(false, "unexpected response");
        return;
      }
      if (decode.containsKey("id")) {
        final int id = int.parse(decode["id"]!.toString());
        final request = _requests.remove(id);
        request?.completer.complete(decode);
      }
    }
  }

  @override
  Future<void> connect(Duration timeout) async {
    await _lock.synchronized(() async {
      if (_status != SocketStatus.disconnect) return;
      final result = await MethodUtils.call(() async {
        final result = provider.callUrl.split(":");
        final socket = await SecureSocket.connect(
            result.first, int.parse(result[1]),
            onBadCertificate: (certificate) => true,
            context: SecurityContext.defaultContext,
            timeout: timeout);
        return socket;
      });
      if (result.hasResult) {
        _status = SocketStatus.connect;
        _socket = result.result;
        _subscription = _socket?.listen(_onMessge, onDone: _onClose);
      } else {
        _status = SocketStatus.disconnect;
      }
    });
  }

  Future<Map<String, dynamic>> post(
      SocketRequestCompleter message, Duration timeout) async {
    try {
      return providerCaller(
          t: () async {
            _requests[message.id] = message;
            _add(_toRequest(message.params));
            final result = await message.completer.future.timeout(timeout);
            return result;
          },
          param: message,
          timeout: timeout);
    } finally {
      _requests.remove(message.id);
    }
  }

  @override
  ServiceProtocol get protocol => ServiceProtocol.ssl;
}
