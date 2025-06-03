import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TronUpdateAccountForm extends TronTransactionOperationForm {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  late final TransactionFormField<String> accountName = TransactionFormField(
    name: "account_name",
    optional: false,
    onChangeForm: (v) {
      try {
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  List<TransactionFormField> get fields => [accountName];

  @override
  late final String name = "update_account";

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
      _checkEstimate();
    }
  }

  void _checkEstimate() {
    if (validateError() == null) {
      onStimateChanged?.call();
    }
  }

  @override
  String? validateError() {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }

  @override
  late final TransactionContractType type =
      TransactionContractType.accountUpdateContract;

  @override
  TronAddress? get destinationAccount {
    return null;
  }

  @override
  TronBaseContract toContract() {
    final validate = validateError();
    if (validate != null) {
      throw WalletException(validate);
    }

    return AccountUpdateContract(
        ownerAddress: address.networkAddress,
        accountName: StringUtils.toBytes(accountName.value!));
  }

  @override
  TronAddress? get smartContractAddress => null;

  @override
  void close() {
    super.close();
    accountName.clear();
  }
}
