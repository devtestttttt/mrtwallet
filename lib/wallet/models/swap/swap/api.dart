import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
// import 'package:on_chain_wallet/future/wallet/swaps/controller/models.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network.dart';
import 'package:on_chain_wallet/wallet/models/network/params/solana.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

import 'models.dart';

class AppSwapServiceApi extends SwapServiceApi {
  AppSwapServiceApi(this.networks, super.services);

  static Future<AppSwapServiceApi> loadApi(
      BaseSwapServiceApiParams params, List<WalletNetwork> networks) async {
    Map<SwapServiceType, SwapService> services = {};
    for (final s in params.services) {
      final SwapService service = switch (s) {
        SwapServiceType.chainFlip => await params.loadChainFlipService(),
        SwapServiceType.maya => await params.loadMayaService(),
        SwapServiceType.thor => await params.loadThorService(),
        SwapServiceType.skipGo => await params.loadSkipGoService(),
        SwapServiceType.swapKit => await params.loadSwapKitService(),
      };
      services[s] = service;
    }
    return AppSwapServiceApi(networks, services);
  }

  final List<WalletNetwork> networks;
  final Map<SwapNetwork, WalletNetwork?> _networks = {};
  Map<WalletNetwork, Set<APPSwapAssets>> _allAssets = {};
  final Map<SwapServiceType, Set<APPSwapAssets>> _localAssets = {};

  NetworkType _findNetowrkType(SwapNetwork network) {
    switch (network.type) {
      case SwapChainType.solana:
        return NetworkType.solana;
      case SwapChainType.polkadot:
        return NetworkType.substrate;
      case SwapChainType.ethereum:
        return NetworkType.ethereum;
      case SwapChainType.bitcoin:
        final bitcoinNetwork = network.cast<SwapBitcoinNetwork>();
        if (bitcoinNetwork.chain == BitcoinCashNetwork.mainnet ||
            bitcoinNetwork.chain == BitcoinCashNetwork.testnet) {
          return NetworkType.bitcoinCash;
        }
        return NetworkType.bitcoinAndForked;
      case SwapChainType.cosmos:
        return NetworkType.cosmos;
    }
  }

  WalletNetwork? _findNetwork(SwapNetwork network) {
    if (_networks.containsKey(network)) return _networks[network];
    final type = _findNetowrkType(network);
    WalletNetwork? findNetwork() {
      switch (type) {
        case NetworkType.ethereum:
          final ethNetwork = network.cast<SwapEthereumNetwork>();
          return networks.whereType<WalletEthereumNetwork>().firstWhereNullable(
              (e) => e.coinParam.chainId == ethNetwork.chainId);
        case NetworkType.cosmos:
          final cosmosNetwork = network.cast<SwapCosmosNetwork>();
          return networks.whereType<WalletCosmosNetwork>().firstWhereNullable(
              (e) =>
                  e.coinParam.chainId == cosmosNetwork.identifier &&
                  e.coinParam.chainType == cosmosNetwork.chainType);

        case NetworkType.bitcoinAndForked:
          final btcNetwork = network.cast<SwapBitcoinNetwork>();
          return networks.whereType<WalletBitcoinNetwork>().firstWhereNullable(
              (e) =>
                  e.coinParam.transacationNetwork == btcNetwork.chain &&
                  e.coinParam.chainType == btcNetwork.chainType);

        case NetworkType.solana:
          final solanaNetwork = network.cast<SwapSolanaNetwork>();
          return networks
              .whereType<WalletSolanaNetwork>()
              .firstWhereNullable((e) {
            if (solanaNetwork.chainType.isMainnet) {
              return e.coinParam.type == SolanaNetworkType.mainnet;
            }
            return e.coinParam.type == SolanaNetworkType.devnet;
          });
        case NetworkType.substrate:
          final substrateChains = networks.whereType<WalletSubstrateNetwork>();
          if (network.chainType.isMainnet) {
            return substrateChains.firstWhereNullable((e) {
              return e.coinParam.token.name == "Polkadot";
            });
          }
          return substrateChains.firstWhereNullable((e) {
            return e.coinParam.token.name == "Cf PDOT";
          });
        default:
          return null;
      }
    }

    _networks[network] = findNetwork();
    return _networks[network];
  }

  Future<Map<WalletNetwork, Set<APPSwapAssets>>> getAppSourceAssets(
      {bool skipServiceWhenFailed = true}) async {
    final services = this.services;
    List<APPSwapAssets> allAssets = [];
    for (final i in services.entries) {
      try {
        final assets = await i.value.loadAssets();
        final supportAssets = assets.map((e) {
          final network = _findNetwork(e.network);
          if (network == null) return null;
          return APPSwapAssets.fromAsset(asset: e, network: network);
        }).whereType<APPSwapAssets>();
        allAssets.addAll(supportAssets);
        _localAssets[i.key] = supportAssets.toImutableSet;
      } catch (_) {
        if (skipServiceWhenFailed) continue;
        rethrow;
      }
    }
    final Map<WalletNetwork, Set<APPSwapAssets>> networkAssets = {};
    for (final i in allAssets) {
      networkAssets[i.network] ??= {};
      networkAssets[i.network]?.add(i);
    }
    _allAssets =
        networkAssets.map((k, v) => MapEntry(k, APPSwapUtils.sortAssets(v)));
    return _allAssets.immutable;
  }

  Map<WalletNetwork, Set<APPSwapAssets>> getAppDestAssets(BaseSwapAsset asset) {
    final Map<WalletNetwork, Set<APPSwapAssets>> networkAssets = {};
    // final Map<SwapNetwork, Set<BaseSwapAsset>> networkAssets = {};
    final services = this.services;
    for (final i in services.values) {
      final assets = i.getDestAssets(asset);
      for (final entry in assets.entries) {
        final network = _findNetwork(entry.key);
        if (network == null) continue;
        final asset =
            _allAssets[network]!.where((e) => entry.value.contains(e.asset));
        networkAssets.update(network, (e) => {...e, ...asset},
            ifAbsent: () => asset.toSet());
      }
    }
    return networkAssets.map((k, v) => MapEntry(k, APPSwapUtils.sortAssets(v)));
  }

  Future<List<RouteOrError>> findAppRoute<ASSET extends BaseSwapAsset>({
    required APPSwapAssets sourceAsset,
    required APPSwapAssets destinationAsset,
    required String amountIn,
    String? sourceAddress,
    String? destinationAddress,
  }) async {
    List<RouteOrError> routes = [];
    for (final i in _localAssets.entries) {
      final sAsset = i.value.firstWhereNullable((e) => e == sourceAsset);
      final destAsset =
          i.value.firstWhereNullable((e) => e == destinationAsset);
      final service = services[i.key];
      if (sAsset == null || destAsset == null || service == null) {
        continue;
      }
      final params = createQuoteParams(
          sourceAsset: sAsset.asset,
          destAsset: destAsset.asset,
          amountIn: amountIn,
          sourceAddress: sourceAddress,
          destinationAddress: destinationAddress);
      try {
        final serviceRoutes = await service.createRoutes(params);
        routes.addAll(serviceRoutes.map((e) =>
            RouteOrError.route(provider: sAsset.asset.provider, route: e)));
      } catch (err) {
        routes.add(
            RouteOrError.error(provider: sAsset.asset.provider, error: err));
      }
    }
    return routes;
  }
}
