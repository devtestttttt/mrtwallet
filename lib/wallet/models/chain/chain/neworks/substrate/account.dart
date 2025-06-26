part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class SubstrateChain extends Chain<
    SubstrateAPIProvider,
    SubstrateNetworkParams,
    BaseSubstrateAddress,
    TokenCore,
    NFTCore,
    ISubstrateAddress,
    WalletSubstrateNetwork,
    SubstrateClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    SubstrateWalletTransaction,
    SubstrateContact,
    SubstrateNewAddressParams> {
  SubstrateChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.addresses})
      : super._();
  @override
  SubstrateChain copyWith(
      {WalletSubstrateNetwork? network,
      StreamValue<IntegerBalance>? totalBalance,
      List<ISubstrateAddress>? addresses,
      int? addressIndex,
      SubstrateClient? client,
      String? id,
      DefaultChainConfig? config}) {
    return SubstrateChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory SubstrateChain.setup({
    required WalletSubstrateNetwork network,
    required String id,
    SubstrateClient? client,
  }) {
    return SubstrateChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        config: DefaultChainConfig(),
        addresses: []);
  }

  factory SubstrateChain.deserialize(
      {required WalletSubstrateNetwork network,
      required CborListValue cbor,
      SubstrateClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<ISubstrateAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ISubstrateAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    return SubstrateChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  @override
  Future<void> updateAddressBalance(ISubstrateAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await initAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: saveAccount);
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ISubstrateAddress address,
      required List<TokenCore<BalanceCore<dynamic, APPToken>, APPToken>>
          tokens}) {
    throw UnimplementedError();
  }
}
