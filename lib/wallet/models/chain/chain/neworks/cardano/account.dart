part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ADAChain extends Chain<
    CardanoAPIProvider,
    CardanoNetworkParams,
    ADAAddress,
    TokenCore,
    NFTCore,
    ICardanoAddress,
    WalletCardanoNetwork,
    CardanoClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    ADAWalletTransaction,
    CardanoContact,
    CardanoNewAddressParams> {
  ADAChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.client,
    required super.addresses,
  }) : super._();
  @override
  ADAChain copyWith({
    WalletCardanoNetwork? network,
    List<ICardanoAddress>? addresses,
    int? addressIndex,
    CardanoClient? client,
    String? id,
    DefaultChainConfig? config,
  }) {
    return ADAChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory ADAChain.setup(
      {required WalletCardanoNetwork network,
      required String id,
      CardanoClient? client}) {
    return ADAChain._(
        network: network,
        addressIndex: 0,
        id: id,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory ADAChain.deserialize(
      {required WalletCardanoNetwork network,
      required CborListValue cbor,
      CardanoClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<ICardanoAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ICardanoAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    return ADAChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  @override
  Future<void> updateAddressBalance(ICardanoAddress address,
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
      {required ICardanoAddress address,
      required List<TokenCore<BalanceCore<dynamic, APPToken>, APPToken>>
          tokens}) async {
    throw UnimplementedError();
  }
}
