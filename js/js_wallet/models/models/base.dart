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

@JSExport()
class ProxyMethodHandler<T> {
  final String? debugKey;
  final T object;
  ProxyMethodHandler(this.object, {this.debugKey});

  @JSExport("set")
  bool set(JSAny object, JSAny? prop, JSAny? value, JSAny? receiver) {
    try {
      final r = Reflect.get(object, prop, receiver);
      if (r.isUndefined) {
        return Reflect.set(object, prop, value, receiver);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @JSExport("get")
  JSAny? get(JSAny object, JSAny? prop, JSAny? receiver) {
    if (prop?.isDefinedAndNotNull ?? false) {
      if (prop.isA<JSString>()) {
        final pr = prop.dartify() as String;
        // if (debugKey != null) {
        //   Logg.log("$debugKey: $pr");
        // }
        if (pr.startsWith("is")) {
          final r = Reflect.get(object, prop, receiver);
          if (r.isDefinedAndNotNull) return r;
          return true.toJS;
        }
      }
    }
    return Reflect.get(object, prop, receiver);
  }
}

@JS("Reflect")
extension type Reflect._(JSObject _) implements JSAny {
  external factory Reflect();
  @JS("get")
  external static JSAny? get(JSAny? object, JSAny? prop, JSAny? receiver);
  @JS("set")
  external static bool set(
      JSAny? object, JSAny? prop, JSAny? value, JSAny? receiver);
}

@JS("Proxy")
extension type Proxy<T extends JSAny>._(JSObject _) implements JSAny {
  external factory Proxy(T target, JSObject handler);
}

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
