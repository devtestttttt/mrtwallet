part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

class FakeKeyData extends CryptoKeyData {
  const FakeKeyData._() : super._();
  factory FakeKeyData() {
    return FakeKeyData._();
  }
  @override
  CborTagValue toCbor() {
    throw UnimplementedError();
  }

  @override
  String get keyName => throw UnimplementedError();
}
