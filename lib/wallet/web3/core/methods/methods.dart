import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/methods/methods.dart';

abstract class Web3RequestMethods {
  final int id;
  final String name;
  final List<String> methodsName;
  final bool reloadAuthenticated;
  List<String> get walletConnectMethodNames => [name, ...methodsName];
  bool get isGlobalMethod => false;

  const Web3RequestMethods(
      {required this.id,
      required this.name,
      required this.methodsName,
      required this.reloadAuthenticated});
  T cast<T extends Web3RequestMethods>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as T;
  }

  @override
  String toString() {
    return name;
  }
}

enum Web3NetworkEvent {
  accountsChanged,
  chainChanged,
  message,
  connect,
  disconnect,
  change;

  bool get needEmit =>
      this == accountsChanged ||
      this == chainChanged ||
      this == connect ||
      this == change;

  static Web3NetworkEvent name(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static List<Web3NetworkEvent> getEvents(NetworkType network) {
    switch (network) {
      case NetworkType.ethereum:
        return values;
      case NetworkType.tron:
      case NetworkType.aptos:
        return [accountsChanged, chainChanged, change];
      default:
        return [change];
    }
  }

  static Web3NetworkEvent? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

abstract class Web3NetworkRequestMethods extends Web3RequestMethods {
  const Web3NetworkRequestMethods(
      {required super.id,
      required super.name,
      super.methodsName = const [],
      super.reloadAuthenticated = false});
  abstract final NetworkType network;
  List<int> get tag => [...network.tag, id];
  static Web3NetworkRequestMethods fromTag(List<int>? tag) {
    final network = NetworkType.fromTag(tag);
    return switch (network) {
      NetworkType.ethereum => Web3EthereumRequestMethods.fromId(tag!.last),
      NetworkType.tron => Web3TronRequestMethods.fromId(tag!.last),
      NetworkType.solana => Web3SolanaRequestMethods.fromId(tag!.last),
      NetworkType.ton => Web3TonRequestMethods.fromId(tag!.last),
      NetworkType.substrate => Web3SubstrateRequestMethods.fromId(tag!.last),
      NetworkType.stellar => Web3StellarRequestMethods.fromId(tag!.last),
      NetworkType.aptos => Web3AptosRequestMethods.fromId(tag!.last),
      NetworkType.sui => Web3SuiRequestMethods.fromId(tag!.last),
      NetworkType.cosmos => Web3CosmosRequestMethods.fromId(tag!.last),
      NetworkType.bitcoinAndForked =>
        Web3BitcoinRequestMethods.fromId(tag!.last),
      _ => throw Web3RequestExceptionConst.invalidNetwork
    };
  }

  static List<Web3NetworkRequestMethods> getMethods(NetworkType network) {
    return switch (network) {
      NetworkType.ethereum => Web3EthereumRequestMethods.values,
      NetworkType.tron => Web3TronRequestMethods.values,
      NetworkType.solana => Web3SolanaRequestMethods.values,
      NetworkType.ton => Web3TonRequestMethods.values,
      NetworkType.stellar => Web3StellarRequestMethods.values,
      NetworkType.aptos => Web3AptosRequestMethods.values,
      NetworkType.sui => Web3SuiRequestMethods.values,
      NetworkType.cosmos => Web3CosmosRequestMethods.values,
      NetworkType.bitcoinAndForked => Web3BitcoinRequestMethods.values,
      NetworkType.substrate => Web3SubstrateRequestMethods.values,
      _ => throw Web3RequestExceptionConst.invalidNetwork
    };
  }
}
