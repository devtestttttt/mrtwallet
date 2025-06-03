part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class TheOpenNetworkChain extends Chain<
    TonAPIProvider,
    TonNetworkParams,
    TonAddress,
    TonJettonToken,
    NFTCore,
    ITonAddress,
    WalletTonNetwork,
    TonClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    TonWalletTransaction,
    TonContact,
    TonNewAddressParams> {
  TheOpenNetworkChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.client,
    required super.addresses,
  }) : super._();
  @override
  TheOpenNetworkChain copyWith({
    WalletTonNetwork? network,
    List<ITonAddress>? addresses,
    List<ContactCore<TonAddress>>? contacts,
    int? addressIndex,
    TonClient? client,
    String? id,
    DefaultChainConfig? config,
  }) {
    return TheOpenNetworkChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory TheOpenNetworkChain.setup(
      {required WalletTonNetwork network,
      required String id,
      TonClient? client}) {
    return TheOpenNetworkChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory TheOpenNetworkChain.deserialize(
      {required WalletTonNetwork network,
      required CborListValue cbor,
      TonClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<ITonAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ITonAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    return TheOpenNetworkChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  @override
  Future<void> updateAddressBalance(ITonAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: saveAccount);
      if (tokens) {
        final tokens = address._tokens;
        final balances = await Future.wait(tokens.map((e) async {
          try {
            return await client.getJettonWalletData(e.walletAddress);
          } catch (_) {
            return null;
          }
        }));
        for (int i = 0; i < tokens.length; i++) {
          final token = tokens[i];
          final balance = balances[i];
          if (balance == null) continue;
          token._updateBalance(balance.balance);
          _saveToken(address: address, token: token);
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ITonAddress address,
      required List<TonJettonToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balances = await Future.wait(tokens.map((e) async {
        try {
          return await client.getJettonWalletData(e.walletAddress);
        } catch (_) {
          return null;
        }
      }));
      for (int i = 0; i < tokens.length; i++) {
        final token = tokens[i];
        final balance = balances[i];
        if (balance == null) continue;
        token._updateBalance(balance.balance);
        _saveToken(address: address, token: token);
      }
    });
  }
}
