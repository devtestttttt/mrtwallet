import 'package:on_chain_wallet/future/wallet/network/solana/transaction/controller/imp/memo_impl.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/progress.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/solana/solana.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/transaction/controller/imp/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/transaction/controller/imp/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/transaction/controller/imp/transaction_impl.dart';

class SolanaTransactionStateController extends SolanaTransactionImpl
    with SolanaTransactionFeeImpl, SolanaSignerImpl, SolanaMemoImpl {
  SolanaTransactionStateController({
    required super.walletProvider,
    required super.account,
    required super.validator,
    required super.apiProvider,
  });
  IntegerBalance? _remainTokenAmount;
  late final IntegerBalance _remainNativeAmount =
      IntegerBalance.zero(network.token);
  late IntegerBalance _remainAmount = IntegerBalance.zero(network.token);
  IntegerBalance get remindAmount => _remainAmount;
  String? _error;
  String? get error => _error;
  bool _trReady = false;
  bool get transactionIsReady => _trReady;

  Future<void> _init() async {
    await validator.validator.initForm(
        account: account,
        address: address,
        client: apiProvider,
        network: network);
    await account.updateAccountBalance(addresses: [address]);
    if (validator.validator.mode == SolanaTransactionType.spl) {
      final tokenTransferFiled = validator.validator as SolanaTransferForm;
      _remainTokenAmount = IntegerBalance.zero(tokenTransferFiled.token);
    }
    _trReady = _checkTransaction();
    progressKey.backToIdle();
  }

  bool _checkTransaction() {
    _error = validator.validator.validateError();
    _remainNativeAmount
        .updateBalance(account.address.address.currencyBalance - fee.balance);
    if (validator.validator.mode != SolanaTransactionType.spl) {
      final transactionValue = validator.validator.transferValue + fee.balance;
      _remainNativeAmount.updateBalance(
          account.address.address.currencyBalance - transactionValue);
      _remainAmount = _remainNativeAmount;
    } else {
      final tokenTransferFiled = validator.validator as SolanaTransferForm;
      final remindTokenAmounts = tokenTransferFiled.splToken!.balance.balance -
          (tokenTransferFiled.transferValue);
      _remainTokenAmount!.updateBalance(remindTokenAmounts);
      if (_remainNativeAmount.isNegative ||
          validator.validator.mode != SolanaTransactionType.spl) {
        _remainAmount = _remainNativeAmount;
      } else {
        _remainAmount = _remainTokenAmount!;
      }
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

  void sendTransaction() async {
    checkTransaction();
    if (!_trReady) {
      return;
    }
    await buildAndSignTransaction();
  }

  @override
  Future<void> onTapMemo(OnSetMemo onTapMemo) async {
    final m = memoStr;
    await super.onTapMemo(onTapMemo);
    if (m != memoStr) {
      calculateFees();
    }
  }

  void onChange() {
    checkTransaction();
    if (_trReady || (error == null && feeError != null)) {
      calculateFees();
    }
  }

  @override
  void ready() {
    _init();
    super.ready();
  }

  @override
  void init() {
    super.init();
    validator.addListener(onChange);
  }

  @override
  void close() {
    validator.removeListener(onChange);
    validator.validator.close();

    super.close();
  }
}
