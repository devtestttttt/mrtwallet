import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

class Web3BitcoinChainAccount extends Web3ChainAccount<BitcoinBaseAddress> {
  @override
  final int id;
  final BitcoinAddressType type;
  final String addressProgram;
  final BasedUtxoNetwork baseNetwork;
  final List<int> publicKey;
  final String? witnessScript;
  final String? redeemScript;

  Web3BitcoinChainAccount._(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.addressProgram,
      required this.type,
      required this.baseNetwork,
      required this.witnessScript,
      required this.redeemScript,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;

  @override
  Web3BitcoinChainAccount clone(
      {AddressDerivationIndex? keyIndex,
      BitcoinBaseAddress? address,
      bool? defaultAddress,
      int? id,
      int? signingScheme,
      String? witnessScript,
      String? redeemScript,
      BasedUtxoNetwork? baseNetwork,
      String? addressProgram,
      List<int>? publicKey,
      BitcoinAddressType? type}) {
    return Web3BitcoinChainAccount._(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        baseNetwork: baseNetwork ?? this.baseNetwork,
        publicKey: publicKey ?? this.publicKey,
        witnessScript: witnessScript ?? this.witnessScript,
        redeemScript: redeemScript ?? this.redeemScript,
        addressProgram: addressProgram ?? this.addressProgram,
        type: type ?? this.type);
  }

  factory Web3BitcoinChainAccount.fromChainAccount(
      {required IBitcoinAddress address,
      required bool isDefault,
      required WalletBitcoinNetwork network}) {
    return Web3BitcoinChainAccount._(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: network.value,
        defaultAddress: isDefault,
        type: address.networkAddress.type,
        addressProgram: address.networkAddress.addressProgram,
        baseNetwork: network.coinParam.transacationNetwork,
        publicKey: address.multiSigAccount ? [] : address.publicKey,
        witnessScript: address.witnessScript()?.toHex(),
        redeemScript: address.redeemScript()?.toHex());
  }

  factory Web3BitcoinChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3BitcoinAccount);
    final type = BitcoinAddressType.fromValue(values.elementAs(4));
    final String program = values.elementAt(1);
    return Web3BitcoinChainAccount._(
        keyIndex: AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
        addressProgram: program,
        type: type,
        address:
            BitcoinBaseAddress.fromProgram(addressProgram: program, type: type),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        baseNetwork: BasedUtxoNetwork.fromName(values.elementAs(5)),
        publicKey: values.elementAs(6),
        witnessScript: values.elementAs(7),
        redeemScript: values.elementAs(8));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.addressProgram,
          id,
          defaultAddress,
          type.value,
          baseNetwork.value,
          CborBytesValue(publicKey),
          witnessScript,
          redeemScript
        ]),
        CborTagsConst.web3BitcoinAccount);
  }

  @override
  late final String addressStr = address.toAddress(baseNetwork);

  String get wcStyle {
    return switch (baseNetwork) {
      BitcoinCashNetwork.mainnet ||
      BitcoinCashNetwork.testnet =>
        addressStr.split(":").last,
      _ => addressStr
    };
  }
}

class Web3BitcoinChainIdnetifier extends Web3ChainIdnetifier {
  final BasedUtxoNetwork network;
  late final bool isBch = network == BitcoinCashNetwork.testnet ||
      network == BitcoinCashNetwork.mainnet;

  Web3BitcoinChainIdnetifier(
      {required this.network,
      required super.wsIdentifier,
      required super.caip2,
      required super.id});
  factory Web3BitcoinChainIdnetifier.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3BitcoinChainIdentifier);
    return Web3BitcoinChainIdnetifier(
        network: BasedUtxoNetwork.fromName(values.elementAs(0)),
        id: values.elementAs(1),
        wsIdentifier: values.elementAs(2),
        caip2: values.elementAs(3));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
      CborListValue.fixedLength([network.value, id, wsIdentifier, caip2]),
      CborTagsConst.web3BitcoinChainIdentifier,
    );
  }
}

class Web3BitcoinChainAuthenticated
    extends Web3ChainAuthenticated<Web3BitcoinChainAccount> {
  @override
  final List<Web3BitcoinChainIdnetifier> networks;
  @override
  final Web3BitcoinChainIdnetifier currentNetwork;
  Web3BitcoinChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3BitcoinChainIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.bitcoinAndForked);

  factory Web3BitcoinChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.bitcoinAndForked.tag);
    return Web3BitcoinChainAuthenticated(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3BitcoinChainAccount.deserialize(object: e))
            .toList(),
        networks: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => Web3BitcoinChainIdnetifier.deserialize(object: e))
            .toList(),
        currentNetwork: Web3BitcoinChainIdnetifier.deserialize(
            object: values.elementAs<CborTagValue>(2)));
  }

  @override
  NetworkType get networkType => NetworkType.bitcoinAndForked;
}
