import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

final class NoneEncryptedRequestMoneroGenerateTxProof
    extends NoneEncryptedCryptoRequest<String, MessageArgsOneBytes> {
  final String txId;
  final MoneroAPIProvider provider;
  final String? message;
  final List<List<int>>? txKeys;
  final MoneroAddress? receiverAddress;
  NoneEncryptedRequestMoneroGenerateTxProof(
      {required this.txId,
      required this.provider,
      required this.message,
      this.txKeys,
      this.receiverAddress});
  factory NoneEncryptedRequestMoneroGenerateTxProof.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.moneroGenerateProof.tag);

    return NoneEncryptedRequestMoneroGenerateTxProof(
        txId: values.elementAs(0),
        provider:
            MoneroAPIProvider.fromCborBytesOrObject(obj: values.getCborTag(1)),
        message: values.elementAs(2),
        txKeys: values
            .elementAsListOf<CborBytesValue>(3, emyptyOnNull: true)
            .map((e) => e.value)
            .toList()
            .emptyAsNull,
        receiverAddress: values.elemetMybeAs<MoneroAddress, CborStringValue>(
            4, (e) => MoneroAddress(e.value)));
  }

  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    final result = await this.result(encryptedPart: encryptedPart);
    return MessageArgsOneBytes(keyOne: StringUtils.encode(result));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return StringUtils.decode(result.keyOne);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          txId,
          provider.toCbor(),
          message,
          CborListValue.fixedLength(
              txKeys?.map((e) => CborBytesValue(e)).toList() ?? []),
          receiverAddress?.address
        ]),
        method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.moneroGenerateProof;

  @override
  Future<String> result({List<int>? encryptedPart}) async {
    final account = MoneroViewAccountDetails.deserialize(bytes: encryptedPart);
    final client = APIUtils.buildMoneroClient(
        provider: provider, network: null, isolate: APPIsolate.current);
    final MoneroTransaction transaction = await client.getTx(txId);
    final txKeys = this.txKeys;
    final receiver = receiverAddress;
    if (txKeys != null && txKeys.isNotEmpty && receiver != null) {
      final proof = MoneroTransactionHelper.generateOutProofVar(
          transaction: transaction,
          receiverAddress: receiver,
          allTxKeys: txKeys.map((e) => MoneroPrivateKey.fromBytes(e)).toList(),
          message: message);
      return proof.toBase58();
    }
    final proof = MoneroTransactionHelper.generateInProofVar(
        transaction: transaction,
        account: account.viewKey.account,
        index: account.index,
        message: message);
    return proof.toBase58();
  }
}
