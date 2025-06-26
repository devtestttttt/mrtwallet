import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/account_tokens_view.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/select_provider.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/transaction_activity.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class SuiAccountPageView extends StatelessWidget {
  const SuiAccountPageView({required this.chainAccount, super.key});
  final SuiChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _SuiServices(account: chainAccount),
      AccountTokensView(
          account: chainAccount,
          importPage: PageRouter.importSuiToken,
          transferPage: PageRouter.suiTransfer),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _SuiServices extends StatelessWidget {
  const _SuiServices({required this.account});
  final SuiChain account;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text("multi_sig_addr".tr),
              subtitle: Text("establishing_multi_sig_addr".tr),
              onTap: () {
                context.to(PageRouter.suiMultisigAddress);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text("sui_key_conversion".tr),
              subtitle: Text("sui_key_conversion_desc".tr),
              onTap: () {
                context.to(PageRouter.suiKeyConversion);
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
