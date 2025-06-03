part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

base mixin TronChainRepository on Chain<
    TronAPIProvider,
    TronNetworkParams,
    TronAddress,
    TronToken,
    NFTCore,
    ITronAddress,
    WalletTronNetwork,
    TronClient,
    TronChainStorageKey,
    TronChainConfig,
    TronWalletTransaction,
    TronContact,
    TronNewAddressParams> {
  Future<TronAccountInfo?> _getTronAccountInfo(ITronAddress address) async {
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) {
      return null;
    }
    final storagekey = TronChainStorageKey.accountInfo;
    final data = await _storage.readAccountStorage(
        account: address, storageKey: storagekey);
    if (data == null) return null;
    final accountInfo = MethodUtils.nullOnException(
        () => TronAccountInfo.deserialize(bytes: data));
    assert(accountInfo != null, 'tron account info deserialization failed.');
    return accountInfo;
  }

  Future<void> _saveTronAccountInfo(
      {required ITronAddress address,
      required TronAccountInfo? accountInfo}) async {
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) {
      return;
    }
    final storageKey = TronChainStorageKey.accountInfo;
    await _storage.writeAccountStorage(
        account: address, storageKey: storageKey, item: accountInfo);
  }

  Future<TronAccountResourceInfo?> _getTronAccountResource(
      ITronAddress address) async {
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) {
      return null;
    }
    final storagekey = TronChainStorageKey.accountResource;
    final data = await _storage.readAccountStorage(
        account: address, storageKey: storagekey);
    if (data == null) return null;
    final accountInfo = MethodUtils.nullOnException(
        () => TronAccountResourceInfo.deserialize(bytes: data));
    assert(
        accountInfo != null, 'tron account resource deserialization failed.');
    return accountInfo;
  }

  Future<void> _saveTronAccountResource(
      {required ITronAddress address,
      required TronAccountResourceInfo? accountResource}) async {
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) {
      return;
    }
    final storagekey = TronChainStorageKey.accountResource;
    await _storage.writeAccountStorage(
        account: address, storageKey: storagekey, item: accountResource);
  }
}
