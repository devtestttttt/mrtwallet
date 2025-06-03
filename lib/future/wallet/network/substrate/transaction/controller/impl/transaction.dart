import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class SubstrateTransactiomImpl extends WalletSendTransactionStateImpl<
    ISubstrateAddress,
    SubstrateClient,
    WalletSubstrateNetwork,
    SubstrateChain> {
  SubstrateTransactiomImpl({
    required super.walletProvider,
    required super.account,
    required super.apiProvider,
  });

  bool get supportBatch => apiProvider.metadata.supportBatch;
  bool get supportMemo => apiProvider.metadata.supportRemarks;

  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "SubstrateTransactiomImpl");
  late final IntegerBalance remindAmount = IntegerBalance.zero(network.token);
  List<String> get memos;
  void onCalculateAmount();
  MetadataApi get api => apiProvider.api;
  SubstrateChainMetadata get metadata => apiProvider.metadata;
}
