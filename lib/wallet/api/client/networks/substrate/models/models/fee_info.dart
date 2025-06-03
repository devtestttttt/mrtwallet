import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateFeeInfos {
  final IntegerBalance baseFee;
  final IntegerBalance lenFee;
  final IntegerBalance adjustedWeightFee;
  final IntegerBalance tip;
  final IntegerBalance total;
  final bool calculated;
  const SubstrateFeeInfos(
      {required this.baseFee,
      required this.lenFee,
      required this.adjustedWeightFee,
      required this.tip,
      required this.total,
      required this.calculated});
  factory SubstrateFeeInfos.zero(WalletSubstrateNetwork network) {
    return SubstrateFeeInfos(
        baseFee: IntegerBalance.zero(network.token),
        lenFee: IntegerBalance.zero(network.token),
        adjustedWeightFee: IntegerBalance.zero(network.token),
        tip: IntegerBalance.zero(network.token),
        total: IntegerBalance.zero(network.token),
        calculated: false);
  }
  factory SubstrateFeeInfos.fromFeeDetails(
      {required QueryFeeInfoFrame fee,
      required WalletSubstrateNetwork network}) {
    if (fee.inclusionFee == null) return SubstrateFeeInfos.zero(network);
    final inclusionFee = fee.inclusionFee!;
    final BigRational totalFee = BigRational(inclusionFee.adjustedWeightFee +
        inclusionFee.baseFee +
        inclusionFee.lenFee +
        fee.tip);

    return SubstrateFeeInfos(
        baseFee: IntegerBalance.token(inclusionFee.baseFee, network.token),
        lenFee: IntegerBalance.token(inclusionFee.lenFee, network.token),
        adjustedWeightFee:
            IntegerBalance.token(inclusionFee.adjustedWeightFee, network.token),
        tip: IntegerBalance.token(fee.tip, network.token),
        total: IntegerBalance.token(
            (totalFee * APPSubstrateConst.feeRate).toBigInt(), network.token),
        calculated: true);
  }
}
