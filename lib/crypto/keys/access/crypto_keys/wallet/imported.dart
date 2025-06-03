part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class ImportedKeyStorage with CborSerializable, Equatable {
  ImportedKeyStorage._(
      {required this.checksum,
      required this.extendedPrivateKey,
      required this.coin,
      required this.publicKey,
      required this.name,
      DateTime? created,
      required this.keyType})
      : created = created ?? DateTime.now();
  final String checksum;
  final String extendedPrivateKey;
  final String publicKey;
  final String? name;
  final DateTime created;
  final CryptoCoins coin;
  final CustomKeyType keyType;
  factory ImportedKeyStorage.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CryptoKeyConst.walletCustomKey);

      final CryptoCoins coin = CustomCoins.getCoin(
        name: cbor.elementAt(4),
        proposal: cbor.elementAt(3),
      );
      return ImportedKeyStorage._(
          checksum: cbor.elementAt(0),
          extendedPrivateKey: cbor.elementAt(1),
          publicKey: cbor.elementAt(2),
          coin: coin,
          created: cbor.elementAt(5),
          name: cbor.elementAt(6),
          keyType: CustomKeyType.fromValue(cbor.elementAt(7)));
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          checksum,
          extendedPrivateKey,
          publicKey,
          coin.proposal.specName,
          coin.coinName,
          CborEpochIntValue(created),
          name,
          keyType.value
        ]),
        CryptoKeyConst.walletCustomKey);
  }

  @override
  List get variabels =>
      [checksum, extendedPrivateKey, coin.coinName, publicKey];

  CryptoPrivateKeyData getKey() {
    if (keyType.isPrivateKey) {
      return PrivateKeyData._(
          coin: coin,
          keyName: checksum,
          key: IPrivateKey.fromHex(extendedPrivateKey, coin.conf.type));
    }
    return PrivateKeyData._fromExtendedKey(
        extendedKey: extendedPrivateKey, coin: coin, keyName: checksum);
  }

  CryptoPrivateKeyData _toBip32Key(AddressDerivationIndex key) {
    final currentCoin = key.currencyCoin;

    if (!keyType.isPrivateKey) {
      if (currentCoin == Bip44Coins.moneroEd25519Slip) {
        return MoneroPrivateKeyData._fromExtendedKey(
            extendedKey: extendedPrivateKey,
            coin: currentCoin,
            keyName: checksum);
      }
      return PrivateKeyData._fromExtendedKey(
          extendedKey: extendedPrivateKey,
          coin: currentCoin,
          keyName: checksum);
    }
    if (currentCoin == Bip44Coins.moneroEd25519Slip) {
      if (coin != Bip44Coins.moneroEd25519Slip) {
        throw WalletExceptionConst.invalidCoin;
      }
      return MoneroPrivateKeyData._(
          spendPrivateKey: MoneroPrivateKey.fromHex(extendedPrivateKey),
          coin: currentCoin,
          keyName: checksum);
    }
    return PrivateKeyData._(
        coin: currentCoin,
        keyName: checksum,
        key: IPrivateKey.fromHex(extendedPrivateKey, currentCoin.conf.type));
  }

  CryptoPrivateKeyData toKey(AddressDerivationIndex key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (key is Bip32AddressIndex) {
      if (key.indexes.isNotEmpty) {
        throw WalletExceptionConst.importedKeyDerivationNotAllowed;
      }
    } else if (key is SubstrateAddressIndex) {
      if (key.substratePath != null) {
        throw WalletExceptionConst.importedKeyDerivationNotAllowed;
      }
    }
    return _toBip32Key(key);
  }
}
