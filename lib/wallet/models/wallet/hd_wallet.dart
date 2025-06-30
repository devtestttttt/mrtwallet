import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/constant/global/storage_key.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/app/synchronized/basic_lock.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/setting/models/lock_time.dart';

final class HDWalletsConst {
  static const String initializeName = "Wallet";
  static const String firstWalletName = "$initializeName (1)";
}

final class HDWallets with CborSerializable {
  final _lock = SynchronizedLock();
  Map<String, HDWallet> _wallets;
  Map<String, HDWallet> get wallets => _wallets;
  String? _currentWallet;
  bool get hasWallet => _wallets.isNotEmpty;
  bool get needSetup => _wallets.isEmpty;

  List<String> get walletNames => _wallets.keys.toList();

  factory HDWallets.init() => HDWallets._(wallets: {});

  HDWallets._({required Map<String, HDWallet> wallets, String? currentWallet})
      : _wallets = Map<String, HDWallet>.unmodifiable(wallets),
        _currentWallet = wallets.containsKey(currentWallet)
            ? currentWallet
            : wallets.isEmpty
                ? null
                : wallets.keys.first;

  factory HDWallets.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.wallets);
    final wallets = values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => HDWallet.deserialize(obj: e));
    return HDWallets._(
        wallets: Map<String, HDWallet>.fromEntries(
            wallets.map((e) => MapEntry<String, HDWallet>(e.name, e))),
        currentWallet: values.elementAs(1));
  }

  HDWallet _getInitializeWallet({String? name}) {
    if (_wallets.isEmpty) {
      throw WalletExceptionConst.incompleteWalletSetup;
    }
    if (_wallets.containsKey(name)) {
      return _wallets[name]!;
    }
    if (_wallets.containsKey(_currentWallet)) {
      return _wallets[_currentWallet]!;
    }
    final wallet = _wallets.values.first;
    return wallet;
  }

  Future<HDWallet> getInitializeWallet({String? name}) async {
    return _lock.synchronized(() async {
      final wallet = _getInitializeWallet(name: name);
      _currentWallet = wallet.name;
      return wallet;
    });
  }

  Future<void> removeWallet(HDWallet wallet) async {
    _lock.synchronized(() async {
      if (_wallets.containsKey(wallet.name)) {
        final wallets = Map<String, HDWallet>.from(_wallets);
        wallets.remove(wallet.name);
        _wallets = Map<String, HDWallet>.unmodifiable(wallets);
        return;
      }
      throw WalletExceptionConst.walletDoesNotExists;
    });
  }

  Future<void> updateWallet(HDWallet wallet) async {
    await _lock.synchronized(() async {
      final current = _wallets.values.firstWhere(
          (element) => element.checksum == wallet.checksum,
          orElse: () => throw WalletExceptionConst.walletDoesNotExists);
      if (wallet.name != current.name && _wallets.containsKey(wallet.name)) {
        throw WalletExceptionConst.walletNameExists;
      }

      final wallets = Map<String, HDWallet>.from(_wallets);
      wallets.remove(current.name);
      wallets.addAll({wallet.name: wallet});
      _wallets = Map<String, HDWallet>.unmodifiable(wallets);
    });
  }

  void _validateImport(HDWallet newWallet) {
    if (_wallets.containsKey(newWallet.name) ||
        _wallets.values
            .any((element) => element.checksum == newWallet.checksum)) {
      throw WalletExceptionConst.walletAlreadyExists;
    }
  }

  Future<void> setupNewWallet(
    HDWallet newWallet,
  ) async {
    return _lock.synchronized(() async {
      _validateImport(newWallet);
      final updateWallet = newWallet._updateCreated();
      final wallets = Map<String, HDWallet>.from(_wallets);
      wallets.addAll({updateWallet.name: updateWallet});
      _wallets = Map<String, HDWallet>.unmodifiable(wallets);
    });
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              _wallets.values.map((e) => e._toCbor()).toList()),
          _currentWallet ?? const CborNullValue()
        ]),
        CborTagsConst.wallets);
  }
}

final class HDWallet {
  final String checksum;
  final String name;
  final String data;
  final bool requiredPassword;
  final bool protectWallet;
  final WalletLockTime locktime;
  final int network;
  final DateTime created;

