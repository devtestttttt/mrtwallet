import 'package:blockchain_utils/service/service.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/stellar.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarHTTPService extends HTTPService<StellarAPIProvider>
    implements StellarServiceProvider {
  StellarHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  final StellarAPIProvider provider;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(StellarRequestDetails params,
      {Duration? timeout}) async {
    final corretUrl = params.apiType == StellarAPIType.horizon
        ? provider.callUrl
        : provider.sorobanUrl;
    final r = await serviceRequest<T>(params,
        uri: params.toUri(corretUrl), allowStatus: [200], timeout: timeout);
    return r;
  }
}
