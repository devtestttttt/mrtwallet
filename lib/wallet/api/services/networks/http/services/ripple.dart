import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleHTTPService extends HTTPService<RippleAPIProvider>
    implements XRPServiceProvider {
  RippleHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  String get url => provider.callUrl;

  @override
  final RippleAPIProvider provider;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(XRPRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