  const HDWallet._(
      {required this.checksum,
      required this.name,
      required this.data,
      required this.requiredPassword,
      required this.locktime,
      required this.network,
      required this.created,
      required this.protectWallet});
  factory HDWallet({
    required String checksum,
    required String name,
    required String data,
    required bool requiredPassword,
    required WalletLockTime locktime,
    required int network,
    bool protectWallet = true,
    DateTime? created,
  }) {
    if (name.trim().isEmpty || name.length < 3 || name.length > 15) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    final lockTime = locktime.value ~/ 60;
    if (lockTime < 1 || lockTime > 30) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return HDWallet._(
        checksum: checksum,
        name: name,
        data: data,
        requiredPassword: requiredPassword,
        locktime: locktime,
        network: network,
        created: created ?? DateTime.now(),
        protectWallet: protectWallet);
  }

  factory HDWallet.setup(
      {required String checksum,
      required String name,
      required String data,
      bool protectWallet = true}) {
    return HDWallet(
        checksum: checksum,
        name: name,
        data: data,
        requiredPassword: false,
        locktime: WalletLockTime.fiveMinute,
        network: 0,
        created: DateTime.now(),
        protectWallet: protectWallet);
  }
  HDWallet updateData(String updateData) {
    return HDWallet(
        checksum: checksum,
        name: name,
        data: updateData,
        requiredPassword: requiredPassword,
        network: network,
        locktime: locktime,
        created: created,
        protectWallet: protectWallet);
  }

  HDWallet updateNetwork(int updateNetworkId) {
    return HDWallet(
        checksum: checksum,
        name: name,
        data: data,
        requiredPassword: requiredPassword,
        network: updateNetworkId,
        locktime: locktime,
        created: created,
        protectWallet: protectWallet);
  }

  HDWallet _updateCreated() {
    return HDWallet(
        checksum: checksum,
        name: name,
        data: data,
        requiredPassword: requiredPassword,
        network: network,
        locktime: locktime,
        created: DateTime.now(),
        protectWallet: protectWallet);
  }

  HDWallet updateSettings({
    required WalletLockTime newLockTime,
    required bool reqPassword,
    required String newName,
    required bool protectWallet,
  }) {
    if (newName.trim().isEmpty || newName.length < 3 || newName.length > 15) {
      throw WalletExceptionConst.dataVerificationFailed;
    }

    return HDWallet(
        checksum: checksum,
        name: newName,
        data: data,
        requiredPassword: reqPassword,
        network: network,
        locktime: newLockTime,
        created: created,
        protectWallet: protectWallet);
  }

  factory HDWallet.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.wallet);
    final int? setting = cbor.elementAt(5);
    final network = cbor.elementAt<int>(4);
    WalletLockTime lockTime = WalletLockTime.fiveMinute;
    if (setting != null) {
      lockTime = WalletLockTime.fromValue(setting);
    }
    return HDWallet(
        checksum: cbor.elementAt(0),
        name: cbor.elementAt(1),
        data: cbor.elementAt(2),
        requiredPassword: cbor.elementAt(3),
        network: network,
        locktime: lockTime,
        created: cbor.elementAt<DateTime>(6),
        protectWallet: cbor.elementAt<bool?>(7) ?? true);
  }

  CborTagValue _toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          checksum,
          name,
          data,
          CborBoleanValue(requiredPassword),
          network,
          locktime.value,
          CborEpochIntValue(created),
          protectWallet
        ]),
        CborTagsConst.wallet);
  }

  List<int> get checkSumBytes => BytesUtils.fromHexString(checksum);
  String get storageKey => "${StorageConst.walletStorageKey}${checksum}_";
  String get chainStorageKey => "${StorageConst.chainSorageKey}${checksum}_";
  String get sharedStorageKey =>
      "${StorageConst.chainSharedSorageKey}${checksum}_";
  String get web3StorageKey => "${StorageConst.web3StorageKey}${checksum}_";
  String get wcStorageKey =>
      "${StorageConst.walletConnectStorageKey}${checksum}_";

  String web3ClientStorageKey(String applicationId) {
    return "$web3StorageKey$applicationId";
  }
}
