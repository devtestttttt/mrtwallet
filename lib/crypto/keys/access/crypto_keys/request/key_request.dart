part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class AccessCryptoPrivateKeysRequest with CborSerializable {
  final List<AccessCryptoPrivateKeyRequest> indexes;
  AccessCryptoPrivateKeysRequest._(List<AccessCryptoPrivateKeyRequest> indexes)
      : indexes = List<AccessCryptoPrivateKeyRequest>.unmodifiable(indexes);
  factory AccessCryptoPrivateKeysRequest(
      List<AccessCryptoPrivateKeyRequest> indexes) {
    return AccessCryptoPrivateKeysRequest._(indexes);
  }
  factory AccessCryptoPrivateKeysRequest.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeysRequest);
    final List<AccessCryptoPrivateKeyRequest> indexes = cbor.value
        .map((e) => AccessCryptoPrivateKeyRequest.fromCborBytesOrObject(obj: e))
        .toList();
    return AccessCryptoPrivateKeysRequest(indexes);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(indexes.map((e) => e.toCbor()).toList(),
        CryptoKeyConst.accessPrivateKeysRequest);
  }
}

final class AccessCryptoPrivateKeyRequest with CborSerializable {
  final AddressDerivationIndex index;
  final int maxLevel;

  const AccessCryptoPrivateKeyRequest._(
      {required this.index, this.maxLevel = 5});
  factory AccessCryptoPrivateKeyRequest(
      {required AddressDerivationIndex index, int maxLevel = 5}) {
    return AccessCryptoPrivateKeyRequest._(index: index, maxLevel: maxLevel);
  }

  factory AccessCryptoPrivateKeyRequest.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeyRequest);

    return AccessCryptoPrivateKeyRequest._(
        index: AddressDerivationIndex.deserialize(obj: cbor.getCborTag(0)),
        maxLevel: cbor.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([index.toCbor(), maxLevel]),
        CryptoKeyConst.accessPrivateKeyRequest);
  }
}
