part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class RippleMultiSigSignerDetails with Equatable, CborSerializable {
  const RippleMultiSigSignerDetails._(
      {required this.publicKey, required this.weight, required this.keyIndex});

  factory RippleMultiSigSignerDetails(
      {required List<int> publicKey,
      required Bip32AddressIndex keyIndex,
      required int weight}) {
    return RippleMultiSigSignerDetails._(
        publicKey: BytesUtils.toHexString(publicKey),
        weight: weight,
        keyIndex: keyIndex);
  }
  factory RippleMultiSigSignerDetails.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.rippleMultiSigSignerAddress);

    final List<int> publicKey = cbor.elementAs(0);
    final int weight = cbor.elementAs(1);
    final keyIndex = Bip32AddressIndex.deserialize(obj: cbor.getCborTag(2));
    return RippleMultiSigSignerDetails(
        publicKey: publicKey, weight: weight, keyIndex: keyIndex);
  }

  final String publicKey;
  final int weight;

  final Bip32AddressIndex keyIndex;
  String get path => keyIndex.toString();

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(BytesUtils.fromHexString(publicKey)),
          weight,
          keyIndex.toCbor()
        ]),
        CborTagsConst.rippleMultiSigSignerAddress);
  }

  @override
  List get variabels => [publicKey, weight, keyIndex];
}

class RippleMultiSignatureAddress with Equatable, CborSerializable {
  final List<RippleMultiSigSignerDetails> signers;

  final int threshold;
  final bool isRegular;

  RippleMultiSignatureAddress._(
      {required this.signers,
      required this.threshold,
      required this.isRegular});

  factory RippleMultiSignatureAddress(
      {required int threshold,
      required List<RippleMultiSigSignerDetails> signers,
      required bool isRegularKey}) {
    final sumWeight = signers.fold(0, (sum, signer) => sum + signer.weight);

    if (sumWeight < threshold) {
      throw WalletExceptionConst.invalidAccountDetails;
    }

    return RippleMultiSignatureAddress._(
        signers: signers, threshold: threshold, isRegular: isRegularKey);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(signers.map((e) => e.toCbor()).toList()),
          threshold,
          CborBoleanValue(isRegular)
        ]),
        CborTagsConst.rippleMultiSignaturAddress);
  }

  factory RippleMultiSignatureAddress.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.rippleMultiSignaturAddress);
    final List<RippleMultiSigSignerDetails> signers = cbor
        .elementAsListOf<CborTagValue>(0)
        .map<RippleMultiSigSignerDetails>(
            (e) => RippleMultiSigSignerDetails.deserialize(obj: e))
        .toList();
    final int threshHold = cbor.elementAs(1);
    final bool isRegularKey = cbor.elementAs(2);
    return RippleMultiSignatureAddress._(
        signers: signers, threshold: threshHold, isRegular: isRegularKey);
  }

  @override
  List get variabels => [threshold, signers];
}
