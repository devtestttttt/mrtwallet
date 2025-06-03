part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

base mixin MoneroChainRepository on Chain<
    MoneroAPIProvider,
    MoneroNetworkParams,
    MoneroAddress,
    TokenCore,
    NFTCore,
    IMoneroAddress,
    WalletMoneroNetwork,
    MoneroClient,
    MoneroChainStorage,
    MoneroChainConfig,
    MoneroWalletTransaction,
    MoneroContact,
    MoneroNewAddressParams> {
  MoneroAccountBlocksTracker get defaultTracker;
  MoneroAddressUtxos get _accountUtxos;

  Future<void> _saveDefaultTracker() async {
    await _storage.writeStorageItem(
        storage: MoneroChainStorage.defaultTracker, item: defaultTracker);
  }

  Future<MoneroAccountBlocksTracker> _getDefaultTracker() async {
    try {
      final data = await _storage.readStorage(
          storage: MoneroChainStorage.defaultTracker);
      if (data == null) {
        return MoneroAccountBlocksTracker.start();
      }
      return MoneroAccountBlocksTracker.deserialize(hex: data);
    } catch (e) {
      assert(false, "tracker deserialization failed.");
      return MoneroAccountBlocksTracker.start();
    }
  }

  Future<MoneroSyncChain> _getSyncChain() async {
    final data =
        await _storage.readSharedStorage(storage: MoneroChainStorage.syncChain);
    if (data == null) {
      return MoneroSyncChain.mainnet;
    }
    return MoneroSyncChain.deserialize(hex: data);
  }

  Future<void> _saveSyncChain(MoneroSyncChain syncChain) async {
    await _storage.writeSharedStorageItem(
        storage: MoneroChainStorage.syncChain, item: syncChain);
  }

  Future<MoneroAPIProvider?> _getWalletRPC() async {
    final data =
        await _storage.readStorage(storage: MoneroChainStorage.walletRPC);
    if (data == null) return null;
    return MoneroAPIProvider.fromCborBytesOrObject(hex: data);
  }

  Future<MoneroWalletClient?> _getWalletClient() async {
    final provider = await _getWalletRPC();
    if (provider == null) return null;
    return MoneroWalletClient(provider, network);
  }

  Future<void> _saveWalletRpc(MoneroAPIProvider? provider) async {
    await _storage.writeStorageItem(
        storage: MoneroChainStorage.walletRPC, item: provider);
  }

  Future<void> _saveUtxos() async {
    final storageKey = MoneroChainStorage.addressUtxos;
    await _storage.writeStorageItem(storage: storageKey, item: _accountUtxos);
  }

  Future<MoneroAddressUtxos> _getAccountUtxos() async {
    final storagekey = MoneroChainStorage.addressUtxos;
    final data = await _storage.readStorage(storage: storagekey);
    if (data == null) return MoneroAddressUtxos();
    try {
      return MoneroAddressUtxos.deserialize(hex: data);
    } catch (e) {
      assert(false, 'monero address deserialization failed. $e');
      return MoneroAddressUtxos();
    }
  }
}
