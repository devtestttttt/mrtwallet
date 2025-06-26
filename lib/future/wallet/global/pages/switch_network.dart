import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';

class SwitchNetworkView extends StatefulWidget {
  const SwitchNetworkView({required this.selectedNetwork, super.key});
  final WalletNetwork selectedNetwork;

  @override
  State<SwitchNetworkView> createState() => _SwitchNetworkViewState();
}

class _SwitchNetworkViewState extends State<SwitchNetworkView>
    with SafeState<SwitchNetworkView> {
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();
  static const double imageRadius = 15;

  List<Chain> allChains = [];
  late List<Chain> networks;
  late WalletProvider wallet;

  int initialIndex = 0;
  bool showTestnet = false;
  NetworkType? showImport;

  void toggleShowTestnet() {
    showTestnet = !showTestnet;
    final setting = wallet.appSetting.walletSetting
        .copyWith(showTestnetNetworks: showTestnet);
    wallet.updateWalletSetting(setting);
    buildChains();
    updateState();
  }

  void initNetwork() {
    wallet = context.watch<WalletProvider>(StateConst.main);
    showTestnet = wallet.appSetting.walletSetting.showTestnetNetworks;
    allChains = wallet.wallet.getChains();
    initialIndex = findIndex(widget.selectedNetwork.type);
    buildChains();
    progressKey.backToIdle();
  }

  void onDestinationSelected(int index) {
    if (index == initialIndex) return;
    initialIndex = index;
    buildChains();
    updateState();
  }

  Iterable<Chain> findChains(int index) {
    switch (index) {
      case 0:
        return allChains.where((element) =>
            (element.network.type == NetworkType.bitcoinAndForked ||
                element.network.type == NetworkType.bitcoinCash));
      case 1:
        return allChains
            .where((element) => (element.network.type == NetworkType.xrpl));
      case 2:
        return allChains
            .where((element) => (element.network.type == NetworkType.ethereum));
      case 3:
        return allChains
            .where((element) => (element.network.type == NetworkType.tron));
      case 4:
        return allChains
            .where((element) => (element.network.type == NetworkType.solana));
      case 5:
        return allChains
            .where((element) => (element.network.type == NetworkType.cardano));
      case 6:
        return allChains
            .where((element) => (element.network.type == NetworkType.cosmos));
      case 7:
        return allChains
            .where((element) => (element.network.type == NetworkType.ton));
      case 8:
        return allChains.where(
            (element) => (element.network.type == NetworkType.substrate));
      case 9:
        return allChains
            .where((element) => (element.network.type == NetworkType.stellar));
      case 10:
        return allChains
            .where((element) => (element.network.type == NetworkType.monero));
      case 11:
        return allChains
            .where((element) => (element.network.type == NetworkType.sui));
      case 12:
        return allChains
            .where((element) => (element.network.type == NetworkType.aptos));
      default:
        throw UnimplementedError();
    }
  }

  int findIndex(NetworkType? type) {
    switch (type) {
      case NetworkType.xrpl:
        return 1;
      case NetworkType.ethereum:
        return 2;
      case NetworkType.tron:
        return 3;
      case NetworkType.solana:
        return 4;
      case NetworkType.cardano:
        return 5;
      case NetworkType.cosmos:
        return 6;
      case NetworkType.ton:
        return 7;
      case NetworkType.substrate:
        return 8;
      case NetworkType.stellar:
        return 9;
      case NetworkType.monero:
        return 10;
      case NetworkType.sui:
        return 11;
      case NetworkType.aptos:
        return 12;
      default:
        return 0;
    }
  }

  void buildChains() {
    networks = findChains(initialIndex).toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    if (!showTestnet) {
      networks = networks
          .where((e) =>
              e.network.coinParam.chainType.isMainnet ||
              e.network == widget.selectedNetwork)
          .toList();
    }
    NetworkType? importNetwork;
    switch (initialIndex) {
      case 2:
        importNetwork = NetworkType.ethereum;
        break;
      case 6:
        importNetwork = NetworkType.cosmos;
        break;
      case 8:
        importNetwork = NetworkType.substrate;
        break;
      default:
        break;
    }
    showImport = importNetwork;
    updateState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    MethodUtils.after(() async => initNetwork(),
        duration: APPConst.milliseconds100);
  }

  @override
  void safeDispose() {
    allChains = [];
    super.safeDispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      alignment: Alignment.center,
      maxHeight: APPConst.maxDialogHeight,
      padding: WidgetConstant.padding20,
      maxWidth: APPConst.dialogWidth,
      child: ClipRRect(
        borderRadius: WidgetConstant.border25,
        child: Scaffold(
          appBar: AppBar(
            title: Text("switch_network".tr),
            leading: const SizedBox(),
            leadingWidth: 0,
            actions: [
              TextButton.icon(
                  onPressed: toggleShowTestnet,
                  label: Text('testnets'.tr),
                  icon: APPCheckBox(
                    ignoring: true,
                    value: showTestnet,
                    onChanged: (_) {},
                  )),
              const CloseButton(),
              WidgetConstant.width8
            ],
          ),
          // shrinkWrap: true,
          body: PageProgress(
            backToIdle: APPConst.oneSecoundDuration,
            initialStatus: StreamWidgetStatus.progress,
            key: progressKey,
            child: (c) => Row(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: APPConst.naviationRailWidth),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                                useIndicator: true,
                                onDestinationSelected: onDestinationSelected,
                                labelType: NavigationRailLabelType.none,
                                destinations: [
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.btc,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.xrp,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.eth,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.trx,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.sol,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.ada,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.atom,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.ton,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(
                                          APPConst.substrate,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(
                                          APPConst.stellar,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(
                                          APPConst.monero,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(APPConst.sui,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                  NavigationRailDestination(
                                      icon: CircleAssetsImageView(
                                          APPConst.aptos,
                                          radius: imageRadius),
                                      label: WidgetConstant.sizedBox),
                                ],
                                selectedIndex: initialIndex),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const VerticalDivider(),
                Expanded(
                    child: AnimatedSwitcher(
                  duration: APPConst.animationDuraion,
                  child: _NetworksView(
                      widget.selectedNetwork, networks, showImport,
                      key: ValueKey(initialIndex)),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworksView extends StatelessWidget {
  const _NetworksView(this.selected, this.networks, this.import, {super.key});
  final WalletNetwork selected;
  final List<Chain> networks;
  final NetworkType? import;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ConditionalWidget(
          onActive: (context) => SliverAppBar(
            pinned: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("import_new_network".tr,
                    style: context.textTheme.titleMedium
                        ?.copyWith(color: context.colors.surface)),
                Text("add_new_network".tr.replaceOne(import?.name ?? ''),
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: context.colors.surface))
              ],
            ),
            leading: WidgetConstant.sizedBox,
            leadingWidth: 0,
            floating: true,
            backgroundColor: context.colors.onSurface,
            foregroundColor: context.colors.surface,
            actions: [
              IconButton(
                  tooltip: "import".tr,
                  onPressed: () {
                    context.pop(import);
                  },
                  icon: const Icon(Icons.add_box)),
              WidgetConstant.width8,
            ],
          ),
          enable: import != null,
          onDeactive: (context) => SliverPadding(padding: EdgeInsets.zero),
        ),
        SliverList.separated(
          itemBuilder: (context, index) {
            final net = networks[index].network;
            final balance = networks[index].totalBalance;
            return Padding(
              padding: WidgetConstant.paddingHorizontal20,
              child: InkWell(
                borderRadius: WidgetConstant.border8,
                onTap: selected == net
                    ? null
                    : () {
                        context.pop(net.value);
                      },
                child: Padding(
                  padding: WidgetConstant.padding5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              CircleTokenImageView(net.coinParam.token,
                                  radius: 20),
                              if (net.coinParam.isTestNet)
                                ToolTipView(
                                  message: "testnet_price_desc".tr,
                                  child: Text(
                                    "testnet".tr,
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(color: context.colors.error),
                                  ),
                                ),
                            ],
                          ),
                          WidgetConstant.width8,
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(net.coinParam.token.symbol,
                                  style: context.textTheme.labelLarge),
                              OneLineTextWidget(net.coinParam.token.name),
                              CoinAndMarketLivePriceView(liveBalance: balance),
                            ],
                          )),
                          WidgetConstant.width8,
                          if (selected == net) const Icon(Icons.check_circle)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: networks.length,
          separatorBuilder: (context, index) => WidgetConstant.divider,
        )
      ],
    );
  }
}

class SwitchNetworkIcon extends StatelessWidget {
  final Chain account;
  const SwitchNetworkIcon({required this.account, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          await context
              .openDialogPage("switch_network".tr,
                  fullWidget: (context) =>
                      SwitchNetworkView(selectedNetwork: account.network))
              .then(
            (value) {
              if (value == null) return;
              if (context.mounted) {
                if (value is int) {
                  context.wallet.wallet.switchNetwork(value);
                } else {
                  context.mybeTo(PageRouter.importNetwork(value));
                }
              }
            },
          );
        },
        icon: CircleTokenImageView(account.network.token,
            radius: APPConst.circleRadius12));
  }
}
