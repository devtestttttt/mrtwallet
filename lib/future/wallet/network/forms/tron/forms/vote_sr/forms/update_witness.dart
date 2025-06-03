import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/vote_sr/forms/create_witness.dart';
import 'package:on_chain/on_chain.dart';

class TronUpdateWitnessForm extends TronCreateWitnessForm {
  @override
  String get name => "update_witness";

  @override
  TransactionContractType get type =>
      TransactionContractType.witnessUpdateContract;

  @override
  TronBaseContract toContract() {
    final validate = validateError();
    if (validate != null) {
      throw WalletException(validate);
    }

    return WitnessUpdateContract(
        ownerAddress: address.networkAddress,
        updateUrl: StringUtils.tryToBytes(url.value));
  }
}
