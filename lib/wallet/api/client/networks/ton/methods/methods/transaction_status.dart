import 'package:blockchain_utils/helper/helper.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:ton_dart/ton_dart.dart';

class TonRquestTransactionStatus
    extends TonApiRequest<WalletTransactionStatus, Map<String, dynamic>> {
  final String txId;
  final TonApiType api;
  TonRquestTransactionStatus({required this.txId, required this.api});
  TonApiRequest? _request;
  TonApiRequest _getRequest() {
    if (!api.isTonCenter) {
      return TonApiGetBlockchainTransaction(txId);
    }
    return TonCenterV3Traces(msgHash: [txId], includeActions: true);
  }

  @override
  TonRequestDetails buildRequest(int v) {
    _request = _getRequest();
    return _request!.buildRequest(v);
  }
// final result =
//         await provider.requestDynamic(TonApiGetBlockchainTransaction(txId));
  // final tx =
  //     MethodUtils.nullOnException(() => TransactionResponse.fromJson(result));

  // if (tx != null) {
  //   if (!tx.success) return WalletTransactionStatus.failed;
  //   return WalletTransactionStatus.block;
  // }
//     return WalletTransactionStatus.block;
  @override
  String get method => throw UnimplementedError();

  @override
  WalletTransactionStatus onResonse(Map<String, dynamic> result) {
    if (api.isTonCenter) {
      final r = TonCenterTracesResponse.fromJson(result);
      final List<Map<String, dynamic>>? actions =
          MethodUtils.nullOnException(() {
        final tx =
            r.traces.firstWhereNullable((e) => e["external_hash"] == txId);
        return (tx?["actions"] as List).cast<Map<String, dynamic>>();
      });
      if (actions == null) {
        return WalletTransactionStatus.unknown;
      }
      if (!actions.every((e) => e["success"])) {
        return WalletTransactionStatus.failed;
      }
      return WalletTransactionStatus.block;
    }
    final tx =
        MethodUtils.nullOnException(() => TransactionResponse.fromJson(result));
    assert(tx != null, 'parsing ton tx failed');
    if (tx != null) {
      if (!tx.success) return WalletTransactionStatus.failed;
      return WalletTransactionStatus.block;
    }
    return WalletTransactionStatus.block;
  }
}
