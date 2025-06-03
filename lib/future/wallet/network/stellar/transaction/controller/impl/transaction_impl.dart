import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'memo.dart';

abstract class StellarTransactionImpl extends WalletSendTransactionStateImpl<
    IStellarAddress, StellarClient, WalletStellarNetwork, StellarChain> {
  StellarTransactionImpl({
    required super.walletProvider,
    required super.account,
    required super.apiProvider,
  });
  StellarAccountResponse get accountInfo;

  void setFee(String? feeType, {BigInt? customFee, DynamicVoid? onError});
  StellarMemoDetils? get memo;
  IntegerBalance? get fee;
  List<StellarTransactionOperation> get customOperations;
  TransactionTimeBound get timebound;

  Future<void> onSetupMemo(OnSetupStellarMemo onSetupMemo);
  void checkTransaction();
  Map<String, IntegerBalance> get fees;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_StellarTransactionImpl");
}
