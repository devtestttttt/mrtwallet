part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class IAptosAddress extends ChainAccount<AptosAddress, AptosFATokens,
    NFTCore, AptosWalletTransaction> {
  IAptosAddress._(
      {required super.keyIndex,
      required super.coin,
      required super.address,
      required super.network,
      required super.networkAddress,
      required this.keyScheme,
      required super.identifier,
      required List<int> publicKey,
      super.accountName})
      : publicKey = publicKey.asImmutableBytes;

  factory IAptosAddress._newAccount(
      {required AptosAddress address,
      required WalletAptosNetwork network,
      required List<int> publicKey,
      required String identifier,
      required AddressDerivationIndex keyIndex,
      required AptosSupportKeyScheme keyScheme,
      required CryptoCoins coin}) {
    final addressDetauls =
        AccountBalance(address: address.address, network: network);
    return IAptosAddress._(
        coin: coin,
        address: addressDetauls,
        keyIndex: keyIndex,
        keyScheme: keyScheme,
        networkAddress: address,
        network: network.value,
        publicKey: publicKey,
        identifier: identifier);
  }
  factory IAptosAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(
        cborTag.tags, CborTagsConst.aptosMultisigAccount)) {
      return IAptosMultiSigAddress.deserialize(network, obj: cborTag);
    }
    final CborListValue values = CborSerializable.cborTagValue(
        object: cborTag, tags: CborTagsConst.aptosAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final AptosAddress networkAddress = AptosAddress(address.address);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAs(4);
    final AptosSupportKeyScheme keyScheme =
        AptosSupportKeyScheme.fromValue(values.elementAs(5));
    final List<int> publicKey = values.elementAs(6);
    final String identifier = values.elementAs(7);
    return IAptosAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex,
        networkAddress: networkAddress,
        network: networkId,
        accountName: accountName,
        keyScheme: keyScheme,
        publicKey: publicKey,
        identifier: identifier);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  final AptosSupportKeyScheme keyScheme;

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
          identifier
        ]),
        CborTagsConst.aptosAccount);
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
    if (other is! IAptosAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  AptosNewAddressParams toAccountParams() {
    return AptosNewAddressParams(
        deriveIndex: keyIndex, coin: coin, keyScheme: keyScheme);
  }

  /// create transaction authenticated.
  AptosAccountAuthenticator createAccountAuthenticated(
      List<AptosAnySignature> signatures) {
    if (signatures.length != 1) {
      throw WalletException("invalid_signature");
    }
    final signature = signatures[0];
    switch (keyScheme) {
      case AptosSupportKeyScheme.ed25519:
        return AptosAccountAuthenticatorEd25519(
            publicKey: AptosED25519PublicKey.fromBytes(publicKey),
            signature: AptosEd25519Signature(signature.signatureBytes()));
      case AptosSupportKeyScheme.signleKeyEd25519:
      case AptosSupportKeyScheme.signleKeySecp256k1:
        return AptosAccountAuthenticatorSingleKey(
            publicKey: AptosCryptoPublicKey.fromBytes(
                publicKeyBytes: publicKey, algorithm: keyScheme.curve),
            signature: signature);
      default:
        throw WalletException("invalid_key_scheme");
    }
  }

  AptosAccountPublicKey aptosPublicKey() {
    switch (keyScheme) {
      case AptosSupportKeyScheme.ed25519:
        return AptosEd25519AccountPublicKey(
            AptosED25519PublicKey.fromBytes(publicKey));
      case AptosSupportKeyScheme.signleKeyEd25519:
      case AptosSupportKeyScheme.signleKeySecp256k1:
        return AptosSingleKeyAccountPublicKey(AptosCryptoPublicKey.fromBytes(
            publicKeyBytes: publicKey, algorithm: keyScheme.curve));
      default:
        throw WalletException("invalid_key_scheme");
    }
  }
}

final class IAptosMultiSigAddress extends IAptosAddress
    implements MultiSigCryptoAccountAddress {
  factory IAptosMultiSigAddress._newAccount(
      {required WalletAptosNetwork network,
      required AptosAddress address,
      required AptosMultisigAccountInfo multiSignatureAddress,
      required String identifier,
      required AptosSupportKeyScheme keyScheme,
      required CryptoCoins coin}) {
    final addressDetauls =
        AccountBalance(address: address.address, network: network);
    return IAptosMultiSigAddress._(
        coin: coin,
        address: addressDetauls,
        networkAddress: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        keyScheme: keyScheme,
        identifier: identifier);
  }

  factory IAptosMultiSigAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.aptosMultisigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAt(0));
    final AptosMultisigAccountInfo multiSignatureAddress =
        AptosMultisigAccountInfo.deserialize(object: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final AptosAddress networkAddress = AptosAddress(address.address);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? name = values.elementAt(4);
    final keyScheme = AptosSupportKeyScheme.fromValue(values.elementAs(5));
    if (keyScheme != multiSignatureAddress.keyScheme) {
      throw WalletExceptionConst.invalidAccountDetails_(
          messsage: "mis match multisig account key scheme.");
    }
    final String identifier = values.elementAs(6);
    return IAptosMultiSigAddress._(
        coin: coin,
        address: address,
        multiSignatureAddress: multiSignatureAddress,
        network: network.value,
        accountName: name,
        networkAddress: networkAddress,
        keyScheme: keyScheme,
        identifier: identifier);
  }
  IAptosMultiSigAddress._({
    required super.coin,
    required super.address,
    required this.multiSignatureAddress,
    required super.network,
    required super.keyScheme,
    required super.identifier,
    super.accountName,
    required super.networkAddress,
  }) : super._(publicKey: const [], keyIndex: MultiSigAddressIndex());

  @override
  List<int> get publicKey =>
      throw WalletExceptionConst.featureUnavailableForMultiSignature;

  final AptosMultisigAccountInfo multiSignatureAddress;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          keyScheme.value,
          identifier
        ]),
        CborTagsConst.aptosMultisigAccount);
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
  AptosNewAddressParams toAccountParams() {
    return AptosMultiSigNewAddressParams(
        coin: coin, multiSignatureAddress: multiSignatureAddress);
  }

  /// create transaction authenticated.
  @override
  AptosAccountAuthenticator createAccountAuthenticated(
      List<AptosAnySignature> signatures) {
    return multiSignatureAddress.createAccountAuthenticated(signatures);
  }

  @override
  AptosAccountPublicKey aptosPublicKey() {
    return multiSignatureAddress.toAptosMutlisigPublicKey();
  }

  @override
  IAdressType get iAddressType => IAdressType.multisigByPublicKey;
}
