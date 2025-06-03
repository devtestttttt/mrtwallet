import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain/solana/src/instructions/memo/program.dart';
import 'package:on_chain/sui/sui.dart';

abstract class SuiTransactionImpl extends WalletSendTransactionStateImpl<
    ISuiAddress, SuiClient, WalletSuiNetwork, SuiChain> {
  SuiTransactionImpl(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider,
      required this.validator});

  final LiveTransactionForm<SuiTransactionForm> validator;
  SuiTransactionForm get form => validator.validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_SolanaTransactionImpl");
  MemoProgram? get memo;
  void checkTransaction();

  Future<SuiTransactionDataV1> createEstimateTransaction(
      {required BigInt gasPrice, required BigInt budget});
}
