import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart' show ApiService;
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/bitcoin/providers/bitcoin.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/http/http.dart';

class BitcoinHTTPService extends HTTPService<BitcoinExplorerAPIProvider>
    implements ApiService {
  BitcoinHTTPService({required this.provider, required this.isolate});
  @override
  final APPIsolate isolate;

  @override
  final BitcoinExplorerAPIProvider provider;

  @override
  Future<T> get<T>(String url) async {
    final result = await providerGET<T>(url);
    return result.bodyAs();
  }

  @override
  Future<T> post<T>(String url,
      {Map<String, String>? headers, Object? body}) async {
    final response = await providerPOST<T>(url, body as String?,
        allowStatus: provider.explorerType.isBlockCypher ? [200, 201] : [200]);
    return response.bodyAs();
  }
}
