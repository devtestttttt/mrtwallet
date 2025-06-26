part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class XRPChainConfig extends DefaultChainConfig {
  XRPChainConfig();
  @override
  DefaultChainStorageKey? get nftStorageKey => DefaultChainStorageKey.nft;
}

final class RippleChain extends Chain<
    RippleAPIProvider,
    RippleNetworkParams,
    XRPAddress,
    RippleIssueToken,
    RippleNFToken,
    IXRPAddress,
    WalletXRPNetwork,
    RippleClient,
    DefaultChainStorageKey,
    XRPChainConfig,
    XRPWalletTransaction,
    RippleContact,
    RippleNewAddressParams> {
  RippleChain._({
    required super.network,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.client,
    required super.addresses,
  }) : super._();
  @override
  RippleChain copyWith({
    WalletXRPNetwork? network,
    List<IXRPAddress>? addresses,
    List<ContactCore<XRPAddress>>? contacts,
    int? addressIndex,
    RippleClient? client,
    String? id,
    XRPChainConfig? config,
  }) {
    return RippleChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory RippleChain.setup(
      {required WalletXRPNetwork network,
      required String id,
      RippleClient? client}) {
    return RippleChain._(
        network: network,
        id: id,
        addressIndex: 0,
        client: client,
        addresses: [],
        config: XRPChainConfig());
  }

  factory RippleChain.deserialize(
      {required WalletXRPNetwork network,
      required CborListValue cbor,
      RippleClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<IXRPAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => IXRPAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    return RippleChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex < 0 ? 0 : addressIndex,
        client: client,
        id: id,
        config: XRPChainConfig());
  }

  @override
  Future<void> updateAddressBalance(IXRPAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await initAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountBalance(address.networkAddress);
      _internalupdateAddressBalance(
          address: address, balance: balance, saveAccount: saveAccount);
      if (tokens) {
        final tokens = address.tokens;
        if (tokens.isEmpty) return;
        final balances = await client.getAccountTokens(address.networkAddress);
        for (final i in tokens) {
          try {
            final currentUpdate = balances.firstWhere((element) =>
                element.issuer.address == i.issuer &&
                element.symbol == i.assetCode);
            i._updateBalance(BigRational.parseDecimal(currentUpdate.balance));
          } on StateError {
            i._updateBalance(BigRational.zero);
          }
          _saveToken(address: address, token: i);
        }
      }
    });
  }

  @override
  Future<void> updateTokenBalance(
      {required IXRPAddress address,
      required List<RippleIssueToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      if (tokens.isEmpty) return;
      final balances = await client.getAccountTokens(address.networkAddress);
      for (final i in tokens) {
        try {
          final currentUpdate = balances.firstWhere((element) =>
              element.issuer.address == i.issuer &&
              element.symbol == i.assetCode);
          i._updateBalance(BigRational.parseDecimal(currentUpdate.balance));
        } on StateError {
          i._updateBalance(BigRational.zero);
        }
        _saveToken(address: address, token: i);
      }
    });
  }
}
