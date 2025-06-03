import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TronDelegatedResourceV2Form extends TronTransactionOperationForm {
  @override
  BigInt get callValue => BigInt.zero;

  @override
  final BigInt tokenValue = BigInt.zero;

  MaxDelegatedResourceAmount? _bandWidthResource;
  MaxDelegatedResourceAmount? _energy;
  MaxDelegatedResourceAmount get bandWidthResource => _bandWidthResource!;
  MaxDelegatedResourceAmount get energy => _energy!;

  MaxDelegatedResourceAmount get maxResourceBalance =>
      resource.value == ResourceCode.bandWidth ? bandWidthResource : energy;

  List<TransactionFormField> get fields => [amount, destination, resource];

  final TransactionFormField<IntegerBalance> amount = TransactionFormField(
    name: "delegatable_amount",
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
  final TransactionFormField<ReceiptAddress<TronAddress>> destination =
      TransactionFormField(
          name: "receiver_address",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
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
  final TransactionFormField<bool> lock = TransactionFormField(
    name: "lock",
    optional: true,
    onChangeForm: (v) {
      return v;
    },
  );
  final TransactionFormField<BigRational> lockPeriod = TransactionFormField(
    name: "lock_period",
    onChangeForm: (v) {
      try {
        if (v!.isNegative || v.isZero || v.isDecimal) return null;
        if (v > TronUtils.maxDelegatedLockPeriod) {
          return null;
        }
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  @override
  late final String name = "delegated_resource";

  void setLockPerid(bool? value) {
    if (lock.setValue(value ?? false)) {
      lockPeriod.setValue(TronUtils.defaultDelegateLockPeriod);
      onChanged?.call();
      _checkEstimate();
    }
  }

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
      TransactionContractType.delegateResourceContract;

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
    BigInt? lockTime;
    if (lock.value == true) {
      if (lockPeriod.value != null &&
          lockPeriod.value != TronUtils.defaultDelegateLockPeriod) {
        lockTime = lockPeriod.value?.toBigInt();
      }
    }
    return DelegateResourceContract(
        ownerAddress: address.networkAddress,
        receiverAddress: destination.value!.networkAddress,
        balance: amount.value!.balance,
        resource: resource.value,
        lock: lock.value == true ? true : null,
        lockPeriod: lockTime);
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
    final delegated = await client.getMaxDelegatedEnergyAndBandwidth(address);
    _energy = delegated.$1;
    _bandWidthResource = delegated.$2;
  }

  @override
  void close() {
    _bandWidthResource = null;
    _energy = null;
    amount.clear();
    destination.clear();
    lock.clear();
    lockPeriod.clear();
    resource.clear();
  }
}
