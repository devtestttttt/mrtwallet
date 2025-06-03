import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/utils/address/utils.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:on_chain_wallet/wallet/models/token/coingecko/coin.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';
// import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class APPSwapUtils {
  static Set<APPSwapAssets> sortAssets(Set<APPSwapAssets> assets) {
    final clone = assets.toList();
    clone.sort((a, b) {
      if (a.asset.isNative && !b.asset.isNative) return -1;
      if (!a.asset.isNative && b.asset.isNative) return 1;
      return a.asset.providerIdentifier
          .toLowerCase()
          .compareTo(b.asset.providerIdentifier.toLowerCase());
    });
    return clone.toImutableSet;
  }

  static Token swapAssetToToken(BaseSwapAsset asset) {
    return Token(
        name: asset.fullName ?? asset.providerIdentifier,
        symbol: asset.symbol,
        decimal: asset.decimal,
        assetLogo: APPImage.network(asset.logoUrl),
        market: asset.coingeckoId == null
            ? null
            : CoingeckoCoin(apiId: asset.coingeckoId!));
  }

  static APPSwapFee swapFeeToAppSwapFee(SwapFee fee) {
    final asset = fee.token;
    final token = asset == null
        ? Token(name: fee.asset, symbol: fee.asset, decimal: 0)
        : swapAssetToToken(asset);
    return APPSwapFee(
      token: asset == null ? null : token,
      fee: fee,
      amount: IntegerBalance.token(fee.amount.amount, token),
    );
  }
}

class APPSwapAssets with Equatable {
  final BaseSwapAsset asset;
  // final IntegerBalance amount;
  final WalletNetwork network;
  final Token token;
  const APPSwapAssets(
      {required this.asset, required this.network, required this.token});
  factory APPSwapAssets.fromAsset(
      {required BaseSwapAsset asset, required WalletNetwork network}) {
    return APPSwapAssets(
        asset: asset,
        network: network,
        token: APPSwapUtils.swapAssetToToken(asset));
  }

  @override
  List get variabels => [asset];
}

class RouteBpsPriceDetails {
  final IntegerBalance amount;
  final String bpsPercentage;
  final bool minus;
  const RouteBpsPriceDetails(
      {required this.amount, required this.bpsPercentage, required this.minus});
}

class SwapRouteWithBps {
  final SwapRoute route;
  final RouteBpsPriceDetails? bps;
  final IntegerBalance? totalFee;
  final IntegerBalance amount;
  final List<APPSwapFee> fees;
  final IntegerBalance worstCaseAmount;
  // final Token source;
  SwapServiceProvider get provider => route.provider;
  SwapRouteWithBps(
      {required this.route,
      required this.bps,
      required this.totalFee,
      required this.amount,
      required List<APPSwapFee> fees,
      required this.worstCaseAmount})
      : fees = fees.immutable;
}

class APPSwapFee {
  final SwapFee fee;
  final IntegerBalance amount;
  final Token? token;
  const APPSwapFee({required this.fee, required this.amount, this.token});
}

class APPSwapRoutes {
  final Chain sourceChain;
  final Chain destChain;
  List<SwapRouteWithBps> _routes;
  StreamValue<SwapRouteWithBps> _route;
  List<SwapRouteWithBps> get routes => _routes;
  StreamValue<SwapRouteWithBps> get route => _route;
  Stream get timeout => Stream.periodic(const Duration(seconds: 1));
  SwapServiceProvider get provider => route.value.provider;
  SwapAmount get expectAmout => route.value.route.expectedAmount;
  double _tolerance;
  double get tolerance => _tolerance;
  bool get hasMultipleRoute => _routes.length > 1;

  bool get supportTolerance => route.value.route.supportTolerance;
  double _maxTolerance;
  double get maxTolerance => _maxTolerance;

  void toggleSorting() {
    final routes = _routes.clone();
    routes.sort((a, b) =>
        a.route.expectedAmount.amount.compareTo(b.route.expectedAmount.amount));
    _routes = routes.immutable;
    _route.notify();
  }

