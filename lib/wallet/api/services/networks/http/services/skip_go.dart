import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/custom.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class SkipGoHTTPService extends HTTPService<CustomAPIProvider>
    implements SkipGoApiServiceProvider {
  SkipGoHTTPService(
      {required this.provider,
      required this.isolate,
      super.timeout = const Duration(minutes: 1)});
  @override
  final APPIsolate isolate;

  @override
  Future<SkipGoApiServiceResponse<T>> doRequest<T>(
      SkipGoApiRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        allowStatus: [200], timeout: timeout);
  }

  @override
  final CustomAPIProvider provider;
}
