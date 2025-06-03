part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class WalletMasterKeys with CborSerializable {
  final List<int> _mnemonic;
  final List<int> _seed;
  final List<int> _entopySeed;
  final List<int> _cardanoLegacyByronSeed;
  final List<int> _cardanoIcarusSeed;
  final List<int> _checksum;
  final APPBip39Languages _language;
  final List<ImportedKeyStorage> _customKeys;
  List<int> get checksum => _checksum;

  AccessMnemonicResponse mnemonic() {
    final encode = Bip39MnemonicEncoder(_language.language).encode(_mnemonic);
    return AccessMnemonicResponse._(encode);
  }

  WalletMasterKeys._({
    required List<int> mnemonic,
    required List<int> seedBytes,
    required List<ImportedKeyStorage> customKeys,
    required List<int> entropySeedBytes,
    required List<int> cardanoLegacyByronSeed,
    required List<int> cardanoIcarusSeed,
    required List<int> checksum,
    required APPBip39Languages language,
  })  : _seed = seedBytes.asImmutableBytes,
        _cardanoLegacyByronSeed = cardanoLegacyByronSeed.asImmutableBytes,
        _cardanoIcarusSeed = cardanoIcarusSeed.asImmutableBytes,
        _checksum = checksum.asImmutableBytes,
        _entopySeed = entropySeedBytes.asImmutableBytes,
        _mnemonic = mnemonic.asImmutableBytes,
        _customKeys = customKeys.immutable,
        _language = language;
  List<int> _getSeed(SeedTypes type) {
    switch (type) {
      case SeedTypes.bip39:
        return _seed;
      case SeedTypes.bip39Entropy:
        return _entopySeed;
      case SeedTypes.icarus:
        return _cardanoIcarusSeed;
      default:
        return _cardanoLegacyByronSeed;
    }
  }

  WalletMasterKeys _addKey(List<ImportedKeyStorage> newKey) {
    return WalletMasterKeys._(
        mnemonic: _mnemonic,
        seedBytes: _seed,
        customKeys: List.unmodifiable([...newKey, ..._customKeys]),
        cardanoLegacyByronSeed: _cardanoLegacyByronSeed,
        cardanoIcarusSeed: _cardanoIcarusSeed,
        checksum: _checksum,
        entropySeedBytes: _entopySeed,
        language: _language);
  }

  WalletMasterKeys removeKey(String keyId) {
    final accounts = _customKeys.where((element) => element.checksum != keyId);
    return WalletMasterKeys._(
        mnemonic: _mnemonic,
        seedBytes: _seed,
        customKeys: List.unmodifiable(accounts),
        cardanoLegacyByronSeed: _cardanoLegacyByronSeed,
        cardanoIcarusSeed: _cardanoIcarusSeed,
        checksum: _checksum,
        entropySeedBytes: _entopySeed,
        language: _language);
  }

  factory WalletMasterKeys.generate(
      {String? passphrase, required String mnemonic}) {
    final mn = Mnemonic.fromString(mnemonic);
    final language = APPBip39Languages.findLanguage(mn);

    final isValid = Bip39MnemonicValidator(language.language);
    if (!isValid.isValid(mnemonic)) {
      throw WalletExceptionConst.invalidMnemonic;
    }
    final decode = Bip39MnemonicDecoder(language.language).decode(mn.toStr());
    final String passPhrase = passphrase ?? '';
    final seed = Bip39SeedGenerator(mn);
    final List<int> seedBytes = seed.generate(passPhrase);
    final List<int> entropySeedBytes = seed.generateFromEntropy(passPhrase);
    final icarus = CardanoIcarusSeedGenerator(mnemonic).generate();
    final cardanoLegacy = CardanoByronLegacySeedGenerator(mnemonic).generate();
    final List<int> checksum = QuickCrypto.sha3256Hash(
        [...seedBytes, ...icarus, ...cardanoLegacy, ...passPhrase.codeUnits]);

    return WalletMasterKeys._(
        mnemonic: decode,
        seedBytes: seedBytes,
        customKeys: List.unmodifiable([]),
        cardanoLegacyByronSeed: cardanoLegacy,
        cardanoIcarusSeed: icarus,
        checksum: checksum,
        entropySeedBytes: entropySeedBytes,
        language: language);
  }

  factory WalletMasterKeys.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    try {
      final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CryptoKeyConst.mnemonic,
      );

      final List<int> mnemonic = values.elementAs(0);
      final List<int> seed = values.elementAs(1);
      final importedKeys = values
          .elementAsListOf<CborTagValue>(2)
          .map((e) => ImportedKeyStorage.fromCborBytesOrObject(obj: e))
          .toList();
      final List<int> cardanoLegacy = values.elementAs(4);
      final List<int> icarus = values.elementAs(5);
      final List<int> checksum = values.elementAs(6);
      final List<int> entropySeed = values.elementAs(7);
      final APPBip39Languages language =
          APPBip39Languages.fromValue(values.elementAs(8));
      return WalletMasterKeys._(
          mnemonic: mnemonic,
          seedBytes: seed,
          customKeys: importedKeys,
          cardanoLegacyByronSeed: cardanoLegacy,
          cardanoIcarusSeed: icarus,
          checksum: checksum,
          entropySeedBytes: entropySeed,
          language: language);
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  static (WalletMasterKeys, bool) generateFromBackup(
      {String? passphrase, List<int>? bytes, CborObject? obj, String? hex}) {
    try {
      final CborListValue values = CborSerializable.cborTagValue(
          cborBytes: bytes,
          object: obj,
          hex: hex,
          tags: CryptoKeyConst.backupMasterKey);

      final List<int> mnemonicBytes = values.elementAs(0);
      final importedKeys = values
          .elementAsListOf<CborTagValue>(1)
          .map((e) => ImportedKeyStorage.fromCborBytesOrObject(obj: e))
          .toList();
      final List<int> checksum = values.elementAs(2);
      final APPBip39Languages language =
          APPBip39Languages.fromValue(values.elementAs(3));
      final mnemonic =
          Bip39MnemonicEncoder(language.language).encode(mnemonicBytes);

      WalletMasterKeys wallet = WalletMasterKeys.generate(
          mnemonic: mnemonic.toStr(), passphrase: passphrase);
      wallet = wallet._addKey(importedKeys);
      return (wallet, BytesUtils.bytesEqual(checksum, wallet.checksum));
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }

  @override
  CborTagValue toCbor({bool backup = false}) {
    if (backup) {
      return CborTagValue(
          CborListValue.fixedLength([
            CborBytesValue(_mnemonic),
            CborListValue.fixedLength(
                _customKeys.map((e) => e.toCbor()).toList()),
            CborBytesValue(_checksum),
            _language.value
          ]),
          CryptoKeyConst.backupMasterKey);
    }
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(_mnemonic),
          CborBytesValue(_seed),
          CborListValue.fixedLength(
              _customKeys.map((e) => e.toCbor()).toList()),
          const CborNullValue(),
          CborBytesValue(_cardanoLegacyByronSeed),
          CborBytesValue(_cardanoIcarusSeed),
          CborBytesValue(_checksum),
          CborBytesValue(_entopySeed),
          _language.value
        ]),
        CryptoKeyConst.mnemonic);
  }

  ImportedKeyStorage? getKeyById(String keyId) {
    try {
      return _customKeys.firstWhere((element) => element.checksum == keyId);
    } on StateError {
      return null;
    }
  }

  CryptoPrivateKeyData toKey(AddressDerivationIndex key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (key.isMultiSig) {
      throw WalletExceptionConst.multiSigDerivationNotSuported;
    }
    if (key.isImportedKey) {
      final customKey = getKeyById(key.importedKeyId!);
      if (customKey == null) {
        throw WalletExceptionConst.privateKeyIsNotAvailable;
      }
      return customKey.toKey(key, maxLevel: maxLevel);
    }
    final seedBytes = _getSeed(key.seedGeneration);
    final bip32Key = CryptoPrivateKeyData._fromSeed(
        seedBytes: seedBytes, coin: key.currencyCoin, keyName: key.name);
    return key._derive(bip32Key, maxLevel: maxLevel);
  }

  CryptoPrivateKeyData getImportedKey(String keyId) {
    final importedKey = getKeyById(keyId);
    if (importedKey == null) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    final keyInfo = importedKey.getKey();
    return keyInfo;
  }

  // List<CryptoPrivateKeyData>
  CryptoPrivateKeysResponse readKeys(
      List<AccessCryptoPrivateKeyRequest> requestKeys) {
    final List<CryptoPrivateKeyData> keys = [];
    for (final i in requestKeys) {
      final key = toKey(i.index, maxLevel: Bip44Levels.fromInt(i.maxLevel));
      keys.add(key);
    }
    return CryptoPrivateKeysResponse._(keys);
  }

  CryptoPublicKeysResponse readPublicKeys(
      List<AccessCryptoPrivateKeyRequest> requestKeys) {
    final List<CryptoPublicKeyData> pubKeys = [];
    for (final i in requestKeys) {
      final bool byronLegacy =
          i.index.currencyCoin.proposal == CustomProposal.cip0019;
      final CryptoPrivateKeyData privateKey = toKey(i.index,
          maxLevel:
              byronLegacy ? Bip44Levels.master : Bip44Levels.addressIndex);
      if (!byronLegacy) {
        pubKeys.add(privateKey.publicKey);
        continue;
      }
      Bip32Base bipKey = privateKey.toBipKey();
      if (byronLegacy) {
        final legacy = CardanoByronLegacy.fromBip32(bipKey);
        if (i.index.hdPath != null) {
          bipKey = legacy.bip32.derivePath(i.index.hdPath!);
        }
        pubKeys.add(AdaLegacyPublicKeyData._fromBip32(
            account: bipKey,
            keyName: privateKey.keyName,
            hdPathKey: legacy.hdPathKey));
        continue;
      }
    }
    return CryptoPublicKeysResponse._(pubKeys);
  }

  WalletMasterKeys importCustomKey(ImportedKeyStorage newKey,
      {bool validateChecksum = true}) {
    final ImportedKeyStorage validateKey;
    if (newKey.keyType == CustomKeyType.extendedKey) {
      validateKey = CryptoKeyUtils.extendeKeyToStorage(
          extendedKey: newKey.extendedPrivateKey, coin: newKey.coin);
    } else {
      validateKey = CryptoKeyUtils.privateKeyToStorage(
          privateKey: newKey.extendedPrivateKey, coin: newKey.coin);
    }

    if (validateKey.publicKey != newKey.publicKey) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (validateChecksum && validateKey.checksum != newKey.checksum) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (_customKeys.contains(newKey) ||
        _customKeys.any((e) => e.checksum == newKey.checksum)) {
      throw WalletExceptionConst.keyAlreadyExist;
    }
    return _addKey([newKey]);
  }

  (EncryptedMasterKey, List<int>) encrypt({required List<int> key}) {
    final memoryStorageBytes =
        _toMemoryStorage(walletData: toCbor().encode(), key: key);
    final encryptedMasterKey = EncryptedMasterKey._(
        keyBytes: memoryStorageBytes,
        customKeys: _customKeys
            .map((e) => EncryptedCustomKey._(
                publicKey: e.publicKey,
                coin: e.coin,
                id: e.checksum,
                created: e.created,
                name: e.name,
                keyType: e.keyType))
            .toList());
    final storageBytes = _toStorage(key: key);
    return (encryptedMasterKey, storageBytes);
  }

  List<int> _toStorage({required List<int> key, int version = 1}) {
    final List<int> nonce = WorkerCryptoUtils.generateNonce(key);
    final encrypt = WorkerCryptoUtils.encryptChacha(
        key: key, nonce: nonce, data: this.toCbor().encode());
    final toCbor = CborListValue.dynamicLength([
      CborIntValue(version),
      CborBytesValue(encrypt),
    ]);
    return toCbor.encode();
  }

  static List<int> _toMemoryStorage({
    required List<int> walletData,
    required List<int> key,
    int version = 1,
  }) {
    final List<int> nonce = QuickCrypto.generateRandom(12);
    final List<int> encrypt = WorkerCryptoUtils.encryptChacha(
        key: key, nonce: nonce, data: walletData);
    final toCbor = CborListValue.dynamicLength([
      CborIntValue(version),
      CborBytesValue(nonce),
      CborBytesValue(encrypt)
    ]);
    return toCbor.encode();
  }
}
