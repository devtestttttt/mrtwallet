import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain/tron/src/provider/models/chain_parameters.dart';

abstract class TronTransactionImpl extends WalletSendTransactionStateImpl<
    ITronAddress, TronClient, WalletTronNetwork, TronChain> {
  TronTransactionImpl({
    required super.walletProvider,
    required super.account,
    required super.apiProvider,
  });
  TronChainParameters get tronChainParameters;
  TronTransactionForm get field;

  String? get memo;
  TronFee? get consumedFee;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_EthTransactionImpl");
}
