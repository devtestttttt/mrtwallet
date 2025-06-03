import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';

abstract class CosmosTransactiomImpl extends WalletSendTransactionStateImpl<
    ICosmosAddress, CosmosClient, WalletCosmosNetwork, CosmosChain> {
  CosmosTransactiomImpl({
    required super.walletProvider,
    required super.account,
    required this.validator,
    required super.apiProvider,
  });

  final LiveTransactionForm<CosmosTransactionForm> validator;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "CosmosTransactiomImpl");
  late final IntegerBalance remindAmount = IntegerBalance.zero(network.token);

  BaseAccount get ownerAccount;
  CosmosTransactionFeeInfo? get fee;
  String? get memo;
  bool get isThorChain =>
      network.coinParam.networkType == CosmosNetworkTypes.thorAndForked;
  Token get feeToken;
  List<CW20Token> get feeTokens;

  void onCalculateAmount();
}
