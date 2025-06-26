import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/sui.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/sui/sui.dart';

class SuiHTTPService extends HTTPService<SuiAPIProvider>
    implements SuiServiceProvider {
  SuiHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  Future<SuiServiceResponse<T>> doRequest<T>(SuiRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }

  @override
  final SuiAPIProvider provider;
}
