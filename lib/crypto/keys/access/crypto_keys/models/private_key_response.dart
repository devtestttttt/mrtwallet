part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class PrivateKeyData extends CryptoPrivateKeyData {
  @override
  final CryptoCoins coin;
  @override
  final String privateKey;
  @override
  final String? extendedKey;
  @override
  final String? wif;
  @override
  final String keyName;
  @override
  final CryptoPublicKeyData publicKey;
  const PrivateKeyData.__(
      {required this.privateKey,
      required this.extendedKey,
      required this.coin,
      required this.wif,
      required this.keyName,
      required this.publicKey})
      : super._();
  factory PrivateKeyData._fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName}) {
    final wifKey =
        CryptoKeyUtils.toWif(privateKey: account.privateKey.raw, coin: coin);
    return PrivateKeyData.__(
        privateKey: account.privateKey.toHex(),
        extendedKey: account.privateKey.toExtended,
        coin: coin,
        wif: wifKey,
        keyName: keyName,
        publicKey:
            PublicKeyData._fromBip32(account: account, keyName: keyName));
  }
  factory PrivateKeyData._fromExtendedKey(
      {required String extendedKey,
      required CryptoCoins coin,
      required String keyName}) {
    final bipKey = CryptoKeyUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey, coin: coin);
    final wifKey =
        CryptoKeyUtils.toWif(privateKey: bipKey.privateKey.raw, coin: coin);
    return PrivateKeyData.__(
        privateKey: bipKey.privateKey.toHex(),
        extendedKey: bipKey.privateKey.toExtended,
        coin: coin,
        wif: wifKey,
        keyName: keyName,
        publicKey: PublicKeyData._fromBip32(account: bipKey, keyName: keyName));
  }
  factory PrivateKeyData.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessPrivateKeyResponse);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(cbor.elementAs(0));
    return PrivateKeyData.__(
        coin: coin,
        privateKey: cbor.elementAs(1),
        extendedKey: cbor.elementAs(2),
        wif: cbor.elementAs(3),
        keyName: cbor.elementAs(4),
        publicKey: PublicKeyData.deserialize(obj: cbor.getCborTag(5)));
  }

  factory PrivateKeyData._(
      {required CryptoCoins coin,
      required String keyName,
      required IPrivateKey key}) {
    return PrivateKeyData.__(
        privateKey: key.toHex(),
        extendedKey: null,
        coin: coin,
        wif: CryptoKeyUtils.toWif(privateKey: key.raw, coin: coin),
        keyName: keyName,
        publicKey:
            PublicKeyData._(key: key.publicKey, coin: coin, keyName: keyName));
  }

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
        CryptoKeyConst.accessPrivateKeyResponse);
  }

  @override
  Bip32Base toBipKey() {
    if (extendedKey == null) {
      return CryptoKeyUtils.privteKeyToBip32(
          privateKey: privateKey, coin: coin);
    }
    return CryptoKeyUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey!, coin: coin);
  }

  @override
  List<int> privateKeyBytes() {
    return BytesUtils.fromHexString(privateKey);
  }

  @override
  CryptoPrivateKeyDataType get type => CryptoPrivateKeyDataType.public;
}
