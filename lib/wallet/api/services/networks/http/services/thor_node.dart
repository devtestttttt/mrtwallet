import 'package:blockchain_utils/service/service.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/cosmos.dart';

class ThorNodeHTTPService extends HTTPService<CosmosAPIProvider>
    implements ThorNodeServiceProvider {
  ThorNodeHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(ThorNodeRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl), allowStatus: [200]);
  }

  @override
  final Duration defaultTimeOut;

  @override
  final CosmosAPIProvider provider;
}
