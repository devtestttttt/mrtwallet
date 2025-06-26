import 'package:on_chain_wallet/app/native_impl/core/core.dart';

mixin NativeSecureStorageImpl {
  String get storageId;
  String _toKey(String key) {
    return "${storageId}_$key";
  }

  Future<String?> read({required String key}) async {
    return await AppNativeMethods.platform.readSecure(_toKey(key));
  }

  Future<void> write({required String key, required String value}) async {
    await AppNativeMethods.platform.writeSecure(_toKey(key), value);
  }

  Future<void> deleteAll({String? identifier}) async {
    final key = identifier == null ? null : _toKey(identifier);
    await AppNativeMethods.platform.removeAllSecure(prefix: key);
  }

  Future<void> delete(String key) async {
    await AppNativeMethods.platform.removeSecure(_toKey(key));
  }

  Future<Map<String, String>> readAll({String? identifier}) async {
    final key = identifier == null ? null : _toKey(identifier);
    return await AppNativeMethods.platform.readAllSecure(prefix: key);
  }

  Future<bool> deleteMultiple(List<String> keys) async {
    return await AppNativeMethods.platform
        .removeMultipleSecure(keys.map(_toKey).toList());
  }
}
