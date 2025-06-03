import 'package:on_chain_wallet/wallet/api/client/networks/ripple/client/ripple.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/xrp.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class RippleTransactionForm extends TransactionForm<RippleClient,
    IXRPAddress, WalletXRPNetwork, RippleChain> {
  List<TransactionFormField> get fields;
  XRPTransaction toTransaction(
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee});
  String get helperUri;
  XRPLTransactionType get transactionType;
  @override
  String? validateError();
  String get validatorName;
  String get validatorDescription;
  void removeIndex<T>(TransactionFormField<List<T>> field, int index);
  void setListValue<T>(TransactionFormField<List<T>> field, T? value);
  void setValue<T>(TransactionFormField<T>? field, T? value);

  XRPWalletTransaction toWalletTransaction({required String txId});

  @override
  void close() {
    for (final i in fields) {
      i.clear();
    }
    super.close();
  }
}

abstract class RippleOperationTransactionForm extends RippleTransactionForm {
  @override
  XRPWalletTransaction toWalletTransaction({required String txId}) {
    return XRPWalletTransaction(txId: txId, network: network, outputs: [
      XRPWalletTransactionOperationOutput(name: transactionType.value)
    ]);
  }
}
