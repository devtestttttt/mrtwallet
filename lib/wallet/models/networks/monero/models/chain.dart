import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
// import 'package:on_chain_wallet/app/utils/utils.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class MoneroCachedBlockHeight {
  final int block;
  final DateTime time;
  MoneroCachedBlockHeight(this.block) : time = DateTime.now();
  bool get needFetch =>
      time.isBefore(DateTime.now().add(MoneroConst.avarageBlockTime));
}

class MoneroRingOutput with CborSerializable {
  final List<BigInt> orderedIndexes;
  final List<BigInt> indexes;
  MoneroRingOutput(
      {required List<BigInt> orderedIndexes, required List<BigInt> indexes})
      : orderedIndexes = orderedIndexes.immutable,
        indexes = indexes.immutable;
  factory MoneroRingOutput.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.monerogenerateRingOutput);
    return MoneroRingOutput(
        orderedIndexes: values
            .elementAsListOf<CborBigIntValue>(0)
            .map((e) => e.value)
            .toList(),
        indexes: values
            .elementAsListOf<CborBigIntValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborListValue.fixedLength(
          orderedIndexes.map((e) => CborBigIntValue(e)).toList()),
      CborListValue.fixedLength(
          indexes.map((e) => CborBigIntValue(e)).toList()),
    ], CborTagsConst.monerogenerateRingOutput);
  }
}

class MoneroSyncAccountRequest {
  final List<IMoneroAddress> addresses;
  final int startHeight;
  final int endHeight;
  final String heightsStr;
  MoneroSyncAccountRequest(
      {required this.addresses,
      required this.startHeight,
      required this.endHeight})
      : heightsStr = "$startHeight/$endHeight";
}
