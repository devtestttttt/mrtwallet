import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class AptosAccountPageView extends StatelessWidget {
  const AptosAccountPageView({required this.chainAccount, super.key});
  final AptosChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _AptosServices(account: chainAccount),
      AccountTokensView(
          account: chainAccount,
          importPage: PageRouter.importAptosToken,
          transferPage: PageRouter.aptosTransfer),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _AptosServices extends StatelessWidget {
  const _AptosServices({required this.account});
  final AptosChain account;
  IAptosAddress get address => account.address;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              title: Text("multi_sig_addr".tr),
              subtitle: Text("establishing_multi_sig_addr".tr),
              onTap: () {
                context.to(PageRouter.aptosMultisigAddress);
              },
            ),
            WidgetConstant.divider
          ],
        ),
      ),
    ]);
  }
}
