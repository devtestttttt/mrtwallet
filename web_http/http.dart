import 'dart:js_interop';
import 'package:on_chain_bridge/models/device/models/platform.dart';
import 'package:on_chain_wallet/app/http/isolate/impl/caller/caller.dart';
import 'package:on_chain_wallet/app/http/isolate/models/message.dart';

@JS("postMessage")
external void postMessage(JSAny data);

@JS()
external set cryptoJsHandler(JSFunction handler);

@JS()
external set cryptoJsActivation(JSFunction? handler);
final Service service = Service();

void _onMessage(JSAny message) {
  service.sentResult(message);
}

String _onActivation() {
  try {
    return "";
  } finally {
    cryptoJsActivation = null;
  }
}

void main(List<String> args) {
  cryptoJsHandler = _onMessage.toJS;
  cryptoJsActivation = _onActivation.toJS;
}

class Service {
  final ServicesHTTPCaller caller = ServicesHTTPCaller();
  void sentResult(JSAny message) async {
    final msg = HTTPWorkerRequest.fromJson(
        (message.dartify()! as Map).cast<String, dynamic>());
    final response = await caller.makeCall(msg, platform: AppPlatform.web);
    postMessage(response.toJson().jsify()!);
  }
}
