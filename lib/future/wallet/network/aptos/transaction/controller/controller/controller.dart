import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/aptos/transaction/controller/imp/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/aptos/transaction/controller/imp/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/aptos/transaction/controller/imp/transaction_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain/aptos/src/transaction/constants/const.dart';
import 'package:on_chain/aptos/src/transaction/types/types.dart';

class AptosTransactionStateController extends AptosTransactionImpl
    with AptosTransactionFeeImpl, AptosSignerImpl {
  AptosTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider,
      required super.validator});
  IntegerBalance? _remainTokenAmount;
  late final IntegerBalance _remainNativeAmount =
      IntegerBalance.zero(network.token);
  late IntegerBalance remindAmount = IntegerBalance.zero(network.token);
  String? _error;
  String? get error => _error;
  bool _trReady = false;
  bool get transactionIsReady => _trReady;

  bool _checkTransaction() {
    _error = validator.validator.validateError();
    _remainNativeAmount.updateBalance(
        account.address.address.currencyBalance - fee.requiredFee);
    switch (validator.validator.transactionType) {
      case AptosTransactionType.transfer:
        final transactionValue =
            validator.validator.transferValue + fee.requiredFee;
        _remainNativeAmount.updateBalance(
            account.address.address.currencyBalance - transactionValue);
        remindAmount = _remainNativeAmount;
        break;
      case AptosTransactionType.tokenTransfer:
        final tokenTransferFiled =
            validator.validator.cast<AptosTransferForm>();
        final remindTokenAmounts = tokenTransferFiled.token!.balance.balance -
            (tokenTransferFiled.transferValue);
        _remainTokenAmount!.updateBalance(remindTokenAmounts);
        if (_remainNativeAmount.isNegative) {
          remindAmount = _remainNativeAmount;
        } else {
          remindAmount = _remainTokenAmount!;
        }
        break;
    }
    return _error == null &&
        !_remainNativeAmount.isNegative &&
        !(_remainTokenAmount?.isNegative ?? false);
  }

  @override
  void checkTransaction() {
    _trReady = _checkTransaction();
    notify();
  }

  void sendTransaction(FuncFutureNullableBoold onSubmit) async {
    checkTransaction();
    if (!_trReady) {
      return;
    }
    if (!fee.isSimulate) {
      final submit = await onSubmit();
      if (submit != true) return;
    }
    await buildAndSignTransaction(
        maxGasAmount: fee.isSimulate
            ? fee.maxGasAmount
            : AptosConstants.defaultMinGasAmount,
        gasUnitPrice: fee.gasUnitPrice);
  }

  Future<void> _init() async {
    await form.initForm(
        account: account,
        address: address,
        client: apiProvider,
        network: network);
    await account.updateAccountBalance(addresses: [address]);

    final r = await MethodUtils.call(() => initFee());
    if (r.hasError) {
      progressKey.errorText(r.error!.tr, backToIdle: false);
      return;
    }
    if (validator.validator.transactionType.isTokenTransfer) {
      final tokenTransferFiled = validator.validator.cast<AptosTransferForm>();
      _remainTokenAmount = IntegerBalance.zero(tokenTransferFiled.token!.token);
    }
    _trReady = _checkTransaction();
    progressKey.backToIdle();
  }

  void onChange() {
    checkTransaction();
    if (_trReady || (error == null && feeError != null)) {
      calculateFees();
    }
  }

  @override
  void ready() {
    super.ready();
    _init();
  }

  @override
  void init() {
    super.init();
    validator.addListener(onChange);
  }

  @override
  AptosTransactionPayload createTransactionPayload() {
    return validator.validator.createTransaction();
  }

  @override
  void close() {
    validator.removeListener(onChange);
    validator.validator.close();
    super.close();
  }
}
