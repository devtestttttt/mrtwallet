import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class XRPRequestTransactionStatus
    extends XRPLedgerRequest<WalletTransactionStatus, Map<String, dynamic>> {
  XRPRequestTransactionStatus(
      {required this.transaction,
      this.maxLedger,
      this.minLedger,
      this.binary = false});
  @override
  String get method => XRPRequestMethod.tx;

  final String transaction;
  final bool binary;
  final int? minLedger;
  final int? maxLedger;

  @override
  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction,
      'max_ledger': maxLedger,
      'min_ledger': minLedger,
      'binary': binary,
    };
  }

  @override
  WalletTransactionStatus onResonse(Map<String, dynamic> result) {
    if (result["status"] == null || result["status"] == "success") {
      if (result["meta"]["TransactionResult"] == "tesSUCCESS") {
        return WalletTransactionStatus.block;
      }
      return WalletTransactionStatus.failed;
    }
    return WalletTransactionStatus.unknown;
  }
}
