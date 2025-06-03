import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/isolate/types/types.dart';
import 'package:on_chain_wallet/crypto/worker.dart';
import 'package:on_chain_wallet/wallet/constant/networks/monero.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network.dart';
import 'package:on_chain_wallet/wallet/models/others/models/receipt_address.dart';

enum MoneroBlockTrackingStatus {
  complete(2),
  pending(3);

  final int value;
  const MoneroBlockTrackingStatus(this.value);
  static MoneroBlockTrackingStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isComplete => this == complete;
  bool get isPending => this == pending;
}

enum MoneroParsingBlockStatus {
  failed(1),
  noBlock(2),
  success(3);

  final int value;
  const MoneroParsingBlockStatus(this.value);
  static MoneroParsingBlockStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isFailed => this == failed;
}

class MoneroBlockTrackingFailed with CborSerializable, Equatable {
  final int startHeight;
  int _endHeight;
  int get endHeight => _endHeight;

  void _updateHeight(int height) {
    assert(height > _endHeight, "invalid failed height");
    if (height > _endHeight) return;
    _endHeight = height;
  }

  MoneroBlockTrackingFailed._(
      {required this.startHeight, required int endHeight})
      : _endHeight = endHeight;
  factory MoneroBlockTrackingFailed(
      {required int startHeight, required int endHeight}) {
    if (startHeight.isNegative || startHeight > endHeight) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return MoneroBlockTrackingFailed._(
        startHeight: startHeight, endHeight: endHeight);
  }
  factory MoneroBlockTrackingFailed.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroChainFailedOffsets);
    return MoneroBlockTrackingFailed(
        startHeight: values.elementAs(0), endHeight: values.elementAs(1));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([startHeight, _endHeight]),
        CborTagsConst.moneroChainFailedOffsets);
  }

  @override
  String toString() {
    return {'start': startHeight, 'end': _endHeight}.toString();
  }

  @override
  List get variabels => [startHeight, _endHeight];
}

enum MoneroBlockTrackerType {
  defaultTracker(CborTagsConst.moneroChainTrackedOffsets),
  request(CborTagsConst.moneroRequestBlockTrackingInfo);

  final List<int> tag;
  const MoneroBlockTrackerType(this.tag);
  static MoneroBlockTrackerType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isDefaultTracker => this == defaultTracker;
}

abstract class MoneroBlockTrackingInfo with CborSerializable, Equatable {
  final MoneroBlockTrackerType type;
  const MoneroBlockTrackingInfo._({required this.type});

  factory MoneroBlockTrackingInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: cbor, hex: hex);
    final type = MoneroBlockTrackerType.fromTag(tag.tags);
    return switch (type) {
      MoneroBlockTrackerType.defaultTracker =>
        MoneroDefaultBlockTrackingInfo.deserialize(cbor: tag),
      MoneroBlockTrackerType.request =>
        MoneroRequestBlockTrackingInfo.deserialize(cbor: tag),
    };
  }
  T cast<T extends MoneroBlockTrackingInfo>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", "$runtimeType"]);
    }
    return this as T;
  }
}

class MoneroDefaultBlockTrackingInfo extends MoneroBlockTrackingInfo {
  final int startHeight;
  final int endHeight;
  final int? requestId;
  MoneroBlockTrackingStatus _status;
  MoneroBlockTrackingStatus get status => _status;
  int _currentHeight;
  int get currentHeight => _currentHeight;
  List<MoneroBlockTrackingFailed> _failed;
  void _update(MoneroSyncBlocksResponse response) {
    assert(_status.isPending, "invalid tracker status");
    assert(
        response.currentHeight >= startHeight &&
            response.currentHeight <= endHeight,
        "invalid resposnse");
    assert(_currentHeight == response.currentHeight, "invalid start height");
    final total = response.currentHeight + response.total;
    assert(total <= endHeight, "invalid response $total $endHeight");
    _currentHeight += response.total;
    assert(_currentHeight <= endHeight, "invalid possition");
    if (_currentHeight == endHeight) {
      _status = MoneroBlockTrackingStatus.complete;
    }
    if (response.type == MoneroSyncBlockResponseType.failed) {
      final lastFailedIndex = _failed
          .firstWhereOrNull((e) => e._endHeight == response.currentHeight);
      if (lastFailedIndex == null) {
        _failed = [
          ..._failed,
          MoneroBlockTrackingFailed(
              startHeight: response.currentHeight, endHeight: total)
        ].toImutableList;
        return;
      }
      lastFailedIndex._updateHeight(total);
    }
  }

  MoneroDefaultBlockTrackingInfo._(
      {required this.startHeight,
      required this.endHeight,
      required MoneroBlockTrackingStatus status,
      required List<MoneroBlockTrackingFailed> failed,
      required this.requestId,
      required int currentHeight})
      : _failed = failed,
        _status = status,
        _currentHeight = currentHeight,
        super._(type: MoneroBlockTrackerType.defaultTracker);

  factory MoneroDefaultBlockTrackingInfo(
      {required int startHeight,
      required int endHeight,
      required int currentHeight,
      required MoneroBlockTrackingStatus status,
      required int? requestId}) {
    if (startHeight.isNegative || startHeight > endHeight) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return MoneroDefaultBlockTrackingInfo._(
        startHeight: startHeight,
        endHeight: endHeight,
        status: status,
        requestId: requestId,
        currentHeight: currentHeight,
        failed: const []);
  }
  factory MoneroDefaultBlockTrackingInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroBlockTrackerType.defaultTracker.tag);
    return MoneroDefaultBlockTrackingInfo._(
        startHeight: values.elementAs(0),
        endHeight: values.elementAs(1),
        status: MoneroBlockTrackingStatus.fromValue(values.elementAs(2)),
        currentHeight: values.elementAs(3),
        requestId: values.elementAs(4),
        failed: values
            .elementAsListOf<CborTagValue>(5)
            .map((e) => MoneroBlockTrackingFailed.deserialize(cbor: e))
            .toList());
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          startHeight,
          endHeight,
          status.value,
          _currentHeight,
          requestId,
          CborListValue.fixedLength(_failed.map((e) => e.toCbor()).toList())
        ]),
        type.tag);
  }

  @override
  String toString() {
    return {
      'start': startHeight,
      'end': endHeight,
      'status': status.name,
      "processId": requestId,
      "currentHeight": _currentHeight
    }.toString();
  }

  @override
  List get variabels => [startHeight, endHeight, requestId];
}

class MoneroRequestBlockTrackingInfo extends MoneroBlockTrackingInfo {
  Set<MoneroSyncAccountsInfos> _accounts;
  Set<MoneroSyncAccountsInfos> get accounts => _accounts;
  final int startHeight;
  final int endHeight;
  List<MoneroDefaultBlockTrackingInfo> _offsets;
  final int requestId;
  List<MoneroBlockTrackingFailed> _failed;
  List<MoneroBlockTrackingFailed> get failedOffsets => _failed;
  MoneroBlockTrackingStatus _status;
  MoneroBlockTrackingStatus get status => _status;
  int get currentHeight {
    if (_status.isComplete) return endHeight;
    return _offsets
            .lastWhereOrNull((e) => e._status.isComplete)
            ?.currentHeight ??
        startHeight;
  }

  final DateTime created;
  MoneroRequestBlockTrackingInfo._(
      {required List<MoneroSyncAccountsInfos> accounts,
      required List<MoneroDefaultBlockTrackingInfo> offsets,
      required this.requestId,
      required this.startHeight,
      required this.endHeight,
      required List<MoneroBlockTrackingFailed> failed,
      required MoneroBlockTrackingStatus status,
      required this.created})
      : _accounts = accounts.toImutableSet,
        _offsets = offsets.toImutableList,
        _failed = failed.immutable,
        _status = status,
        super._(type: MoneroBlockTrackerType.request);

