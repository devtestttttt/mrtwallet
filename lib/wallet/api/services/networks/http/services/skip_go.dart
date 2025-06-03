import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/custom.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class SkipGoHTTPService extends HTTPService<CustomAPIProvider>
    implements SkipGoApiServiceProvider {
  SkipGoHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;

  @override
  Future<SkipGoApiServiceResponse<T>> doRequest<T>(
      SkipGoApiRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: [200]);
  }

  @override
  final Duration defaultTimeOut;

  @override
  final CustomAPIProvider provider;
}
