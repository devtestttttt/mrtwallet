part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class ChainStorageManagerUtils {
  /// storage id for save chain data
  static String buildStorageId(int networkId, String walletid) {
    return "${StorageConst.walletStorageKey}${walletid}_${networkId.toString()}";
  }

  /// base storage id for save network stroage ids like tx,token, and ...
  static String buildChainStorageId(int networkId, String walletid) {
    return "${StorageConst.chainSorageKey}${walletid}_${networkId.toString()}_";
  }

  static String buildSharedStorageId(NetworkType network, String walletid) {
    return "${StorageConst.chainSharedSorageKey}${walletid}_${network.value}_";
  }

  static String buildChainStorageStorageId(String chainStorageId, int storageId,
      {String? suffix}) {
    return "$chainStorageId${storageId}_${suffix ?? ''}";
  }

  static (int, String?) cleanUpChainStorageKey(
      {required String key, required String chainStorageId}) {
    assert(key.startsWith(chainStorageId), "invalid chain storage key");
    final withoutChain = key.replaceFirst(chainStorageId, '');
    final parts = withoutChain.split('_');
    final int storageId = int.parse(parts[0]);
    final suffix = withoutChain.substring(parts[0].length + 1);
    final String? prefix = suffix.isEmpty ? null : suffix;
    return (storageId, prefix);
  }
}

class ChainStorageManager {
  final ChainConfig config;
  final int networkId;
  final String id;
  final String storageId;
  final String chainStorageId;
  final String sharedStorageId;
  const ChainStorageManager._(
      {required this.networkId,
      required this.id,
      required this.storageId,
      required this.chainStorageId,
      required this.config,
      required this.sharedStorageId});
  factory ChainStorageManager(
      {required WalletNetwork network,
      required String id,
      required ChainConfig config}) {
    return ChainStorageManager._(
        networkId: network.value,
        id: id,
        storageId: ChainStorageManagerUtils.buildStorageId(network.value, id),
        chainStorageId:
            ChainStorageManagerUtils.buildChainStorageId(network.value, id),
        config: config,
        sharedStorageId:
            ChainStorageManagerUtils.buildSharedStorageId(network.type, id));
  }
  String _buildStorageKey(ChainStorageKey storage, {String? suffix}) {
    assert(config.storageKeys.contains(storage), "invalid storage key");
    return ChainStorageManagerUtils.buildChainStorageStorageId(
        chainStorageId, storage.storageId,
        suffix: suffix);
  }

  String _buildSharedStorageKey(ChainStorageKey storage, {String? suffix}) {
    assert(config.storageKeys.contains(storage), "invalid storage key");
    assert(storage.isSharedStorage, "invalid storage key");
    return ChainStorageManagerUtils.buildChainStorageStorageId(
        sharedStorageId, storage.storageId,
        suffix: suffix);
  }

  Future<String?> readStorage(
      {required ChainStorageKey storage, String? identifier}) async {
    final String key = _buildStorageKey(storage, suffix: identifier);
    return await AppNativeMethods.platform.readSecure(key);
  }

  Future<String?> readSharedStorage(
      {required ChainStorageKey storage, String? identifier}) async {
    final String key = _buildSharedStorageKey(storage, suffix: identifier);
    return await AppNativeMethods.platform.readSecure(key);
  }

  Future<List<List<int>>> readStorages(
      {required ChainStorageKey storage, String? identifier}) async {
    final String key = _buildStorageKey(storage, suffix: identifier);
    final data = await AppNativeMethods.platform.readAllSecure(prefix: key);
    return data.values.map(BytesUtils.fromHexString).toList();
  }

  Future<List<List<int>>> readAccountStorages(
      {required ChainAccount account,
      required ChainStorageKey storageKey}) async {
    assert(account.network == networkId, "invalid chain account.");
    final String key = _buildStorageKey(storageKey, suffix: account.identifier);
    final keys = await AppNativeMethods.platform.readAllSecure(prefix: key);
    return keys.values.map(BytesUtils.fromHexString).toList();
  }

  Future<List<int>?> readAccountStorage(
      {required ChainAccount account,
      required ChainStorageKey storageKey}) async {
    assert(account.network == networkId, "invalid chain account.");
    final String key = _buildStorageKey(storageKey, suffix: account.identifier);
    final data = await AppNativeMethods.platform.readSecure(key);
    if (data == null) return null;
    return BytesUtils.fromHexString(data);
  }

  Future<void> writeAccountStorage(
      {required ChainAccount account,
      required ChainStorageKey storageKey,
      CborSerializable? item,
      String? identifier}) async {
    String suffix = account.identifier;
    if (identifier != null) {
      suffix = "$suffix-$identifier";
    }
    await writeStorageItem(storage: storageKey, item: item, identifier: suffix);
  }

  Future<void> cleanAddressStorage(
      {required ChainAccount account,
      required ChainStorageKey storageKey}) async {
    final String key = _buildStorageKey(storageKey, suffix: account.identifier);
    await AppNativeMethods.platform.removeAllSecure(prefix: key);
  }

