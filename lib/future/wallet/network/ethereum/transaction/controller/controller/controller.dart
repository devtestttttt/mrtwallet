import 'dart:async';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class EthereumTransactionStateController extends EthTransactionImpl
    with ETHTransactionFeeImpl, ETHSignerImpl, ETHMemoImpl {
  EthereumTransactionStateController({
    required super.walletProvider,
    required super.account,
    required this.validator,
    required super.apiProvider,
  });

  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_EthTransactionImpl");
  final LiveTransactionForm<EthereumTransactionForm> validator;
  EthereumTransactionForm get form => validator.validator;
  IntegerBalance? _remainTokenAmount;
  late final IntegerBalance _remainNativeAmount =
      IntegerBalance.zero(network.token);
  late IntegerBalance _remainAmount = IntegerBalance.zero(network.token);
  IntegerBalance get remindAmount => _remainAmount;
  bool _trReady = false;
  bool get trIsReady => _trReady;
  String? _error;
  String? get error => _error ?? estimateError;

  bool _checkTransaction() {
    _error = validator.validator.validateError();
    final transactionValue = validator.validator.callValue +
        (currentEIP1559Fee?.fee.balance ?? BigInt.zero);
    _remainNativeAmount.updateBalance(
        account.address.address.currencyBalance - transactionValue);
    if (validator.validator.mode != ETHTransactionMode.erc20Transfer) {
      _remainAmount = _remainNativeAmount;
    } else {
      final tokenTransferFiled = validator.validator as EthereumTransferForm;
      final remindTokenAmounts =
          tokenTransferFiled.erc20Token!.balance.balance -
              tokenTransferFiled.tokenValue;
      _remainTokenAmount!.updateBalance(remindTokenAmounts);
      if (_remainNativeAmount.isNegative ||
          validator.validator.mode != ETHTransactionMode.erc20Transfer) {
        _remainAmount = _remainNativeAmount;
      } else {
        _remainAmount = _remainTokenAmount!;
      }
    }
    final ready = _error == null &&
        !_remainNativeAmount.isNegative &&
        !(_remainTokenAmount?.isNegative ?? false) &&
        gasInited &&
        (feeSpeed == EIP1559FeeSpeed.customFee || !updatingGas);

    return ready;
  }

  @override
  Future<void> onTapMemo(OnAddETHMemo onAddMemo) async {
    final String? currentMemo = memo;
    await super.onTapMemo(onAddMemo);
    if (memo != currentMemo) {
      estimateGasLimit();
    }
  }

  @override
  Future<void> estimateGasLimit({Map<String, dynamic>? estimateDetails}) async {
    final estimateDetails = validator.validator.toEstimate(memo: memo);
    await super.estimateGasLimit(estimateDetails: estimateDetails);
    notify();
  }

  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final EthWalletTransaction transaction =
          validator.validator.toWalletTransaction(txId: txId);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save ethereum transaction failed $txId");
  }

  void sedTransaction() async {
    try {
      final fee = currentEIP1559Fee?.clone(network);
      if (fee == null || !trIsReady) return;
      final transaction =
          validator.validator.toTransaction(fee: fee, memo: memo);
      progressKey.progressText("create_send_transaction"
          .tr
          .replaceOne(network.coinParam.token.name));
      final result = await MethodUtils.call(() async {
        final txId = await signAndBroadCastTransaction(transaction);
        await _saveTransaction(txId: txId);
        return txId;
      });
      if (result.hasError) {
        progressKey.errorText(result.error!.tr,
            showBackButton: true, backToIdle: false);
      } else {
        stopGasEstimate();
        progressKey.success(
            progressWidget: SuccessTransactionTextView(
              network: network,
              txIds: [result.result],
            ),
            backToIdle: false);
      }
    } finally {
      notify();
    }
  }

  @override
  void onFeeChanged() {
    _trReady = _checkTransaction();
    notify();
  }

  void _onFormListener() => onFeeChanged();

  void _onEstimateNeeded() {
    estimateGasLimit();
  }

  void _init() {
    if (validator.validator.mode == ETHTransactionMode.erc20Transfer) {
      final tokenTransferFiled = validator.validator as EthereumTransferForm;
      _remainTokenAmount = IntegerBalance.zero(tokenTransferFiled.token);
    }
    _trReady = _checkTransaction();
  }

  @override
  void init() {
    super.init();

    validator.addListener(_onFormListener);
    validator.validator.onStimateChanged = _onEstimateNeeded;
  }

  @override
  void ready() {
    super.ready();
    form.initFormSync(
        account: account,
        address: address,
        network: network,
        client: apiProvider);
    startGasListening();
    _init();
    estimateGasLimit();
  }

  void _close() {
    validator.removeListener(_onFormListener);
    validator.dispose();
    form.onStimateChanged = null;
    form.close();
  }

  @override
  void close() {
    super.close();
    _close();
  }
}