  APPSwapRoutes._({
    required List<SwapRouteWithBps> routes,
    required SwapRouteWithBps route,
    required this.sourceChain,
    required this.destChain,
  })  : _routes = routes.immutable,
        _route = StreamValue(route),
        _tolerance = route.route.tolerance,
        _maxTolerance =
            IntUtils.max(50, route.route.tolerance.ceil()).toDouble();
  factory APPSwapRoutes(
      {required List<SwapRouteWithBps> routes,
      required Chain sourceChain,
      required Chain destChain}) {
    routes.sort((a, b) =>
        a.route.expectedAmount.amount.compareTo(b.route.expectedAmount.amount));
    return APPSwapRoutes._(
        routes: routes,
        route: routes.last,
        destChain: destChain,
        sourceChain: sourceChain);
  }
  int get index => _routes.indexOf(route.value);

  void updateTolerance(double tolerance) {
    final route = this.route;
    final routes = _routes.clone();
    final index = routes.indexOf(route.value);
    if (index.isNegative) return;
    final updateRoute = route.value.route.updateTolerance(tolerance);
    final newRoute = SwapRouteWithBps(
        route: updateRoute,
        bps: route.value.bps,
        totalFee: route.value.totalFee,
        amount: route.value.amount,
        fees: route.value.fees,
        worstCaseAmount: route.value.worstCaseAmount);
    routes[index] = newRoute;
    _routes = routes.immutable;
    _tolerance = newRoute.route.tolerance;
    _maxTolerance =
        IntUtils.max(50, newRoute.route.tolerance.ceil()).toDouble();
    _route.value = newRoute;
  }

  void onChangeRoute(int index) {
    assert(index < _routes.length, "Invalid route index.");
    if (index >= _routes.length) return;
    final route = routes.elementAt(index);
    _tolerance = route.route.tolerance;
    _maxTolerance = IntUtils.max(50, route.route.tolerance.ceil()).toDouble();
    _route.value = route;
  }

  void dispose() {
    _route.dispose();
  }
}

class RouteError {
  final SwapServiceProvider? provider;
  final String error;
  const RouteError({this.provider, required this.error});
}

class DefaultSwapServiceApiParams extends BaseSwapServiceApiParams {
  final bool testnet;
  final List<SwapKitSwapServiceProvider>? swapKitServiceProviders;
  DefaultSwapServiceApiParams.testnet()
      : testnet = true,
        swapKitServiceProviders = null,
        super([SwapServiceType.chainFlip]);
  DefaultSwapServiceApiParams({
    List<SwapServiceType> services = const [
      SwapServiceType.chainFlip,
      SwapServiceType.maya,
      SwapServiceType.thor,
      SwapServiceType.swapKit
    ],
    List<SwapKitSwapServiceProvider>? swapKitServiceProviders,
  })  : swapKitServiceProviders = swapKitServiceProviders?.immutable,
        testnet = false,
        super(services);

  /// 1339942095353
  /// 1275848805863
  @override
  Future<MayaSwapService> loadMayaService() async {
    return MayaSwapService(
        provider: ThorNodeProvider(ThorNodeHTTPService(
            isolate: APPIsolate.separate,
            provider: CosmosAPIProvider(
              uri: "https://mayanode.mayachain.info/mayachain",
              identifier: 'identifier',
            ))));
  }

  @override
  Future<SkipGoSwapService> loadSkipGoService() async {
    return SkipGoSwapService(
        provider: SkipGoApiProvider(SkipGoHTTPService(
      provider:
          CustomAPIProvider(url: "https://api.skip.build", identifier: ''),
      defaultTimeOut: const Duration(minutes: 1),
      isolate: APPIsolate.separate,
    )));
  }

