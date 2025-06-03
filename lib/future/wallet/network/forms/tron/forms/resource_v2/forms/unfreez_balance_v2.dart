import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TronUnFreezBalanceV2Form extends TronTransactionOperationForm {
  TronUnFreezBalanceV2Form();
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;
  TronAccountInfo? _accountInfo;
  TronAccountInfo? get accountInfo => _accountInfo;

  late final TransactionFormField<IntegerBalance> amount = TransactionFormField(
    name: "unfreeze_balance",
    optional: false,
    onChangeForm: (v) {
      try {
        if (v!.isZero || v.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  late final TransactionFormField<ResourceCode> resource = TransactionFormField(
    name: "resource",
    optional: false,
    onChangeForm: (v) {
      try {
        if (v == ResourceCode.tronPower) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  List<TransactionFormField> get fields => [resource, amount];

  @override
  late final String name = "tron_unstack_v2";

  IntegerBalance? _stackedBalance;
  IntegerBalance get stackedBalance => _stackedBalance!;

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      if (field == resource) {
        if (resource.hasValue) {
          final findResource = MethodUtils.nullOnException(() => accountInfo!
              .frozenV2
              .firstWhere((element) => element.type == resource.value));
          stackedBalance.updateBalance(findResource?.amount ?? BigInt.zero);
        } else {
          stackedBalance.updateBalance(BigInt.zero);
        }
        amount.setValue(null);
      }
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
      TransactionContractType.unfreezeBalanceV2Contract;

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

    return UnfreezeBalanceV2Contract(
        ownerAddress: address.networkAddress,
        unfreezeBalance: amount.value!.balance,
        resource: resource.value);
  }

  @override
  TronAddress? get smartContractAddress => null;
  @override
  Future<void> initForm(
      {required TronChain account,
      required ITronAddress address,
      required WalletTronNetwork network,
      required TronClient client}) async {
    await super.initForm(
        account: account, address: address, network: network, client: client);
    _accountInfo = address.accountInfo;
    _stackedBalance = IntegerBalance.zero(account.network.token);
  }

  @override
  void close() {
    _accountInfo = null;
    amount.clear();
    resource.clear();
    super.close();
  }
}
