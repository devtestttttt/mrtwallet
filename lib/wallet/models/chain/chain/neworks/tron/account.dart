part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

enum TronChainStorageKey implements ChainStorageKey {
  contacts(0),
  transaction(1),
  token(2),
  nft(3),
  accountInfo(11),
  accountResource(12);

  @override
  final int storageId;
  const TronChainStorageKey(this.storageId);

  @override
  bool get isSharedStorage => false;
}

class TronChainConfig extends ChainConfig<TronChainStorageKey> {
  TronChainConfig();
  @override
  TronChainStorageKey? get nftStorageKey => TronChainStorageKey.nft;

  @override
  TronChainStorageKey? get tokenStorageKey => TronChainStorageKey.token;

  @override
  TronChainStorageKey get transactionStorageKey =>
      TronChainStorageKey.transaction;
  @override
  TronChainStorageKey get contactsStorageKey => TronChainStorageKey.contacts;

  @override
  List<TronChainStorageKey> get storageKeys => TronChainStorageKey.values;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([]), CborTagsConst.tronChainConfig);
  }

  @override
  List<TronChainStorageKey> get addressStorage => [
        TronChainStorageKey.transaction,
        TronChainStorageKey.token,
        TronChainStorageKey.nft,
        TronChainStorageKey.accountInfo,
        TronChainStorageKey.accountResource
      ];
}

final class TronChain extends Chain<
    TronAPIProvider,
    TronNetworkParams,
    TronAddress,
    TronToken,
    NFTCore,
    ITronAddress,
    WalletTronNetwork,
    TronClient,
    TronChainStorageKey,
    TronChainConfig,
    TronWalletTransaction,
    TronContact,
    TronNewAddressParams> with TronChainRepository {
  TronChain._(
      {required super.network,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.addresses})
      : super._();
  @override
  TronChain copyWith(
      {WalletTronNetwork? network,
      List<ITronAddress>? addresses,
      int? addressIndex,
      TronClient? client,
      String? id,
      TronChainConfig? config}) {
    return TronChain._(
        network: network ?? this.network,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory TronChain.setup(
      {required WalletTronNetwork network,
      required String id,
      TronClient? client}) {
    return TronChain._(
      network: network,
      addressIndex: 0,
      id: id,
      client: client,
      addresses: [],
      config: TronChainConfig(),
    );
  }
  factory TronChain.deserialize(
      {required WalletTronNetwork network,
      required CborListValue cbor,
      TronClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String id = cbor.elementAt<String>(2);
    final List<ITronAddress> accounts = cbor
        .elementAsListOf<CborTagValue>(3)
        .map((e) => ITronAddress.deserialize(network, obj: e))
        .toList();
    final int addressIndex = cbor.elementAs(4);
    return TronChain._(
        network: network,
        addresses: accounts,
        addressIndex: addressIndex,
        client: client,
        id: id,
        config: TronChainConfig());
  }

  @override
  Future<void> updateAddressBalance(ITronAddress address,
      {bool tokens = true, bool saveAccount = true}) async {
    _isAccountAddress(address);
    await initAddress(address);
    await onClient(onConnect: (client) async {
      final balance = await client.getAccountInfo(address.networkAddress);
      final accountInfo = balance?.accountInfo;
      final accountResource = balance?.resource;
      address._setTronAccount(accountInfo);
      address._setAccountResource(accountResource);
      _saveTronAccountInfo(address: address, accountInfo: accountInfo);
      _saveTronAccountResource(
          address: address, accountResource: accountResource);
      _internalupdateAddressBalance(
          address: address,
          balance: accountInfo?.balance ?? BigInt.zero,
          saveAccount: saveAccount);
      if (tokens) {
        final tokens = address._tokens.whereType<SolidityToken>().toList();
        final balances = await Future.wait(tokens.map((e) async {
          try {
            return await client.solidityProvider.getTokenBalance(
                contract: e.contractAddress, address: address.networkAddress);
          } catch (e) {
            return null;
          }
        }));
        for (int i = 0; i < tokens.length; i++) {
          final token = tokens[i];
          final balance = balances[i];
          if (balance == null) continue;
          token._updateBalance(balance);
          _saveToken(address: address, token: token as TronToken);
        }
      }
    });
  }

  @override
  Future<void> _initAddress(ITronAddress? address) async {
    if (address == null || !address._status.isInit) return;
    await super._initAddress(address);
    final resource = await _getTronAccountResource(address);
    address._setAccountResource(resource);
    final accountInfo = await _getTronAccountInfo(address);
    address._setTronAccount(accountInfo);
  }

  @override
  Future<void> updateTokenBalance(
      {required ITronAddress address, required List<TronToken> tokens}) async {
    _isAccountAddress(address);
    await onClient(onConnect: (client) async {
      final trc10Tokens = tokens.where((e) => e.tronTokenType.isTrc10);
      if (trc10Tokens.isNotEmpty) {
        final balance = await client.getAccountInfo(address.networkAddress);
        final accountInfo = balance?.accountInfo;
        final accountResource = balance?.resource;
        address._setTronAccount(accountInfo);
        address._setAccountResource(accountResource);
        for (final i in trc10Tokens) {
          final balance =
              accountInfo?.assetV2.firstWhereNullable((e) => i.issuer == e.key);
          i._updateBalance(balance?.value ?? BigInt.zero);
        }
      }
      final trc20Tokens = tokens.whereType<SolidityToken>().toList();
      final balances = await Future.wait(trc20Tokens.map((e) async {
        try {
          return await client.solidityProvider.getTokenBalance(
              contract: e.contractAddress, address: address.networkAddress);
        } catch (e) {
          return null;
        }
      }));
      for (int i = 0; i < trc20Tokens.length; i++) {
        final token = trc20Tokens[i];
        final balance = balances[i];
        if (balance == null) continue;
        token._updateBalance(balance);
        _saveToken(address: address, token: token as TronToken);
      }
    });
  }
}
