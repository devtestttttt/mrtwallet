import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/app.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/token_details.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/token_details_view.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class AccountTokensView extends StatelessWidget {
  const AccountTokensView({
    super.key,
    required this.account,
    required this.transferPage,
    required this.importPage,
  });
  final String transferPage;
  final String importPage;
  final Chain account;
  ChainAccount get address => account.address;

  @override
  Widget build(BuildContext context) {
    final tokens = address.tokens;
    return AccountTabbarScrollWidget(slivers: [
      EmptyItemSliverWidgetView(
          isEmpty: tokens.isEmpty,
          onEmpty: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.token, size: APPConst.double80),
                  WidgetConstant.height8,
                  Text("no_tokens_found".tr),
                  WidgetConstant.height20,
                  FilledButton(
                      onPressed: () {
                        context.to(importPage);
                      },
                      child: Text("monitor_my_tokens".tr))
                ],
              ),
          itemBuilder: (context) => SliverToBoxAdapter(
              child: AppListTile(
                  leading: const Icon(Icons.token),
                  onTap: () {
                    context.to(importPage);
                  },
                  title: Text("manage_tokens".tr),
                  subtitle: Text("add_or_remove_tokens".tr)))),
      SliverList.builder(
          itemBuilder: (context, index) {
            final token = address.tokens[index];
            return TokenDetailsView(
              token: token,
              onSelectWidget: WidgetConstant.sizedBox,
              onSelect: () {
                context.openDialogPage<TokenAction>("token_info".tr,
                    child: (ctx) => TokenDetailsModalView(
                        token: token,
                        address: address,
                        account: account,
                        transferPath: transferPage));
              },
            );
          },
          itemCount: address.tokens.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false)
    ]);
  }
}
