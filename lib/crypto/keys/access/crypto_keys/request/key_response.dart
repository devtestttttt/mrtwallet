part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class CryptoPrivateKeysResponse with CborSerializable {
  final List<CryptoPrivateKeyData> keys;
  CryptoPrivateKeysResponse.__(List<CryptoPrivateKeyData> keys)
      : keys = List<CryptoPrivateKeyData>.unmodifiable(keys);
  factory CryptoPrivateKeysResponse._(List<CryptoPrivateKeyData> keys) {
    return CryptoPrivateKeysResponse.__(keys);
  }
  factory CryptoPrivateKeysResponse.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeysRequest);
    final List<CryptoPrivateKeyData> indexes = cbor.value
        .map((e) => CryptoPrivateKeyData.fromCborBytesOrObject(obj: e))
        .toList();
    return CryptoPrivateKeysResponse._(indexes);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(keys.map((e) => e.toCbor()).toList(),
        CryptoKeyConst.accessPrivateKeysRequest);
  }
}

final class CryptoPublicKeysResponse with CborSerializable {
  final List<CryptoPublicKeyData> keys;
  CryptoPublicKeysResponse.__(List<CryptoPublicKeyData> keys)
      : keys = List<CryptoPublicKeyData>.unmodifiable(keys);
  factory CryptoPublicKeysResponse._(List<CryptoPublicKeyData> keys) {
    return CryptoPublicKeysResponse.__(keys);
  }
  factory CryptoPublicKeysResponse.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPublicKeysRequest);
    final List<CryptoPublicKeyData> indexes = cbor.value
        .map((e) => CryptoPublicKeyData.fromCborBytesOrObject(obj: e))
        .toList();
    return CryptoPublicKeysResponse.__(indexes);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(keys.map((e) => e.toCbor()).toList(),
        CryptoKeyConst.accessPublicKeysRequest);
  }
}
