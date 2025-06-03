import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/controller/impl/memo_impl.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class RippleTransactionImpl extends WalletSendTransactionStateImpl<
    IXRPAddress, RippleClient, WalletXRPNetwork, RippleChain> {
  RippleTransactionImpl({
    required super.walletProvider,
    required super.account,
    required super.apiProvider,
  });

  void setFee(String? feeType, {BigInt? customFee});
  List<XRPLMemo> get memos;
  Future<void> onSetupMemo(XRPLMemo? memo, OnSetupMemo onSetupMemo);
  IntegerBalance get fee;
  XrplFeeType? get feeType;
  Map<String, IntegerBalance> get fees;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_XRPTransaactionStateController");
}