  factory MoneroRequestBlockTrackingInfo({
    required int startHeight,
    required int endHeight,
    required int requestId,
    required List<MoneroSyncAccountsInfos> accounts,
  }) {
    if (startHeight.isNegative || startHeight > endHeight || accounts.isEmpty) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return MoneroRequestBlockTrackingInfo._(
        accounts: accounts,
        offsets: MoneroAccountBlocksTracker._buildOffsets(
            currentHeight: startHeight,
            endHeight: endHeight,
            requestId: requestId),
        requestId: requestId,
        endHeight: endHeight,
        failed: [],
        startHeight: startHeight,
        status: MoneroBlockTrackingStatus.pending,
        created: DateTime.now());
  }
  factory MoneroRequestBlockTrackingInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroBlockTrackerType.request.tag);
    return MoneroRequestBlockTrackingInfo._(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroSyncAccountsInfos.deserialize(cbor: e))
            .toList(),
        offsets: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => MoneroDefaultBlockTrackingInfo.deserialize(cbor: e))
            .toList(),
        failed: values
            .elementAsListOf<CborTagValue>(2)
            .map((e) => MoneroBlockTrackingFailed.deserialize(cbor: e))
            .toList(),
        startHeight: values.elementAs(3),
        endHeight: values.elementAs(4),
        requestId: values.elementAs(5),
        status: MoneroBlockTrackingStatus.fromValue(values.elementAs(6)),
        created: values.elementAs<DateTime?>(7) ?? DateTime.now());
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_offsets.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(_failed.map((e) => e.toCbor()).toList()),
          startHeight,
          endHeight,
          requestId,
          _status.value,
          created
        ]),
        type.tag);
  }

  @override
  String toString() {
    return {}.toString();
  }

  @override
  List get variabels => [accounts, _offsets, requestId];

  void _updateOffset(MoneroSyncBlocksResponse response) {
    final index = _offsets.indexOf(response.offset);
    assert(index >= 0, "invalid sync block response.");
    if (index.isNegative) return;
    assert(_status.isPending,
        "invalid sync block response. request already completed.");
    if (!_status.isPending) return;
    _offsets[index]._update(response);
    if (_offsets.every((e) => e._status.isComplete)) {
      _status = MoneroBlockTrackingStatus.complete;
      _failed = _offsets.expand((e) => e._failed).toImutableList;
      _offsets = <MoneroDefaultBlockTrackingInfo>[].toImutableList;
    }
  }
}

enum MoneroAccountBlocksTrackerStatus {
  synced(1),
  pending(2);

  bool get inProcess => this == pending;
  bool get isSynced => this == synced;

  final int value;
  const MoneroAccountBlocksTrackerStatus(this.value);
  static MoneroAccountBlocksTrackerStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "block tracker status does not exists."));
  }
}

class MoneroAccountBlocksTracker with CborSerializable {
  Set<MoneroSyncAccountsInfos> _accounts;
  Set<MoneroSyncAccountsInfos> get accounts => _accounts;
  MoneroAccountBlocksTrackerStatus _status;
  MoneroAccountBlocksTrackerStatus get status => _status;
  List<MoneroBlockTrackingFailed> _failedOffsets;
  List<MoneroBlockTrackingFailed> get failedOffsets => _failedOffsets;
  List<MoneroDefaultBlockTrackingInfo> _currentOffsets;
  List<MoneroDefaultBlockTrackingInfo> get offsets => _currentOffsets;

  List<MoneroRequestBlockTrackingInfo> _requestOffsets;
  List<MoneroRequestBlockTrackingInfo> get requestOffsets => _requestOffsets;
  final _lock = SynchronizedLock();
  bool get synced => _status.isSynced;
  // final DateTime created;
  int _startHeight;
  int get startHeight => _startHeight;
  int _endHeight;
  int get endHeight => _endHeight;
  int _currentHeight;
  int get currentHeight => _currentHeight;
  bool get isStart => _startHeight == 0;

  bool get hasPendingTxes {
    return _accounts.any((e) => e.pendingTxes.isNotEmpty);
  }

  MoneroSyncAccountsRequestInfos _getTrackerAccount(
      MoneroBlockTrackingInfo tracker) {
    if (tracker.type.isDefaultTracker) {
      return MoneroSyncAccountsRequestInfos._(
          accounts: _accounts.map((e) => e.toRequest()).toList());
    }
    final requestTracker = tracker.cast<MoneroRequestBlockTrackingInfo>();
    return MoneroSyncAccountsRequestInfos._(
        accounts: requestTracker._accounts.map((e) => e.toRequest()).toList());
  }

  MoneroAccountBlocksTracker.start()
      : _accounts = {},
        _startHeight = 0,
        _endHeight = 0,
        _failedOffsets = [],
        _currentOffsets = [],
        _currentHeight = 0,
        _requestOffsets = [],
        _status = MoneroAccountBlocksTrackerStatus.pending;
  MoneroAccountBlocksTracker.__({
    List<MoneroSyncAccountsInfos> accounts = const [],
    required List<MoneroBlockTrackingFailed> failedOffsets,
    required List<MoneroDefaultBlockTrackingInfo> currentOffsets,
    required List<MoneroRequestBlockTrackingInfo> requestOffsets,
    required int startHeight,
    required int endHeight,
    required int currentHeight,
    required MoneroAccountBlocksTrackerStatus status,
  })  : _accounts = accounts.toImutableSet,
        _failedOffsets = failedOffsets.immutable,
        _endHeight = endHeight,
        _startHeight = startHeight,
        _currentOffsets = currentOffsets.clone(),
        _currentHeight = currentHeight,
        _status = status,
        _requestOffsets = requestOffsets.clone();

