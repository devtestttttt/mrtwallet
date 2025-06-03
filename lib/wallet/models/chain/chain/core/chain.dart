part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

abstract final class Chain<
        PROVIDER extends APIProvider,
        NETWORKPARAMS extends NetworkCoinParams,
        NETWORKADDRESS,
        CHAINTOKEN extends TokenCore,
        NFT extends NFTCore,
        ADDRESS extends ChainAccount,
        NETWORK extends WalletNetwork,
        CLIENT extends NetworkClient,
        STORAGE extends ChainStorageKey,
        CONFIG extends ChainConfig,
        TRANSACTION extends ChainTransaction,
        CONTACT extends ContactCore,
        ADDRESSPARAM extends NewAccountParams>
    extends BaseChain<
        PROVIDER,
        NETWORKPARAMS,
        NETWORKADDRESS,
        CHAINTOKEN,
        NFT,
        ADDRESS,
        NETWORK,
        CLIENT,
        STORAGE,
        CONFIG,
        TRANSACTION,
        CONTACT,
        ADDRESSPARAM>
    with
        ChainRepository<ADDRESS, NETWORK, CLIENT, STORAGE, CONFIG, CHAINTOKEN,
            NFT, TRANSACTION, CONTACT, ADDRESSPARAM>,
        BaseChainController<
            PROVIDER,
            NETWORKPARAMS,
            NETWORKADDRESS,
            CHAINTOKEN,
            NFT,
            ADDRESS,
            NETWORK,
            CLIENT,
            STORAGE,
            CONFIG,
            TRANSACTION,
            CONTACT,
            ADDRESSPARAM>,
        CborSerializable,
        CryptoWokerImpl {
  @override
  final ChainStorageManager _storage;
  String get storageId => _storage.storageId;

  NETWORK _network;
  @override
  NETWORK get network => _network;

  @override
  CLIENT? _client;
  @override
  List<ADDRESS> _addresses;
  @override
  int _addressIndex;
  @override
  final StreamValue<IntegerBalance> totalBalance;
  @override
  List<CONTACT> _contacts;
  @override
  List<ADDRESS> get addresses => _addresses;
  @override
  bool get haveAddress => addresses.isNotEmpty;
  @override
  List<CONTACT> get contacts => _contacts;
  @override
  ADDRESS get address => addresses.elementAt(_addressIndex);
  @override
  final String id;
  @override
  CONFIG _config;
  @override
  CONFIG get config => _config;

  @override
  _WalletChainStatus _status = _WalletChainStatus.init;
  @override
  NodeClientStatus _clientStatus = NodeClientStatus.disconnect;

  bool get transferEnabled => true;

  @override
  final _lock = SynchronizedLock();

  factory Chain.deserialize({String? hex, CborObject? obj, List<int>? bytes}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, hex: hex, tags: CborTagsConst.iAccount);
    final int networkId = values.elementAs(0);
    WalletNetwork? network = MethodUtils.nullOnException(() {
      return WalletNetwork.fromCborBytesOrObject(obj: values.getCborTag(1));
    });
    network = ChainConst.updateNetwork(networkId: networkId, network: network);
    final ProviderIdentifier? providerId = MethodUtils.nullOnException(() {
      final CborTagValue? identifier = values.elementAs(6);
      if (identifier == null) return null;
      return ProviderIdentifier.deserialize(cbor: identifier);
    });
    return Chain._fromNetwork(
        network: network, values: values, provider: providerId);
  }
  static Chain setup({required WalletNetwork network, required String id}) {
    switch (network.type) {
      case NetworkType.ethereum:
        return EthereumChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.tron:
        return TronChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.xrpl:
        return RippleChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.solana:
        return SolanaChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.stellar:
        return StellarChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);

      case NetworkType.cardano:
        return ADAChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.cosmos:
        return CosmosChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.ton:
        return TheOpenNetworkChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.monero:
        return MoneroChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.substrate:
        return SubstrateChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        return BitcoinChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.sui:
        return SuiChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      case NetworkType.aptos:
        return AptosChain.setup(
            network: network.toNetwork(),
            client: APIUtils.createApiClient(network),
            id: id);
      default:
        throw UnimplementedError("network does not eixst.");
    }
  }

  factory Chain._fromNetwork(
      {required WalletNetwork network,
      required CborListValue values,
      ProviderIdentifier? provider}) {
    final Chain chain;
    switch (network.type) {
      case NetworkType.bitcoinCash:
      case NetworkType.bitcoinAndForked:
        chain = BitcoinChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.substrate:
        chain = SubstrateChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.ethereum:
        chain = EthereumChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.cosmos:
        chain = CosmosChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.ton:
        chain = TheOpenNetworkChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.tron:
        chain = TronChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.xrpl:
        chain = RippleChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.solana:
        chain = SolanaChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.stellar:
        chain = StellarChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.monero:
        chain = MoneroChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;

      case NetworkType.cardano:
        chain = ADAChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.sui:
        chain = SuiChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      case NetworkType.aptos:
        chain = AptosChain.deserialize(
            network: network.toNetwork(),
            cbor: values,
            client: APIUtils.createApiClient(network, identifier: provider));
        break;
      default:
        throw UnimplementedError("Network does not exist");
    }
    return chain.cast();
  }

  Chain._(
      {required NETWORK network,
      required this.id,
      required CONFIG config,
      List<ADDRESS> addresses = const [],
      required int addressIndex,
      required CLIENT? client})
      : _addresses = addresses.imutable,
        _network = network,
        _addressIndex = addressIndex < 0 || addressIndex >= addresses.length
            ? 0
            : addressIndex,
        _contacts = [],
        _client = client,
        _config = config,
        totalBalance = StreamValue.immutable(IntegerBalance.token(
            BaseChainController._totalBalance(addresses), network.token,
            immutable: true)),
        _storage =
            ChainStorageManager(network: network, id: id, config: config);

  Chain copyWith(
      {NETWORK? network,
      List<ADDRESS>? addresses,
      int? addressIndex,
      String? id,
      CONFIG? config,
      CLIENT? client});

  Future<void> _reloadChain() async {
    final account = await _storage.loadAccount();
    final chain = Chain.deserialize(hex: account);
    assert(chain.id == id);
    if (chain.id != id || chain.network.type != network.type) {
      return;
    }
    await chain.init();
    await _callSynchronized(
        t: () async {
          _contacts = [];
          _network = chain._network.toNetwork<NETWORK>();
          _addresses = chain._addresses.cast<ADDRESS>();
          _config = chain._config as CONFIG;
          _client = chain._client as CLIENT;
          _contacts = chain.contacts.cast<CONTACT>();
          _status = _WalletChainStatus.init;
          totalBalance.value._updateBalance(chain.totalBalance.value.balance);
        },
        type: ChainNotify.account,
        notifyProgress: true,
        allowStatus: null);
    await init();
  }

  Future<void> reloadChain() async {
    await _reloadChain();
  }
}
