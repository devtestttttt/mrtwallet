part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

abstract final class BaseBitcoinNewAddressParams<T extends IBitcoinAddress>
    implements NewAccountParams<T> {
  const BaseBitcoinNewAddressParams();
}

final class BitcoinNewAddressParams
    extends BaseBitcoinNewAddressParams<IBitcoinAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
  final PubKeyModes keyType;
  @override
  final CryptoCoins coin;

  const BitcoinNewAddressParams._(
      {required this.deriveIndex,
      required this.bitcoinAddressType,
      required this.coin,
      required this.keyType});
  factory BitcoinNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required BitcoinAddressType bitcoinAddressType,
      required CryptoCoins coin,
      required PubKeyModes keyType}) {
    return BitcoinNewAddressParams._(
        deriveIndex: deriveIndex,
        bitcoinAddressType: bitcoinAddressType,
        coin: coin,
        keyType: keyType);
  }
  factory BitcoinNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.bitcoinNewAddressParams.tag);
    return BitcoinNewAddressParams(
        deriveIndex:
            AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
        bitcoinAddressType: BitcoinAddressType.fromValue(values.elementAs(1)),
        coin: CustomCoins.getSerializationCoin(values.elementAs(2)),
        keyType: PubKeyModes.fromValue(values.elementAs(3)));
  }

  @override
  IBitcoinAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletBitcoinNetwork ||
        network.coinParam.transacationNetwork is BitcoinCashNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final pubkeyBytes = publicKey.keyBytes(mode: keyType, immutable: true);
    final address = BlockchainAddressUtils.publicKeyToBitcoinAddress(
        publicKey: pubkeyBytes,
        coin: coin,
        addressType: bitcoinAddressType,
        keyType: keyType);
    return IBitcoinAddress._newAccount(
      publicKey: publicKey.keyBytes(mode: keyType),
      network: network,
      address: address,
      addressType: bitcoinAddressType,
      keyIndex: deriveIndex,
      coin: coin,
      pubKeyMode: keyType,
      identifier: NewAccountParams.toIdentifier(
          address.toAddress(network.coinParam.transacationNetwork)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          deriveIndex.toCbor(),
          bitcoinAddressType.value,
          coin.toCbor(),
          keyType.value
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.bitcoinNewAddressParams;
}

final class BitcoinMultiSigNewAddressParams implements BitcoinNewAddressParams {
  @override
  final BitcoinAddressType bitcoinAddressType;
  final BitcoinMultiSignatureAddress multiSignatureAddress;
  @override
  final AddressDerivationIndex deriveIndex = MultiSigAddressIndex();
  @override
  bool get isMultiSig => true;
  @override
  final CryptoCoins coin;

  @override
  PubKeyModes get keyType =>
      throw UnsupportedError("key type must be implements on signers.");

  BitcoinMultiSigNewAddressParams._({
    required this.bitcoinAddressType,
    required this.multiSignatureAddress,
    required this.coin,
  });

  factory BitcoinMultiSigNewAddressParams({
    required BitcoinAddressType bitcoinAddressType,
    required BitcoinMultiSignatureAddress multiSignatureAddress,
    required CryptoCoins coin,
  }) {
    return BitcoinMultiSigNewAddressParams._(
        bitcoinAddressType: bitcoinAddressType,
        multiSignatureAddress: multiSignatureAddress,
        coin: coin);
  }

  factory BitcoinMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.bitcoinMultiSigNewAddressParams.tag);
    return BitcoinMultiSigNewAddressParams(
      bitcoinAddressType: BitcoinAddressType.fromValue(values.elementAs(0)),
      multiSignatureAddress:
          BitcoinMultiSignatureAddress.deserialize(obj: values.getCborTag(1)),
      coin: CustomCoins.getSerializationCoin(values.elementAs(2)),
    );
  }

  @override
  IBitcoinAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (network is! WalletBitcoinNetwork ||
        network.coinParam.transacationNetwork is BitcoinCashNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final address = multiSignatureAddress.fromType(
        network: network.coinParam.transacationNetwork,
        addressType: bitcoinAddressType);
    return IBitcoinMultiSigAddress._newAccount(
      address: address,
      coin: coin,
      multiSignatureAddress: multiSignatureAddress,
      network: network,
      addressType: bitcoinAddressType,
      identifier: NewAccountParams.toIdentifier(
          address.toAddress(network.coinParam.transacationNetwork)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          bitcoinAddressType.value,
          multiSignatureAddress.toCbor(),
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.bitcoinMultiSigNewAddressParams;
}

final class BitcoinCashNewAddressParams
    implements BaseBitcoinNewAddressParams<IBitcoinCashAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
  @override
  final CryptoCoins coin;
  final PubKeyModes keyType;

  BitcoinCashNewAddressParams._(
      {required this.deriveIndex,
      required this.bitcoinAddressType,
      required this.coin,
      required this.keyType});
  factory BitcoinCashNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required BitcoinAddressType bitcoinAddressType,
      required CryptoCoins coin,
      required PubKeyModes keyType}) {
    return BitcoinCashNewAddressParams._(
        deriveIndex: deriveIndex,
        bitcoinAddressType: bitcoinAddressType,
        coin: coin,
        keyType: keyType);
  }
  factory BitcoinCashNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.bitcoinCashNewAddressParams.tag);
    return BitcoinCashNewAddressParams(
        deriveIndex:
            AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
        bitcoinAddressType: BitcoinAddressType.fromValue(values.elementAt(1)),
        coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
        keyType: PubKeyModes.fromValue(values.elementAs(3),
            defaultValue: PubKeyModes.compressed));
  }

  @override
  IBitcoinCashAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    final pubKey = publicKey.keyBytes(mode: keyType, immutable: true);
    final address = BlockchainAddressUtils.publicKeyToBitcoinAddress(
        publicKey: pubKey,
        coin: coin,
        addressType: bitcoinAddressType,
        keyType: keyType);
    if (network is! WalletBitcoinCashNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return IBitcoinCashAddress._newAccount(
      identifier: NewAccountParams.toIdentifier(
          address.toAddress(network.coinParam.transacationNetwork)),
      coin: coin,
      addressType: bitcoinAddressType,
      keyIndex: deriveIndex,
      pubkeyMode: keyType,
      address: BlockchainAddressUtils.publicKeyToBitcoinAddress(
          publicKey: pubKey,
          coin: coin,
          addressType: bitcoinAddressType,
          keyType: keyType),
      publicKey: pubKey,
      network: network,
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          deriveIndex.toCbor(),
          bitcoinAddressType.value,
          coin.toCbor(),
          keyType.value
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.bitcoinCashNewAddressParams;
}

final class BitcoinCashMultiSigNewAddressParams
    implements BitcoinCashNewAddressParams {
  @override
  final BitcoinAddressType bitcoinAddressType;
  final BitcoinMultiSignatureAddress multiSignatureAddress;

  @override
  final AddressDerivationIndex deriveIndex = MultiSigAddressIndex();
  @override
  PubKeyModes get keyType =>
      throw UnsupportedError("key type must be implements on signers.");
  @override
  bool get isMultiSig => true;

  @override
  final CryptoCoins coin;
  BitcoinCashMultiSigNewAddressParams._(
      {required this.bitcoinAddressType,
      required this.multiSignatureAddress,
      required this.coin});
  factory BitcoinCashMultiSigNewAddressParams(
      {required BitcoinAddressType bitcoinAddressType,
      required BitcoinMultiSignatureAddress multiSignatureAddress,
      required CryptoCoins coin}) {
    return BitcoinCashMultiSigNewAddressParams._(
        bitcoinAddressType: bitcoinAddressType,
        multiSignatureAddress: multiSignatureAddress,
        coin: coin);
  }
  factory BitcoinCashMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.bitcoinCashMultiSigNewAddressParams.tag);
    return BitcoinCashMultiSigNewAddressParams(
      bitcoinAddressType: BitcoinAddressType.fromValue(values.elementAt(0)),
      multiSignatureAddress:
          BitcoinMultiSignatureAddress.deserialize(obj: values.getCborTag(1)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }

  @override
  IBitcoinCashAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (network is! WalletBitcoinCashNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final address = multiSignatureAddress.fromType(
        network: network.coinParam.transacationNetwork,
        addressType: bitcoinAddressType);

    return IBitcoinCashMultiSigAddress._newAccount(
        address: address,
        addressType: bitcoinAddressType,
        coin: coin,
        multiSignatureAddress: multiSignatureAddress,
        identifier: NewAccountParams.toIdentifier(
            address.toAddress(network.coinParam.transacationNetwork)),
        network: network);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          bitcoinAddressType.value,
          multiSignatureAddress.toCbor(),
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.bitcoinCashMultiSigNewAddressParams;
}