  factory MoneroAccountBlocksTracker.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroSyncRequestChainTracker);
    return MoneroAccountBlocksTracker.__(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => MoneroSyncAccountsInfos.deserialize(cbor: e))
          .toList(),
      startHeight: values.elementAs(1),
      endHeight: values.elementAs(2),
      failedOffsets: values
          .elementAsListOf<CborTagValue>(3)
          .map((e) => MoneroBlockTrackingFailed.deserialize(cbor: e))
          .toList(),
      currentOffsets: values
          .elementAsListOf<CborTagValue>(4)
          .map((e) => MoneroDefaultBlockTrackingInfo.deserialize(cbor: e))
          .toList(),
      currentHeight: values.elementAs(5),
      status: MoneroAccountBlocksTrackerStatus.fromValue(values.elementAs(7)),
      requestOffsets: values
          .elementAsListOf<CborTagValue>(8)
          .map((e) => MoneroRequestBlockTrackingInfo.deserialize(cbor: e))
          .toList(),
    );
  }

  List<MoneroAccountPendingTxes> getAccountsPendingTxes() {
    final List<MoneroAccountPendingTxes> accounts = [];
    for (final i in this.accounts) {
      if (i.pendingTxes.isEmpty) continue;
      accounts.add(MoneroAccountPendingTxes(
          primaryAddress: i.primaryAccount, txIDs: i.pendingTxes));
    }
    return accounts;
  }

  Future<void> addSyncRequest({
    required int startHeight,
    required int endHeight,
    required List<MoneroSyncAccountsInfos> accounts,
  }) async {
    await _lock.synchronized(() async {
      for (final i in accounts) {
        if (!_accounts.contains(i)) {
          throw WalletExceptionConst.accountDoesNotFound;
        }
      }
      int requestId = 0;
      while (_requestOffsets.any((e) => e.requestId == requestId)) {
        requestId++;
      }
      final request = MoneroRequestBlockTrackingInfo(
          startHeight: startHeight,
          endHeight: endHeight,
          requestId: requestId,
          accounts: accounts);
      _requestOffsets = [..._requestOffsets, request].toImutableList;
    });
  }

  static List<MoneroDefaultBlockTrackingInfo> _buildOffsets({
    required int currentHeight,
    required int endHeight,
    required int? requestId,
  }) {
    if (currentHeight >= endHeight) return [];

    const int minBlockPerOffset = 2000;
    const int maxOffsets = 50;

    final totalBlocks = endHeight - currentHeight;

    // Calculate the max number of offsets based on min block size
    int offsetCount = (totalBlocks ~/ minBlockPerOffset);

    // Enforce at most 50 offsets, but also at least 1
    offsetCount = offsetCount.clamp(1, maxOffsets);

    // Calculate size of each offset
    final blockPerOffset = (totalBlocks / offsetCount).ceil();

    final List<MoneroDefaultBlockTrackingInfo> offsets = [];
    int start = currentHeight;

    for (int i = 0; i < offsetCount; i++) {
      int nextEnd = start + blockPerOffset;
      if (nextEnd > endHeight || i == offsetCount - 1) {
        nextEnd = endHeight;
      }

      final size = nextEnd - start;
      // Ensure size is valid (>= 2000 unless it's the last offset)
      if (size < minBlockPerOffset && nextEnd != endHeight) {
        continue; // Skip small offset
      }

      offsets.add(MoneroDefaultBlockTrackingInfo(
          startHeight: start,
          endHeight: nextEnd,
          currentHeight: start,
          status: MoneroBlockTrackingStatus.pending,
          requestId: requestId));

      start = nextEnd;
      if (start >= endHeight) break;
    }

    return offsets;
  }

  void _checkOffsets() {
    final bool offsetsComplete = _currentOffsets
        .every((e) => e.status != MoneroBlockTrackingStatus.pending);
    if (!offsetsComplete) return;
    final offsets = _currentOffsets;
    if (offsets.isNotEmpty) {
      _currentHeight = offsets.last.endHeight;
      _failedOffsets = [..._failedOffsets, ...offsets.expand((e) => e._failed)];
    }
    _currentOffsets = _buildOffsets(
        currentHeight: currentHeight, endHeight: endHeight, requestId: null);
    _checkStatus();
  }

  void _updateOffset(MoneroSyncBlocksResponse offset) async {
    if (offset.offset.requestId != null) {
      final request = _requestOffsets
          .firstWhereNullable((e) => e.requestId == offset.offset.requestId);
      assert(request != null, "unknown sync block response request id");
      if (request == null) return;
      request._updateOffset(offset);
      addSyncedAccountsPaymentTx(offset.txIds);
      return;
    }
    final index = _currentOffsets.indexOf(offset.offset);
    assert(!index.isNegative, "unknown sync block response request id");
    if (index.isNegative) return;
    _currentOffsets[index]._update(offset);
    addSyncedAccountsPaymentTx(offset.txIds);
    _checkOffsets();
  }

  void _setStartHeight(int height) {
    assert(isStart, "default tracker already set starts.");
    assert(height > 0, "invalid height.");
    if (!isStart || height <= 0) return;
    _startHeight = height - 2500;
    _endHeight = height;
    _currentHeight = height - 2500;
    _currentOffsets = _buildOffsets(
        currentHeight: currentHeight, endHeight: endHeight, requestId: null);
    _checkStatus();
    for (final i in _accounts) {
      i._updateStartHeights(_currentHeight);
    }
  }

  Future<void> resetTracker() async {
    await _lock.synchronized(() async {
      _startHeight = 0;
      _endHeight = 0;
      _currentHeight = 0;
      _status = MoneroAccountBlocksTrackerStatus.pending;
      _currentOffsets = [];
    });
  }

  Future<void> updateDefaultTrackerHeight(int endHeight) async {
    await _lock.synchronized(() async {
      assert(isStart || endHeight >= this.endHeight,
          "invalid update track height.");
      if (!isStart && this.endHeight > endHeight) {
        return;
      }
      if (isStart) {
        if (_accounts.isEmpty) return;
        _setStartHeight(endHeight);
      } else {
        _endHeight = endHeight;
        _checkOffsets();
        _checkStatus();
      }
    });
  }

  void _checkStatus() {
    if (_currentHeight >= endHeight) {
      assert(_currentHeight == endHeight, "must be equal");
      _status = MoneroAccountBlocksTrackerStatus.synced;
    } else {
      _status = MoneroAccountBlocksTrackerStatus.pending;
    }
  }

  void addSyncedAccountsPaymentTx(Iterable<MoneroSyncAccountsInfos> accounts) {
    for (final i in accounts) {
      final account = _accounts.firstWhereOrNull((e) => e == i);
      assert(account != null, "account does not exist.");
      account?._addPendingTx(i.pendingTxes);
    }
  }

  void addPendingTx(MoneroAccountPendingTxes tx) {
    for (final i in accounts) {
      if (i.primaryAccount == tx.primaryAddress) {
        i._addPendingTx(tx.txIDs);
        break;
      }
    }
  }

  MoneroSyncAccountsInfos getAccountInfo(
      MoneroViewPrimaryAccountDetails primaryAccount) {
    return _accounts.firstWhere(
      (e) => e.primaryAccount == primaryAccount,
      orElse: () => throw WalletExceptionConst.accountDoesNotFound,
    );
  }

  void removePendingTxes(Iterable<MoneroSyncAccountsInfos> accounts) {
    for (final i in accounts) {
      final account = _accounts.firstWhereOrNull((e) => e == i);
      assert(account != null, "account does not exist.");
      account?._removeTxes(i.pendingTxes);
    }
  }

  void removeAccountPendingTxes(
      {required MoneroViewPrimaryAccountDetails account,
      required List<String> txes}) {
    getAccountInfo(account)._removeTxes(txes);
  }

  void addAccount(MoneroViewAccountDetails account) {
    final primaryAccount = account.primaryAccount();
    MoneroSyncAccountsInfos? syncAccount =
        accounts.firstWhereNullable((e) => e.primaryAccount == primaryAccount);
    if (syncAccount == null) {
      syncAccount = MoneroSyncAccountsInfos(primaryAccount: primaryAccount);
      _accounts = {..._accounts, syncAccount}.toImutableSet;
    }
    syncAccount._addIndex(MoneroSyncAccountIndexInfo(
        index: account.index, startHeight: currentHeight));
  }

  void removeAccount(
      {required MoneroViewPrimaryAccountDetails account,
      required MoneroAccountIndex index}) {
    final MoneroSyncAccountsInfos? syncAccount =
        accounts.firstWhereNullable((e) => e.primaryAccount == account);
    if (syncAccount == null) return;
    syncAccount._removeIndex(index);
    if (syncAccount.indexes.isEmpty) {
      _accounts =
          _accounts.where((e) => e.primaryAccount != account).toImutableSet;
    }
  }

  List<MoneroRequestBlockTrackingInfo> getPendingRequestOffsets() {
    return _requestOffsets.where((e) => e._status.isPending).toList();
  }

  List<MoneroDefaultBlockTrackingInfo> _getPendingOffsets() {
    return [
      if (accounts.isNotEmpty) ..._currentOffsets,
      ..._requestOffsets
          .expand((e) => e._offsets.where((e) => e.status.isPending))
    ];
  }

  Future<Stream<void>?> getHeightRequest(
      {required Future<
                  SyncRequestController<MoneroSyncBlocksResponse,
                      MoneroBlockTrackingInfo>>
              Function(int processId, MoneroSyncAccountsRequestInfos account)
          onRequest,
      required void Function() onTrackerUpdated,
      int totalThread = 2}) async {
    return await _lock.synchronized(() async {
      List<MoneroDefaultBlockTrackingInfo> offsets = _getPendingOffsets();
      if (offsets.isEmpty) return null;
      Timer? timer;
      int repeat = 0;
      void updateTracker() {
        repeat = 0;
        onTrackerUpdated();
      }

      void emitUpdated() {
        if (repeat > 10) return;
        repeat++;
        timer?.cancel();
        timer = null;
        timer = Timer(const Duration(seconds: 3), updateTracker);
      }

      List<SyncRequestController> connectors = [];
      StreamController? controller = StreamController(
        onCancel: () {
          timer?.cancel();
          timer = null;
          updateTracker();
          for (final i in connectors) {
            i.close();
          }
          connectors.clear();
        },
      );
      int index = 0;
      MoneroDefaultBlockTrackingInfo? getNextOffset() {
        final offset = offsets.elementAtOrNull(index++);
        return offset;
      }

      Future<void> startSync(
          {required MoneroDefaultBlockTrackingInfo? Function() getOffset,
          required int processId}) async {
        while (true) {
          final offset = getOffset();
          if (offset == null) return;
          final completer = Completer();
          final accounts = _getTrackerAccount(offset);
          final connector = await onRequest(processId, accounts);
          connectors.add(connector);
          try {
            final stream = connector.stream.listen((event) async {
              _updateOffset(event);
              emitUpdated();
              if (offset.status.isPending) return;
              completer.complete();
            }, onDone: () {
              if (!completer.isCompleted) completer.completeError('');
            }, onError: (e) {});
            connector.subscription = stream;
            connector.controller.add(offset);
            await completer.future;
          } finally {
            connector.close();
            connectors.remove(connector);
          }
        }
      }

      Future.wait(List.generate(2,
              (i) => startSync(getOffset: () => getNextOffset(), processId: i)))
          .then((e) {
        controller?.add(null);
        controller = null;
      });
      return controller?.stream;
    });
  }

  Future<MoneroRequestBlockTrackingInfo?> removeSyncRequest(
      int requestId) async {
    return _lock.synchronized(() async {
      final request =
          _requestOffsets.firstWhereOrNull((e) => e.requestId == requestId);
      assert(request != null, "unknow request id. request does not exists.");
      if (request == null) return null;
      _requestOffsets = _requestOffsets.where((e) => e != request).toList();
      return request;
    });
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          startHeight,
          endHeight,
          CborListValue.fixedLength(
              _failedOffsets.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              _currentOffsets.map((e) => e.toCbor()).toList()),
          currentHeight,
          const CborNullValue(),
          status.value,
          CborListValue.fixedLength(
              _requestOffsets.map((e) => e.toCbor()).toList()),
        ]),
        CborTagsConst.moneroSyncRequestChainTracker);
  }

  @override
  String toString() {
    return {
      "offsets": _currentOffsets,
      "error": _failedOffsets,
      "height": _currentHeight,
      "start_height": startHeight,
      "end_height": endHeight
    }.toString();
  }
}

