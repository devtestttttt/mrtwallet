part of 'package:on_chain_wallet/repository/repository.dart';

mixin BaseRepository {
  String get repositoryStorageId;
  String _toKey(String storageId, String key) {
    assert(key.trim().isNotEmpty && key != StorageConst.walletStorageKey);
    return "${StorageConst.baseStoragePrefix}${storageId}_$key";
  }

  Future<void> write({required String key, required String value}) async {
    await AppNativeMethods.platform
        .writeSecure(_toKey(repositoryStorageId, key), value);
  }

  Future<String?> read(String key) async {
    return await AppNativeMethods.platform
        .readSecure(_toKey(repositoryStorageId, key));
  }

  Future<void> deleteAll({String? identifier}) async {
    await AppNativeMethods.platform
        .removeAllSecure(prefix: _toKey(repositoryStorageId, identifier ?? ''));
  }

  Future<Map<String, String>> readAll({String? identifier}) async {
    return await AppNativeMethods.platform
        .readAllSecure(prefix: _toKey(repositoryStorageId, identifier ?? ''));
  }

  Future<void> remove(String key) async {
    await AppNativeMethods.platform
        .removeSecure(_toKey(repositoryStorageId, key));
  }

  Future<void> deleteMultiple(List<String> keys) async {
    await AppNativeMethods.platform.removeMultipleSecure(
        keys.map((e) => _toKey(repositoryStorageId, e)).toList());
  }
}
