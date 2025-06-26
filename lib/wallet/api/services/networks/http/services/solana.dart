import 'package:blockchain_utils/service/service.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/solana.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaHTTPService extends HTTPService<SolanaAPIProvider>
    implements SolanaServiceProvider {
  SolanaHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SolanaRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }

  @override
  final SolanaAPIProvider provider;
}
