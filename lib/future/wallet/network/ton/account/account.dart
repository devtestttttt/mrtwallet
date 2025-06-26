import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TonAccountPageView extends StatelessWidget {
  const TonAccountPageView({required this.chainAccount, super.key});
  final TheOpenNetworkChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _TonServices(chainAccount),
      AccountTokensView(
          account: chainAccount,
          importPage: PageRouter.importJettons,
          transferPage: PageRouter.tonTransfer),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _TonServices extends StatelessWidget {
  const _TonServices(this.chainAccount);
  final TheOpenNetworkChain chainAccount;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: chainAccount.service),
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text("ton_mnemonic".tr),
              subtitle: Text("generate_ton_private_key".tr),
              onTap: () {
                context.to(PageRouter.tonMnemonic);
              },
            ),
          ],
        ),
      )
    ]);
  }
}
