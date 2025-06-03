import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';

class EthereumFee {
  EthereumFee._({
    required this.gasLimit,
    required this.fee,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
  });
  EthereumFee copyWith({
    int? gasLimit,
    IntegerBalance? fee,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) {
    return EthereumFee._(
      gasLimit: gasLimit ?? this.gasLimit,
      fee: fee ?? this.fee,
      gasPrice: gasPrice ?? this.gasPrice,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
    );
  }

  EthereumFee clone(WalletEthereumNetwork network) {
    return EthereumFee._(
        gasLimit: gasLimit,
        fee: IntegerBalance.token(fee.balance, network.token),
        gasPrice: gasPrice,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxFeePerGas);
  }

  factory EthereumFee.legacy(
      WalletEthereumNetwork network, int gasLimit, BigInt gasPrice) {
    final fee = gasPrice * BigInt.from(gasLimit);
    return EthereumFee._(
        gasLimit: gasLimit,
        gasPrice: gasPrice,
        fee: IntegerBalance.token(fee, network.token));
  }
  factory EthereumFee.eip1559(WalletEthereumNetwork network, int gasLimit,
      BigInt maxPriorityFeePerGas, BigInt baseFee,
      {BigInt? maxFeePerGas}) {
    final mFeePerGas = maxFeePerGas ?? maxPriorityFeePerGas + baseFee;
    final fee = mFeePerGas * BigInt.from(gasLimit);
    return EthereumFee._(
        gasLimit: gasLimit,
        maxFeePerGas: mFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        fee: IntegerBalance.token(fee, network.token));
  }

  final int gasLimit;
  final BigInt? gasPrice;
  final BigInt? maxFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  final IntegerBalance fee;

  bool get isEIP1559 => maxFeePerGas != null;

  @override
  String toString() {
    return '''EthereumFee{
    gasLimit: $gasLimit,
    gasPrice: $gasPrice,
    maxFeePerGas: $maxFeePerGas,
    maxPriorityFeePerGas: $maxPriorityFeePerGas.
    fee: $fee
    }''';
  }
}
