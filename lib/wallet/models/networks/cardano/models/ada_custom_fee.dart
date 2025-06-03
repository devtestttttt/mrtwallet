import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain/ada/src/builder/builder/deposit.dart';

enum ADACustomFeeTypes {
  stakeRegistration("stake_registration");

  final String viewName;
  const ADACustomFeeTypes(this.viewName);
}

class ADATransactionDeposit {
  final ADACustomFeeTypes type;
  final IntegerBalance fee;
  ADADepositBuilder toDepositBuilder() {
    return ADADepositBuilder(deposit: fee.balance);
  }

  const ADATransactionDeposit({required this.type, required this.fee});
  factory ADATransactionDeposit.amount(
      {required ADACustomFeeTypes type,
      required BigInt fee,
      required WalletCardanoNetwork network}) {
    return ADATransactionDeposit(
        type: type,
        fee: IntegerBalance.token(fee, network.token, immutable: true));
  }
}
