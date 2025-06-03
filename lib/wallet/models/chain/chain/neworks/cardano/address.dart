part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ICardanoAddress
    extends ChainAccount<ADAAddress, TokenCore, NFTCore, ADAWalletTransaction> {
  ICardanoAddress._(
      {required super.keyIndex,
      required super.coin,
      required super.address,
      required super.network,
      required super.networkAddress,
      required this.addressDetails,
      required super.identifier,
      Bip32AddressIndex? rewardKeyIndex,
      super.accountName})
      : _rewardKeyIndex = rewardKeyIndex,
        rewardAddress = CardanoUtils.extractRewardAddress(networkAddress);

  factory ICardanoAddress._newAccount(
      {required ADAAddress address,
      required CryptoCoins coin,
      required AddressDerivationIndex keyIndex,
      required List<int> publicKey,
      required WalletCardanoNetwork network,
      required Bip32AddressIndex? rewardIndex,
      required String identifier,
      required CardanoAddrDetails addressDetails}) {
    final balance = AccountBalance(address: address.address, network: network);
    return ICardanoAddress._(
        coin: coin,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        addressDetails: addressDetails,
        rewardKeyIndex: rewardIndex,
        identifier: identifier);
  }

  factory ICardanoAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: obj, cborBytes: bytes, tags: CborTagsConst.cardanoAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final ADAAddress adaAddress = ADAAddress.fromAddress(address.toAddress);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }

    final CardanoAddrDetails addrDetails =
        CardanoAddrDetails.deserialize(obj: values.getCborTag(4));
    final String? accountName = values.elementAs(5);
    final CborTagValue? rewardIndexCbor = values.getCborTag(6);
    final rewardIndex = rewardIndexCbor == null
        ? null
        : Bip32AddressIndex.deserialize(obj: rewardIndexCbor);
    if (adaAddress.addressType == ADAAddressType.base && rewardIndex == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final String identifier = values.elementAs(7);
    return ICardanoAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex,
        networkAddress: adaAddress,
        network: networkId,
        addressDetails: addrDetails,
        accountName: accountName,
        rewardKeyIndex: rewardIndex,
        identifier: identifier);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          address.toCbor(),
          network,
          addressDetails.toCbor(),
          accountName ?? const CborNullValue(),
          rewardKeyIndex?.toCbor() ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.cardanoAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, networkAddress.addressType, addressDetails];
  }

  final CardanoAddrDetails addressDetails;

  final ADARewardAddress? rewardAddress;

  final Bip32AddressIndex? _rewardKeyIndex;

  Bip32AddressIndex? get rewardKeyIndex => _rewardKeyIndex;

  bool get isBaseAddress => networkAddress.addressType == ADAAddressType.base;
  bool get isRewardAddress =>
      networkAddress.addressType == ADAAddressType.reward;
  @override
  String? get type => networkAddress.addressType.name;

  @override
  String get orginalAddress => networkAddress.address;

  List<AddressDerivationIndex> get keyIndexes =>
      [keyIndex, if (rewardKeyIndex != null) rewardKeyIndex!];

  @override
  List<AddressDerivationIndex> signerKeyIndexes() {
    if (multiSigAccount) {
      throw WalletExceptionConst.featureUnavailableForMultiSignature;
    }
    return [keyIndex, if (_rewardKeyIndex != null) _rewardKeyIndex];
  }

  @override
  bool isEqual(ChainAccount other) {
    if (other is! ICardanoAddress) return false;
    return networkAddress == other.networkAddress &&
        rewardAddress == other.rewardAddress;
  }

  @override
  CardanoNewAddressParams toAccountParams() {
    return CardanoNewAddressParams(
        addressType: addressDetails.addressType,
        deriveIndex: keyIndex,
        rewardKeyIndex: rewardKeyIndex,
        addressDetails: addressDetails,
        customHdPath: addressDetails.hdPath,
        customHdPathKey: addressDetails.hdPathKey,
        coin: coin);
  }

  @override
  List<int>? get publicKey => addressDetails.publicKey;
}
