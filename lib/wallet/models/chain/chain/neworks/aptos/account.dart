part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class AptosChain extends Chain<
    AptosAPIProvider,
    AptosNetworkParams,
    AptosAddress,
    AptosFATokens,
    NFTCore,
    IAptosAddress,
    WalletAptosNetwork,
    AptosClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    AptosWalletTransaction,
    AptosContact,
    AptosNewAddressParams> {
  AptosChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.addresses})
      : super._();
  @override
  AptosChain copyWith({
    WalletAptosNetwork? network,
    List<IAptosAddress>? addresses,
    int? addressIndex,
    AptosClient? client,
    String? id,
    DefaultChainConfig? config,
  }) {
    return AptosChain._(
      network: network ?? this.network,
      addressIndex: addressIndex ?? _addressIndex,
      addresses: addresses ?? _addresses,
      client: client ?? _client,
      id: id ?? this.id,
      config: config ?? this.config,
    );
  }

  factory AptosChain.setup(
      {required WalletAptosNetwork network,
      required String id,
      AptosClient? client}) {
    return AptosChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory AptosChain.deserialize(
      {required WalletAptosNetwork network,
      required CborListValue cbor,
      AptosClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<IAptosAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => IAptosAddress.deserialize(network, obj: e))
        .toList();

    int addressIndex = cbor.elementAs(4);
    return AptosChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  @override
  Future<void> updateAddressBalance(IAptosAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: saveAccount);

      if (tokens) {
        final accountTokens = address.tokens;
        final tokenbalances = await client.getAccountTokenBalances(
            address: address.networkAddress,
            assetTypes: accountTokens.map((e) => e.assetType).toList());
        for (final token in accountTokens) {
          final balance = tokenbalances
              .firstWhereOrNull((e) => e.assetType == token.assetType);
          token._updateBalance(balance?.balance ?? BigInt.zero);
          token.setFreeze(balance?.frozen ?? false);
          _saveToken(address: address, token: token);
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required IAptosAddress address,
      required List<AptosFATokens> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final tokenbalances = await client.getAccountTokenBalances(
          address: address.networkAddress,
          assetTypes: tokens.map((e) => e.assetType).toList());
      for (final token in tokens) {
        final balance = tokenbalances
            .firstWhereOrNull((e) => e.assetType == token.assetType);
        token._updateBalance(balance?.balance ?? BigInt.zero);
        token.setFreeze(balance?.frozen ?? false);
        _saveToken(address: address, token: token);
      }
    });
  }
}
