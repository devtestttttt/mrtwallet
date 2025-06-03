part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

base mixin CosmosChainRepository on Chain<
    CosmosAPIProvider,
    CosmosNetworkParams,
    CosmosBaseAddress,
    CW20Token,
    NFTCore,
    ICosmosAddress,
    WalletCosmosNetwork,
    CosmosClient,
    ChainStorageKey,
    CosmosChainConfig,
    CosmosWalletTransaction,
    CosmosContact,
    CosmosNewAddressParams> {
  CosmosAccountIBCChannelIds _channelId = CosmosAccountIBCChannelIds();
  CosmosAccountIBCChannelIds get channelId => _channelId;
  Future<void> _loadChannelIds() async {
    try {
      final data =
          await _storage.readStorage(storage: CosmosChainStorage.channelIds);
      if (data == null) return;
      _channelId = CosmosAccountIBCChannelIds.deserialize(hex: data);
    } catch (_) {
      assert(false, "load cosmos channel ids failed.");
    }
  }

  Future<void> _saveChannelId(CosmosIBCChannelId channel) async {
    _channelId.addChannel(channel);
    await _storage.writeStorageItem(
        storage: CosmosChainStorage.channelIds, item: _channelId);
  }
}
