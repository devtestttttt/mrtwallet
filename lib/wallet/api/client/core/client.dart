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
  abstract final BaseServiceProtocol<P> service;

  NetworkType get networkType;
  ProviderIdentifier get serviceIdentifier => DefaultProviderIdentifier(
      identifier: service.provider.identifier, network: networkType);

  // NodeClientStatus _status = NodeClientStatus.disconnect;
  // NodeClientStatus get status => _status;

  // bool get isConnect => _status.isConnect;

  Future<bool> onInit();

  // final _lock = SynchronizedLock();

  Future<bool> _init({ONCLIENTSTATUS? onStatusChanged}) async {
    // if (_status.isConnect) return true;
    // _status = NodeClientStatus.pending;
    // onStatusChanged?.call(_status);
    final init = await MethodUtils.call(() async => await onInit());
    // if (init.hasResult && init.result) {
    //   _status = NodeClientStatus.connect;
    // } else {
    //   _status = NodeClientStatus.disconnect;
    // }
    // onStatusChanged?.call(_status);
    return init.hasResult && init.result;
  }

  Future<bool> init({ONCLIENTSTATUS? onStatusChanged}) async {
    // if (_status.isConnect) return true;
    return await _init(onStatusChanged: onStatusChanged);
  }

  Future<WalletTransactionStatus> transactionStatus({required String txId}) =>
      throw UnimplementedError();

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
    final StreamController<T> controller = StreamController(onCancel: () {
      timer?.cancel();
      timer = null;
    });
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
        controller.add(tx);
      }
    }

    Future<bool> fetchTxStatus() async {
      List<T> unconfirmedTx =
          transactions.where((e) => e.status.inMempool).toList();
      if (unconfirmedTx.isEmpty) {
        controller.close();
        return true;
      }
      await run(unconfirmedTx);
      if (transactions.every((e) => !e.status.inMempool)) {
        controller.close();
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

    return controller.stream;
  }

  void dispose() {
    service.disposeService();
  }

  @override
  String toString() {
    return "Client: ${network?.token.name}";
  }
}
