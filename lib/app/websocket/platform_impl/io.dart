import 'dart:async';
import 'dart:io';
import 'package:on_chain_wallet/app/error/exception/exception.dart';
import 'package:on_chain_wallet/app/websocket/core/core.dart';

Future<PlatformWebScoket> connectSoc(String url,
        {List<String>? protocols}) async =>
    await WebsocketIO.connect(url);

class WebsocketIO implements PlatformWebScoket {
  final WebSocket _socket;
  late StreamController<dynamic>? _streamController =
      StreamController<dynamic>()..onCancel = _onCloseStream;
  void _onCloseStream() {
    _socket.close(1000, "closed by client.");
  }

  @override
  bool get isConnected => _socket.readyState == WebSocket.open;
  WebsocketIO._(this._socket) {
    _socket.listen(
      (dynamic data) {
        _streamController?.add(data);
      },
      onDone: () {
        close();
      },
      onError: (dynamic error) {
        _streamController?.addError(error);
      },
    );
  }

  @override
  void close() {
    _streamController?.close();
    _streamController = null;
  }

  @override
  Stream<dynamic> get stream {
    final stream = _streamController?.stream;
    if (stream == null) {
      throw ApiProviderExceptionConst.connectionClosed;
    }
    return stream;
  }

  static Future<WebsocketIO> connect(String url,
      {List<String>? protocols}) async {
    try {
      final socket = await WebSocket.connect(url, protocols: protocols);
      return WebsocketIO._(socket);
    } on WebSocketException catch (e) {
      throw ApiProviderException.error(e.message);
    } on TlsException catch (e) {
      throw ApiProviderException.error(e.message);
    }
  }

  @override
  void sink(List<int> message) {
    _socket.add(message);
  }
}
