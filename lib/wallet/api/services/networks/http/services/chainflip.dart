import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/custom.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class ChainFlipHTTPService extends HTTPService<CustomAPIProvider>
    implements CfServiceProvider {
  ChainFlipHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  Future<CfServiceResponse<T>> doRequest<T>(CfRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: [200]);
  }

  @override
  final CustomAPIProvider provider;
}
