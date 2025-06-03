part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

enum CryptoPublicKeyDataType {
  public(CryptoKeyConst.accessPubliKeyResponse),
  ada(CryptoKeyConst.accessAdaPubliKeyResponse),
  monero(CryptoKeyConst.accessMoneroPublicKeyResponse);

  final List<int> tag;
  const CryptoPublicKeyDataType(this.tag);
  static CryptoPublicKeyDataType fromTag(List<int>? tag) {
    return CryptoPublicKeyDataType.values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

enum CryptoPrivateKeyDataType {
  public(CryptoKeyConst.accessPrivateKeyResponse),
  ada(CryptoKeyConst.accessAdaLegacyPrivateKeyResponse),
  monero(CryptoKeyConst.accessMoneroPrivateKeyResponse);

  final List<int> tag;
  const CryptoPrivateKeyDataType(this.tag);
  static CryptoPrivateKeyDataType fromTag(List<int>? tag) {
    return CryptoPrivateKeyDataType.values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

abstract class CryptoKeyData with CborSerializable {
  abstract final String keyName;
  const CryptoKeyData._();
}

abstract final class CryptoPublicKeyData extends CryptoKeyData {
  const CryptoPublicKeyData._() : super._();
  abstract final CryptoPublicKeyDataType type;
  abstract final String? extendedKey;
  abstract final String comprossed;
  abstract final String? chainCode;
  abstract final String? uncomprossed;

  PublicKeysView get toViewKey => PublicKeysView._(
      extendKey: extendedKey,
      comprossed: comprossed,
      uncomprossed: uncomprossed,
      chainCode: chainCode,
      keyName: keyName,
      keyType: type);

  factory CryptoPublicKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    final type = CryptoPublicKeyDataType.fromTag(cbor.tags);
    switch (type) {
      case CryptoPublicKeyDataType.public:
        return PublicKeyData.deserialize(obj: cbor);
      case CryptoPublicKeyDataType.ada:
        return AdaLegacyPublicKeyData.deserialize(obj: cbor);
      case CryptoPublicKeyDataType.monero:
        return MoneroPublicKeyData.deserialize(obj: cbor);
    }
  }

  List<int> keyBytes(
      {PubKeyModes mode = PubKeyModes.compressed, bool immutable = false}) {
    final List<int> keyBytes = switch (mode) {
      PubKeyModes.compressed => BytesUtils.fromHexString(comprossed),
      PubKeyModes.uncompressed => () {
          assert(uncomprossed != null, "should not use uncomprossed mode.");
          return BytesUtils.fromHexString(uncomprossed ?? comprossed);
        }(),
    };
    if (immutable) return keyBytes.asImmutableBytes;
    return keyBytes;
  }

  List<int>? uncomprossedkeyBytes() {
    return BytesUtils.tryFromHexString(uncomprossed);
  }

  List<int>? chainCodeBytes() {
    return BytesUtils.tryFromHexString(chainCode);
  }

  T cast<T extends CryptoPublicKeyData>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}

abstract final class CryptoPrivateKeyData extends CryptoKeyData {
  abstract final CryptoPrivateKeyDataType type;
  const CryptoPrivateKeyData._() : super._();
  Bip32Base toBipKey();
  List<int> privateKeyBytes();
  abstract final String privateKey;
  abstract final String? extendedKey;
  abstract final CryptoPublicKeyData publicKey;
  abstract final CryptoCoins coin;
  abstract final String? wif;
  PrivateKeysView get toViewKey => PrivateKeysView._(
      extendKey: extendedKey,
      privateKey: privateKey,
      wif: wif,
      curve: coin.conf.type,
      keyName: keyName,
      keyType: type,
      inNetworkStyle: null);
  factory CryptoPrivateKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    final type = CryptoPrivateKeyDataType.fromTag(cbor.tags);
    switch (type) {
      case CryptoPrivateKeyDataType.public:
        return PrivateKeyData.deserialize(obj: cbor);
      case CryptoPrivateKeyDataType.ada:
        return ADALegacyPrivateKeyData.deserialize(obj: cbor);
      case CryptoPrivateKeyDataType.monero:
        return MoneroPrivateKeyData.deserialize(obj: cbor);
    }
  }
  factory CryptoPrivateKeyData._fromSeed(
      {required CryptoCoins coin,
      required String keyName,
      required List<int> seedBytes}) {
    if (coin is BipCoins) {
      final account =
          CryptoKeyUtils.seedToBipKey(seedBytes: seedBytes, coin: coin);
      return CryptoPrivateKeyData._fromBip32(
          account: account, coin: coin, keyName: keyName);
    }
    final substrate = CryptoKeyUtils.seedToSubstratePrivateKey(
        seedBytes: seedBytes, coin: coin);
    return PrivateKeyData._(coin: coin, keyName: keyName, key: substrate);
  }
  factory CryptoPrivateKeyData._fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName}) {
    switch (coin) {
      case Bip44Coins.moneroEd25519Slip:
        return MoneroPrivateKeyData._fromBip32(
            account: account, coin: coin, keyName: keyName);
      default:
        return PrivateKeyData._fromBip32(
            coin: coin, keyName: keyName, account: account);
    }
  }
  T cast<T extends CryptoPrivateKeyData>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}
