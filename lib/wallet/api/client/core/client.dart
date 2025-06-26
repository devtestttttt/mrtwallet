import 'dart:async';
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';

enum NodeClientStatus {
  connect,
  disconnect,
  pending;

  bool get isConnect => this == NodeClientStatus.connect;
  bool get isPending => this == NodeClientStatus.pending;
  bool get isDisconnect => this == NodeClientStatus.disconnect;
}

typedef ONCLIENTSTATUS = void Function(NodeClientStatus status);

abstract class NetworkClient<TRANSACTION extends ChainTransaction,
    P extends APIProvider> {
  NetworkClient();
  abstract final WalletNetwork? network;
  abstract final NetworkServiceProtocol<P> service;
  NetworkType get networkType;
  ProviderIdentifier get serviceIdentifier => DefaultProviderIdentifier(
      identifier: service.provider.identifier, network: networkType);
  Future<bool> onInit();
  Future<bool> init({ONCLIENTSTATUS? onStatusChanged}) async {
    final init = await MethodUtils.call(() async => await onInit());
    return init.hasResult && init.result;
  }

  Future<WalletTransactionStatus> transactionStatus({required String txId});

  Stream<T> trackMempoolTransaction<T extends TRANSACTION>(
      List<T> transactions) {
    Future<WalletTransactionStatus> getTxStatus(TRANSACTION transaction) async {
      try {
        return await transactionStatus(txId: transaction.txId);
      } catch (e) {
        return WalletTransactionStatus.unknown;
      }
    }

    final maxBlockIntervalSec = network?.coinParam.averageBlockTime ?? 60;
    final maxTxConfirmationBlock =
        network?.coinParam.maxTxConfirmationBlock ?? 20;
    final totalSec = maxBlockIntervalSec * maxTxConfirmationBlock;

    Timer? timer;
    StreamController<T>? controller = StreamController();
    Future<void> run(List<T> unconfirmedTx) async {
      final future = unconfirmedTx.map((e) => getTxStatus(e));
      final result = await future.wait;
      for (int i = 0; i < result.length; i++) {
        final tx = unconfirmedTx[i];
        final r = result[i];
        if (r.isUnknown) {
          final end = tx.time.add(Duration(seconds: totalSec));
          final now = DateTime.now();
          if (end.isAfter(now)) continue;
        }
        tx.updateStatus(result[i]);
        controller?.add(tx);
      }
    }

    void close() {
      controller?.close();
      controller = null;
      timer?.cancel();
      timer = null;
    }

    Future<bool> fetchTxStatus() async {
      List<T> unconfirmedTx =
          transactions.where((e) => e.status.inMempool).toList();
      if (unconfirmedTx.isEmpty) {
        close();
        return true;
      }
      await run(unconfirmedTx);
      if (transactions.every((e) => !e.status.inMempool)) {
        close();
        return true;
      }
      return false;
    }

    Future<void> runTimer() async {
      final complete = await fetchTxStatus();
      if (complete) return;
      timer = Timer.periodic(Duration(seconds: maxBlockIntervalSec), (e) {
        fetchTxStatus();
      });
    }

    runTimer();

    return controller!.stream;
  }

  void dispose() {
    service.disposeService();
  }

  @override
  String toString() {
    return "Client: ${network?.token.name ?? runtimeType}";
  }
}
