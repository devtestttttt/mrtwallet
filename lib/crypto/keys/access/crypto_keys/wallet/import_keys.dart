part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class ImportCustomKeys with CborSerializable {
  final String privateKey;
  final String publicKey;
  final CryptoCoins coin;
  const ImportCustomKeys._(
      {required this.privateKey, required this.publicKey, required this.coin});

  factory ImportCustomKeys.fromPrivateKey(
      {required List<int> privateKey, required CryptoCoins coin}) {
    final key = IPrivateKey.fromBytes(privateKey, coin.conf.type);
    return ImportCustomKeys._fromBytes(
        privateKey: key.raw,
        publicKey: CryptoKeyUtils.toPublicBytes(key.publicKey),
        coin: coin);
  }
  factory ImportCustomKeys._fromBytes(
      {required List<int> privateKey,
      required List<int> publicKey,
      required CryptoCoins coin}) {
    return ImportCustomKeys._(
        privateKey: BytesUtils.toHexString(privateKey),
        publicKey: BytesUtils.toHexString(publicKey),
        coin: coin);
  }
  factory ImportCustomKeys.deserialize({List<int>? bytes, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoKeyConst.importCustomKeys);
    return ImportCustomKeys._(
        privateKey: values.elementAs(0),
        publicKey: values.elementAs(1),
        coin: CustomCoins.getSerializationCoin(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([privateKey, publicKey, coin.toCbor()]),
        CryptoKeyConst.importCustomKeys);
  }
}
