part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

mixin WalletsStoragesManger on WalletStorageWriter, CryptoWokerImpl {
  Future<HDWallets> _readWallet() async {
    final wallet = await _read(key: StorageConst.hdWallets);
    if (wallet == null) {
      return HDWallets.init();
    }
    return HDWallets.fromCborBytesOrObject(hex: wallet);
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

    // final keys = await _readAll();
    // final walletKeys = keys.keys
    //     .where((element) => element.startsWith(wallet.networkKey))
    //     .toList();
    // final permissionKeys = keys.keys
    //     .where((element) => element.startsWith(wallet._web3StorageKey))
    //     .toList();
    // final repositoriesKey = keys.keys
    //     .where((element) => element.startsWith(wallet._repositoriesKeys))
    //     .toList();
    // await _deleteMultiple(
    //     keys: [...walletKeys, ...permissionKeys, ...repositoriesKey]);
  }

  Future<void> _setupWalletAccounts(
      List<WalletChainBackup> accounts, HDWallet wallet) async {
    for (final i in accounts) {
      final account = i.chain;
      await account.restoreAccount(i.repositories);
      assert(account.id == wallet._checksum, "invalid account wallet id.");
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

  Future<int?> _readStorageVersion() async {
    final r = await _read(key: StorageConst.storageVersion);
    return IntUtils.tryParse(r);
  }

  Future<void> _writeStorageVersion(int version) async {
    await _write(key: StorageConst.storageVersion, value: version.toString());
  }
}
