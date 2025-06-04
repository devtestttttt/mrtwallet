import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

final class WalletRequestMoneroOutputUnlocker
    extends WalletRequest<MoneroBatchProcessTxesResponse, MessageArgsOneBytes> {
  final MoneroAPIProvider provider;

  final List<MoneroAccountPendingTxes> requests;

  WalletRequestMoneroOutputUnlocker._(
      {required this.requests, required this.provider});

  factory WalletRequestMoneroOutputUnlocker(
      {required List<MoneroAccountPendingTxes> requests,
      required MoneroAPIProvider provider}) {
    return WalletRequestMoneroOutputUnlocker._(
        requests: requests.immutable, provider: provider);
  }
  factory WalletRequestMoneroOutputUnlocker.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.moneroOutputUnlocker.tag);
    return WalletRequestMoneroOutputUnlocker(
        requests: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroAccountPendingTxes.deserialize(obj: e))
            .toList(),
        provider:
            MoneroAPIProvider.fromCborBytesOrObject(obj: values.getCborTag(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(requests.map((e) => e.toCbor()).toList()),
          provider.toCbor(),
        ]),
        method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.moneroOutputUnlocker;

  @override
  Future<MessageArgsOneBytes> getResult(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    final response = await result(wallet: wallet, key: key);
    return MessageArgsOneBytes(keyOne: response.toCbor().encode());
  }

  @override
  Future<MoneroBatchProcessTxesResponse> result(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    final client = APIUtils.buildMoneroClient(
        provider: provider, network: null, isolate: APPIsolate.current);
    final txids =
        requests.expand((e) => e.indexes.expand((e) => e.txes)).toList();
    final txInfos = await client.getTxes(txIds: txids);
    final List<MoneroPrivateKeyData> keys = wallet
        .readKeys(requests
            .map((e) => AccessCryptoPrivateKeyRequest(index: e.accountIndex))
            .toList())
        .keys
        .cast<MoneroPrivateKeyData>();
    final accounts = List.generate(keys.length, (i) {
      final key = keys[i];
      return MoneroAccountKeys(
          account: key.toMoneroAccount(),
          network: MoneroNetwork.mainnet,
          indexes: requests[i].indexes.map((e) => e.index).toList());
    });
    final unlockedTx = List.generate(
        requests.length,
        (i) => unlockOuts(
            txes: txInfos, account: accounts[i], accountTx: requests[i]));
    final response = MoneroBatchProcessTxesResponse(unlockedTx);
    return response;
  }

  MoneroAccountPendingTxes unlockOuts(
      {required List<TxResponse> txes,
      required MoneroAccountKeys account,
      required MoneroAccountPendingTxes accountTx}) {
    final List<MoneroUnlockedPaymentRequestDetails> payments = [];
    for (final index in accountTx.indexes) {
      for (final txId in index.txes) {
        final txResponse = txes.firstWhereOrNull(
            (e) => StringUtils.strip0x(e.txHash.toLowerCase()) == txId);
        final tx = MethodUtils.nullOnException(() => txResponse?.toTx());
        if (txResponse == null || tx == null) {
          continue;
        }
        for (int i = 0; i < tx.vout.length; i++) {
          final getOut = MoneroTransactionHelper.getUnlockOut(
              tx: tx, account: account, realIndex: i);
          if (getOut == null) {
            continue;
          }
          final address = account.indexAddress(getOut.accountIndex);
          BigInt? globalIndex;
          if (tx.vout.length == txResponse.outoutIndices.length) {
            globalIndex = txResponse.outoutIndices[getOut.realIndex];
          }
          payments.add(MoneroUnlockedPaymentRequestDetails.fromUnlockOutput(
              output: getOut,
              txId: txId,
              address: address,
              comfirmation: txResponse.confirmations,
              globalIndex: globalIndex,
              index: index.index));
        }
      }
    }
    return accountTx.toResponse(payments);
  }

  @override
  Future<MoneroBatchProcessTxesResponse> parsResult(
      MessageArgsOneBytes result) async {
    return MoneroBatchProcessTxesResponse.deserialize(bytes: result.keyOne);
  }
}
