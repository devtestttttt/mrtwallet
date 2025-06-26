part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class StellarChain extends Chain<
    StellarAPIProvider,
    StellarNetworkParams,
    StellarAddress,
    StellarIssueToken,
    NFTCore,
    IStellarAddress,
    WalletStellarNetwork,
    StellarClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    StellarWalletTransaction,
    StellarContact,
    StellarNewAddressParams> {
  StellarChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.addresses})
      : super._();
  @override
  StellarChain copyWith({
    WalletStellarNetwork? network,
    List<IStellarAddress>? addresses,
    int? addressIndex,
    StellarClient? client,
    String? id,
    DefaultChainConfig? config,
  }) {
    return StellarChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory StellarChain.setup(
      {required WalletStellarNetwork network,
      required String id,
      StellarClient? client}) {
    return StellarChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory StellarChain.deserialize(
      {required WalletStellarNetwork network,
      required CborListValue cbor,
      StellarClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<IStellarAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => IStellarAddress.deserialize(network, obj: e))
        .toList();

    final int addressIndex = cbor.elementAs(4);
    return StellarChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  @override
  Future<void> updateAddressBalance(IStellarAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await initAddress(address);
    await onClient(onConnect: (client) async {
      final accountInfo = await client.getAccount(address.networkAddress);
      final balance = accountInfo?.balances
              .whereType<StellarNativeBalanceResponse>()
              .fold(BigInt.zero, (p, c) => p + c.unlockedBalance) ??
          BigInt.zero;
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: saveAccount);
      for (final i in address.tokens) {
        final balance = accountInfo?.getAssetByIssueAsset(i);
        if (balance == null) {
          i._updateBalance(BigInt.zero);
        } else {
          i._updateBalance(balance.unlockedBalance);
        }
        _saveToken(address: address, token: i);
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required IStellarAddress address,
      required List<StellarIssueToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final accountInfo = await client.getAccount(address.networkAddress);
      final balance = accountInfo?.balances
              .whereType<StellarNativeBalanceResponse>()
              .fold(BigInt.zero, (p, c) => p + c.unlockedBalance) ??
          BigInt.zero;
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: true);
      for (final i in tokens) {
        final balance = accountInfo?.getAssetByIssueAsset(i);
        if (balance == null) {
          i._updateBalance(BigInt.zero);
        } else {
          i._updateBalance(balance.unlockedBalance);
        }
        _saveToken(address: address, token: i);
      }
    });
  }
}
