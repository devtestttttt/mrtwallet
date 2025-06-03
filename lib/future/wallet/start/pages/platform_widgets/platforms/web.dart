import 'package:flutter/material.dart';
import 'package:on_chain_bridge/web/api/chrome/api/core.dart';
import 'package:on_chain_wallet/app/constant/global/state.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/controller/impl/extention_wallet.dart';
import 'package:on_chain_wallet/future/wallet/controller/wallet/cross/web.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/client_info.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/permission_view.dart';
import 'package:on_chain_wallet/future/widgets/widgets/conditional_widget.dart';
import 'package:on_chain_wallet/future/widgets/widgets/list_tile.dart';
import 'package:on_chain_wallet/future/widgets/widgets/widget_constant.dart';

Widget appbarWidgets(bool walletIsUnlock) {
  if (isExtension) return _AppbarExtentionWidget(walletIsUnlock);
  return WidgetConstant.sizedBox;
}

class _AppbarExtentionWidget extends StatelessWidget {
  final bool walletIsUnlock;
  const _AppbarExtentionWidget(this.walletIsUnlock);

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main).wallet
        as ExtentionWallet;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (walletIsUnlock)
          StreamWidget(
              value: wallet.latestClient,
              builder: (context, client) => Web3ClientInfoIconView(
                  client: client,
                  onTap: (s) {
                    context.openDialogPage(
                      "update_permission".tr,
                      fullWidget: (context) =>
                          Web3PermissionUpdateView(controller: wallet),
                    );
                  })),
        ConditionalWidget(
            enable: wallet.context.context.isAction,
            onActive: (context) => PopupMenuButton<ExtensionWalletContextType>(
                iconColor: context.colors.onSurface,
                icon: Icon(Icons.more_vert),
                constraints: WidgetConstant.constraintsMinWidth200,
                onSelected: (v) {
                  wallet.openPopup(v);
                },
                itemBuilder: (c) {
                  return [
                    PopupMenuItem<ExtensionWalletContextType>(
                      value: ExtensionWalletContextType.popup,
                      child: AppListTile(
                        trailing: const Icon(Icons.open_in_new),
                        title: Text("open_as_popup".tr,
                            style: context.textTheme.labelMedium),
                      ),
                    ),
                    PopupMenuItem<ExtensionWalletContextType>(
                      value: ExtensionWalletContextType.tab,
                      child: AppListTile(
                        trailing: const Icon(Icons.open_in_browser),
                        title: Text("open_in_new_tab".tr,
                            style: context.textTheme.labelMedium),
                      ),
                    ),
                    if (wallet.supportedActions
                        .contains(ExtensionWalletContextType.sidePanel))
                      PopupMenuItem<ExtensionWalletContextType>(
                        value: ExtensionWalletContextType.sidePanel,
                        child: AppListTile(
                          trailing: const Icon(Icons.view_sidebar),
                          title: Text("opn_in_side_panel".tr,
                              style: context.textTheme.labelMedium),
                        ),
                      )
                    else if (wallet.supportedActions
                        .contains(ExtensionWalletContextType.sidebarAction))
                      PopupMenuItem<ExtensionWalletContextType>(
                        value: ExtensionWalletContextType.sidebarAction,
                        child: AppListTile(
                          trailing: const Icon(Icons.view_sidebar),
                          title: Text("opn_in_side_panel".tr,
                              style: context.textTheme.labelMedium),
                        ),
                      ),
                  ];
                })),
      ],
    );
  }
}
