part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class BitcoinChain extends Chain<
    BaseBitcoinAPIProvider,
    BitcoinParams,
    BitcoinBaseAddress,
    TokenCore,
    NFTCore,
    IBitcoinAddress,
    WalletBitcoinNetwork,
    BitcoinClient,
    DefaultChainStorageKey,
    DefaultChainConfig,
    BitcoinWalletTransaction,
    BitcoinContact,
    BaseBitcoinNewAddressParams> {
  BitcoinChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.client,
    required super.addresses,
  }) : super._();
  @override
  BitcoinChain copyWith({
    WalletBitcoinNetwork? network,
    List<IBitcoinAddress>? addresses,
    int? addressIndex,
    BitcoinClient? client,
    String? id,
    DefaultChainConfig? config,
  }) {
    return BitcoinChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory BitcoinChain.setup(
      {required WalletBitcoinNetwork network,
      required String id,
      BitcoinClient? client}) {
    return BitcoinChain._(
        network: network,
        addressIndex: 0,
        id: id,
        client: client,
        addresses: [],
        config: DefaultChainConfig());
  }

  factory BitcoinChain.deserialize(
      {required WalletBitcoinNetwork network,
      required CborListValue cbor,
      BitcoinClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<IBitcoinAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => switch (network.type) {
              NetworkType.bitcoinAndForked =>
                IBitcoinAddress.deserialize(network, obj: e),
              NetworkType.bitcoinCash =>
                IBitcoinCashAddress.deserialize(network, obj: e),
              _ => throw WalletExceptionConst.invalidAccountDetails
            })
        .toList();
    final int addressIndex = cbor.elementAs(4);
    return BitcoinChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: DefaultChainConfig());
  }

  BitcoinBaseAddress? findAddressFromScript(Script script) {
    return _addresses
        .firstWhereOrNull((e) => e.networkAddress.toScriptPubKey() == script)
        ?.networkAddress;
  }

  @override
  Future<void> updateAddressBalance(IBitcoinAddress address,
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
      {required IBitcoinAddress address,
      required List<TokenCore<BalanceCore<dynamic, APPToken>, APPToken>>
          tokens}) {
    throw UnimplementedError();
  }
}
