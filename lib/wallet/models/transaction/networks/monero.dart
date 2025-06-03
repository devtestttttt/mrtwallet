import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/constant/constant.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';

class MoneroWalletTransactionProof {
  final String txId;
  final List<List<int>> txKeys;
  final MoneroWalletTransactionOutput output;
  const MoneroWalletTransactionProof(
      {required this.txKeys, required this.output, required this.txId});
}

class MoneroWalletTransaction extends ChainTransaction {
  final List<List<int>> txKeys;
  MoneroWalletTransaction(
      {required super.txId,
      required super.time,
      required super.outputs,
      required WalletMoneroNetwork network,
      required List<List<int>> txKeys,
      required super.totalOutput,
      super.type = WalletTransactionType.send,
      super.status = WalletTransactionStatus.pending})
      : txKeys = txKeys.map((e) => e.asImmutableBytes).toImutableList,
        super();

  factory MoneroWalletTransaction.deserialize(WalletMoneroNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: NetworkType.monero.tag);
    return MoneroWalletTransaction(
      txId: values.elementAs(0),
      time: values.elementAs(1),
      network: network,
      totalOutput: values.elemetMybeAs<WalletTransactionAmount, CborTagValue>(
          2, (e) => WalletTransactionAmount.deserialize(network, object: e)),
      outputs: values
          .elementAsListOf<CborTagValue>(3)
          .map((e) =>
              MoneroWalletTransactionOutput.deserialize(network, object: e))
          .toList(),
      type: WalletTransactionType.fromValue(values.elementAs(5)),
      status: WalletTransactionStatus.fromValue(values.elementAs(6)),
      txKeys: values
          .elementAsListOf<CborBytesValue>(7)
          .map((e) => e.value)
          .toList(),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          txId,
          time,
          totalOutput?.toCbor(),
          CborListValue.fixedLength(outputs.map((e) => e.toCbor()).toList()),
          web3Client?.toCbor(),
          type.value,
          status.value,
          CborListValue.fixedLength(
              txKeys.map((e) => CborBytesValue(e)).toList()),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.monero;

  MoneroWalletTransactionProof generateProofRequest(
      MoneroWalletTransactionOutput output) {
    return MoneroWalletTransactionProof(
        txKeys: txKeys, output: output, txId: txId);
  }
}

class MoneroWalletTransactionOutput
    extends WalletTransactionTransferOutput<MoneroAddress> {
  MoneroWalletTransactionOutput({required super.amount, required super.to});

  @override
  String get address => to.address;

  factory MoneroWalletTransactionOutput.deserialize(WalletMoneroNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: CborTagsConst.moneroWalletTransactionOutput);
    return MoneroWalletTransactionOutput(
      amount: WalletTransactionIntegerAmount.deserialize(network,
          object: values.getCborTag(0)),
      to: MoneroAddress(values.elementAs(1)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([amount.toCbor(), to.address]),
        CborTagsConst.moneroWalletTransactionOutput);
  }
}
