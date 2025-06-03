part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class RippleNewAddressParams extends NewAccountParams<IXRPAddress> {
  @override
  bool get isMultiSig => false;

  EllipticCurveTypes get curve => coin.conf.type;
  @override
  final AddressDerivationIndex deriveIndex;

  final int? tag;
  @override
  final CryptoCoins coin;
  const RippleNewAddressParams._(
      {required this.deriveIndex, required this.coin, this.tag})
      : super._();
  factory RippleNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin,
      int? tag}) {
    return RippleNewAddressParams._(
        deriveIndex: deriveIndex, coin: coin, tag: tag);
  }

  factory RippleNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.rippleNewAddressParams.tag);
    return RippleNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
      tag: values.elementAt(1),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }
  @override
  IXRPAddress toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletXRPNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final keyBytes = publicKey.keyBytes(immutable: true);
    final keyAlgorithm = XRPKeyAlgorithm.values.firstWhere(
        (e) => e.curveType == curve,
        orElse: () => throw WalletExceptionConst.invalidAccountDetails);
    final address = RippleUtils.publicKeyToRippleAddress(keyBytes,
        algorithm: keyAlgorithm,
        tag: tag,
        isTenstNet: !network.coinParam.mainnet);
    return IXRPAddress._newAccount(
        publicKey: keyBytes,
        network: network,
        address: address,
        coin: coin,
        keyIndex: deriveIndex,
        tag: tag,
        identifier: NewAccountParams.toIdentifier(address.toAddress()));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), tag, coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.rippleNewAddressParams;
}

final class RippleMultiSigNewAddressParams implements RippleNewAddressParams {
  @override
  bool get isMultiSig => true;

  final XRPAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex = MultiSigAddressIndex();

  final RippleMultiSignatureAddress multiSigAccount;

  @override
  final int? tag;
  @override
  EllipticCurveTypes get curve => throw UnimplementedError();

  @override
  final CryptoCoins coin;

  RippleMultiSigNewAddressParams._(
      {required this.multiSigAccount,
      required this.masterAddress,
      required this.coin,
      this.tag});
  factory RippleMultiSigNewAddressParams(
      {required RippleMultiSignatureAddress multiSigAccount,
      required XRPAddress masterAddress,
      required CryptoCoins coin}) {
    return RippleMultiSigNewAddressParams._(
        multiSigAccount: multiSigAccount,
        masterAddress: masterAddress,
        coin: coin,
        tag: masterAddress.tag);
  }
  factory RippleMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.rippleMultiSigNewAddressParams.tag);
    return RippleMultiSigNewAddressParams._(
      masterAddress: XRPAddress(values.elementAs(0)),
      multiSigAccount:
          RippleMultiSignatureAddress.deserialize(obj: values.getCborTag(1)),
      tag: values.elementAs(1),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }

  @override
  IXRPMultisigAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (network is! WalletXRPNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final isTestnet = masterAddress.isTesnet;
    if (isTestnet != null &&
        isTestnet &&
        network.coinParam.chainType.isMainnet) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return IXRPMultisigAddress._newAccount(
        network: network,
        address: masterAddress,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(masterAddress.toAddress()),
        multiSigAccount: multiSigAccount,
        tag: tag);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterAddress.address,
          multiSigAccount.toCbor(),
          tag,
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.rippleMultiSigNewAddressParams;
}
