part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class EthereumChain extends Chain<
    EthereumAPIProvider,
    EthereumNetworkParams,
    ETHAddress,
    ETHERC20Token,
    NFTCore,
    IEthAddress,
    WalletEthereumNetwork,
    EthereumClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    EthWalletTransaction,
    EthereumContact,
    EthereumNewAddressParams> {
  EthereumChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.addresses,
      required super.client})
      : super._();
  @override
  EthereumChain copyWith(
      {WalletEthereumNetwork? network,
      List<IEthAddress>? addresses,
      int? addressIndex,
      EthereumClient? client,
      String? id,
      DefaultChainConfig? config}) {
    return EthereumChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory EthereumChain.setup(
      {required WalletEthereumNetwork network,
      required String id,
      EthereumClient? client}) {
    return EthereumChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory EthereumChain.deserialize(
      {required WalletEthereumNetwork network,
      required CborListValue cbor,
      EthereumClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<IEthAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => IEthAddress.deserialize(network, obj: e))
        .toList();

    int addressIndex = cbor.elementAs(4);
    return EthereumChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  BigInt get chainId => network.coinParam.chainId;

  @override
  Future<void> updateAddressBalance(IEthAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getBalance(address.networkAddress);
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: saveAccount);
      if (tokens) {
        final tokens = address.tokens;
        final balances = await Future.wait(tokens.map((e) async {
          try {
            final balance = await client.getTokenBalance(
                address: address.networkAddress, contract: e.contractAddress);
            return balance;
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
      {required IEthAddress address,
      required List<ETHERC20Token> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balances = await Future.wait(tokens.map((e) async {
        try {
          final balance = await client.getTokenBalance(
              address: address.networkAddress, contract: e.contractAddress);
          return balance;
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
