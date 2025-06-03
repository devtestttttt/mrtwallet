import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/custom.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class SwapKitHTTPService extends HTTPService<CustomAPIProvider>
    implements SwapKitServiceProvider {
  SwapKitHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;

  @override
  Future<SwapKitServiceResponse<T>> doRequest<T>(SwapKitRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: []);
  }

  @override
  final Duration defaultTimeOut;

  @override
  final CustomAPIProvider provider;
}
