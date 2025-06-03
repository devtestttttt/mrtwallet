import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain/solana/src/instructions/memo/program.dart';

abstract class SolanaTransactionImpl extends WalletSendTransactionStateImpl<
    ISolanaAddress, SolanaClient, WalletSolanaNetwork, SolanaChain> {
  SolanaTransactionImpl({
    required super.walletProvider,
    required super.account,
    required this.validator,
    required super.apiProvider,
  });
  final LiveTransactionForm<SolanaTransactionForm> validator;
  SolanaTransactionForm get form => validator.validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_SolanaTransactionImpl");
  MemoProgram? get memo;
  void checkTransaction();
}
