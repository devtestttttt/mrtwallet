import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/theme/theme.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/controller/tabs/tabs.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/switch_network.dart';
import 'package:on_chain_wallet/future/wallet/setting/color_selector.dart';
import 'package:on_chain_wallet/future/wallet/start/pages/platform_widgets/widgets.dart';
import 'package:on_chain_wallet/future/wallet/swap/pages/pages/swap.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/others/models/status.dart';
import 'package:on_chain_wallet/wallet/wallet.dart' show Chain, HDWallet;
import 'account_page.dart';
import 'login_page.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'setup.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return UnfocusableChild(
      child: StateBuilder(
          controller: () => wallet,
          removable: false,
          builder: (controller) {
            final status = wallet.appStatus;
            return PopScope(
              canPop: controller.canPop,
              onPopInvokedWithResult: controller.onPop,
              child: APPAnimatedSwitcher(enable: status.status, widgets: {
                APPStatusType.ready: (context) => _APPISReady(wallet),
                APPStatusType.init: (context) => ProgressWithAPPLogo(),
                APPStatusType.failed: (context) => Text(status.error!),
              }),
            );
          },
          repositoryId: StateConst.main),
    );
  }
}

class _APPISReady extends StatelessWidget {
  final WalletProvider wallet;
  const _APPISReady(this.wallet);

  @override
  Widget build(BuildContext context) {
    return StreamWidget(
      value: wallet.wallet.status,
      builder: (context, value) {
        return MaterialPageView(
          child: RefreshIndicator(
            onRefresh: wallet.onRefresh,
            notificationPredicate: (notification) {
              return wallet.allowRefresh;
            },
            child: CustomScrollView(
              slivers: [
                _WalletAppBar(wallet),
                SliverFillRemaining(
                  // fillOverscroll: true,
                  hasScrollBody: false,
                  child: APPAnimated(
                      isActive: value.isOpen,
                      onDeactive: (context) => APPAnimated(
                          isActive: value.isInit || wallet.wallet.inProgress,
                          onActive: (context) => ProgressWithAPPLogo(),
                          onDeactive: (context) => APPAnimatedSwitcher<WStatus>(
                                  enable: value,
                                  widgets: {
                                    WStatus.init: (c) => Container(),
                                    WStatus.setup: (c) =>
                                        const WalletSetupPageWidget(),
                                    WStatus.lock: (context) =>
                                        const WalletLoginPageView()
                                  })),
                      onActive: (context) => Shimmer(
                          onActive: (e, context) => NetworkAccountPageView(
                              wallet: wallet,
                              account: wallet.wallet.currentChain),
                          enable: !wallet.wallet.inProgress)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalletAppBar extends StatelessWidget {
  const _WalletAppBar(this.wallet);
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    final bool isReady = wallet.wallet.homePageStatus.isReady;
    final bool isOpen = wallet.wallet.isOpen;
    return SliverAppBar(
      centerTitle: false,
      snap: false,
      toolbarHeight: isReady ? kToolbarHeight : 0,
      title: ConditionalWidget(
          onActive: (context) {
            if (isOpen) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OneLineTextWidget(
                      wallet.wallet.currentChain.network.networkName,
                      style: context.textTheme.titleMedium),
                  if (wallet.wallet.currentChain.network.coinParam.isTestNet)
                    ToolTipView(
                      message: "testnet_price_desc".tr,
                      child: Text("testnet".tr,
                          style: context.textTheme.labelSmall
                              ?.copyWith(color: context.colors.error)),
                    ),
                ],
              );
            }
            return Text(wallet.wallet.wallet.name);
          },
          enable: isReady),
      pinned: true,
      floating: false,
      actions: [
        // ElevatedButton(
        //     onPressed: () {
        //       context.to(PageRouter.webview);
        //     },
        //     child: Text("testpage")),
        WidgetConstant.width8,
        ConditionalWidget(
            enable: isOpen,
            onDeactive: (context) => _AppbarLockActions(wallet),
            onActive: (context) => _AppbarUnlockActions(
                account: wallet.wallet.currentChain, wallet: wallet))
      ],
      leading: IconButton(
          onPressed: () {
            context
                .openSliverDialog<HDWallet>(
                    (c) => _SwitchWalletView(
                          wallets: wallet.wallet.wallets,
                          selectedWallet: wallet.wallet.wallet,
                        ),
                    "switch_wallets".tr,
                    content: (c) => [
                          IconButton(
                              onPressed: () {
                                context.offTo(PageRouter.createWallet);
                              },
                              icon: const Icon(Icons.add))
                        ])
                .then(wallet.wallet.switchWallet);
          },
          icon: const Icon(Icons.account_balance_wallet_rounded)),
    );
  }
}

class _SwitchWalletView extends StatelessWidget {
  const _SwitchWalletView(
      {required this.wallets, required this.selectedWallet});
  final List<HDWallet> wallets;
  final HDWallet selectedWallet;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        final bool selected = selectedWallet.name == wallet.name;
        return ContainerWithBorder(
          onRemove: () {
            context.pop(wallet);
          },
          enableTap: selected ? false : true,
          onRemoveWidget: selected
              ? const Icon(Icons.check_circle)
              : WidgetConstant.sizedBox,
          child: Row(
            children: [
              wallet.requiredPassword
                  ? const Icon(Icons.lock)
                  : const Icon(Icons.lock_open),
              WidgetConstant.width8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wallet.name, style: context.textTheme.labelLarge),
                    Text(wallet.created.toString(),
                        style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      itemCount: wallets.length,
      shrinkWrap: true,
    );
  }
}

class _AppbarLockActions extends StatelessWidget {
  final WalletProvider wallet;
  const _AppbarLockActions(this.wallet);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      BrightnessToggleIcon(
          onToggleBrightness: () => wallet.toggleBrightness(),
          brightness: ThemeController.appTheme.brightness),
      ColorSelectorIconView(
        (p0) {
          if (p0 == null) return;
          return wallet.changeColor(p0);
        },
      ),
      appbarWidgets(false),
    ]);
  }
}

class _AppbarUnlockActions extends StatelessWidget {
  final Chain account;
  final WalletProvider wallet;
  const _AppbarUnlockActions({required this.account, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      APPAnimatedSwitcher<WalletPage>(enable: wallet.walletPage, widgets: {
        WalletPage.swap: (context) => SwitchNetworkIcon(account: account),
        WalletPage.webview: (context) => SwitchNetworkIcon(account: account),
      }),
      IconButton(
          onPressed: () {
            final page = wallet.walletPage;
            switch (page) {
              case WalletPage.swap:
                wallet.swap?.updateSettings((controller) {
                  return context.openSliverDialog(
                      (context) => SelectSwapProvidersView(controller),
                      'swap_settings'.tr);
                });
                break;
              default:
                context.to(PageRouter.setting);
                break;
            }
          },
          icon: const Icon(Icons.settings)),
      WidgetConstant.width8,
      appbarWidgets(true),
    ]);
  }
}
