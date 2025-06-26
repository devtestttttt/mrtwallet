import 'package:blockchain_utils/service/service.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/cosmos.dart';

class TendermintHTTPService extends HTTPService<CosmosAPIProvider>
    implements TendermintServiceProvider {
  TendermintHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TendermintRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl), allowStatus: [200]);
  }

  @override
  final CosmosAPIProvider provider;
}
