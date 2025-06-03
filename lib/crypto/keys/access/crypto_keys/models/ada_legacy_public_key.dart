part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class AdaLegacyPublicKeyData extends CryptoPublicKeyData {
  @override
  final String extendedKey;
  @override
  final String comprossed;
  @override
  final String? uncomprossed;
  final String hdPathKey;
  @override
  final String chainCode;
  @override
  final String keyName;
  const AdaLegacyPublicKeyData._(
      {required this.extendedKey,
      required this.comprossed,
      required this.uncomprossed,
      required this.keyName,
      required this.hdPathKey,
      required this.chainCode})
      : super._();
  factory AdaLegacyPublicKeyData._fromBip32(
      {required Bip32Base account,
      required List<int> hdPathKey,
      required String keyName}) {
    final comperesed = BytesUtils.toHexString(account.publicKey.compressed);
    final uncompresed = BytesUtils.toHexString(account.publicKey.uncompressed);
    return AdaLegacyPublicKeyData._(
        extendedKey: account.publicKey.toExtended,
        comprossed: comperesed,
        uncomprossed: uncompresed == comperesed ? null : uncompresed,
        keyName: keyName,
        chainCode: account.chainCode.toHex(),
        hdPathKey: BytesUtils.toHexString(hdPathKey));
  }
  factory AdaLegacyPublicKeyData.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessAdaPubliKeyResponse);
    return AdaLegacyPublicKeyData._(
        extendedKey: cbor.elementAs(0),
        comprossed: cbor.elementAs(1),
        uncomprossed: cbor.elementAs(2),
        keyName: cbor.elementAs(3),
        hdPathKey: cbor.elementAs(4),
        chainCode: cbor.elementAs(5));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          extendedKey,
          comprossed,
          uncomprossed ?? const CborNullValue(),
          keyName,
          hdPathKey,
          chainCode
        ]),
        type.tag);
  }

  List<int> hdPathKeyBytes() {
    return BytesUtils.fromHexString(hdPathKey);
  }

  @override
  List<int> chainCodeBytes() {
    return BytesUtils.fromHexString(chainCode);
  }

  @override
  CryptoPublicKeyDataType get type => CryptoPublicKeyDataType.ada;
}
