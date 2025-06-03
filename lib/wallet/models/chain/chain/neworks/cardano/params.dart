part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class CardanoNewAddressParams extends NewAccountParams<ICardanoAddress> {
  final ADAAddressType addressType;
  @override
  final AddressDerivationIndex deriveIndex;
  final Bip32AddressIndex? rewardKeyIndex;
  final CardanoAddrDetails? addressDetails;
  final String? customHdPath;
  final List<int>? customHdPathKey;
  bool get needStakeKey => addressType == ADAAddressType.base;
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;
  CardanoNewAddressParams._(
      {required this.addressType,
      required this.deriveIndex,
      required this.rewardKeyIndex,
      required this.coin,
      this.addressDetails,
      this.customHdPath,
      List<int>? customHdPathKey})
      : customHdPathKey =
            BytesUtils.tryToBytes(customHdPathKey, unmodifiable: true),
        super._();
  factory CardanoNewAddressParams(
      {required ADAAddressType addressType,
      required AddressDerivationIndex deriveIndex,
      required Bip32AddressIndex? rewardKeyIndex,
      required CryptoCoins coin,
      CardanoAddrDetails? addressDetails,
      String? customHdPath,
      List<int>? customHdPathKey}) {
    return CardanoNewAddressParams._(
        addressType: addressType,
        deriveIndex: deriveIndex,
        rewardKeyIndex: rewardKeyIndex,
        coin: coin,
        addressDetails: addressDetails,
        customHdPath: customHdPath,
        customHdPathKey: customHdPathKey);
  }

  factory CardanoNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.cardanoNewAddressParams.tag);
    return CardanoNewAddressParams(
        addressType: ADAAddressType.fromHeader(values.elementAt(0)),
        deriveIndex:
            AddressDerivationIndex.deserialize(obj: values.getCborTag(1)),
        rewardKeyIndex: values.getCborTag(2)?.to<Bip32AddressIndex, CborObject>(
            (e) => Bip32AddressIndex.deserialize(obj: e)),
        addressDetails: values
            .getCborTag(3)
            ?.to((e) => CardanoAddrDetails.deserialize(obj: e)),
        customHdPath: values.elementAt(4),
        customHdPathKey: values.elementAt(5),
        coin: CustomCoins.getSerializationCoin(values.elementAt(6)));
  }
  CardanoNewAddressParams copyWith(
      {ADAAddressType? addressType,
      AddressDerivationIndex? deriveIndex,
      CardanoAddrDetails? addressDetails,
      Bip32AddressIndex? rewardKeyIndex,
      List<int>? publicKey,
      String? customHdPath,
      List<int>? customHdPathKey,
      CryptoCoins? coin}) {
    return CardanoNewAddressParams(
        addressType: addressType ?? this.addressType,
        deriveIndex: deriveIndex ?? this.deriveIndex,
        addressDetails: addressDetails ?? this.addressDetails,
        rewardKeyIndex: rewardKeyIndex ?? this.rewardKeyIndex,
        customHdPath: customHdPath,
        customHdPathKey: customHdPathKey,
        coin: coin ?? this.coin);
  }

  @override
  ICardanoAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    final addressDetails = this.addressDetails;
    if (addressDetails == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (network is! WalletCardanoNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (needStakeKey && rewardKeyIndex == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final address = addressDetails.toAddress(
        deriveIndex.currencyCoin, !network.coinParam.mainnet);
    return ICardanoAddress._newAccount(
        publicKey: addressDetails.publicKey,
        network: network,
        address: address,
        addressDetails: addressDetails,
        coin: coin,
        keyIndex: deriveIndex,
        rewardIndex: rewardKeyIndex,
        identifier: NewAccountParams.toIdentifier(address.address));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          addressType.header,
          deriveIndex.toCbor(),
          rewardKeyIndex?.toCbor(),
          addressDetails?.toCbor(),
          customHdPath,
          customHdPathKey == null
              ? const CborNullValue()
              : CborBytesValue(customHdPathKey!),
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.cardanoNewAddressParams;
}
