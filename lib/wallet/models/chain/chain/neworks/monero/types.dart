part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

enum MoneroChainStatus {
  none(value: 0, height: 0),
  outputReceived(value: 1, height: 70);

  const MoneroChainStatus({required this.value, required this.height});
  final int value;
  final double height;
  static MoneroChainStatus fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "invalid monero chain status tag"));
  }
}

class MoneroSyncChain with CborSerializable, Equatable {
  final int value;
  final ChainType? chain;
  const MoneroSyncChain._(this.value, this.chain);
  static const MoneroSyncChain none = MoneroSyncChain._(0, null);
  static const MoneroSyncChain mainnet =
      MoneroSyncChain._(1, ChainType.mainnet);
  static const MoneroSyncChain testnet =
      MoneroSyncChain._(2, ChainType.testnet);

  factory MoneroSyncChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.moneroSyncChain);
    final int value = values.elementAs(0);
    return switch (value) {
      0 => MoneroSyncChain.none,
      1 => MoneroSyncChain.mainnet,
      2 => MoneroSyncChain.testnet,
      _ => throw WalletExceptionConst.invalidData(
          messsage: "invalid monero sync chain tag")
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([value]), CborTagsConst.moneroSyncChain);
  }

  @override
  List get variabels => [value];
}

enum MoneroChainStorage implements ChainStorageKey {
  contacts(0),
  transaction(1),
  defaultTracker(11),
  // syncRequests(12),
  walletRPC(13),
  addressUtxos(14),
  syncChain(101);

  @override
  final int storageId;
  const MoneroChainStorage(this.storageId);

  @override
  bool get isSharedStorage => this == syncChain;
}

class MoneroChainConfig extends ChainConfig<MoneroChainStorage> {
  MoneroChainConfig(
      {MoneroChainStatus status = MoneroChainStatus.none,
      bool showInitializeAlert = true})
      : _status = status,
        _showInitializeAlert = showInitializeAlert;
  factory MoneroChainConfig.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.moneroChainConfig);
    return MoneroChainConfig(
        status: MoneroChainStatus.fromValue(values.elementAs(0)),
        showInitializeAlert: values.elementAs<bool?>(1) ?? true);
  }
  MoneroChainStatus _status;

  MoneroChainStatus get status => _status;

  MoneroChainConfig copyWith(
      {MoneroChainStatus? status, bool? showInitializeAlert}) {
    return MoneroChainConfig(
        showInitializeAlert: showInitializeAlert ?? this.showInitializeAlert,
        status: status ?? this.status);
  }

  @override
  double get appbarHeight => _status.height;

  @override
  bool get hasAction => _status != MoneroChainStatus.none;
  bool _showInitializeAlert;
  bool get showInitializeAlert => _showInitializeAlert;

  @override
  MoneroChainStorage get transactionStorageKey =>
      MoneroChainStorage.transaction;
  @override
  MoneroChainStorage? get nftStorageKey => null;

  @override
  MoneroChainStorage? get tokenStorageKey => null;
  @override
  MoneroChainStorage get contactsStorageKey => MoneroChainStorage.contacts;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([_status.value, _showInitializeAlert]),
        CborTagsConst.moneroChainConfig);
  }

  @override
  List<MoneroChainStorage> get storageKeys => MoneroChainStorage.values;

  @override
  List<MoneroChainStorage> get addressStorage =>
      [MoneroChainStorage.transaction];

  @override
  String toString() {
    return _status.name;
  }

  @override
  List get variabels => [storageKeys, hasAction, _status, showInitializeAlert];
}
