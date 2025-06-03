part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class EncryptedCustomKey with Equatable, CborSerializable {
  final String publicKey;
  final String id;
  final CryptoCoins coin;
  final DateTime created;
  final String? name;
  final CustomKeyType keyType;
  const EncryptedCustomKey.__(
      {required this.publicKey,
      required this.coin,
      required this.id,
      required this.created,
      required this.name,
      required this.keyType});
  factory EncryptedCustomKey._(
      {required String publicKey,
      required CryptoCoins coin,
      required String id,
      required DateTime created,
      required String? name,
      required CustomKeyType keyType}) {
    return EncryptedCustomKey.__(
        publicKey: publicKey,
        coin: coin,
        id: id,
        created: created,
        name: name,
        keyType: keyType);
  }
  factory EncryptedCustomKey.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CryptoKeyConst.encryptedCustomKey);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(cbor.elementAs(2));
    return EncryptedCustomKey._(
        publicKey: cbor.elementAs(0),
        id: cbor.elementAs(1),
        coin: coin,
        created: cbor.elementAs(3),
        name: cbor.elementAs(4),
        keyType: CustomKeyType.fromValue(cbor.elementAs(5)));
  }

  bool get allowDerivation {
    if (keyType.isPrivateKey && coin == Bip44Coins.moneroEd25519Slip) {
      return false;
    }
    return true;
  }

  @override
  List get variabels => [publicKey, id, coin, keyType.name];

  bool canUseFor(CryptoCoins coin) {
    if (this.coin == coin) return true;
    if (!keyType.isPrivateKey) return false;
    if (coin == Bip44Coins.moneroEd25519Slip) {
      return this.coin == coin;
    }
    return this.coin.conf.type == coin.conf.type;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          publicKey,
          id,
          coin.toCbor(),
          CborEpochIntValue(created),
          name ?? const CborNullValue(),
          keyType.value,
        ]),
        CryptoKeyConst.encryptedCustomKey);
  }
}
