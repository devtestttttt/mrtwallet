part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class ChainsHandler {
  HDWallet _wallet;
  HDWallet get wallet => _wallet;

  StreamSubscription<bool>? _networkStream;
  StreamSubscription<dynamic>? _ping;

  ChainsHandler._(
      {required Map<int, Chain> networks,
      required int network,
      required HDWallet wallet})
      : _network = network,
        _networks = networks,
        _wallet = wallet;

  static Future<ChainsHandler> setup(
      {required List<Chain> chains, required HDWallet wallet}) async {
    for (final i in chains) {
      if (i.id != wallet.checksum) {
        throw WalletExceptionConst.invalidData(
            messsage: "Invalid chain data. different wallet ids detected.");
      }
    }
    final toMap = {for (final i in chains) i.network.value: i};
    List<Chain> newChains = [];
    for (final i in ChainConst.defaultCoins.keys) {
      if (toMap.containsKey(i)) {
        continue;
      }
      final network = ChainConst.defaultCoins[i]!;
      final chain = Chain.setup(network: network, id: wallet.checksum);
      newChains.add(chain);
      toMap.addAll({chain.network.value: chain});
    }
    await Future.wait(newChains.map((e) => e.save()));
    int currentNetwork = wallet.network;
    if (!toMap.containsKey(wallet.network)) {
      currentNetwork = 0;
    }
    return ChainsHandler._(
        networks: toMap, network: currentNetwork, wallet: wallet);
  }

  final Map<int, Chain> _networks;
  String get id => _wallet.checksum;
  int _network;

  bool get hasChain => _networks.isNotEmpty;
  WalletNetwork get network => _networks[_network]!.network;
  Chain get chain => _networks[_network]!;
  List<ChainAccount> get accounts =>
      _networks.values.map((e) => e.addresses).expand((e) => e).toList();
  List<WalletNetwork> networks() =>
      _networks.values.map((e) => e.network).toList();

  void updateWalletData(HDWallet wallet) {
    if (_wallet.checksum != wallet.checksum) {
      throw WalletExceptionConst.walletDoesNotExists;
    }
    _wallet = wallet;
  }

  List<String> coinIds() {
    final ids = _networks.values
        .map((e) => e.tokens().map((e) => e.token.market?.apiId))
        .expand((e) => e)
        .where((element) => element != null);
    final networkIds = _networks.values
        .map((e) => e.network.token.market?.apiId)
        .where((element) => element != null);
    return List<String>.from([...ids, ...networkIds]);
  }

  List<Chain> chains({NetworkType? type}) {
    if (type == null) return _networks.values.toList();
    if (type.isBitcoin) {
      return _networks.values.where((e) => e.network.type.isBitcoin).toList();
    }
    return _networks.values.where((e) => e.network.type == type).toList();
  }

  Future<bool> switchNetwork(int networkId) async {
    if (_network == networkId || !_networks.containsKey(networkId)) {
      return false;
    }
    final currentChain = chain;
    _network = networkId;
    await currentChain.dispose();
    await chain.init();
    final emit = ChainWalletChainChangeEvent(prv: currentChain, current: chain);
    await _emitChainChanged(emit);
    updateWalletData(_wallet.updateNetwork(networkId));
    return true;
  }

  Future<Chain> updateImportNetwork(WalletNetwork network) async {
    int networkId = network.value;
    Chain? existChain = _networks[networkId];
    if (!network.isWalletNetwork) {
      if (!network.supportImportNetwork) {
        throw const WalletException("invalid_network_information");
      }
      if (_networks.values.any((e) =>
          e.network.type == network.type &&
          e.network.identifier == network.identifier)) {
        throw const WalletException("network_chain_id_already_exist");
      }
      final ids = _networks.values.map((e) => e.network.value).toList();
      networkId = StrUtils.findFirstMissingNumber(ids,
          start: ChainConst.importedNetworkStartId);
      network = network.copyWith(value: networkId);
      if (network.value != networkId) {
        throw const WalletException("invalid_network_information");
      }
    } else {
      if (existChain == null ||
          _networks[networkId]!.network.type != network.type) {
        throw const WalletException("invalid_network_information");
      }
    }
    if (existChain != null) {
      existChain = existChain.copyWith(network: network);
      existChain = Chain.deserialize(bytes: existChain.toCbor().encode());
    } else {
      existChain = Chain.setup(network: network, id: id);
    }
    await existChain.save();
    _networks[networkId] = existChain;
    if (existChain.network.value == _network) {
      await existChain.init();
    }
    return existChain;
  }

  Future<void> removeChain(Chain removeChain) async {
    if (removeChain.id != id) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    final hasDefaultNetwork =
        ChainConst.defaultCoins[removeChain.network.value];
    if (!removeChain.network.isWalletNetwork || hasDefaultNetwork != null) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (_network == removeChain.network.value) {
      final changeNetwork = _networks.keys.firstWhere((e) =>
          e != removeChain.network.value &&
          _networks[e]!.network.type == removeChain.network.type);
      await switchNetwork(changeNetwork);
    }
    _networks.remove(removeChain.network.value);
  }

  List<Web3ChainNetworkData> getWeb3NetworkData() {
    return _networks.values
        .where((e) => e.network.supportWeb3)
        .map((e) {
          final serviceIdentifier = e.serviceIdentifier;
          return switch (e.network.type) {
            NetworkType.ethereum => Web3ChainNetworkData<WalletEthereumNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.tron => Web3ChainNetworkData<WalletTronNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.solana => Web3ChainNetworkData<WalletSolanaNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.stellar => Web3ChainNetworkData<WalletStellarNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.ton => Web3ChainNetworkData<WalletTonNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.substrate =>
              Web3ChainNetworkData<WalletSubstrateNetwork>(
                  network: e.network.toNetwork(),
                  serviceIdentifier: serviceIdentifier),
            NetworkType.aptos => Web3ChainNetworkData<WalletAptosNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.sui => Web3ChainNetworkData<WalletSuiNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.cosmos => Web3ChainNetworkData<WalletCosmosNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
            NetworkType.bitcoinCash ||
            NetworkType.bitcoinAndForked =>
              Web3ChainNetworkData<WalletBitcoinNetwork>(
                  network: e.network.toNetwork(),
                  serviceIdentifier: serviceIdentifier),
            _ => throw UnimplementedError()
          };
        })
        .toList()
        .cast();
  }

  Future<void> _emitChainChanged(ChainWalletChainChangeEvent event) async {
    for (final i in _networks.entries) {
      await i.value._onWalletEvent(event);
    }
  }

  void _onConnectionStatus(bool isOnline) {
    final event = ChainWalletConnectionEvent(isOnline);
    for (final i in _networks.entries) {
      i.value._onWalletEvent(event);
    }
  }

  Future<void> _onPing(var _) async {
    final event = ChainWalletPingEvent();
    final aciveNetworks = _networks.values.where((e) => e.haveAddress);
    for (final i in aciveNetworks) {
      await i._onWalletEvent(event);
    }
  }

  Future<void> init() async {
    await chain.init();
    assert(_networkStream == null && _ping == null);
    _networkStream =
        PlatformInterface.instance.onNetworkStatus.listen(_onConnectionStatus);
    _ping = Stream.periodic(const Duration(minutes: 10)).listen(_onPing);
    final emit = ChainWalletChainChangeEvent(prv: null, current: chain);
    _emitChainChanged(emit);
  }

  void dispose() {
    _networkStream?.cancel();
    _ping?.cancel();
    _networkStream = null;
    _ping = null;
    for (final i in _networks.values) {
      i._disposeInternal();
    }
  }
}
