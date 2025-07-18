import 'dart:async';
import 'package:on_chain_bridge/models/device/models/platform.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/http/isolate/models/message.dart';
import 'package:http/http.dart' as http;

class HTTPCaller {
  static final HttpClientManager _clientManager = HttpClientManager();
  static Future<HTTPCallerResponse> post({
    required Uri uri,
    required Duration timeout,
    AppPlatform platform = AppPlatform.android,
    ProviderAuthenticated? authenticated,
    HTTPResponseType type = HTTPResponseType.binary,
    HTTPClientType clientType = HTTPClientType.cached,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final data = await _clientManager.call(
      t: ({required client, required headers, required uri}) async {
        return client.post(uri, headers: headers, body: body).timeout(timeout);
      },
      uri: uri,
      clientType: clientType,
      method: HTTPRequestType.post,
      authenticated: authenticated,
      headers: headers,
    );
    return HTTPCallerResponse.parse(
        bodyBytes: data.bodyBytes,
        statusCode: data.statusCode,
        type: type,
        platform: platform);
  }

  static Future<HTTPCallerResponse> get<T>({
    required Uri uri,
    required Duration timeout,
    AppPlatform platform = AppPlatform.android,
    ProviderAuthenticated? authenticated,
    HTTPClientType clientType = HTTPClientType.cached,
    HTTPResponseType type = HTTPResponseType.binary,
    Map<String, String>? headers,
  }) async {
    final data = await _clientManager.call(
        t: ({required client, required headers, required uri}) async {
          return client.get(uri, headers: headers).timeout(timeout);
        },
        uri: uri,
        clientType: clientType,
        method: HTTPRequestType.post,
        authenticated: authenticated,
        headers: headers);
    return HTTPCallerResponse.parse(
        bodyBytes: data.bodyBytes,
        statusCode: data.statusCode,
        type: type,
        platform: platform);
  }

  static Future<HTTPCallerResponse> getStream(
      {required Uri uri,
      AppPlatform platform = AppPlatform.android,
      Map<String, String> headers = const {},
      OnStreamReapose? onProgress}) async {
    StreamSubscription<List<int>>? subscription;
    final client = _clientManager.getClient();
    try {
      final Completer<HTTPCallerResponse> completer = Completer();
      final r = http.Request("GET", uri);
      r.headers.addAll(headers);
      final stream = await client.send(r);
      final List<int> data = List<int>.empty(growable: true);
      subscription = stream.stream.listen((e) {
        data.addAll(e);
        if (stream.contentLength != null) {
          onProgress?.call(data.length, stream.contentLength!);
        }
      }, onDone: () {
        if (!completer.isCompleted) {
          completer.complete(HTTPCallerResponse.parse(
              bodyBytes: data,
              statusCode: stream.statusCode,
              type: HTTPResponseType.binary,
              platform: platform));
        }
      }, onError: (s) {
        completer.completeError(s);
      }, cancelOnError: true);
      return await completer.future;
    } finally {
      client.close();
      subscription?.cancel();
      subscription = null;
    }
  }
}
