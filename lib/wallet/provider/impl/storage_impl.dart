part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

mixin WalletsStoragesManger {
  Future<String?> _read({required String key}) async {
    return await AppNativeMethods.platform.readSecure(key);
  }

  Future<void> _write({required String key, required String value}) async {
    await AppNativeMethods.platform.writeSecure(key, value);
  }

  Future<HDWallets> _readWallet() async {
    final wallet = await _read(key: StorageConst.hdWallets);
    if (wallet == null) {
      return HDWallets.init();
    }
    return HDWallets.deserialize(hex: wallet);
  }

  Future<void> _writeHdWallet(HDWallets wallet) async {
    await _write(
        key: StorageConst.hdWallets, value: wallet.toCbor().toCborHex());
  }

  Future<void> _removeWalletStorage(HDWallet wallet) async {
    await Future.wait([
      AppNativeMethods.platform.removeAllSecure(prefix: wallet.storageKey),
      AppNativeMethods.platform.removeAllSecure(prefix: wallet.chainStorageKey),
      AppNativeMethods.platform
          .removeAllSecure(prefix: wallet.sharedStorageKey),
      AppNativeMethods.platform.removeAllSecure(prefix: wallet.web3StorageKey),
      AppNativeMethods.platform.removeAllSecure(prefix: wallet.wcStorageKey),
    ]);
  }

  Future<void> _setupWalletBackupAccounts(
      {required HDWallet wallet, required WalletRestoreV2 backup}) async {
    for (final i in backup.chains) {
      final account = i.chain;
      await account.restoreAccount(i.repositories);
      assert(account.id == wallet.checksum, "invalid account wallet id.");
    }
    for (final i in backup.dapps) {
      await _savePermission(wallet: wallet, permission: i);
    }
  }

  Future<void> _removeAccount(Chain account) async {
    await AppNativeMethods.platform.removeAllSecure(prefix: account.storageId);
  }

  Future<List<String>> _readAccounts(HDWallet wallet) async {
    final keys = await _readAll(prefix: wallet.storageKey);
    return keys.values.toList();
  }

  Future<String?> _readWeb3Permission(
      {required HDWallet wallet, required String key}) async {
    return await _read(key: wallet.web3ClientStorageKey(key));
  }

  Future<void> _savePermission(
      {required HDWallet wallet,
      required Web3APPAuthentication permission}) async {
    await _write(
        key: wallet.web3ClientStorageKey(permission.applicationKey),
        value: permission.toCbor().toCborHex());
  }

  Future<void> _removeWeb3Permission(
      {required HDWallet wallet,
      required Web3APPAuthentication permission}) async {
    await AppNativeMethods.platform.removeSecure(permission.applicationKey);
  }

  Future<Map<String, String>> _readAll({String? prefix}) async {
    return await AppNativeMethods.platform.readAllSecure(prefix: prefix);
  }
}
