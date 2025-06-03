import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';

class CosmosWalletTransaction extends ChainTransaction {
  CosmosWalletTransaction(
      {required super.txId,
      required super.time,
      required super.outputs,
      super.web3Client,
      required super.totalOutput,
      required WalletCosmosNetwork network,
      super.type = WalletTransactionType.send,
      super.status = WalletTransactionStatus.block})
      : super();

  factory CosmosWalletTransaction.deserialize(WalletCosmosNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: NetworkType.cosmos.tag);
    return CosmosWalletTransaction(
        txId: values.elementAs(0),
        time: values.elementAs(1),
        network: network,
        totalOutput: values.elemetMybeAs<WalletTransactionAmount, CborTagValue>(
            2, (e) => WalletTransactionAmount.deserialize(network, object: e)),
        outputs: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => CosmosWalletTransactionTransferOutput.deserialize(
                network,
                object: e))
            .toList(),
        web3Client:
            values.elemetMybeAs<WalletWeb3ClientTransaction, CborTagValue>(
                4, (e) => WalletWeb3ClientTransaction.deserialize(object: e)),
        type: WalletTransactionType.fromValue(values.elementAs(5)),
        status: WalletTransactionStatus.fromValue(values.elementAs(6)));
  }

  @override
  NetworkType get network => NetworkType.cosmos;
}

class CosmosWalletTransactionTransferOutput
    extends WalletTransactionTransferOutput<CosmosBaseAddress> {
  const CosmosWalletTransactionTransferOutput(
      {required super.to, required super.amount});

  factory CosmosWalletTransactionTransferOutput.deserialize(
      WalletCosmosNetwork network,
      {List<int>? bytes,
      String? cborHex,
      CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionOutputType.transfer.tag);
    return CosmosWalletTransactionTransferOutput(
        amount: WalletTransactionIntegerAmount.deserialize(network,
            object: values.elementAs<CborTagValue>(0)),
        to: CosmosBaseAddress(values.elementAs(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([amount.toCbor(), to.address]), type.tag);
  }

  @override
  String get address => to.address;
}
