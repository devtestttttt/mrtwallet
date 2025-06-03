import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/theme/theme.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/setting/color_selector.dart';
import 'package:on_chain_wallet/future/wallet/setup/controller/controller.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';

class WalletSetupPageWidget extends StatelessWidget {
  const WalletSetupPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StateBuilder<WalletProvider>(
        controller: () => context.watch<WalletProvider>(StateConst.main),
        removable: false,
        repositoryId: StateConst.main,
        builder: (wallet) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text("setup".tr),
                  pinned: true,
                  centerTitle: false,
                  actions: [
                    BrightnessToggleIcon(
                        onToggleBrightness: () => wallet.toggleBrightness(),
                        brightness: ThemeController.appTheme.brightness),
                    ColorSelectorIconView(
                      (p0) {
                        if (p0 == null) return;
                        return wallet.changeColor(p0);
                      },
                    ),
                    WidgetConstant.width8,
                  ],
                ),
                SliverConstraintsBoxView(
                    sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAssetsImageView(APPConst.logo),
                      WidgetConstant.height8,
                      AppListTile(
                        title: Text("use_mnemonic".tr),
                        subtitle: Text("e_mnemonic".tr),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () async {
                          context.to(PageRouter.setup,
                              argruments: SetupWalletMode.exist);
                        },
                      ),
                      WidgetConstant.height8,
                      AppListTile(
                        title: Text("generate_mnemonic".tr),
                        subtitle: Text("g_mnemonic".tr),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          context.to(PageRouter.setup);
                        },
                      ),
                      WidgetConstant.height8,
                      AppListTile(
                        title: Text("restore_backup".tr),
                        subtitle: Text("restore_backuo_desc".tr),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          context.to(PageRouter.setup,
                              argruments: SetupWalletMode.backup);
                        },
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        });
  }
}
