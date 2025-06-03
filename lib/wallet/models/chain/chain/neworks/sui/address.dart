part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ISuiAddress
    extends ChainAccount<SuiAddress, SuiToken, NFTCore, SuiWalletTransaction> {
  ISuiAddress._(
      {required super.keyIndex,
      required super.coin,
      required super.address,
      required super.network,
      required super.networkAddress,
      required List<int> publicKey,
      required this.keyScheme,
      required super.identifier,
      super.accountName})
      : publicKey = publicKey.asImmutableBytes;

  factory ISuiAddress._newAccount({
    // required SuiNewAddressParams accountParams,
    required SuiAddress address,
    required WalletSuiNetwork network,
    required List<int> publicKey,
    required CryptoCoins coin,
    required AddressDerivationIndex keyIndex,
    required SuiSupportKeyScheme keyScheme,
    required String identifier,
  }) {
    final balance = AccountBalance(address: address.address, network: network);
    return ISuiAddress._(
        coin: coin,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        keyScheme: keyScheme,
        publicKey: publicKey,
        identifier: identifier);
  }

  factory ISuiAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(cborTag.tags, CborTagsConst.suiMultisigAccount)) {
      return ISuiMultiSigAddress.deserialize(network, obj: cborTag);
    }
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.suiAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final SuiAddress ethAddress = SuiAddress(address.toAddress);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAs(4);
    final SuiSupportKeyScheme keyScheme =
        SuiSupportKeyScheme.fromValue(values.elementAs(5));
    final List<int> publicKey = values.elementAs(6);
    final String identifier = values.elementAs(7);
    return ISuiAddress._(
      coin: coin,
      address: address,
      keyIndex: keyIndex,
      networkAddress: ethAddress,
      network: networkId,
      accountName: accountName,
      keyScheme: keyScheme,
      publicKey: publicKey,
      identifier: identifier,
    );
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  final SuiSupportKeyScheme keyScheme;

  @override
  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          keyScheme.value,
          CborBytesValue(publicKey),
          identifier,
        ]),
        CborTagsConst.suiAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, keyScheme];
  }

  @override
  String? get type => keyScheme.name;

  @override
  String get orginalAddress => networkAddress.address;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! ISuiAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  SuiNewAddressParams toAccountParams() {
    return SuiNewAddressParams(
        deriveIndex: keyIndex, coin: coin, keyScheme: keyScheme);
  }

  SuiAccountPublicKey toSuiPublicKey() {
    final SuiCryptoPublicKey publicKey = SuiCryptoPublicKey.fromBytes(
        keyBytes: this.publicKey, algorithm: keyScheme.suiKeyAlgorithm);
    switch (keyScheme) {
      case SuiSupportKeyScheme.ed25519:
        return SuiEd25519AccountPublicKey(publicKey.cast());
      case SuiSupportKeyScheme.secp256k1:
        return SuiSecp256k1AccountPublicKey(publicKey.cast());
      case SuiSupportKeyScheme.secp256r1:
        return SuiSecp256r1AccountPublicKey(publicKey.cast());
      default:
        throw WalletException("invalid_key_scheme");
    }
  }

  SuiBaseSignature createTransactionAuthenticated(
      List<SuiGenericSignature> signatures) {
    if (signatures.length != 1) {
      throw WalletException("invalid_signature");
    }
    final SuiCryptoPublicKey publicKey = SuiCryptoPublicKey.fromBytes(
        keyBytes: this.publicKey, algorithm: keyScheme.suiKeyAlgorithm);
    switch (keyScheme) {
      case SuiSupportKeyScheme.ed25519:
        return SuiEd25519Signature(
            publicKey: publicKey.cast(), signature: signatures.first);
      case SuiSupportKeyScheme.secp256k1:
        return SuiSecp256k1Signature(
            publicKey: publicKey.cast(), signature: signatures.first);
      case SuiSupportKeyScheme.secp256r1:
        return SuiSecp256r1Signature(
            publicKey: publicKey.cast(), signature: signatures.first);
      default:
        throw WalletException("invalid_key_scheme");
    }
  }
}

final class ISuiMultiSigAddress extends ISuiAddress
    implements MultiSigCryptoAccountAddress {
  factory ISuiMultiSigAddress._newAccount({
    required WalletSuiNetwork network,
    required CryptoCoins coin,
    required String identifier,
    required SuiAddress address,
    required SuiMultisigAccountInfo multiSignatureAddress,
  }) {
    final balance = AccountBalance(address: address.address, network: network);
    return ISuiMultiSigAddress._(
        coin: coin,
        address: balance,
        networkAddress: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        identifier: identifier);
  }

  factory ISuiMultiSigAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.suiMultisigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAt(0));
    final SuiMultisigAccountInfo multiSignatureAddress =
        SuiMultisigAccountInfo.deserialize(object: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final SuiAddress networkAddress = SuiAddress(address.address);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? name = values.elementAt(4);
    final String identifier = values.elementAs(5);
    return ISuiMultiSigAddress._(
        coin: coin,
        address: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        accountName: name,
        networkAddress: networkAddress,
        identifier: identifier);
  }
  ISuiMultiSigAddress._({
    required super.coin,
    required super.address,
    required this.multiSignatureAddress,
    required super.network,
    super.accountName,
    required super.networkAddress,
    required super.identifier,
  }) : super._(
            publicKey: const [],
            keyIndex: MultiSigAddressIndex(),
            keyScheme: SuiSupportKeyScheme.multisig);

  @override
  List<int> get publicKey =>
      throw WalletExceptionConst.featureUnavailableForMultiSignature;

  final SuiMultisigAccountInfo multiSignatureAddress;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.suiMultisigAccount);
  }

  @override
  List get variabels => [multiSignatureAddress];

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAddress.publicKeys
          .map((e) => (BytesUtils.toHexString(e.publicKey), e.keyIndex))
          .toList();

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  SuiNewAddressParams toAccountParams() {
    return SuiMultiSigNewAddressParams(
        coin: coin,
        multiSignatureAddress: multiSignatureAddress,
        address: networkAddress);
  }

  @override
  SuiAccountPublicKey toSuiPublicKey() {
    return multiSignatureAddress.toSuiMutlisigPublicKey();
  }

  @override
  SuiBaseSignature createTransactionAuthenticated(
      List<SuiGenericSignature> signatures) {
    return multiSignatureAddress.createTransactionAuthenticated(signatures);
  }

  @override
  IAdressType get iAddressType => IAdressType.multisigByPublicKey;
}
