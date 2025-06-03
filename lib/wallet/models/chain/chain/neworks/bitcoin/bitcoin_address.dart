part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class IBitcoinAddress extends ChainAccount<BitcoinBaseAddress, TokenCore,
    NFTCore, BitcoinWalletTransaction> {
  factory IBitcoinAddress._newAccount(
      {
      // required BitcoinNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletBitcoinNetwork network,
      required BitcoinBaseAddress address,
      required CryptoCoins coin,
      required BitcoinAddressType addressType,
      required PubKeyModes pubKeyMode,
      required String identifier,
      required AddressDerivationIndex keyIndex}) {
    final balance = AccountBalance(
        address: address.toAddress(network.coinParam.transacationNetwork),
        network: network);
    return IBitcoinAddress(
        coin: coin,
        publicKey: publicKey,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        addressType: addressType,
        network: network.value,
        keyType: pubKeyMode,
        identifier: identifier);
  }

  factory IBitcoinAddress.deserialize(WalletBitcoinNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue toCborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(
        toCborTag.tags, CborTagsConst.bitcoinMultiSigAccount)) {
      return IBitcoinMultiSigAddress.fromCborBytesOrObject(network,
          obj: toCborTag);
    }
    final CborListValue cbor = CborSerializable.cborTagValue(
        object: toCborTag, tags: CborTagsConst.bitcoinAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(cbor.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: cbor.getCborTag(1));
    final List<int> publicKey = cbor.elementAs(2);
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: cbor.getCborTag(3));
    final BitcoinAddressType bitcoinAddressType =
        BitcoinAddressType.fromValue(cbor.elementAs(4));
    final networkId = cbor.elementAs(5);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? name = cbor.elementAs(6);
    final keyType = PubKeyModes.fromValue(cbor.elementAs(7),
        defaultValue: PubKeyModes.compressed);
    final btcNetwork =
        network.toNetwork<WalletBitcoinNetwork>().coinParam.transacationNetwork;
    final bitcoinAddress = BlockchainAddressUtils.toBitcoinAddress(
        address.toAddress, btcNetwork,
        p2shAddressType: bitcoinAddressType);
    if (bitcoinAddress.toAddress(btcNetwork) != address.toAddress ||
        bitcoinAddress.type != bitcoinAddressType) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final String identifier = cbor.elementAs(8);

    return IBitcoinAddress(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: bitcoinAddress,
        addressType: bitcoinAddressType,
        network: network.value,
        accountName: name,
        keyType: keyType,
        identifier: identifier);
  }
  IBitcoinAddress(
      {required super.keyIndex,
      required super.coin,
      required List<int> publicKey,
      required super.networkAddress,
      required super.address,
      required this.addressType,
      required super.network,
      super.accountName,
      required this.keyType,
      required super.identifier})
      : publicKey = List.unmodifiable(publicKey);

  @override
  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          addressType.value,
          network,
          accountName ?? const CborNullValue(),
          keyType.value,
          identifier
        ]),
        CborTagsConst.bitcoinAccount);
  }

  final BitcoinAddressType addressType;
  final PubKeyModes keyType;

  UtxoAddressDetails toUtxoRequest() {
    return UtxoAddressDetails(
        publicKey: BytesUtils.toHexString(publicKey), address: networkAddress);
  }

  @override
  List get variabels => [addressType, keyIndex, network];

  List<String> get signers => [BytesUtils.toHexString(publicKey)];

  @override
  String accountToString() {
    return "${addressType.value}\n${address.toAddress}";
  }

  @override
  String get type => addressType.value;

  @override
  String get orginalAddress => address.toAddress;

  @override
  bool isEqual(ChainAccount other) {
    return network == other.network && orginalAddress == other.orginalAddress;
  }

  Script? witnessScript() {
    switch (addressType) {
      case SegwitAddressType.p2wsh:
      case P2shAddressType.p2wshInP2sh:
        final publicKey = ECPublic.fromBytes(this.publicKey);
        return publicKey.toP2wshScript();
      default:
        return null;
    }
  }

  List<int>? xOnly() {
    if (addressType.isP2tr) {
      final publicKey = ECPublic.fromBytes(this.publicKey);
      return publicKey.toXOnly();
    }
    return null;
  }

  Script? tapScript() {
    return null;
  }

  Script? redeemScript() {
    if (!addressType.isP2sh) return null;
    final publicKey = ECPublic.fromBytes(this.publicKey);
    switch (addressType) {
      case P2shAddressType.p2wshInP2sh:
        return publicKey.toP2wshAddress().toScriptPubKey();
      case P2shAddressType.p2wpkhInP2sh:
        return publicKey.toSegwitAddress().toScriptPubKey();
      case P2shAddressType.p2pkInP2sh:
      case P2shAddressType.p2pkInP2sh32:
      case P2shAddressType.p2pkInP2shwt:
      case P2shAddressType.p2pkInP2sh32wt:
        return publicKey.toRedeemScript(mode: keyType);
      case P2shAddressType.p2pkhInP2sh:
      case P2shAddressType.p2pkhInP2sh32:
      case P2shAddressType.p2pkhInP2shwt:
      case P2shAddressType.p2pkhInP2sh32wt:
        return publicKey.toAddress(mode: keyType).toScriptPubKey();
      default:
        return null;
    }
  }

  @override
  NewAccountParams toAccountParams() {
    return BitcoinNewAddressParams(
        deriveIndex: keyIndex,
        bitcoinAddressType: addressType,
        coin: coin,
        keyType: keyType);
  }
}

