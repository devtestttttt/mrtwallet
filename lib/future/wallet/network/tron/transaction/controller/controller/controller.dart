import 'dart:async';

import 'package:on_chain_wallet/future/wallet/network/tron/transaction/controller/impl/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/transaction/controller/impl/memo_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/transaction/controller/impl/network_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/transaction/controller/impl/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/transaction/controller/impl/transaction.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/tron/src/models/contract/base_contract/transaction_type.dart';

class TronTransactionStateController extends TronTransactionImpl
    with
        TronMemoImpl,
        TronNetworkConditionImpl,
        TronTransactionFeeIMpl,
        TronSignerImpl {
  TronTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider,
      required this.validator});
  @override
  final LiveTransactionForm<TronTransactionForm> validator;
  String? _error;

  String? get error => _error;
  bool _trIsReady = false;
  bool get trIsReady => _trIsReady;
  bool get showTxInfo => validator.validator.showTxInfo;

  IntegerBalance? _remainTokenAmount;
  late final IntegerBalance _remainNativeAmount =
      IntegerBalance.zero(network.token);
  late IntegerBalance _remainAmount = IntegerBalance.zero(network.token);
  IntegerBalance get remindAmount => _remainAmount;

  bool _checkTransaction() {
    _error = validator.validator.validateError();
    final transactionValue = validator.validator.callValue;
    _remainNativeAmount.updateBalance(account.address.address.currencyBalance -
        (transactionValue + (totalBurn?.balance ?? BigInt.zero)));
    if (validator.validator.type !=
        TransactionContractType.triggerSmartContract) {
      _remainAmount = _remainNativeAmount;
    } else {
      final tokenTransferFiled = validator.validator as TronTransferForm;
      final remindTokenAmounts =
          tokenTransferFiled.transferToken!.balance.balance -
              tokenTransferFiled.tokenValue;
      _remainTokenAmount!.updateBalance(remindTokenAmounts);
      if (_remainNativeAmount.isNegative) {
        _remainAmount = _remainNativeAmount;
      } else {
        _remainAmount = _remainTokenAmount!;
      }
    }
    return _error == null &&
        !_remainNativeAmount.isNegative &&
        !(_remainTokenAmount?.isNegative ?? false) &&
        consumedFee != null;
  }

  @override
  Future<void> onTapMemo(OnAddTronMemo onAddMemo) async {
    final currentMemo = memo;
    await super.onTapMemo(onAddMemo);
    _checkTransaction();
    if (currentMemo != memo && _error == null) {
      calculateFee();
    }
  }

  void _init() {
    if (validator.validator.type ==
        TransactionContractType.triggerSmartContract) {
      final tokenTransferFiled = validator.validator as TronTransferForm;
      _remainTokenAmount = IntegerBalance.zero(tokenTransferFiled.token);
    }
    _trIsReady = _checkTransaction();
  }

  void sedTransaction() async {
    await signAndSendTransaction(validator.validator.toContract());
  }

  void _onFormListener() {
    _trIsReady = _checkTransaction();
    notify();
  }

  void _onEstimateNeeded() {
    calculateFee();
  }

  @override
  void ready() {
    super.ready();
    initNetworkCondition();
  }

  @override
  Future<bool> initNetworkCondition() async {
    final isOK = await super.initNetworkCondition();
    if (!isOK) return isOK;
    _init();
    _error = validator.validator.validateError();
    if (_error == null) {
      calculateFee();
    }
    notify();
    return isOK;
  }

  @override
  TransactionContractType get type => validator.validator.type;

  @override
  TronTransactionForm get field => validator.validator;

  @override
  void onFeeChanged() {
    _trIsReady = _checkTransaction();
    notify();
  }

  @override
  void init() {
    super.init();
    validator.addListener(_onFormListener);
    validator.validator.onStimateChanged = _onEstimateNeeded;
  }

  @override
  void close() {
    validator.removeListener(_onFormListener);
    validator.validator.close();
    super.close();
  }
}
