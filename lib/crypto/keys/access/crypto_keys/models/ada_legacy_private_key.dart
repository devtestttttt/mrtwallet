part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class ADALegacyPrivateKeyData extends CryptoPrivateKeyData {
  @override
  final CryptoCoins coin;
  @override
  final String privateKey;
  @override
  final String extendedKey;
  @override
  final String? wif;
  @override
  final String keyName;

  @override
  final CryptoPublicKeyData publicKey;
  factory ADALegacyPrivateKeyData.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessAdaLegacyPrivateKeyResponse);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(cbor.elementAs(0));
    return ADALegacyPrivateKeyData._(
        coin: coin,
        privateKey: cbor.elementAs(1),
        extendedKey: cbor.elementAs(2),
        wif: cbor.elementAs(3),
        keyName: cbor.elementAs(4),
        publicKey: AdaLegacyPublicKeyData.deserialize(obj: cbor.getCborTag(5)));
  }

  const ADALegacyPrivateKeyData._(
      {required this.privateKey,
      required this.extendedKey,
      required this.coin,
      required this.wif,
      required this.keyName,
      required this.publicKey})
      : super._();

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          privateKey,
          extendedKey,
          wif ?? const CborNullValue(),
          keyName,
          publicKey.toCbor()
        ]),
        type.tag);
  }

  @override
  Bip32Base toBipKey() {
    return CryptoKeyUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey, coin: coin);
  }

  @override
  List<int> privateKeyBytes() {
    return BytesUtils.fromHexString(privateKey);
  }

  @override
  CryptoPrivateKeyDataType get type => CryptoPrivateKeyDataType.ada;
}