class MoneroChainAccountTranckerInfo with CborSerializable {
  final DateTime updateTime;
  final List<int> fetchedBlock;

  MoneroChainAccountTranckerInfo(
      {required this.updateTime, required List<int> fetchedBlock})
      : fetchedBlock = fetchedBlock.immutable;
  factory MoneroChainAccountTranckerInfo.create() {
    return MoneroChainAccountTranckerInfo(
        updateTime: DateTime.now(), fetchedBlock: []);
  }
  factory MoneroChainAccountTranckerInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroChainTrackerInfo);
    return MoneroChainAccountTranckerInfo(
        updateTime: values.elementAs(0),
        fetchedBlock: values
            .elementAsListOf<CborIntValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborEpochIntValue(updateTime),
          CborListValue.fixedLength(
              fetchedBlock.map((e) => CborIntValue(e)).toList())
        ]),
        CborTagsConst.moneroChainTrackerInfo);
  }
}

class MoneroViewPrimaryAccountDetails with CborSerializable, Equatable {
  final List<int> viewPrivateKey;
  final List<int> spendPublicKey;
  final MoneroNetwork network;
  late final account = MoneroAccount.fromWatchOnly(
      viewPrivateKey, spendPublicKey,
      coinType: network.coin);
  late final primaryAddress = MoneroAccountAddress(account.primaryAddress,
      network: network, type: XmrAddressType.primaryAddress);
  MoneroViewPrimaryAccountDetails._(
      {required List<int> viewPrivateKey,
      required List<int> spendPublicKey,
      required this.network})
      : viewPrivateKey = viewPrivateKey.asImmutableBytes,
        spendPublicKey = spendPublicKey.asImmutableBytes;
  factory MoneroViewPrimaryAccountDetails({
    required MoneroPrivateKey viewPrivateKey,
    required MoneroPublicKey spendPublicKey,
    required MoneroNetwork network,
  }) {
    return MoneroViewPrimaryAccountDetails._(
        viewPrivateKey: viewPrivateKey.key,
        spendPublicKey: spendPublicKey.key,
        network: network);
  }

  factory MoneroViewPrimaryAccountDetails.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.moneroViewPrimaryAccountDetails);

    return MoneroViewPrimaryAccountDetails._(
        viewPrivateKey: values.elementAs(0),
        spendPublicKey: values.elementAs(1),
        network: MoneroNetwork.fromIndex(values.elementAs(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborBytesValue(viewPrivateKey),
      CborBytesValue(spendPublicKey),
      network.index
    ], CborTagsConst.moneroViewPrimaryAccountDetails);
  }

  @override
  List get variabels => [viewPrivateKey, spendPublicKey, network];

  @override
  String toString() {
    return primaryAddress.toString();
  }
}

class MoneroViewAccountDetails with Equatable, CborSerializable {
  final MoneroViewPrimaryAccountDetails viewKey;
  final MoneroAccountIndex index;
  bool get isPrimary => !index.isSubaddress;
  bool get isSubAddresss => index.isSubaddress;
  XmrAddressType get addrType =>
      isSubAddresss ? XmrAddressType.subaddress : XmrAddressType.primaryAddress;

  const MoneroViewAccountDetails._(
      {required this.viewKey, required this.index});
  factory MoneroViewAccountDetails(
      {required MoneroViewPrimaryAccountDetails viewKey,
      required int major,
      required int minor}) {
    return MoneroViewAccountDetails._(
        viewKey: viewKey,
        index: MoneroAccountIndex(minor: minor, major: major));
  }
  factory MoneroViewAccountDetails.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.moneroNewAddressParams.tag);
    final viewKey = MoneroViewPrimaryAccountDetails.deserialize(
        object: values.getCborTag(0));
    return MoneroViewAccountDetails(
      viewKey: viewKey,
      major: values.elementAs(1),
      minor: values.elementAs(2),
    );
  }

  MoneroViewPrimaryAccountDetails primaryAccount() {
    return viewKey;
  }

  MoneroAddress toAddress(WalletMoneroNetwork network) {
    final keys = viewKey.account.scubaddr.computeKeys(index.minor, index.major);
    return MoneroAccountAddress.fromPubKeys(
        pubSpendKey: keys.pubSKey.key,
        pubViewKey: keys.pubVKey.key,
        network: network.coinParam.network,
        type: addrType);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([viewKey.toCbor(), index.major, index.minor],
        NewAccountParamsType.moneroNewAddressParams.tag);
  }

  @override
  List get variabels => [
        viewKey,
        index.major,
        index.minor,
      ];
}

class MoneroTxInfo with CborSerializable {
  final String txId;
  final String txHex;
  final List<BigInt> globalIndices;
  final int confirmations;
  MoneroTransaction? toTx() {
    return MethodUtils.nullOnException(
        () => MoneroTransaction.deserialize(BytesUtils.fromHexString(txHex)));
  }

