part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class PublicKeyData extends CryptoPublicKeyData {
  @override
  final String? extendedKey;
  @override
  final String comprossed;
  @override
  final String? uncomprossed;
  @override
  final String keyName;
  @override
  final String? chainCode;

  const PublicKeyData.__(
      {required this.extendedKey,
      required this.comprossed,
      required this.uncomprossed,
      required this.keyName,
      required this.chainCode})
      : super._();
  factory PublicKeyData._fromBip32(
      {required Bip32Base account, required String keyName}) {
    final comperesed = BytesUtils.toHexString(account.publicKey.compressed);
    final uncompresed = BytesUtils.toHexString(account.publicKey.uncompressed);
    return PublicKeyData.__(
        extendedKey: account.publicKey.toExtended,
        comprossed: comperesed,
        uncomprossed: uncompresed == comperesed ? null : uncompresed,
        keyName: keyName,
        chainCode: account.publicKey.chainCode.toHex());
  }
  factory PublicKeyData._(
      {required IPublicKey key,
      required CryptoCoins coin,
      required String keyName}) {
    final comperesed = BytesUtils.toHexString(key.compressed);
    final uncompresed = BytesUtils.toHexString(key.uncompressed);
    return PublicKeyData.__(
        extendedKey: null,
        comprossed: key.toHex(),
        uncomprossed: uncompresed == comperesed ? null : uncompresed,
        keyName: keyName,
        chainCode: null);
  }

  factory PublicKeyData.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessPubliKeyResponse);
    return PublicKeyData.__(
        extendedKey: cbor.elementAs(0),
        comprossed: cbor.elementAs(1),
        uncomprossed: cbor.elementAs(2),
        keyName: cbor.elementAs(3),
        chainCode: cbor.elementAs(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          extendedKey,
          comprossed,
          uncomprossed ?? const CborNullValue(),
          keyName,
          chainCode
        ]),
        type.tag);
  }

  @override
  CryptoPublicKeyDataType get type => CryptoPublicKeyDataType.public;
}
