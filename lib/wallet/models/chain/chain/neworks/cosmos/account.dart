part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

enum CosmosChainStorage implements ChainStorageKey {
  contacts(0),
  transaction(1),
  token(2),
  nft(3),
  channelIds(11);

  @override
  bool get isSharedStorage => false;
  @override
  final int storageId;
  const CosmosChainStorage(this.storageId);
}

class CosmosChainConfig extends ChainConfig<CosmosChainStorage> {
  CosmosChainConfig();
  factory CosmosChainConfig.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    return CosmosChainConfig();
  }

  @override
  double get appbarHeight => 0;

  @override
  bool get hasAction => false;

  @override
  CosmosChainStorage? get nftStorageKey => null;

  @override
  CosmosChainStorage? get tokenStorageKey => CosmosChainStorage.token;

  @override
  CosmosChainStorage get transactionStorageKey =>
      CosmosChainStorage.transaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([]), CborTagsConst.cosmosChainConfig);
  }

  @override
  List<CosmosChainStorage> get storageKeys => CosmosChainStorage.values;

  @override
  CosmosChainStorage get contactsStorageKey => CosmosChainStorage.contacts;

  @override
  List<CosmosChainStorage> get addressStorage => [
        CosmosChainStorage.transaction,
        CosmosChainStorage.nft,
        CosmosChainStorage.token
      ];
}

final class CosmosChain extends Chain<
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
    CosmosNewAddressParams> with CosmosChainRepository {
  CosmosChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.addresses})
      : super._();
  @override
  CosmosChain copyWith(
      {WalletCosmosNetwork? network,
      StreamValue<IntegerBalance>? totalBalance,
      List<ICosmosAddress>? addresses,
      int? addressIndex,
      CosmosClient? client,
      String? id,
      CosmosChainConfig? config}) {
    return CosmosChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory CosmosChain.setup(
      {required WalletCosmosNetwork network,
      required String id,
      CosmosClient? client}) {
    return CosmosChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: CosmosChainConfig());
  }
  factory CosmosChain.deserialize(
      {required WalletCosmosNetwork network,
      required CborListValue cbor,
      CosmosClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<ICosmosAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ICosmosAddress.deserialize(network, obj: e))
        .toList();
    int addressIndex = cbor.elementAs(4);
    return CosmosChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: CosmosChainConfig());
  }

  @override
  Future<void> updateAddressBalance(ICosmosAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balances = await client.getAddressCoins(address.networkAddress);
      final nativeToken =
          balances.firstWhereOrNull((e) => e.denom == network.coinParam.denom);
      _internalupdateAddressBalance(
          address: address,
          balance: nativeToken?.amount ?? BigInt.zero,
          saveAccount: saveAccount);
      for (final i in address.tokens) {
        final balance = balances.firstWhereOrNull((e) => e.denom == i.denom);
        i._updateBalance(balance?.amount ?? BigInt.zero);
        _saveToken(address: address, token: i);
      }
    });
  }

  Future<void> saveChannelId(CosmosIBCChannelId channel) async {
    await _callSynchronized(t: () async {
      await _saveChannelId(channel);
    });
  }

  @override
  Future<void> _initInternal() async {
    await super._initInternal();
    await _loadChannelIds();
  }

  @override
  Future<void> updateTokenBalance(
      {required ICosmosAddress address,
      required List<CW20Token> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balances = await client.getAddressCoins(address.networkAddress);
      final nativeToken =
          balances.firstWhereOrNull((e) => e.denom == network.coinParam.denom);
      _internalupdateAddressBalance(
          address: address,
          balance: nativeToken?.amount ?? BigInt.zero,
          saveAccount: true);
      for (final i in tokens) {
        final balance = balances.firstWhereOrNull((e) => e.denom == i.denom);
        i._updateBalance(balance?.amount ?? BigInt.zero);
        _saveToken(address: address, token: i);
      }
    });
  }
}
