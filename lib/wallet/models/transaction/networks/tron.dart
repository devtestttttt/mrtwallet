import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain/on_chain.dart';

class TronWalletTransaction extends ChainTransaction {
  TronWalletTransaction(
      {required super.txId,
      DateTime? time,
      super.outputs = const [],
      super.web3Client,
      super.totalOutput,
      required WalletTronNetwork network,
      super.type = WalletTransactionType.send,
      super.status = WalletTransactionStatus.pending})
      : super(time: time ?? DateTime.now());

  factory TronWalletTransaction.deserialize(WalletTronNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: NetworkType.tron.tag);
    return TronWalletTransaction(
        txId: values.elementAs(0),
        time: values.elementAs(1),
        network: network,
        totalOutput: values.elemetMybeAs<WalletTransactionAmount, CborTagValue>(
            2, (e) => WalletTransactionAmount.deserialize(network, object: e)),
        outputs: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) =>
                TronWalletTransactionOutput.deserialize(network, object: e))
            .toList(),
        web3Client:
            values.elemetMybeAs<WalletWeb3ClientTransaction, CborTagValue>(
                4, (e) => WalletWeb3ClientTransaction.deserialize(object: e)),
        type: WalletTransactionType.fromValue(values.elementAs(5)),
        status: WalletTransactionStatus.fromValue(values.elementAs(6)));
  }

  @override
  NetworkType get network => NetworkType.tron;
}

abstract class TronWalletTransactionOutput extends WalletTransactionOutput {
  const TronWalletTransactionOutput({required super.type});
  factory TronWalletTransactionOutput.deserialize(WalletTronNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: cborHex, object: object);
    final type = WalletTransactionOutputType.fromTag(tag.tags);
    return switch (type) {
      WalletTransactionOutputType.transfer =>
        TronWalletTransactionTransferOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      WalletTransactionOutputType.operation =>
        TronWalletTransactionOperationOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      _ => throw WalletExceptionConst.invalidData(
          messsage: 'invalid tron tx output')
    };
  }
}

class TronWalletTransactionTransferOutput
    extends WalletTransactionTransferOutput<TronAddress>
    implements TronWalletTransactionOutput {
  const TronWalletTransactionTransferOutput(
      {required super.to, required super.amount});

  factory TronWalletTransactionTransferOutput.deserialize(
      WalletTronNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.transfer.tag);
    return TronWalletTransactionTransferOutput(
        amount: WalletTransactionIntegerAmount.deserialize(network,
            object: values.elementAs<CborTagValue>(0)),
        to: TronAddress(values.elementAs(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([amount.toCbor(), to.toAddress()]), type.tag);
  }

  @override
  String get address => to.toAddress();
}

class TronWalletTransactionOperationOutput
    extends WalletTransactionOperationOutput
    implements TronWalletTransactionOutput {
  const TronWalletTransactionOperationOutput(
      {required super.name, super.amount, super.content});

  factory TronWalletTransactionOperationOutput.deserialize(
      WalletTronNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.operation.tag);
    return TronWalletTransactionOperationOutput(
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
