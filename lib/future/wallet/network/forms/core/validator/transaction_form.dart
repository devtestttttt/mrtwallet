import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'field.dart';

typedef OnChageFormField<T> = void Function(TransactionFormField<T>, T?);

abstract class ValidatorForm {
  String get name;
  OnChangeForm? onChanged;
  void close() {}

  void notify() {
    assert(onChanged != null, "form callback not set");
    onChanged?.call();
  }
}

abstract class TransactionForm<
    CLIENT extends NetworkClient?,
    ADDRESS extends ChainAccount,
    NETWORK extends WalletNetwork,
    ACCOUNT extends Chain> extends ValidatorForm {
  CLIENT? _client;
  CLIENT get client => _client as CLIENT;
  ADDRESS? _address;
  ADDRESS get address => _address!;
  NETWORK? _network;
  NETWORK get network => _network!;
  ACCOUNT? _account;
  ACCOUNT get account => _account!;
  Future<void> initForm(
      {required ACCOUNT account,
      required ADDRESS address,
      required NETWORK network,
      required CLIENT client}) async {
    initFormSync(
        account: account, address: address, network: network, client: client);
  }

  void initFormSync(
      {required ACCOUNT account,
      required ADDRESS address,
      required NETWORK network,
      required CLIENT client}) {
    _address = address;
    _network = network;
    _client = client;
    _account = account;
  }

  bool get enableSwitchAccount => true;
  String? validateError();
  T cast<T extends TransactionForm>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }

  @override
  void close() {
    _address = null;
    _network = null;
    _client = null;
    _account = null;
  }
}

abstract class Web3Form<
    NETWORKADDRESS,
    CLIENT extends NetworkClient?,
    ADDRESS extends ChainAccount?,
    NETWORK extends WalletNetwork,
    CHAIN extends Chain,
    ACCOUNT extends ChainAccount,
    CHAINACCOUNT extends Web3ChainAccount,
    WEB3CHAIN extends Web3Chain<NETWORKADDRESS, CHAIN, ACCOUNT, CHAINACCOUNT,
        NETWORK>,
    PARAMS extends Web3RequestParams<dynamic, NETWORKADDRESS, CHAIN, ACCOUNT,
        CHAINACCOUNT, WEB3CHAIN>> extends ValidatorForm {
  ObjectVoid? onCompleteForm;

  CLIENT? _client;
  CLIENT get client => _client as CLIENT;
  ADDRESS? _address;
  ADDRESS get address => _address as ADDRESS;
  NETWORK? _network;
  NETWORK get network => _network!;
  CHAIN? _account;
  CHAIN get account => _account!;
  Future<void> initForm(
      {required CHAIN account,
      required ADDRESS address,
      required NETWORK network,
      required CLIENT client}) async {
    initFormSync(
        account: account, address: address, network: network, client: client);
  }

  void initFormSync(
      {required CHAIN account,
      required ADDRESS address,
      required NETWORK network,
      required CLIENT client}) {
    _address = address;
    _network = network;
    _client = client;
    _account = account;
  }

  @override
  void close() {
    _address = null;
    _network = null;
    _client = null;
    _account = null;
  }
}
