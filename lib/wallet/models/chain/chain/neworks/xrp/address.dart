part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

enum XrpAddressType {
  xAddress("x_address"),
  classic("classic_address");

  final String value;
  const XrpAddressType(this.value);
}

final class IXRPAddress extends ChainAccount<XRPAddress, RippleIssueToken,
    RippleNFToken, XRPWalletTransaction> {
  IXRPAddress._(
      {required super.keyIndex,
      required super.coin,
      required List<int> publicKey,
      required super.address,
      required super.network,
      required super.networkAddress,
      required this.tag,
      required super.identifier,
      super.accountName})
      : publicKey = List.unmodifiable(publicKey),
        addressType =
            tag == null ? XrpAddressType.classic : XrpAddressType.xAddress;

  factory IXRPAddress._newAccount(
      {required CryptoCoins coin,
      required int? tag,
      required XRPAddress address,
      required AddressDerivationIndex keyIndex,
      required List<int> publicKey,
      required WalletXRPNetwork network,
      required String identifier}) {
    final addressDetails =
        AccountBalance(address: address.toAddress(), network: network);
    return IXRPAddress._(
        coin: coin,
        publicKey: publicKey,
        address: addressDetails,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        tag: tag,
        identifier: identifier);
  }

  factory IXRPAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(
        cborTag.tags, CborTagsConst.rippleMultisigAccount)) {
      return IXRPMultisigAddress.deserialize(network, obj: cborTag);
    }
    final CborListValue values = CborSerializable.cborTagValue(
        object: cborTag, tags: CborTagsConst.rippleAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final List<int> publicKey = values.elementAt(2);
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(3));
    final XRPAddress rippleAddress = XRPAddress(address.toAddress);
    final int? tag = values.elementAs(4);
    final networkId = values.elementAs(5);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAt(6);
    final String identifier = values.elementAt(7);
    return IXRPAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: rippleAddress,
        network: networkId,
        tag: tag,
        accountName: accountName,
        identifier: identifier);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          tag,
          network,
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.rippleAccount);
  }

  @override
  List get variabels {
    return [tag, keyIndex, network];
  }

  final XrpAddressType addressType;
  EllipticCurveTypes get curveType => coin.conf.type;
  final int? tag;

  @override
  String get type => addressType.value;

  @override
  String get orginalAddress => networkAddress.address;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! IXRPAddress) return false;
    return networkAddress.address == other.networkAddress.address &&
        networkAddress.tag == other.networkAddress.tag &&
        multiSigAccount == other.multiSigAccount;
  }

  @override
  RippleNewAddressParams toAccountParams() {
    return RippleNewAddressParams(deriveIndex: keyIndex, coin: coin, tag: tag);
  }
}

final class IXRPMultisigAddress extends IXRPAddress
    implements MultiSigCryptoAccountAddress {
  IXRPMultisigAddress._(
      {required super.address,
      required super.network,
      required super.coin,
      required super.networkAddress,
      required super.tag,
      required this.multiSignatureAccount,
      required super.identifier,
      super.accountName})
      : super._(keyIndex: MultiSigAddressIndex(), publicKey: const []);
  @override
  RippleMultiSigNewAddressParams toAccountParams() {
    return RippleMultiSigNewAddressParams(
        coin: coin,
        masterAddress: networkAddress,
        multiSigAccount: multiSignatureAccount);
  }

  factory IXRPMultisigAddress._newAccount({
    // required RippleMultiSigNewAddressParams accountParams,
    required WalletXRPNetwork network,
    required CryptoCoins coin,
    required int? tag,
    required XRPAddress address,
    required RippleMultiSignatureAddress multiSigAccount,
    required String identifier,
  }) {
    final balance =
        AccountBalance(address: address.toAddress(), network: network);
    return IXRPMultisigAddress._(
        coin: coin,
        multiSignatureAccount: multiSigAccount,
        address: balance,
        networkAddress: address,
        network: network.value,
        tag: tag,
        identifier: identifier);
  }
  factory IXRPMultisigAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.rippleMultisigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(1));
    final int? tag = values.elementAs(2);
    final int networkId = values.elementAs(3);
    final XRPAddress rippleAddress = XRPAddress(address.toAddress);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final RippleMultiSignatureAddress multiSigAccount =
        RippleMultiSignatureAddress.deserialize(obj: values.getCborTag(4));
    final String? accountName = values.elementAs(5);
    final String identifier = values.elementAs(6);
    return IXRPMultisigAddress._(
        coin: coin,
        address: address,
        networkAddress: rippleAddress,
        network: networkId,
        tag: tag,
        multiSignatureAccount: multiSigAccount,
        accountName: accountName,
        identifier: identifier);
  }

  final RippleMultiSignatureAddress multiSignatureAccount;
  @override
  List<int> get publicKey => throw UnimplementedError();
  @override
  EllipticCurveTypes get curveType => throw UnimplementedError();

  @override
  List get variabels {
    return [tag, keyIndex, network, multiSignatureAccount];
  }

  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          address.toCbor(),
          tag,
          network,
          multiSignatureAccount.toCbor(),
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.rippleMultisigAccount);
  }

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAccount.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();

  @override
  IAdressType get iAddressType => IAdressType.multisigByAddress;
}
