import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/permission/models/account.dart';

abstract class Web3ChainAccount<NETWORKADDRESS>
    with CborSerializable, Equatable {
  int get id;
  final AddressDerivationIndex keyIndex;
  final NETWORKADDRESS address;
  bool _defaultAddress;
  bool get defaultAddress => _defaultAddress;
  String get addressStr;
  Web3ChainAccount({
    required this.keyIndex,
    required this.address,
    required bool defaultAddress,
  }) : _defaultAddress = defaultAddress;

  void changeDefault(bool defaultAddress) {
    _defaultAddress = defaultAddress;
  }

  Web3ChainAccount<NETWORKADDRESS> clone();

  @override
  List get variabels => [keyIndex, addressStr, id, defaultAddress];
}

abstract class Web3ChainIdnetifier with CborSerializable, Equatable {
  final int id;
  final String wsIdentifier;
  final String caip2;
  final String caipChainId;
  final String wsChainId;

  bool isChain(String chainId) {
    if (chainId.indexOf(":") > 0) {
      return wsIdentifier == chainId || caip2 == chainId;
    }
    return caipChainId == chainId || wsChainId == chainId;
  }

  Web3ChainIdnetifier(
      {required this.id, required this.wsIdentifier, required this.caip2})
      : caipChainId = caip2.split(":").last,
        wsChainId = wsIdentifier.split(":").last;
  @override
  List get variabels => [id];
}

class Web3ChainDefaultIdnetifier extends Web3ChainIdnetifier {
  Web3ChainDefaultIdnetifier(
      {required super.id, required super.wsIdentifier, required super.caip2});
  factory Web3ChainDefaultIdnetifier.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.web3ChainIdentifier);
    return Web3ChainDefaultIdnetifier(
        id: values.elementAs(0),
        wsIdentifier: values.elementAs(1),
        caip2: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([id, wsIdentifier, caip2]),
        CborTagsConst.web3ChainIdentifier);
  }
}

abstract class Web3ChainAuthenticated<CHAINACCOUNT extends Web3ChainAccount>
    with CborSerializable {
  final NetworkType networkType;
  final List<CHAINACCOUNT> accounts;
  abstract final List<Web3ChainIdnetifier> networks;
  abstract final Web3ChainIdnetifier currentNetwork;

  Web3ChainAuthenticated({
    required this.networkType,
    required List<CHAINACCOUNT> accounts,
  }) : accounts = accounts.immutable;
  factory Web3ChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(object: object, cborBytes: bytes, hex: hex);
    final type = NetworkType.fromTag(tag.tags);
    return switch (type) {
      NetworkType.solana =>
        Web3SolanaChainAuthenticated.deserialize(object: tag),
      NetworkType.ethereum =>
        Web3EthereumChainAuthenticated.deserialize(object: tag),
      NetworkType.ton => Web3TonChainAuthenticated.deserialize(object: tag),
      NetworkType.tron => Web3TronChainAuthenticated.deserialize(object: tag),
      NetworkType.stellar =>
        Web3StellarChainAuthenticated.deserialize(object: tag),
      NetworkType.substrate =>
        Web3SubstrateChainAuthenticated.deserialize(object: tag),
      NetworkType.aptos => Web3AptosChainAuthenticated.deserialize(object: tag),
      NetworkType.sui => Web3SuiChainAuthenticated.deserialize(object: tag),
      NetworkType.cosmos =>
        Web3CosmosChainAuthenticated.deserialize(object: tag),
      NetworkType.bitcoinAndForked =>
        Web3BitcoinChainAuthenticated.deserialize(object: tag),
      _ => throw WalletExceptionConst.invalidData(
          messsage: "unsuported web3 network")
    } as Web3ChainAuthenticated<CHAINACCOUNT>;
  }

  T cast<T extends Web3ChainAuthenticated>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(networks.map((e) => e.toCbor()).toList()),
          currentNetwork.toCbor()
        ]),
        networkType.tag);
  }
}
