part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class SuiNewAddressParams extends NewAccountParams<ISuiAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  final SuiAddress? address;
  final SuiSupportKeyScheme keyScheme;
  SuiNewAddressParams._(
      {required this.deriveIndex,
      required this.coin,
      this.address,
      required this.keyScheme})
      : super._();
  factory SuiNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin,
      SuiAddress? address,
      required SuiSupportKeyScheme keyScheme}) {
    return SuiNewAddressParams._(
        deriveIndex: deriveIndex,
        coin: coin,
        keyScheme: keyScheme,
        address: address);
  }

  SuiNewAddressParams updateAddress(SuiAddress address) {
    assert(this.address == null, "Address must be null.");
    return SuiNewAddressParams(
        deriveIndex: deriveIndex,
        coin: coin,
        address: address,
        keyScheme: keyScheme);
  }

  factory SuiNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.suiNewAddressParams.tag);
    return SuiNewAddressParams(
        deriveIndex:
            AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
        coin: CustomCoins.getSerializationCoin(values.elementAs(1)),
        address: values.elemetMybeAs<SuiAddress, CborStringValue>(
            2, (e) => SuiAddress(e.value)),
        keyScheme: SuiSupportKeyScheme.fromValue(values.elementAs(3)));
  }

  @override
  ISuiAddress toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    final address = this.address;
    if (address == null || network is! WalletSuiNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return ISuiAddress._newAccount(
        network: network,
        address: address,
        publicKey: publicKey.keyBytes(immutable: true),
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        keyIndex: deriveIndex,
        keyScheme: keyScheme);
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
  NewAccountParamsType get type => NewAccountParamsType.suiNewAddressParams;
}

final class SuiMultiSigNewAddressParams implements SuiNewAddressParams {
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;
  @override
  final CryptoCoins coin;
  final SuiMultisigAccountInfo multiSignatureAddress;
  @override
  final SuiAddress address;

  SuiMultiSigNewAddressParams._({
    required this.multiSignatureAddress,
    required this.coin,
    required this.address,
  }) : deriveIndex = MultiSigAddressIndex();

  factory SuiMultiSigNewAddressParams(
      {required SuiMultisigAccountInfo multiSignatureAddress,
      required CryptoCoins coin,
      required SuiAddress address}) {
    return SuiMultiSigNewAddressParams._(
        multiSignatureAddress: multiSignatureAddress,
        coin: coin,
        address: address);
  }

  factory SuiMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.suiMultisigNewAddressParams.tag);
    return SuiMultiSigNewAddressParams(
        coin: CustomCoins.getSerializationCoin(values.elementAt(0)),
        multiSignatureAddress:
            SuiMultisigAccountInfo.deserialize(object: values.elementAs(1)),
        address: SuiAddress(values.elementAs(2)));
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
      NewAccountParamsType.suiMultisigNewAddressParams;

  @override
  SuiSupportKeyScheme get keyScheme => SuiSupportKeyScheme.multisig;

  @override
  SuiNewAddressParams updateAddress(SuiAddress address) {
    return SuiMultiSigNewAddressParams(
        multiSignatureAddress: multiSignatureAddress,
        coin: coin,
        address: address);
  }

  @override
  ISuiAddress toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (network is! WalletSuiNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }

    return ISuiMultiSigAddress._newAccount(
        network: network,
        address: address,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        multiSignatureAddress: multiSignatureAddress);
  }
}
