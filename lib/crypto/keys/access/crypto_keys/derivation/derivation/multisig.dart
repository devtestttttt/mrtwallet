part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class MultiSigAddressIndex extends AddressDerivationIndex {
  @override
  final String? hdPath = null;
  final String? keyName;
  const MultiSigAddressIndex._({this.keyName}) : super._();
  factory MultiSigAddressIndex({String? keyName}) {
    return MultiSigAddressIndex._(keyName: keyName);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([keyName]),
        CryptoKeyConst.multiSigAccountKeyIndex);
  }

  @override
  List get variabels => [];

  @override
  CryptoCoins get currencyCoin =>
      throw WalletExceptionConst.inaccessibleKeyAlgorithm;

  @override
  SeedTypes get seedGeneration => throw WalletExceptionConst.unsuportedFeature;

  @override
  AddressDerivationType get derivationType => AddressDerivationType.multisig;

  @override
  String get name => "multi_signature";

  @override
  String toString() {
    return name;
  }

  @override
  String? get importedKeyId => null;

  @override
  AddressDerivationIndex asImportedKey(String importKeyId) {
    throw WalletExceptionConst.featureUnavailableForMultiSignature;
  }

  @override
  CryptoPrivateKeyData _derive(CryptoPrivateKeyData masterKey,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    throw WalletExceptionConst.multiSigDerivationNotSuported;
  }
}
