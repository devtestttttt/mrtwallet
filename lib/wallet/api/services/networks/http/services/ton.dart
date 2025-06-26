import 'package:blockchain_utils/service/service.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/ton.dart';
import 'package:ton_dart/ton_dart.dart'
    show TonApiType, TonRequestDetails, TonServiceProvider;

class TonHTTPService extends HTTPService<TonAPIProvider>
    implements TonServiceProvider {
  TonHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  final TonAPIProvider provider;
  @override
  TonApiType get api => provider.apiType;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TonRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