  MoneroTxInfo(
      {required String txId,
      required String txHex,
      required List<BigInt> globalIndices,
      required int confirmations})
      : txId = QuickCryptoValidator.asValidHexBytes(txId,
            lengthInBytes: MoneroConst.txHashLength),
        txHex = QuickCryptoValidator.asValidHexBytes(txHex),
        globalIndices = globalIndices.immutable,
        confirmations = confirmations.asInt32;
  factory MoneroTxInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: cbor,
        tags: CborTagsConst.moneroUtxoRequestTxInfo);
    return MoneroTxInfo(
        txId: String.fromCharCodes(values.elementAs(0)),
        txHex: String.fromCharCodes(values.elementAs(1)),
        globalIndices: values
            .elementAsListOf<CborBigIntValue>(2)
            .map((e) => e.value)
            .toList(),
        confirmations: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue([
      CborBytesValue(txId.codeUnits),
      CborBytesValue(txHex.codeUnits),
      CborListValue.fixedLength(globalIndices),
      confirmations
    ], CborTagsConst.moneroUtxoRequestTxInfo);
  }
}

class MoneroTxIDsUnlockOutputResponse with CborSerializable {
  final List<MoneroUnlockedPaymentRequestDetails> payments;
  MoneroTxIDsUnlockOutputResponse(
      List<MoneroUnlockedPaymentRequestDetails> payments)
      : payments = payments.imutable;

  factory MoneroTxIDsUnlockOutputResponse.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.moneroUtxoRequestTxId);
    return MoneroTxIDsUnlockOutputResponse(values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => MoneroUnlockedPaymentRequestDetails.deserialize(cbor: e))
        .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(payments.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.moneroUtxoRequestTxId);
  }
}

enum MoneroUnlockPaymentRequestStatus {
  success(1),
  error(2);

  const MoneroUnlockPaymentRequestStatus(this.value);

  final int value;
  static MoneroUnlockPaymentRequestStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get hasPayment => this == MoneroUnlockPaymentRequestStatus.success;
}

enum MoneroUnlockPaymentRequestOutputStatus {
  unknown(0),
  spent(1),
  unspent(2),
  pool(3);

  const MoneroUnlockPaymentRequestOutputStatus(this.value);

  final int value;
  static MoneroUnlockPaymentRequestOutputStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isUnspent => this == unspent;
  bool get inPool => this == pool;
  bool get isUnknown => this == unknown;
  bool get isSpent => this == spent;
}

class MoneroOutputDetails with CborSerializable, Equatable {
  final MoneroLockedOutput lockedOutput;
  final String txId;
  final String keyImage;
  final BigInt amount;
  MoneroAccountIndex get index => lockedOutput.accountIndex;
  BigInt? _globalIndex;
  BigInt? get globalIndex => _globalIndex;
  bool get hasGlobalIndex => globalIndex != null;
  int _confirmations;
  int? _height;
  int get confirmations => _confirmations;
  int? get height => _height;
  MoneroUnlockPaymentRequestOutputStatus _status;
  MoneroUnlockPaymentRequestOutputStatus get status => _status;
  bool _needUpdate = false;
  bool get needUpdate => _needUpdate;
  void _checkUpdate() {
    _needUpdate = _status.inPool ||
        (_status.isUnspent && (_confirmations < 10 || _globalIndex == null));
  }

  MoneroOutputDetails._({
    required this.txId,
    required this.keyImage,
    required this.lockedOutput,
    BigInt? globalIndex,
    int? confirmations,
    int? height,
    required MoneroUnlockPaymentRequestOutputStatus status,
  })  : _status = status,
        _confirmations = confirmations ?? 0,
        _height = height,
        amount = lockedOutput.amount,
        _globalIndex = globalIndex {
    _checkUpdate();
  }
  factory MoneroOutputDetails({
    required String txId,
    required String keyImage,
    required MoneroLockedOutput lockedOut,
    BigInt? globalIndex,
    int? confirmations,
    int? height,
    MoneroUnlockPaymentRequestOutputStatus status =
        MoneroUnlockPaymentRequestOutputStatus.unknown,
  }) {
    return MoneroOutputDetails._(
        txId: QuickCryptoValidator.asValidHexBytes(txId,
            lengthInBytes: MoneroConst.txHashLength),
        keyImage: QuickCryptoValidator.asValidHexBytes(keyImage,
            lengthInBytes: MoneroConst.keyImageLength),
        confirmations: confirmations,
        height: height,
        status: status,
        lockedOutput: lockedOut,
        globalIndex: globalIndex);
  }
  factory MoneroOutputDetails.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: cbor,
        tags: CborTagsConst.moneroUtxoDetails);
    final lockedOut = MoneroLockedOutput.deserialize(values.elementAs(5));
    return MoneroOutputDetails(
      txId: String.fromCharCodes(values.elementAs(0)),
      keyImage: String.fromCharCodes(values.elementAs(1)),
      confirmations: values.elementAs(2),
      height: values.elementAs(3),
      status:
          MoneroUnlockPaymentRequestOutputStatus.fromValue(values.elementAs(4)),
      lockedOut: lockedOut,
      globalIndex: values.elementAs(6),
    );
  }

  void _updatePaymentStatus({required DaemonKeyImageSpentStatus status}) {
    switch (status) {
      case DaemonKeyImageSpentStatus.unspent:
        _status = MoneroUnlockPaymentRequestOutputStatus.unspent;
        break;
      case DaemonKeyImageSpentStatus.spentInBlockchain:
        _status = MoneroUnlockPaymentRequestOutputStatus.spent;
        break;
      case DaemonKeyImageSpentStatus.spentInPool:
        _status = MoneroUnlockPaymentRequestOutputStatus.pool;
        break;
    }
    _checkUpdate();
  }

  void _updateConfrimation(int confirmations) {
    assert(this.confirmations <= confirmations, "should not be happend.");
    if (this.confirmations >= confirmations) {
      return;
    }
    _confirmations = confirmations;
    _checkUpdate();
  }

  void _updateIndices(List<BigInt> outputIndeces) {
    if (outputIndeces.isEmpty ||
        outputIndeces.length <= lockedOutput.realIndex) {
      return;
    }
    assert(
        _globalIndex == null ||
            _globalIndex == outputIndeces[lockedOutput.realIndex],
        "must be updated. not changed.");
    _globalIndex = outputIndeces[lockedOutput.realIndex];
    _checkUpdate();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(txId.codeUnits),
          CborBytesValue(keyImage.codeUnits),
          confirmations,
          height,
          status.value,
          CborBytesValue(lockedOutput.serialize()),
          globalIndex
        ]),
        CborTagsConst.moneroUtxoDetails);
  }

  @override
  List get variabels => [keyImage, lockedOutput.realIndex];
  MoneroLockedPayment toLockedPayment() {
    if (needUpdate) {
      throw const WalletException("output_is_not_ready_for_spending");
    }
    return MoneroLockedPayment(
        output: MoneroLockedOutput(
            amount: lockedOutput.amount,
            derivation: lockedOutput.derivation,
            mask: lockedOutput.mask,
            outputPublicKey: lockedOutput.outputPublicKey,
            accountIndex: lockedOutput.accountIndex,
            unlockTime: lockedOutput.unlockTime,
            realIndex: lockedOutput.realIndex),
        txPubkey: lockedOutput.outputPublicKey,
        paymentId: null,
        encryptedPaymentid: null,
        globalIndex: globalIndex!);
  }

  MoneroUnLockedPayment toUnlockedFakePayment() {
    return MoneroUnLockedPayment(
        output: MoneroUnlockedOutput(
            amount: lockedOutput.amount,
            derivation: lockedOutput.derivation,
            ephemeralSecretKey: RCT.identity(clone: false),
            ephemeralPublicKey: lockedOutput.outputPublicKey,
            keyImage: RCT.identity(clone: false),
            mask: lockedOutput.mask,
            outputPublicKey: lockedOutput.outputPublicKey,
            accountIndex: lockedOutput.accountIndex,
            unlockTime: lockedOutput.unlockTime,
            realIndex: lockedOutput.realIndex),
        txPubkey: lockedOutput.outputPublicKey,
        paymentId: null,
        encryptedPaymentid: null,
        globalIndex: globalIndex ?? BigInt.from(1 << 31));
  }

  @override
  String toString() {
    return "UTXO: $txId";
  }
}

