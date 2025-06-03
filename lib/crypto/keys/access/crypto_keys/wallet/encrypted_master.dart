part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class EncryptedMasterKey with CborSerializable {
  final List<int> masterKey;
  final List<EncryptedCustomKey> customKeys;
  EncryptedMasterKey.__({
    required List<int> keyBytes,
    required List<EncryptedCustomKey> customKeys,
  })  : masterKey = List<int>.unmodifiable(keyBytes),
        customKeys = List<EncryptedCustomKey>.unmodifiable(customKeys);
  factory EncryptedMasterKey._(
      {required List<int> keyBytes,
      required List<EncryptedCustomKey> customKeys}) {
    return EncryptedMasterKey.__(keyBytes: keyBytes, customKeys: customKeys);
  }
  factory EncryptedMasterKey.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.encryptedMasterKey);
    final List<EncryptedCustomKey> customKeys = values
        .elementAsListOf<CborTagValue>(1)
        .map((e) => EncryptedCustomKey.deserialize(obj: e))
        .toList();
    return EncryptedMasterKey._(
        keyBytes: values.elementAs(0), customKeys: customKeys);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(masterKey),
          CborListValue.fixedLength(customKeys.map((e) => e.toCbor()).toList()),
        ]),
        CryptoKeyConst.encryptedMasterKey);
  }
}
