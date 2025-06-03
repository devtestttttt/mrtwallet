import 'package:on_chain_wallet/future/wallet/network/ton/transaction/controller/impl/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/transaction/controller/impl/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/transaction/controller/impl/transaction_impl.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class TonTransactionStateController extends TonTransactionImpl
    with TonSignerImpl, TonFeeImpl {
  TonTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider,
      required super.validator});

  bool get hasMultipleMessage => address.context.version.version > 1;

  late final IntegerBalance remindAmount = IntegerBalance.zero(network.token);

  String? _error;
  String? get error => _error;
  bool _trReady = false;
  bool get transactionIsReady => _trReady;

  bool _isReady() {
    _error = validator.validator.validateError();
    if (remindAmount.isNegative || _error != null) return false;
    if (hasFee) return true;
    return feeError != null;
  }

  @override
  void onChange() {
    final totalAmounts = validator.validator.callValue;
    final remind = address.address.currencyBalance - (totalAmounts + fee);
    remindAmount.updateBalance(remind);
    _trReady = _isReady();
    notify();
  }

  void onChangeForm() {
    onChange();
    if (_error == null) {
      estimateFee();
    }
  }

  void _init() {
    validator.addListener(onChangeForm);
    validator.validator.initFormSync(
        account: account,
        address: address,
        network: network,
        client: apiProvider);
  }

  void _close() {
    validator.removeListener(onChangeForm);
    validator.validator.close();
  }

  void sendTransaction() {
    if (!transactionIsReady) return;
    signAndSendTransaction();
  }

  @override
  void ready() {
    super.ready();
    _init();
  }

  @override
  void close() {
    super.close();
    _close();
  }
}
