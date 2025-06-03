import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/aptos/src/transaction/types/types.dart';

abstract class AptosTransactionImpl extends WalletSendTransactionStateImpl<
    IAptosAddress, AptosClient, WalletAptosNetwork, AptosChain> {
  AptosTransactionImpl(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider,
      required this.validator});
  final LiveTransactionForm<AptosTransactionForm> validator;
  AptosTransactionForm get form => validator.validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_SolanaTransactionImpl");
  void checkTransaction();
  Future<AptosSignedTransaction> createTransaction(
      {BigInt? maxGasAmount, BigInt? gasUnitPrice, bool simulateTx = false});
}
