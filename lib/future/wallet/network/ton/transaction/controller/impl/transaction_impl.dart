import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:ton_dart/ton_dart.dart';

abstract class TonTransactionImpl extends WalletSendTransactionStateImpl<
    ITonAddress, TonClient, WalletTonNetwork, TheOpenNetworkChain> {
  TonTransactionImpl(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider,
      required this.validator});
  final LiveTransactionForm<TonTransactionForm> validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_TonTransactionImpl");
  void onChange();
  Future<Message> buildTransaction({bool fakeSignature = false});
}