  Future<List<WalletBackupChainRepository>> readAllRepositories() async {
    final shared =
        await AppNativeMethods.platform.readAllSecure(prefix: sharedStorageId);
    final keys =
        await AppNativeMethods.platform.readAllSecure(prefix: chainStorageId);
    List<WalletBackupChainRepository> chainRepositories = [];
    for (final i in keys.entries) {
      final storageKey = ChainStorageManagerUtils.cleanUpChainStorageKey(
          key: i.key, chainStorageId: chainStorageId);
      final storage = config.storageKeys
          .firstWhereOrNull((e) => e.storageId == storageKey.$1);
      // assert(storage != null, "invalid storage!");
      if (storage == null) {
        NetworkType.monero;
        continue;
      }
      final repository = WalletBackupChainRepository(
          identifier: storageKey.$2,
          storageID: storageKey.$1,
          value: i.value,
          networkID: networkId);
      chainRepositories.add(repository);
    }
    List<WalletBackupChainRepository> sharedRepositories = [];
    for (final i in shared.entries) {
      final storageKey = ChainStorageManagerUtils.cleanUpChainStorageKey(
          key: i.key, chainStorageId: sharedStorageId);
      final storage = config.storageKeys
          .firstWhereOrNull((e) => e.storageId == storageKey.$1);
      assert(storage != null, "unknow storage key ");
      assert(storage?.isSharedStorage == true, "unknow storage key ");
      if (storage == null || !storage.isSharedStorage) continue;
      final repository = WalletBackupChainRepository(
          identifier: storageKey.$2,
          storageID: storageKey.$1,
          value: i.value,
          networkID: networkId);
      sharedRepositories.add(repository);
    }
    assert(() {
      for (final i in chainRepositories) {
        final storageKey = config.storageKeys
            .firstWhereOrNull((e) => e.storageId == i.storageID);
        if (storageKey == null) return false;
        final String key = _buildStorageKey(storageKey, suffix: i.identifier);

        if (keys.containsKey(key)) return true;
        return false;
      }
      return true;
    }(), "invalid storage id");
    assert(() {
      for (final i in sharedRepositories) {
        final storageKey = config.storageKeys
            .firstWhereOrNull((e) => e.storageId == i.storageID);
        if (storageKey == null) return false;
        final String key =
            _buildSharedStorageKey(storageKey, suffix: i.identifier);
        if (!shared.containsKey(key)) return false;
      }
      return true;
    }(), "invalid shared storage id");
    return [...chainRepositories, ...sharedRepositories];
  }

  Future<void> restoreChainRepositories(
      List<WalletBackupChainRepository> repositories) async {
    for (final i in repositories) {
      if (i.networkID != networkId) {
        throw WalletExceptionConst.invalidData(
            messsage: "invalid repository data.");
      }
      final storageKey = config.storageKeys
          .firstWhereOrNull((e) => e.storageId == i.storageID);
      assert(storageKey != null, "unknown storage key");
      if (storageKey == null) continue;
      if (storageKey.isSharedStorage) {
        await _writeSharedStorageItem(
            storage: storageKey, item: i.value, identifier: i.identifier);
      } else {
        await _writeStorageItem(
            storage: storageKey, item: i.value, identifier: i.identifier);
      }
    }
  }

  Future<void> _write({required String key, required String? item}) async {
    if (item == null) {
      await AppNativeMethods.platform.removeSecure(key);
      return;
    }
    await AppNativeMethods.platform.writeSecure(key, item);
  }

  Future<void> _writeStorageItem(
      {required ChainStorageKey storage,
      required String? item,
      String? identifier}) async {
    final String key = _buildStorageKey(storage, suffix: identifier);
    await _write(key: key, item: item);
  }

  Future<void> writeStorageItem(
      {required ChainStorageKey storage,
      required CborSerializable? item,
      String? identifier}) async {
    await _writeStorageItem(
        storage: storage,
        item: item?.toCbor().toCborHex(),
        identifier: identifier);
  }

  Future<void> _writeSharedStorageItem(
      {required ChainStorageKey storage,
      required String? item,
      String? identifier}) async {
    final String key = _buildSharedStorageKey(storage, suffix: identifier);
    await _write(key: key, item: item);
  }

  Future<void> writeSharedStorageItem(
      {required ChainStorageKey storage,
      required CborSerializable? item,
      String? identifier}) async {
    await _writeSharedStorageItem(
        storage: storage,
        item: item?.toCbor().toCborHex(),
        identifier: identifier);
  }

  Future<void> saveAccount(Chain chain) async {
    if (chain.network.value != networkId || chain.id != id) {
      throw WalletExceptionConst.invalidData(messsage: "invalid network id.");
    }
    await AppNativeMethods.platform
        .writeSecure(storageId, chain.toCbor().toCborHex());
  }

  Future<String?> loadAccount() async {
    return await AppNativeMethods.platform.readSecure(storageId);
  }
}
