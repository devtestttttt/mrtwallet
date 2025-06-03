import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateWalletTransaction extends ChainTransaction {
  final int block;
  final String extrinsics;
  SubstrateWalletTransaction(
      {required super.txId,
      required this.block,
      required this.extrinsics,
      DateTime? time,
      super.outputs = const [],
      super.web3Client,
      super.totalOutput,
      required WalletSubstrateNetwork network,
      super.type = WalletTransactionType.send,
      super.status = WalletTransactionStatus.pending})
      : super(time: time ?? DateTime.now());

  factory SubstrateWalletTransaction.deserialize(WalletSubstrateNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: NetworkType.substrate.tag);
    return SubstrateWalletTransaction(
        txId: values.elementAs(0),
        time: values.elementAs(1),
        network: network,
        totalOutput: values.elemetMybeAs<WalletTransactionAmount, CborTagValue>(
            2, (e) => WalletTransactionAmount.deserialize(network, object: e)),
        outputs: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => SubstrateWalletTransactionOutput.deserialize(network,
                object: e))
            .toList(),
        web3Client:
            values.elemetMybeAs<WalletWeb3ClientTransaction, CborTagValue>(
                4, (e) => WalletWeb3ClientTransaction.deserialize(object: e)),
        type: WalletTransactionType.fromValue(values.elementAs(5)),
        status: WalletTransactionStatus.fromValue(values.elementAs(6)),
        block: values.elementAs(7),
        extrinsics: values.elementAs(8));
  }

  @override
  NetworkType get network => NetworkType.substrate;

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
          block,
          extrinsics
        ]),
        network.tag);
  }
}

abstract class SubstrateWalletTransactionOutput
    extends WalletTransactionOutput {
  const SubstrateWalletTransactionOutput({required super.type});
  factory SubstrateWalletTransactionOutput.deserialize(
      WalletSubstrateNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: cborHex, object: object);
    final type = WalletTransactionOutputType.fromTag(tag.tags);
    return switch (type) {
      WalletTransactionOutputType.transfer =>
        SubstrateWalletTransactionTransferOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      WalletTransactionOutputType.operation =>
        SubstrateWalletTransactionOperationOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      _ => throw WalletExceptionConst.invalidData(
          messsage: 'invalid bitcoin tx output')
    };
  }
}

class SubstrateWalletTransactionTransferOutput
    extends WalletTransactionTransferOutput<BaseSubstrateAddress>
    implements SubstrateWalletTransactionOutput {
  const SubstrateWalletTransactionTransferOutput(
      {required super.to, required super.amount});

  factory SubstrateWalletTransactionTransferOutput.deserialize(
      WalletSubstrateNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.transfer.tag);
    return SubstrateWalletTransactionTransferOutput(
        amount: WalletTransactionIntegerAmount.deserialize(network,
            object: values.elementAs<CborTagValue>(0)),
        to: BaseSubstrateAddress(values.elementAs(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([amount.toCbor(), to.address]), type.tag);
  }

  @override
  String get address => to.address;
}

class SubstrateWalletTransactionOperationOutput
    extends WalletTransactionOperationOutput
    implements SubstrateWalletTransactionOutput {
  const SubstrateWalletTransactionOperationOutput(
      {required super.name, super.amount, super.content});

  factory SubstrateWalletTransactionOperationOutput.deserialize(
      WalletSubstrateNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.operation.tag);
    return SubstrateWalletTransactionOperationOutput(
        name: values.elementAs(0),
        amount:
            values.elemetMybeAs<WalletTransactionIntegerAmount, CborTagValue>(
                1,
                (e) => WalletTransactionIntegerAmount.deserialize(network,
                    object: e)),
        content: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([name, amount?.toCbor(), content]), type.tag);
  }
}
