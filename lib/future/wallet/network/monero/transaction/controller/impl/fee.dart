import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/crypto/requets/messages/messages.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/transaction/controller/impl/transaction.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

mixin MoneroTransactionFeeImpl on MoneroTransactionImpl {
  DaemonGetEstimateFeeResponse? _fee;
  late final api = MoneroApi(apiProvider.provider);
  String? _feeError;
  String? get feeError => _feeError;
  MoneroFeePrority? _priority = MoneroFeePrority.defaultPriority;
  MoneroFeePrority? get priority => _priority;
  late Map<String, IntegerBalance> _fees;
  Map<String, IntegerBalance> get fees => _fees;

  @override
  DaemonGetEstimateFeeResponse get baseFee => _fee!;

  Map<String, IntegerBalance> _buildFeeRate(BigInt txWeight) {
    return {
      for (final i in MoneroFeePrority.values)
        i.name: IntegerBalance.token(
            i.calcuateFee(weight: txWeight, baseFee: baseFee),
            network.coinParam.token,
            immutable: true,
            allowNegative: false)
    };
  }

  Future<void> initialFee() async {
    _fee ??= await apiProvider.getFeeEstimate();
    fee.updateBalance(_fee?.fees[0]);
  }

  @override
  Future<void> calculateFee() async {
    final destinations = receivers.map((e) => e.toMoneroDestination()).toList();
    final fakePayments = selectedUtxos.values
        .expand((e) => e)
        .map((e) => e.toUnlockedFakePayment())
        .toList();

    final weight = await walletProvider.wallet.nonEncryptedRequest(
      NoneEncryptedRequestFakeMoneroTx(
          destinations: destinations,
          fee: fee.balance,
          change: MoneroTxDestination(
              amount: remindAmount.balance, address: change.networkAddress),
          fakePayments: fakePayments),
    );
    _fees = _buildFeeRate(weight);
    if (_priority != null) {
      fee.updateBalance(_fees[priority?.name]?.balance);
    }
    onCalculateAmount();
    notify();
  }

  void setFee(String? feeType, {BigInt? customFee}) {
    if (feeType == null && customFee == null) return;
    _priority = feeType == null
        ? null
        : MoneroFeePrority.values
            .firstWhere((element) => element.name == feeType);
    if (_priority == null) {
      fee.updateBalance(customFee!);
    } else {
      fee.updateBalance(_fees[priority?.name]?.balance);
    }
    onCalculateAmount();
    notify();
  }
}
