part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class AptosNewAddressParams implements NewAccountParams<IAptosAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  final AptosSupportKeyScheme keyScheme;
  final AptosAddress? address;
  AptosNewAddressParams._(
      {required this.deriveIndex,
      required this.coin,
      this.address,
      required this.keyScheme});
  factory AptosNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin,
      required AptosSupportKeyScheme keyScheme}) {
    return AptosNewAddressParams._(
        deriveIndex: deriveIndex, coin: coin, keyScheme: keyScheme);
  }

  AptosNewAddressParams updateAddress(AptosAddress address) {
    assert(this.address == null, "Address must be null.");
    return AptosNewAddressParams._(
        deriveIndex: deriveIndex,
        coin: coin,
        address: address,
        keyScheme: keyScheme);
  }

  factory AptosNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.aptosNewAddressParams.tag);
    return AptosNewAddressParams._(
        deriveIndex:
            AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
        coin: CustomCoins.getSerializationCoin(values.elementAs(1)),
        address: values.elemetMybeAs<AptosAddress, CborStringValue>(
            2, (e) => AptosAddress(e.value)),
        keyScheme: AptosSupportKeyScheme.fromValue(values.elementAs(3)));
  }

  @override
  IAptosAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    final address = this.address;
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }

    if (address == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    // if(coin.conf.type!= )
    return IAptosAddress._newAccount(
        coin: coin,
        keyIndex: deriveIndex,
        keyScheme: keyScheme,
        address: address,
        identifier: NewAccountParams.toIdentifier(address.address),
        network: network.toNetwork(),
        publicKey: publicKey.keyBytes());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          deriveIndex.toCbor(),
          coin.toCbor(),
          address?.address,
          keyScheme.value
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.aptosNewAddressParams;
}

final class AptosMultiSigNewAddressParams implements AptosNewAddressParams {
  @override
  bool get isMultiSig => true;
  @override
  final CryptoCoins coin;
  @override
  final AptosAddress address;

  final AptosMultisigAccountInfo multiSignatureAddress;
  @override
  final AddressDerivationIndex deriveIndex = MultiSigAddressIndex();

  AptosMultiSigNewAddressParams._({
    required this.multiSignatureAddress,
    required this.coin,
    required this.address,
  }) : super();
  factory AptosMultiSigNewAddressParams({
    required AptosMultisigAccountInfo multiSignatureAddress,
    required CryptoCoins coin,
  }) {
    return AptosMultiSigNewAddressParams._(
        multiSignatureAddress: multiSignatureAddress,
        coin: coin,
        address: multiSignatureAddress.generateAddress());
  }

  factory AptosMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.aptosMultisigNewAddressParams.tag);
    return AptosMultiSigNewAddressParams._(
        coin: CustomCoins.getSerializationCoin(values.elementAs(0)),
        multiSignatureAddress: AptosMultisigAccountInfo.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        address: AptosAddress(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          coin.toCbor(),
          multiSignatureAddress.toCbor(),
          address.address,
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.aptosMultisigNewAddressParams;

  @override
  AptosSupportKeyScheme get keyScheme => multiSignatureAddress.keyScheme;

  @override
  AptosNewAddressParams updateAddress(AptosAddress address) {
    throw UnimplementedError();
  }

  @override
  IAptosAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    final address = this.address;
    if (network is! WalletAptosNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return IAptosMultiSigAddress._newAccount(
        network: network.toNetwork(),
        address: address,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        keyScheme: keyScheme,
        multiSignatureAddress: multiSignatureAddress);
  }
}
