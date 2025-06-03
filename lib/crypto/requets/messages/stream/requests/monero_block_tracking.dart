import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/models/networks/monero/models/account_related.dart';

final class StreamRequestMoneroBlockTracking extends IsolateStreamRequest<
    MoneroSyncBlocksResponse, MoneroDefaultBlockTrackingInfo> {
  StreamRequestMoneroBlockTracking({required this.provider})
      : client = APIUtils.buildMoneroClient(
            provider: provider, network: null, isolate: APPIsolate.current);
  final MoneroAPIProvider provider;
  final MoneroClient client;
  factory StreamRequestMoneroBlockTracking.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: StreamIsolateMethod.moneroAccountTracker.tag);
    return StreamRequestMoneroBlockTracking(
        provider:
            MoneroAPIProvider.fromCborBytesOrObject(obj: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([provider.toCbor()]), method.tag);
  }

  MoneroSyncBlocksResponse _proccessBlock(
      {required _FetchedBlocks blocks,
      required MoneroSyncAccountsRequestInfos accounts,
      required MoneroDefaultBlockTrackingInfo offset,
      required int total,
      required int startHeight}) {
    try {
      final viewAccounts = accounts.accounts;
      final accountsKeys = viewAccounts.map((e) => e.getAccountKeys()).toList();
      final start = startHeight - blocks.startHeight;
      final end = start + total;
      for (int i = start; i < end; i++) {
        final block = blocks.blocks[i];
        MoneroBlock? moneroBlock;
        for (int t = 0; t < block.txs.length; t++) {
          MoneroTransaction tx;
          try {
            tx = block.txs[t].toTx();
          } catch (_) {
            assert(false, "should not be faild.");
            continue;
          }
          for (int realIndex = 0; realIndex < tx.vout.length; realIndex++) {
            for (int a = 0; a < accountsKeys.length; a++) {
              final account = accountsKeys[a];
              final unlock = MoneroTransactionHelper.getLockedOutputs(
                  realIndex: realIndex, tx: tx, account: account);
              if (unlock != null) {
                moneroBlock ??= block.toBlock();
                final txid = BytesUtils.toHexString(moneroBlock.txHashes[t]);
                accounts.addPendingTx(viewAccounts[a], txid);
              }
            }
          }
        }
      }

      return MoneroSyncAccountResponse(
        txIds: accounts.accounts,
        currentHeight: startHeight,
        total: total,
        offset: offset,
      );
    } catch (e, _) {
      assert(false, "parsing blocks failed. $e");
      return MoneroSyncFailedResponse(
          currentHeight: startHeight, total: total, offset: offset);
    }
  }

  Stream<MoneroSyncBlocksResponse> processBlocksStream({
    required MoneroDefaultBlockTrackingInfo offset,
    required MoneroSyncAccountsRequestInfos accounts,
    required bool Function() isCancelled,
  }) async* {
    int startBlock = offset.currentHeight;
    while (startBlock < offset.endHeight) {
      final blocks = await _fetchBlocks(startBlock, offset.endHeight);
      MoneroSyncBlocksResponse result;
      if (blocks == null) {
        result = MoneroSyncFailedResponse(
            currentHeight: startBlock,
            total: IntUtils.max(offset.endHeight, startBlock + 5),
            offset: offset);
      } else {
        result = _proccessBlock(
            blocks: blocks.$1,
            accounts: accounts,
            startHeight: startBlock,
            total: blocks.$2,
            offset: offset);
      }

      startBlock += result.total;
      yield result;
    }
  }

  @override
  StreamIsolateMethod get method => StreamIsolateMethod.moneroAccountTracker;
  _FetchedBlocks? _blocks;
  Future<(_FetchedBlocks, int)?> _fetchBlocks(
      int startHeight, int maxHeight) async {
    final remainBlocks = _blocks?.remainBlock(startHeight);
    if (remainBlocks != null) return (_blocks!, remainBlocks);
    int tryFetchBlock = 1;
    while (true) {
      final blockData = await MethodUtils.call(
          () => client.getBlocksByRangeBinary(startHeight),
          waitAtError: APPConst.oneSecoundDuration * tryFetchBlock);
      if (blockData.hasError) {
        if (tryFetchBlock < 3) {
          tryFetchBlock++;
        }
        continue;
      }
      try {
        final json = MoneroStorageSerializer.deserialize(blockData.result);
        final b = DaemonBaseResponse.fromJson(json);
        if (!b.isOk) return null;
        final blocks = DaemonGetBlockBinResponse.fromJson(json).blocks;
        int endHeight = startHeight + blocks.length;
        if (endHeight > maxHeight) {
          endHeight = maxHeight;
        }
        final bl = _FetchedBlocks(
            blocks: blocks, startHeight: startHeight, endHeight: endHeight);
        final remailBlock = bl.remainBlock(startHeight);
        _blocks = bl;
        return (bl, remailBlock!);
      } catch (e) {
        return null;
      }
    }
  }

  void _sendResult(
      {required EventSink<MessageArgsStreamResponse> sink,
      required MessageArgsStreamResponse data}) {
    if (closed) return;
    sink.add(data);
  }

  StreamSubscription<MoneroSyncBlocksResponse>? subscription;

  @override
  void handleIsolateData(
      {required MoneroDefaultBlockTrackingInfo param,
      required EventSink<MessageArgsStreamResponse> sink,
      required String streamId,
      List<int>? encryptedPart}) async {
    final accounts =
        MoneroSyncAccountsRequestInfos.deserialize(bytes: encryptedPart);
    subscription?.cancel();
    subscription = null;
    subscription = processBlocksStream(
      offset: param,
      accounts: accounts,
      isCancelled: () => closed,
    ).listen((result) {
      _sendResult(
          data: MessageArgsStreamResponse(
            data: result.toCbor().encode(),
            streamId: streamId,
          ),
          sink: sink);
    }, onDone: () {});
  }

  @override
  void add(MessageArgsStream args) {
    super.add(args);
    switch (args.method) {
      case MessageArgsStreamMethod.data:
        streamController
            ?.add(MoneroDefaultBlockTrackingInfo.deserialize(bytes: args.data));
        break;
      default:
    }
  }

  @override
  MoneroSyncBlocksResponse parsResult(MessageArgsStreamResponse result) {
    return MoneroSyncBlocksResponse.deserialize(bytes: result.data!);
  }

  @override
  MessageArgsStream toRequest(
      {required MoneroDefaultBlockTrackingInfo message,
      required String streamId}) {
    return MessageArgsStream(
        data: message.toCbor().encode(), streamId: streamId);
  }

  @override
  void handleData(
      {required MoneroDefaultBlockTrackingInfo param,
      required EventSink<MoneroSyncBlocksResponse> sink,
      required String streamId,
      List<int>? encryptedPart}) {}

  @override
  void close() {
    super.close();
    subscription?.cancel();
    subscription = null;
  }
}

class _FetchedBlocks {
  final List<DaemonBlockCompleteEntryResponse> blocks;
  final int startHeight;
  final int endHeight;
  // final MoneroBlocksInfoResponse status;
  _FetchedBlocks(
      {required this.blocks,
      required this.startHeight,
      required this.endHeight});
  int? remainBlock(int height) {
    assert(height >= startHeight, "invalid height");
    if (height >= endHeight) return null;
    final remain = endHeight - height;
    if (remain >= 25) return 25;
    return remain;
    // return
  }

  @override
  String toString() {
    return {"startHeight": startHeight, "endHeight": endHeight}.toString();
  }
}
