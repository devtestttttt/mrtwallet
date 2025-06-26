import 'package:blockchain_utils/service/service.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/tron.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/on_chain.dart';

class TronHTTPService extends HTTPService<TronAPIProvider>
    implements TronServiceProvider {
  TronHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;
  @override
  final TronAPIProvider provider;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TronRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