class MoneroAddressUtxos with CborSerializable {
  final Map<MoneroAddress, Set<MoneroOutputDetails>> _utxos;
  List<MoneroOutputDetails> get allUtxos =>
      _utxos.values.expand((e) => e).toList();
  List<String> get allTxIds =>
      _utxos.values.expand((e) => e.map((e) => e.txId)).toList();
  MoneroAddressUtxos._(
      {Map<MoneroAddress, Set<MoneroOutputDetails>> utxos = const {}})
      : _utxos = utxos;
  List<MoneroAddress> get addresses => _utxos.keys.toList();
  factory MoneroAddressUtxos(
      {Map<MoneroAddress, List<MoneroOutputDetails>> utxos = const {}}) {
    for (final i in utxos.entries) {
      if (i.key.isSubaddress) {
        throw WalletExceptionConst.invalidData(
            messsage: 'monero subaddress not allowed');
      }
    }
    return MoneroAddressUtxos._(
        utxos: utxos.map((k, v) => MapEntry(k, v.toSet())));
  }
  factory MoneroAddressUtxos.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroAddressUtxos);
    return MoneroAddressUtxos._(
        utxos: values.elementAsMap<CborStringValue, CborListValue>(0).map(
            (k, v) => MapEntry<MoneroAddress, Set<MoneroOutputDetails>>(
                MoneroAddress(k.value),
                v.value
                    .map((e) => MoneroOutputDetails.deserialize(cbor: e))
                    .toSet())));
  }

  void _cleanUpSpentUtxos() {
    final keys = _utxos.keys.toList();
    for (final i in keys) {
      _utxos[i] = _utxos[i]!.where((e) => !e.status.isSpent).toSet();
    }
  }

  void updatePaymentStatus(
      MoneroOutputDetails utxo, DaemonKeyImageSpentStatus status) {
    assert(allUtxos.contains(utxo), "utxo not found");
    utxo._updatePaymentStatus(status: status);
    _cleanUpSpentUtxos();
  }

  void updateUtxoInfromation(
      {required MoneroOutputDetails utxo,
      required List<BigInt> outoutIndices,
      required int? confirmations}) {
    assert(allUtxos.contains(utxo), "utxo not found");
    if (outoutIndices.isNotEmpty) {
      if (!utxo.hasGlobalIndex) {
        utxo._updateIndices(outoutIndices);
      }
    }
    if (confirmations != null) {
      utxo._updateConfrimation(confirmations);
    }
  }

  void updateUtxos(
      {required List<MoneroOutputDetails> utxos,
      required MoneroAddress primaryAddress}) {
    if (primaryAddress.isSubaddress) {
      throw WalletExceptionConst.invalidData(
          messsage: 'monero subaddress not allowed');
    }
    final existsUtxos = <MoneroOutputDetails>[
      ..._utxos[primaryAddress] ?? {},
      ...utxos
    ];
    _utxos[primaryAddress] =
        existsUtxos.where((e) => !e.status.isSpent).toSet();
  }

  List<MoneroOutputDetails> getUtxos(
      MoneroViewPrimaryAccountDetails primaryAddress) {
    assert(_utxos.containsKey(primaryAddress.primaryAddress),
        "address does not exist");
    return _utxos[primaryAddress.primaryAddress]?.toList() ?? [];
  }

  void addNewAccount(MoneroViewAccountDetails primaryAddress) {
    _utxos[primaryAddress.viewKey.primaryAddress] ??= <MoneroOutputDetails>{};
  }

  void removeAccount(MoneroViewAccountDetails primaryAddress) {
    final utxos = _utxos[primaryAddress.viewKey.primaryAddress] ?? {};
    if (utxos.isEmpty) return;
    _utxos[primaryAddress.viewKey.primaryAddress] =
        utxos.where((e) => e.index != primaryAddress.index).toSet();
  }

  BigInt getAddressBalance(MoneroViewAccountDetails address) {
    assert(_utxos.containsKey(address.viewKey.primaryAddress),
        "address does not exist");
    final utxos = _utxos[address.viewKey.primaryAddress] ?? {};
    return utxos.fold<BigInt>(BigInt.zero, (p, c) => p + c.amount);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborMapValue.fixedLength(_utxos.map((k, v) => MapEntry(
              CborStringValue(k.address),
              CborListValue.fixedLength(v.map((e) => e.toCbor()).toList()))))
        ]),
        CborTagsConst.moneroAddressUtxos);
  }
}

class MoneroViewOutputDetails {
  final MoneroOutputDetails output;
  final IntegerBalance amount;
  const MoneroViewOutputDetails({required this.output, required this.amount});
}

class MoneroViewUnlockedPaymentRequestDetails {
  final String txID;
  final MoneroViewOutputDetails? output;
  final MoneroUnlockPaymentRequestStatus status;
  const MoneroViewUnlockedPaymentRequestDetails(
      {required this.txID, required this.output, required this.status});
}

class MoneroUnlockedPaymentRequestDetails with CborSerializable {
  final String txID;
  final MoneroOutputDetails? output;
  final MoneroUnlockPaymentRequestStatus status;
  bool get hasPayment => output != null;

  MoneroUnlockedPaymentRequestDetails._(
      {required this.output, required this.status, required this.txID});
  factory MoneroUnlockedPaymentRequestDetails(
      {required String txid, MoneroOutputDetails? output}) {
    return MoneroUnlockedPaymentRequestDetails._(
      output: output,
      status: output == null
          ? MoneroUnlockPaymentRequestStatus.error
          : MoneroUnlockPaymentRequestStatus.success,
      txID: QuickCryptoValidator.asValidHexBytes(txid),
    );
  }
  factory MoneroUnlockedPaymentRequestDetails.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroUtxoPaymentInfo);
    final status =
        MoneroUnlockPaymentRequestStatus.fromValue(values.elementAs(1));
    final output = status.hasPayment
        ? MoneroOutputDetails.deserialize(cbor: values.getCborTag(0))
        : null;
    return MoneroUnlockedPaymentRequestDetails._(
      output: output,
      status: status,
      txID: QuickCryptoValidator.asValidHexBytes(
          String.fromCharCodes(values.elementAs<List<int>>(2))),
    );
  }
  factory MoneroUnlockedPaymentRequestDetails.fromUnlockOutput(
      {required String txId,
      required int? comfirmation,
      required BigInt? globalIndex,
      MoneroUnlockedOutput? output,
      MoneroAddress? address}) {
    if (output == null) return MoneroUnlockedPaymentRequestDetails(txid: txId);
    assert(address != null, "address must not be null");
    return MoneroUnlockedPaymentRequestDetails(
        txid: txId,
        output: MoneroOutputDetails(
            txId: txId,
            keyImage: output.keyImageAsHex,
            confirmations: comfirmation,
            globalIndex: globalIndex,
            lockedOut: MoneroLockedOutput(
                amount: output.amount,
                mask: output.mask,
                derivation: output.derivation,
                outputPublicKey: output.outputPublicKey,
                accountIndex: output.accountIndex,
                unlockTime: output.unlockTime,
                realIndex: output.realIndex)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [output?.toCbor(), status.value, CborBytesValue(txID.codeUnits)]),
        CborTagsConst.moneroUtxoPaymentInfo);
  }
}

class MoneroProcessTxesResponse with CborSerializable {
  final MoneroViewPrimaryAccountDetails address;
  final List<MoneroUnlockedPaymentRequestDetails> responses;
  MoneroUpdatePaymentRequest? toPayment() {
    final successOuts = responses.where((e) => e.hasPayment);
    if (successOuts.isEmpty) return null;
    return MoneroUpdatePaymentRequest(
        payments: successOuts.map((e) => e.output!).toList(),
        primaryAddress: address);
  }

