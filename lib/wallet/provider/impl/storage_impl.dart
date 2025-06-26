part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

mixin WalletsStoragesManger on WalletStorageWriter, CryptoWokerImpl {
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
    await AppNativeMethods.platform.removeAllSecure(prefix: wallet.storageKey);
    await AppNativeMethods.platform
        .removeAllSecure(prefix: wallet.chainStorageKey);
    await AppNativeMethods.platform
        .removeAllSecure(prefix: wallet.sharedStorageKey);
    await AppNativeMethods.platform
        .removeAllSecure(prefix: wallet.web3StorageKey);
    await AppNativeMethods.platform
        .removeAllSecure(prefix: wallet.wcStorageKey);
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
    await _removeKeys(account.storageId);
  }

  Future<List<(String, String)>> _readAccounts(HDWallet wallet) async {
    final keys = await _readAll(prefix: wallet.storageKey);
    return keys.keys.map((e) => (e, keys[e]!)).toList();
  }

  Future<String?> _readWeb3Permission(
      {required HDWallet wallet, required String applicationId}) async {
    final key = await crypto.generateHashString(
        type: CryptoRequestHashingType.md4,
        dataBytes: applicationId.codeUnits,
        isolate: false);
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
    await _remove(wallet.web3ClientStorageKey(permission.applicationKey));
  }

  Future<int?> _readStorageVersion() async {
    final r = await _read(key: StorageConst.storageVersion);
    return IntUtils.tryParse(r);
  }

  Future<void> _writeStorageVersion(int version) async {
    await _write(key: StorageConst.storageVersion, value: version.toString());
  }
}
