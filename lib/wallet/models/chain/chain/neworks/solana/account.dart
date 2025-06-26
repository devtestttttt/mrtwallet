part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class SolanaChain extends Chain<
    SolanaAPIProvider,
    SolanaNetworkParams,
    SolAddress,
    SolanaSPLToken,
    NFTCore,
    ISolanaAddress,
    WalletSolanaNetwork,
    SolanaClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    SolanaWalletTransaction,
    SolanaContact,
    SolanaNewAddressParams> {
  SolanaChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.addresses})
      : super._();
  @override
  SolanaChain copyWith(
      {WalletSolanaNetwork? network,
      List<ISolanaAddress>? addresses,
      int? addressIndex,
      SolanaClient? client,
      String? id,
      DefaultChainConfig? config}) {
    return SolanaChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory SolanaChain.setup(
      {required WalletSolanaNetwork network,
      required String id,
      SolanaClient? client}) {
    return SolanaChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory SolanaChain.deserialize(
      {required WalletSolanaNetwork network,
      required CborListValue cbor,
      SolanaClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<ISolanaAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ISolanaAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    return SolanaChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  @override
  Future<void> updateAddressBalance(ISolanaAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await initAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: saveAccount);
      if (tokens) {
        final tokens = address._tokens;
        final balances = await Future.wait(tokens.map((e) async {
          try {
            return await client.getTokenAddressBalance(e.tokenAccount);
          } catch (_) {
            return null;
          }
        }));
        for (int i = 0; i < tokens.length; i++) {
          final token = tokens[i];
          final balance = balances[i];
          if (balance == null) continue;
          token._updateBalance(balance);
          _saveToken(address: address, token: token);
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ISolanaAddress address,
      required List<SolanaSPLToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balances = await Future.wait(tokens.map((e) async {
        try {
          return await client.getTokenAddressBalance(e.tokenAccount);
        } catch (_) {
          return null;
        }
      }));
      for (int i = 0; i < tokens.length; i++) {
        final token = tokens[i];
        final balance = balances[i];
        if (balance == null) continue;
        token._updateBalance(balance);
        _saveToken(address: address, token: token);
      }
    });
  }
}