  MoneroProcessTxesResponse(
      {required List<MoneroUnlockedPaymentRequestDetails> responses,
      required this.address})
      : responses = responses.immutable;
  factory MoneroProcessTxesResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroProcessTxesResponse);
    return MoneroProcessTxesResponse(
        responses: values
            .elementAsListOf<CborTagValue>(0)
            .map(
                (e) => MoneroUnlockedPaymentRequestDetails.deserialize(cbor: e))
            .toList(),
        address: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(responses.map((e) => e.toCbor()).toList()),
          address.toCbor()
        ]),
        CborTagsConst.moneroProcessTxesResponse);
  }
}

class MoneroBatchProcessTxesResponse with CborSerializable {
  final List<MoneroProcessTxesResponse> payments;

  List<MoneroUpdatePaymentRequest> successPaymets() {
    return payments
        .map((e) => e.toPayment())
        .whereType<MoneroUpdatePaymentRequest>()
        .toList();
  }

  MoneroBatchProcessTxesResponse(List<MoneroProcessTxesResponse> payments)
      : payments = payments.immutable;
  factory MoneroBatchProcessTxesResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroBatchProcessTxesResponse);
    return MoneroBatchProcessTxesResponse(values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => MoneroProcessTxesResponse.deserialize(cbor: e))
        .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(payments.map((e) => e.toCbor()).toList()),
        ]),
        CborTagsConst.moneroBatchProcessTxesResponse);
  }
}

class MoneroAccountWithUtxo {
  final ReceiptAddress<MoneroAddress> address;
  final List<MoneroViewOutputDetails> utxos;
  MoneroAccountWithUtxo(
      {required this.address, required List<MoneroViewOutputDetails> utxos})
      : utxos = utxos.immutable;
  @override
  String toString() {
    return {"address": address.view, "Utxos": utxos}.toString();
  }
}

class MoneroOutputWithBalance {
  final ReceiptAddress<MoneroAddress> address;
  final IntegerBalance amount;
  MoneroOutputWithBalance(
      {required this.address, required WalletMoneroNetwork network})
      : amount = IntegerBalance.zero(network.token, allowNegative: false);
  bool _hasAmount = false;
  bool get hasAmount => _hasAmount;

  MoneroTxDestination toMoneroDestination() {
    return MoneroTxDestination(
        amount: amount.balance, address: address.networkAddress);
  }

  void updateBalance([BigInt? updateBalance]) {
    amount.updateBalance(updateBalance);
    _hasAmount = amount.largerThanZero;
  }

  bool get isIntegratedRecipient => address.networkAddress.isIntegratedAddress;
}

class MoneroChainTrackerResponse with CborSerializable {
  final List<String> txIds;
  final int blockLength;
  final int startHeight;
  int get height => startHeight + blockLength;
  final MoneroBlockTrackingStatus status;
  MoneroChainTrackerResponse(
      {required List<String> txIds,
      required this.blockLength,
      required this.startHeight,
      required this.status})
      : txIds = txIds
            .map((e) => QuickCryptoValidator.asValidHexBytes(e,
                lengthInBytes: MoneroConst.txHashLength))
            .toImutableList;

  factory MoneroChainTrackerResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroChainTrackingResponse);
    return MoneroChainTrackerResponse(
        txIds: values
            .elementAsListOf<CborBytesValue>(0)
            .map((e) => String.fromCharCodes(e.value))
            .toList(),
        blockLength: values.elementAs(1),
        startHeight: values.elementAs(2),
        status: MoneroBlockTrackingStatus.fromValue(values.elementAs(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              txIds.map((e) => CborBytesValue(e.codeUnits)).toList()),
          blockLength,
          startHeight,
          status.value
        ]),
        CborTagsConst.moneroChainTrackingResponse);
  }
}

class MoneroUpdatePaymentRequest {
  final List<MoneroOutputDetails> payments;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  MoneroUpdatePaymentRequest(
      {required List<MoneroOutputDetails> payments,
      required this.primaryAddress})
      : payments = payments.imutable;
}

class MoneroAccountPendingTxes with CborSerializable, Equatable {
  List<String> _txIDs;
  List<String> get txIDs => _txIDs;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  MoneroAccountPendingTxes(
      {Iterable<String> txIDs = const [], required this.primaryAddress})
      : _txIDs = txIDs.toImutableList;

  factory MoneroAccountPendingTxes.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.moneroAccountPendingTxes);
    return MoneroAccountPendingTxes(
        primaryAddress: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(0)),
        txIDs: values
            .elementAsListOf<CborStringValue>(1)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          primaryAddress.toCbor(),
          txIDs.map((e) => CborStringValue(e)).toList()
        ]),
        CborTagsConst.moneroAccountPendingTxes);
  }

  void addTxes(Iterable<String> txs) {
    _txIDs = <String>{..._txIDs, ...txs}.toImutableList;
  }

  @override
  List get variabels => [primaryAddress];

  @override
  String toString() {
    return {"address": primaryAddress, "txIds": _txIDs}.toString();
  }
}

class MoneroFetchTxIdsResponse {
  final List<MoneroTxInfo> txes;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  MoneroFetchTxIdsResponse(
      {required List<MoneroTxInfo> txes, required this.primaryAddress})
      : txes = txes.imutable;
}

class MoneroProcessTxIdsRequest with CborSerializable {
  final List<MoneroTxInfo> txes;
  final MoneroViewPrimaryAccountDetails primaryAddress;
  final List<MoneroAccountIndex> keyIndexes;
  final Bip32AddressIndex index;
  MoneroProcessTxIdsRequest(
      {required List<MoneroTxInfo> txes,
      required this.primaryAddress,
      required List<MoneroAccountIndex> keyIndexes,
      required this.index})
      : txes = txes.immutable,
        keyIndexes = keyIndexes.immutable;
  factory MoneroProcessTxIdsRequest.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroProcessTxIdRequest);
    return MoneroProcessTxIdsRequest(
        txes: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroTxInfo.deserialize(cbor: e))
            .toList(),
        primaryAddress: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(1)),
        keyIndexes: values
            .elementAsListOf<CborBytesValue>(2)
            .map((e) => MoneroAccountIndex.deserialize(e.value))
            .toList(),
        index: Bip32AddressIndex.deserialize(obj: values.getCborTag(3)));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(txes.map((e) => e.toCbor()).toList()),
          primaryAddress.toCbor(),
          CborListValue.fixedLength(
              keyIndexes.map((e) => CborBytesValue(e.serialize())).toList()),
          index.toCbor(),
        ]),
        CborTagsConst.moneroProcessTxIdRequest);
  }
}

class MoneroWalletRPCAddress {
  final MoneroAddress address;
  final int addressIndex;
  final int accountIndex;
  const MoneroWalletRPCAddress(
      {required this.address,
      required this.addressIndex,
      required this.accountIndex});
}

class MoneroWalletRPCAccounts {
  final MoneroAddress primary;

  final List<MoneroWalletRPCAddress> addresses;
  MoneroWalletRPCAccounts(
      {required this.primary, required List<MoneroWalletRPCAddress> addresses})
      : addresses = addresses.immutable;
  @override
  String toString() {
    return "$primary $addresses";
  }
}

class MoneroSyncAccountsRequestInfos with CborSerializable {
  final List<MoneroSyncAccountsInfos> accounts;
  MoneroSyncAccountsRequestInfos._(
      {required List<MoneroSyncAccountsInfos> accounts})
      : accounts = accounts.immutable;

  void addPendingTx(MoneroSyncAccountsInfos account, String txId) {
    final index = accounts.indexOf(account);
    assert(index >= 0, "account does not exists.");
    if (index.isNegative) return;
    accounts[index]._addPendingTx({txId});
  }

