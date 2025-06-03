part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class TronMultiSigSignerDetais with Equatable, CborSerializable {
  TronMultiSigSignerDetais._(
      {required this.publicKey, required this.weight, required this.keyIndex});

  factory TronMultiSigSignerDetais(
      {required List<int> publicKey,
      required Bip32AddressIndex keyIndex,
      required BigInt weight}) {
    return TronMultiSigSignerDetais._(
        publicKey: BytesUtils.toHexString(publicKey),
        weight: weight,
        keyIndex: keyIndex);
  }
  factory TronMultiSigSignerDetais.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.tronMultiSigSignerAddress);

    final List<int> publicKey = cbor.elementAs(0);
    final BigInt weight = cbor.elementAs(1);
    final keyIndex = Bip32AddressIndex.deserialize(obj: cbor.getCborTag(2));
    return TronMultiSigSignerDetais(
        publicKey: publicKey, weight: weight, keyIndex: keyIndex);
  }

  final String publicKey;
  final BigInt weight;

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
        CborTagsConst.tronMultiSigSignerAddress);
  }

  @override
  List get variabels => [publicKey, weight, keyIndex];
}

class TronMultiSignatureAddress with Equatable, CborSerializable {
  final List<TronMultiSigSignerDetais> signers;
  final BigInt threshold;
  final int? permissionID;

  TronMultiSignatureAddress._(
      {required this.signers,
      required this.threshold,
      required this.permissionID});

  factory TronMultiSignatureAddress(
      {required BigInt threshold,
      required List<TronMultiSigSignerDetais> signers,
      required int? permissionID}) {
    final sumWeight =
        signers.fold(BigInt.zero, (sum, signer) => sum + signer.weight);

    if (sumWeight < threshold) {
      throw const WalletException(
          'The total weight of the signatories should reach the threshold');
    }

    return TronMultiSignatureAddress._(
        signers: signers, threshold: threshold, permissionID: permissionID);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(signers.map((e) => e.toCbor()).toList()),
          threshold,
          permissionID,
        ]),
        CborTagsConst.tronMultiSignaturAddress);
  }

  factory TronMultiSignatureAddress.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.tronMultiSignaturAddress);
    final List<TronMultiSigSignerDetais> signers = cbor
        .elementAsListOf<CborTagValue>(0)
        .map<TronMultiSigSignerDetais>(
            (e) => TronMultiSigSignerDetais.deserialize(obj: e))
        .toList();
    final BigInt threshHold = cbor.elementAs(1);
    final int? permissionID = cbor.elementAs(2);
    return TronMultiSignatureAddress._(
        signers: signers, threshold: threshHold, permissionID: permissionID);
  }

  @override
  List get variabels => [threshold, signers, permissionID];
}
