import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarWalletTransaction extends ChainTransaction {
  StellarWalletTransaction(
      {required super.txId,
      DateTime? time,
      super.outputs = const [],
      super.web3Client,
      super.totalOutput,
      required WalletStellarNetwork network,
      super.type = WalletTransactionType.send,
      super.status = WalletTransactionStatus.pending})
      : super(time: time ?? DateTime.now());

  factory StellarWalletTransaction.deserialize(WalletStellarNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: NetworkType.stellar.tag);
    return StellarWalletTransaction(
        txId: values.elementAs(0),
        time: values.elementAs(1),
        network: network,
        totalOutput: values.elemetMybeAs<WalletTransactionAmount, CborTagValue>(
            2, (e) => WalletTransactionAmount.deserialize(network, object: e)),
        outputs: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) =>
                StellarWalletTransactionOutput.deserialize(network, object: e))
            .toList(),
        web3Client:
            values.elemetMybeAs<WalletWeb3ClientTransaction, CborTagValue>(
                4, (e) => WalletWeb3ClientTransaction.deserialize(object: e)),
        type: WalletTransactionType.fromValue(values.elementAs(5)),
        status: WalletTransactionStatus.fromValue(values.elementAs(6)));
  }

  @override
  NetworkType get network => NetworkType.stellar;
}

abstract class StellarWalletTransactionOutput extends WalletTransactionOutput {
  const StellarWalletTransactionOutput({required super.type});
  factory StellarWalletTransactionOutput.deserialize(
      WalletStellarNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: cborHex, object: object);
    final type = WalletTransactionOutputType.fromTag(tag.tags);
    return switch (type) {
      WalletTransactionOutputType.transfer =>
        StellarWalletTransactionTransferOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      WalletTransactionOutputType.operation =>
        StellarWalletTransactionOperationOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      _ => throw WalletExceptionConst.invalidData(
          messsage: 'invalid bitcoin tx output')
    };
  }
}

class StellarWalletTransactionTransferOutput
    extends WalletTransactionTransferOutput<StellarAddress>
    implements StellarWalletTransactionOutput {
  const StellarWalletTransactionTransferOutput(
      {required super.to, required super.amount});

  factory StellarWalletTransactionTransferOutput.deserialize(
      WalletStellarNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.transfer.tag);
    return StellarWalletTransactionTransferOutput(
        amount: WalletTransactionIntegerAmount.deserialize(network,
            object: values.elementAs<CborTagValue>(0)),
        to: StellarAddress.fromBase32Addr(values.elementAs(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([amount.toCbor(), to.baseAddress]), type.tag);
  }

  @override
  String get address => to.baseAddress;
}

class StellarWalletTransactionOperationOutput
    extends WalletTransactionOperationOutput
    implements StellarWalletTransactionOutput {
  const StellarWalletTransactionOperationOutput(
      {required super.name, super.amount, super.content});

  factory StellarWalletTransactionOperationOutput.deserialize(
      WalletStellarNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.operation.tag);
    return StellarWalletTransactionOperationOutput(
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
