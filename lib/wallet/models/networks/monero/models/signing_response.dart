import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/crypto/utils/utils.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class MoneroViewTxDestinationWithProof {
  final MoneroTxDestination proof;
  final IntegerBalance amount;
  const MoneroViewTxDestinationWithProof(
      {required this.proof, required this.amount});
}

class MoneroSignedTxData with CborSerializable {
  final String txID;
  final List<MoneroPrivateKey> txKeys;
  final List<MoneroAccountIndex> indexes;
  MoneroSignedTxData(
      {required String txID,
      required List<MoneroPrivateKey> txKeys,
      required List<MoneroAccountIndex> indexes})
      : txID = QuickCryptoValidator.asValidHexBytes(txID,
            lengthInBytes: MoneroConst.txHashLength),
        txKeys = txKeys.immutable,
        indexes = indexes.immutable;
  factory MoneroSignedTxData.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroSignedTxData);
    return MoneroSignedTxData(
        txID: String.fromCharCodes(values.elementAs(0)),
        txKeys: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => MoneroPrivateKey.fromBytes(e.value))
            .toList(),
        indexes: values
            .elementAsListOf<CborBytesValue>(2)
            .map((e) => MoneroAccountIndex.deserialize(e.value))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(txID.codeUnits),
          CborListValue.fixedLength(
              txKeys.map((e) => CborBytesValue(e.key)).toList()),
          CborListValue.fixedLength(
              indexes.map((e) => CborBytesValue(e.serialize())).toList()),
        ]),
        CborTagsConst.moneroSignedTxData);
  }
}

class MoneroSigningTxResponse with CborSerializable {
  final MoneroSignedTxData txData;
  final List<MoneroTxDestination> destinations;
  final String txBytes;
  MoneroSigningTxResponse({
    required this.txData,
    required List<MoneroTxDestination> destinations,
    required String txHex,
  })  : destinations = destinations.immutable,
        txBytes = QuickCryptoValidator.asValidHexBytes(txHex);
  factory MoneroSigningTxResponse.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.moneroSigningTxResponse);
    return MoneroSigningTxResponse(
        txData: MoneroSignedTxData.deserialize(obj: values.getCborTag(0)),
        destinations: values
            .elementAsListOf<CborBytesValue>(1)
            .map((e) => MoneroTxDestination.deserialize(e.value))
            .toList(),
        txHex: String.fromCharCodes(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          txData.toCbor(),
          CborListValue.fixedLength(
              destinations.map((e) => CborBytesValue(e.serialize())).toList()),
          CborBytesValue(txBytes.codeUnits)
        ]),
        CborTagsConst.moneroSigningTxResponse);
  }
}