  factory MoneroSyncAccountsRequestInfos.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroSyncAccountRequestInfo);
    return MoneroSyncAccountsRequestInfos._(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroSyncAccountsInfos.deserialize(cbor: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.moneroSyncAccountRequestInfo);
  }
}

class MoneroSyncAccountsInfos with CborSerializable, Equatable {
  final MoneroViewPrimaryAccountDetails primaryAccount;
  Set<MoneroSyncAccountIndexInfo> _indexes;
  Set<MoneroSyncAccountIndexInfo> get indexes => _indexes;
  Set<String> _pendingTxes;
  Set<String> get pendingTxes => _pendingTxes;

  MoneroSyncAccountsInfos toRequest() {
    return MoneroSyncAccountsInfos(
        primaryAccount: primaryAccount, indexes: _indexes.toList());
  }

  List<MoneroSyncAccountInfo> getAddresses() {
    return _indexes
        .map((e) => MoneroSyncAccountInfo(
            address: MoneroAddress(primaryAccount.account
                .subaddress(e.index.minor, majorIndex: e.index.major)),
            startHeight: e.startHeight))
        .toList();
  }

  MoneroAccountKeys getAccountKeys() {
    return MoneroAccountKeys(
        account: primaryAccount.account,
        network: primaryAccount.network,
        indexes: _indexes.map((e) => e.index).toList());
  }

  MoneroSyncAccountsInfos(
      {List<MoneroSyncAccountIndexInfo> indexes = const [],
      required this.primaryAccount,
      List<String> pendingTxes = const []})
      : _indexes = indexes.toImutableSet,
        _pendingTxes = pendingTxes.toImutableSet;
  factory MoneroSyncAccountsInfos.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroProcessTxesResponse);
    return MoneroSyncAccountsInfos(
        primaryAccount: MoneroViewPrimaryAccountDetails.deserialize(
            object: values.getCborTag(0)),
        indexes: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => MoneroSyncAccountIndexInfo.deserialize(cbor: e))
            .toList(),
        pendingTxes: values
            .elementAsListOf<CborStringValue>(2)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          primaryAccount.toCbor(),
          CborListValue.fixedLength(_indexes.map((e) => e.toCbor()).toList()),
          CborListValue.fixedLength(
              _pendingTxes.map((e) => CborStringValue(e)).toList()),
        ]),
        CborTagsConst.moneroProcessTxesResponse);
  }

  bool _removeIndex(MoneroAccountIndex index) {
    final indexes = this.indexes.clone();
    indexes.removeWhere((e) => e.index == index);
    _indexes = indexes.toImutableSet;
    return _indexes.isNotEmpty;
  }

  void _updateStartHeights(int startHeight) {
    assert(startHeight >= 0, "invalid start height.");
    _indexes = _indexes.map((e) => e._updateHeight(startHeight)).toImutableSet;
  }

  void _addIndex(MoneroSyncAccountIndexInfo index) {
    if (_indexes.contains(index)) return;
    _indexes = {..._indexes, index}.toImutableSet;
  }

  void _addPendingTx(Iterable<String> txes) {
    _pendingTxes = {..._pendingTxes, ...txes}.toImutableSet;
  }

  void _removeTxes(Iterable<String> txes) {
    _pendingTxes = _pendingTxes.where((e) => !txes.contains(e)).toImutableSet;
  }

  @override
  List get variabels => [primaryAccount];

  @override
  String toString() {
    return {
      "index": indexes.toString(),
      "address": primaryAccount.primaryAddress,
      "pending_txes": pendingTxes
    }.toString();
  }
}

class MoneroSyncAccountIndexInfo with CborSerializable, Equatable {
  final MoneroAccountIndex index;
  final int startHeight;

  MoneroSyncAccountIndexInfo({required this.index, required this.startHeight});
  factory MoneroSyncAccountIndexInfo.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: CborTagsConst.moneroSyncAccountIndexInfo);
    return MoneroSyncAccountIndexInfo(
        index: MoneroAccountIndex.deserialize(values.elementAs(0)),
        startHeight: values.elementAs(1));
  }

  MoneroSyncAccountIndexInfo _updateHeight(int height) {
    return MoneroSyncAccountIndexInfo(index: index, startHeight: height);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(index.serialize()), startHeight]),
        CborTagsConst.moneroSyncAccountIndexInfo);
  }

  @override
  List get variabels => [index];

  @override
  String toString() {
    return {"index": index.toString(), "startHeight": startHeight}.toString();
  }
}

class MoneroSyncAccountInfo {
  final MoneroAddress address;
  final int startHeight;
  const MoneroSyncAccountInfo(
      {required this.address, required this.startHeight});
}

enum MoneroSyncBlockResponseType {
  failed(CborTagsConst.moneroBlockInfoResponse),
  success(CborTagsConst.moneroSyncAccountResponse);

  const MoneroSyncBlockResponseType(this.tag);
  final List<int> tag;
  static MoneroSyncBlockResponseType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "Invalid sync block data."));
  }
}

abstract class MoneroSyncBlocksResponse with CborSerializable {
  Set<MoneroSyncAccountsInfos> get txIds => {};
  final MoneroSyncBlockResponseType type;
  final MoneroDefaultBlockTrackingInfo offset;
  final int currentHeight;
  final int total;
  const MoneroSyncBlocksResponse._(
      {required this.type,
      required this.offset,
      required this.currentHeight,
      required this.total});
  factory MoneroSyncBlocksResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborTagValue values =
        CborSerializable.decode(cborBytes: bytes, object: cbor, hex: hex);
    final type = MoneroSyncBlockResponseType.fromTag(values.tags);
    return switch (type) {
      MoneroSyncBlockResponseType.failed =>
        MoneroSyncFailedResponse.deserialize(cbor: values),
      MoneroSyncBlockResponseType.success =>
        MoneroSyncAccountResponse.deserialize(cbor: values)
    };
  }

  T cast<T extends MoneroSyncBlocksResponse>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", "$runtimeType"]);
    }
    return this as T;
  }
}

class MoneroSyncAccountResponse extends MoneroSyncBlocksResponse {
  @override
  final Set<MoneroSyncAccountsInfos> txIds;
  MoneroSyncAccountResponse({
    required Iterable<MoneroSyncAccountsInfos> txIds,
    required super.currentHeight,
    required super.total,
    required super.offset,
  })  : txIds = txIds.toImutableSet,
        super._(type: MoneroSyncBlockResponseType.success);

  factory MoneroSyncAccountResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroSyncBlockResponseType.success.tag);
    return MoneroSyncAccountResponse(
        txIds: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => MoneroSyncAccountsInfos.deserialize(cbor: e))
            .toList(),
        currentHeight: values.elementAs(1),
        total: values.elementAs(2),
        offset: MoneroDefaultBlockTrackingInfo.deserialize(
            cbor: values.elementAs<CborTagValue>(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(txIds.map((e) => e.toCbor()).toList()),
          currentHeight,
          total,
          offset.toCbor(),
        ]),
        type.tag);
  }

  @override
  String toString() {
    return {
      "startHeight": currentHeight,
      "total": total,
    }.toString();
  }
}

class MoneroSyncFailedResponse extends MoneroSyncBlocksResponse {
  MoneroSyncFailedResponse({
    required super.currentHeight,
    required super.total,
    required super.offset,
  }) : super._(type: MoneroSyncBlockResponseType.failed);

  factory MoneroSyncFailedResponse.deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: cbor,
        hex: hex,
        tags: MoneroSyncBlockResponseType.failed.tag);
    return MoneroSyncFailedResponse(
        currentHeight: values.elementAs(0),
        total: values.elementAs(1),
        offset: MoneroDefaultBlockTrackingInfo.deserialize(
            cbor: values.elementAs<CborTagValue>(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([currentHeight, total, offset]), type.tag);
  }

  @override
  String toString() {
    return {
      "startHeight": currentHeight,
      "total": total,
    }.toString();
  }
}
