import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/webview/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/widgets/list_tile.dart';
import 'package:on_chain_wallet/future/widgets/widgets/widget_constant.dart';

class WebViewPopupMenu extends StatelessWidget {
  const WebViewPopupMenu(this.controller, {super.key});
  final WebViewController controller;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
        iconColor: context.colors.onSurface,
        icon: Icon(Icons.more_vert),
        routeSettings: RouteSettings(name: PageRouter.webviewMenu),
        constraints: WidgetConstant.constraintsMinWidth200,
        onSelected: (v) {
          switch (v) {
            case 0:
              controller.showOpenTabs();
              break;
            case 1:
              controller.showHistories();
              break;
            case 2:
              controller
                  .addOrRemoveFromBookMark(controller.controller.tab.value);
              break;
            case 3:
              controller.showBookmarks();
              break;
            default:
              break;
          }
        },
        itemBuilder: (c) {
          return [
            PopupMenuItem<int>(
              value: 0,
              child: AppListTile(
                trailing: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.check_box_outline_blank_rounded),
                    Text(controller.tabsLength.toString(),
                        style: context.textTheme.bodyMedium)
                  ],
                ),
                title: Text("tabs".tr, style: context.textTheme.labelMedium),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: AppListTile(
                trailing: const Icon(Icons.history),
                title:
                    Text("histories".tr, style: context.textTheme.labelMedium),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: AppListTile(
                trailing: controller.controller.inBookmark
                    ? const Icon(Icons.bookmark_added)
                    : const Icon(Icons.bookmark_add_outlined),
                title:
                    Text("bookmark".tr, style: context.textTheme.labelMedium),
              ),
            ),
            PopupMenuItem<int>(
              value: 3,
              child: AppListTile(
                trailing: const Icon(Icons.bookmarks),
                title:
                    Text("bookmarks".tr, style: context.textTheme.labelMedium),
              ),
            ),
          ];
        });
  }
}
