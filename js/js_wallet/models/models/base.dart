import 'dart:js_interop';
import 'package:on_chain_bridge/web/api/core/js.dart';
import 'networks.dart';

@JS("onChain")
external OnChainWallet? get onChainNullable;

@JS("onChain")
external OnChainWallet get onChain;

@JS("onChain")
external set onChain(JSAny onChain);

@JS("ethereum")
external set ethereum(Proxy<EIP1193>? ethereum);

extension type OnChainWallet(JSObject _) implements JSOBJ {
  @JS("scriptId")
  external JSAny get _scriptId;
  @JS("scriptId")
  external String _scriptIdFunc();
  @JS("scriptId")
  external String get _scriptIdStr;

  @JS("ethereum")
  external set ethereum(EIP1193 ethereum);
  external set version(int version);
  external int get version;

  external EIP1193 get ethereum;

  @JS("onWebViewMessage")
  external set onWebViewMessage(JSFunction? f);

  @JS("onChainInternalJsRequest")
  external void onChainInternalJsRequest(
      String id, String data, String requestId, String type);

  String get clientId {
    if (_scriptId.isA<JSFunction>()) {
      return _scriptIdFunc();
    } else {
      return _scriptIdStr;
    }
  }
}
@JS()
extension type JSInt58(JSObject _) implements JSAny {
  external int get low;
  external int get high;
  external bool get unsigned;
  static const List<String> properties = ['low', 'high', 'unsigned'];
}