  @override
  Future<SwapKitSwapService> loadSwapKitService() async {
    return SwapKitSwapService(
        providers: swapKitServiceProviders ?? [],
        provider: SwapKitProvider(SwapKitHTTPService(
            isolate: APPIsolate.separate,
            provider: CustomAPIProvider(
                identifier: '',
                url: "https://api.swapkit.dev",
                auth: BasicProviderAuthenticated(
                    type: ProviderAuthType.header,
                    key: "x-api-key",
                    value: "9e1a8dce-8e2d-4cad-9d09-9430df70743c")))));
  }

  @override
  Future<ThorSwapService> loadThorService() async {
    return ThorSwapService(
        provider: ThorNodeProvider(ThorNodeHTTPService(
            isolate: APPIsolate.separate,
            provider: CosmosAPIProvider(
                identifier: '',
                uri: "https://thornode.ninerealms.com/thorchain"))));
  }

  @override
  Future<CfSwapService> loadChainFlipService() async {
    if (testnet) {
      return CfSwapService(
          chainType: ChainType.testnet,
          provider: CfProvider(ChainFlipHTTPService(
              isolate: APPIsolate.separate,
              provider: CustomAPIProvider(
                  url: 'https://chainflip-swap-perseverance.chainflip.io/',
                  identifier: ''))));
    }
    return CfSwapService(
        provider: CfProvider(ChainFlipHTTPService(
            isolate: APPIsolate.separate,
            provider: CustomAPIProvider(
                url: 'https://chainflip-swap.chainflip.io/', identifier: ''))));
  }
}

class APPSwapRoute {
  final Chain sourceChain;
  final Chain destChain;
  final SwapRouteWithBps route;
  final SwapRouteTransactionBuilder transaction;
  final List<ChainAccount> sources;
  final ReceiptAddress destAddress;
  final APPSwapAssets sourceAsset;
  final APPSwapAssets destAsset;
  final IntegerBalance sourceAmount;
  final IntegerBalance destAmount;
  factory APPSwapRoute({
    required Chain sourceChain,
    required Chain destChain,
    required SwapRouteWithBps route,
    required SwapRouteTransactionBuilder transaction,
    required List<ChainAccount> sources,
    required ReceiptAddress destAddress,
    required APPSwapAssets sourceAsset,
    required APPSwapAssets destAsset,
  }) {
    final err = WalletException("invalid_swap_information");
    if (sourceAsset.asset != route.route.quote.sourceAsset) {
      throw err;
    }
    if (destAsset.asset != route.route.quote.destinationAsset) {
      throw err;
    }
    if (sourceChain.network != sourceAsset.network) {
      throw err;
    }
    if (destChain.network != destAsset.network) {
      throw err;
    }
    if (sources.isEmpty ||
        sources.any((e) => e.network != sourceChain.network.value)) {
      throw err;
    }
    if (!BlockchainAddressUtils.isValidNetworkAddress(
        destAddress.view, destChain.network)) {
      throw err;
    }
    if (transaction.operations.isEmpty ||
        transaction.route != route.route ||
        transaction.params.destinationAddress != destAddress.view ||
        !sources.any(
            (e) => e.address.address == transaction.params.sourceAddress) ||
        transaction.operations
            .any((e) => e.network != sourceAsset.asset.network)) {
      throw err;
    }
    return APPSwapRoute._(
        sourceChain: sourceChain,
        destChain: destChain,
        route: route,
        transaction: transaction,
        sources: sources,
        destAddress: destAddress,
        sourceAsset: sourceAsset,
        destAsset: destAsset,
        sourceAmount: IntegerBalance.token(
            transaction.route.quote.amount.amount, sourceAsset.token),
        destAmount: IntegerBalance.token(
            transaction.route.expectedAmount.amount, destAsset.token));
  }
  APPSwapRoute._(
      {required this.sourceChain,
      required this.destChain,
      required this.route,
      required this.transaction,
      required List<ChainAccount> sources,
      required this.destAddress,
      required this.sourceAsset,
      required this.destAsset,
      required this.sourceAmount,
      required this.destAmount})
      : sources = sources.immutable;
}
