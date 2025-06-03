import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';

class BitcoinWalletTransaction extends ChainTransaction {
  final String scriptHash;
  BitcoinWalletTransaction(
      {required super.txId,
      required super.time,
      required super.outputs,
      super.web3Client,
      required super.totalOutput,
      required WalletBitcoinNetwork network,
      required this.scriptHash,
      super.type = WalletTransactionType.send,
      super.status = WalletTransactionStatus.pending})
      : super();

  factory BitcoinWalletTransaction.deserialize(WalletBitcoinNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: NetworkType.bitcoinAndForked.tag);
    return BitcoinWalletTransaction(
        txId: values.elementAs(0),
        time: values.elementAs(1),
        network: network,
        totalOutput: values.elemetMybeAs<WalletTransactionAmount, CborTagValue>(
            2, (e) => WalletTransactionAmount.deserialize(network, object: e)),
        outputs: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) =>
                BitcoinWalletTransactionOutput.deserialize(network, object: e))
            .toList(),
        web3Client:
            values.elemetMybeAs<WalletWeb3ClientTransaction, CborTagValue>(
                4, (e) => WalletWeb3ClientTransaction.deserialize(object: e)),
        type: WalletTransactionType.fromValue(values.elementAs(5)),
        status: WalletTransactionStatus.fromValue(values.elementAs(6)),
        scriptHash: values.elementAs(7));
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
          scriptHash
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.bitcoinAndForked;
}

abstract class BitcoinWalletTransactionOutput extends WalletTransactionOutput {
  const BitcoinWalletTransactionOutput({required super.type});
  factory BitcoinWalletTransactionOutput.deserialize(
      WalletBitcoinNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: cborHex, object: object);
    final type = WalletTransactionOutputType.fromTag(tag.tags);
    return switch (type) {
      WalletTransactionOutputType.transfer =>
        BitcoinWalletTransactionTransferOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      WalletTransactionOutputType.operation =>
        BitcoinWalletTransactionScriptOutput.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      _ => throw WalletExceptionConst.invalidData(
          messsage: 'invalid bitcoin tx output')
    };
  }
}

class BitcoinWalletTransactionScriptOutput
    extends WalletTransactionOperationOutput
    implements BitcoinWalletTransactionOutput {
  BitcoinWalletTransactionScriptOutput({
    required super.name,
    required super.content,
    required BigInt? value,
    required WalletBitcoinNetwork network,
  }) : super(
            amount: value == null || value == BigInt.zero
                ? null
                : WalletTransactionIntegerAmount(
                    amount: value, network: network));

  factory BitcoinWalletTransactionScriptOutput.deserialize(
      WalletBitcoinNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.operation.tag);
    return BitcoinWalletTransactionScriptOutput(
        name: values.elementAs(0),
        content: values.elementAs(1),
        value: values.elementAs(2),
        network: network);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([name, content, amount?.amount.balance]),
        type.tag);
  }
}

class BitcoinWalletTransactionTransferOutput
    extends WalletTransactionTransferOutput<BitcoinNetworkAddress>
    implements BitcoinWalletTransactionOutput {
  BitcoinWalletTransactionTransferOutput(
      {required super.amount, required super.to});

  @override
  String get address => to.address;

  factory BitcoinWalletTransactionTransferOutput.deserialize(
      WalletBitcoinNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.transfer.tag);
    return BitcoinWalletTransactionTransferOutput(
        amount: WalletTransactionIntegerAmount.deserialize(network,
            object: values.getCborTag(0)),
        to: BitcoinNetworkAddress.parse(
            address: values.elementAs(1),
            network: network.coinParam.transacationNetwork));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([amount.toCbor(), to.address]), type.tag);
  }
}
