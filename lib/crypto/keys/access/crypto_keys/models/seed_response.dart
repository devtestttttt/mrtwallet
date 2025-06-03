part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

class AccessMnemonicResponse extends CryptoKeyData {
  final Mnemonic mnemonic;
  const AccessMnemonicResponse._(this.mnemonic) : super._();

  factory AccessMnemonicResponse.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessMnemonicResponse);
    return AccessMnemonicResponse._(Mnemonic.fromString(cbor.elementAs(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([mnemonic.toStr()]),
        CryptoKeyConst.accessMnemonicResponse);
  }

  @override
  String get keyName => "mnemonic";
}
