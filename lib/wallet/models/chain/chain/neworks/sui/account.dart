part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class SuiChain extends Chain<
    SuiAPIProvider,
    SuiNetworkParams,
    SuiAddress,
    SuiToken,
    NFTCore,
    ISuiAddress,
    WalletSuiNetwork,
    SuiClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    SuiWalletTransaction,
    SuiContact,
    SuiNewAddressParams> {
  SuiChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.client,
    required super.addresses,
  }) : super._();
  @override
  SuiChain copyWith(
      {WalletSuiNetwork? network,
      List<ISuiAddress>? addresses,
      int? addressIndex,
      SuiClient? client,
      String? id,
      DefaultChainConfig? config}) {
    return SuiChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory SuiChain.setup(
      {required WalletSuiNetwork network,
      required String id,
      SuiClient? client}) {
    return SuiChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory SuiChain.deserialize(
      {required WalletSuiNetwork network,
      required CborListValue cbor,
      SuiClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<ISuiAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ISuiAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);

    return SuiChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  @override
  Future<void> updateAddressBalance(ISuiAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await initAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAcountBalances(address.networkAddress);
      final native = balance.firstWhereOrNull(
          (e) => e.coinType == SuiTransactionConst.suiTypeArgs);
      _internalupdateAddressBalance(
          address: address,
          balance: native?.totalBalance ?? BigInt.zero,
          saveAccount: saveAccount);
      for (final token in address.tokens) {
        final asset =
            balance.firstWhereOrNull((e) => e.coinType == token.assetType);
        token._updateBalance(asset?.totalBalance ?? BigInt.zero);
        _saveToken(address: address, token: token);
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required ISuiAddress address, required List<SuiToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAcountBalances(address.networkAddress);
      final native = balance.firstWhereOrNull(
          (e) => e.coinType == SuiTransactionConst.suiTypeArgs);
      _internalupdateAddressBalance(
          address: address,
          balance: native?.totalBalance ?? BigInt.zero,
          saveAccount: true);
      for (final token in tokens) {
        final asset =
            balance.firstWhereOrNull((e) => e.coinType == token.assetType);
        token._updateBalance(asset?.totalBalance ?? BigInt.zero);
        _saveToken(address: address, token: token);
      }
    });
  }
}