final class IBitcoinMultiSigAddress extends IBitcoinAddress
    with BitcoinMultiSigBase
    implements MultiSigCryptoAccountAddress {
  factory IBitcoinMultiSigAddress._newAccount({
    required WalletBitcoinNetwork network,
    required BitcoinBaseAddress address,
    required CryptoCoins coin,
    required BitcoinMultiSignatureAddress multiSignatureAddress,
    required String identifier,
    required BitcoinAddressType addressType,
  }) {
    final balance = AccountBalance(
        address: address.toAddress(network.coinParam.transacationNetwork),
        network: network);
    return IBitcoinMultiSigAddress._(
        coin: coin,
        address: balance,
        multiSignatureAddress: multiSignatureAddress,
        bitcoinAddress: address,
        addressType: addressType,
        network: network.value,
        keyIndex: MultiSigAddressIndex(),
        identifier: identifier);
  }

  factory IBitcoinMultiSigAddress.fromCborBytesOrObject(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.bitcoinMultiSigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(cbor.elementAs(0));
    final BitcoinMultiSignatureAddress multiSignatureAddress =
        BitcoinMultiSignatureAddress.deserialize(obj: cbor.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: cbor.getCborTag(2));
    final BitcoinAddressType bitcoinAddressType =
        BitcoinAddressType.fromValue(cbor.elementAs(3));
    final int networkId = cbor.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }

    final keyIndex =
        AddressDerivationIndex.deserialize(obj: cbor.getCborTag(5));
    final String? name = cbor.elementAs(6);
    final String identifier = cbor.elementAs(7);

    return IBitcoinMultiSigAddress._(
        coin: coin,
        address: address,
        bitcoinAddress: multiSignatureAddress.fromType(
            network: network
                .toNetwork<WalletBitcoinNetwork>()
                .coinParam
                .transacationNetwork,
            addressType: bitcoinAddressType),
        addressType: bitcoinAddressType,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        keyIndex: keyIndex,
        accountName: name,
        identifier: identifier);
  }
  IBitcoinMultiSigAddress._(
      {required super.coin,
      required BitcoinBaseAddress bitcoinAddress,
      required super.address,
      required super.addressType,
      required this.multiSignatureAddress,
      required super.network,
      required super.keyIndex,
      required super.identifier,
      super.accountName})
      : super(
            publicKey: const [],
            networkAddress: bitcoinAddress,
            keyType: PubKeyModes.uncompressed);

  @override
  List<int> get publicKey => throw UnimplementedError();
  @override
  PubKeyModes get keyType => throw UnimplementedError();
  @override
  final BitcoinMultiSignatureAddress multiSignatureAddress;

  @override
  UtxoAddressDetails toUtxoRequest() {
    return UtxoAddressDetails.multiSigAddress(
        multiSigAddress: multiSignatureAddress, address: networkAddress);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          address.toCbor(),
          addressType.value,
          network,
          keyIndex.toCbor(),
          accountName ?? const CborNullValue(),
          identifier,
        ]),
        CborTagsConst.bitcoinMultiSigAccount);
  }

  @override
  List get variabels => [
        addressType,
        keyIndex,
        network,
        multiSignatureAddress.multiSigScript.toHex()
      ];

  @override
  List<String> get signers =>
      multiSignatureAddress.signers.map((e) => e.publicKey).toList();

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAddress.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  BitcoinMultiSigNewAddressParams toAccountParams() {
    return BitcoinMultiSigNewAddressParams(
        multiSignatureAddress: multiSignatureAddress,
        bitcoinAddressType: addressType,
        coin: coin);
  }

  @override
  IAdressType get iAddressType => IAdressType.multisigByPublicKey;

  @override
  Script? witnessScript() {
    switch (addressType) {
      case SegwitAddressType.p2wsh:
      case P2shAddressType.p2wshInP2sh:
        return multiSignatureAddress.multiSigScript;
      default:
        return null;
    }
  }

  @override
  Script? redeemScript() {
    if (!addressType.isP2sh) return null;
    switch (addressType) {
      case P2shAddressType.p2wshInP2sh:
        return P2wshAddress.fromScript(
                script: multiSignatureAddress.multiSigScript)
            .toScriptPubKey();
      case P2shAddressType.p2pkInP2sh:
      case P2shAddressType.p2pkInP2sh32:
      case P2shAddressType.p2pkInP2shwt:
      case P2shAddressType.p2pkInP2sh32wt:
        return multiSignatureAddress.multiSigScript;
      case P2shAddressType.p2pkhInP2sh:
      case P2shAddressType.p2pkhInP2sh32:
      case P2shAddressType.p2pkhInP2shwt:
      case P2shAddressType.p2pkhInP2sh32wt:
        return multiSignatureAddress.multiSigScript;
      default:
        return null;
    }
  }
}
