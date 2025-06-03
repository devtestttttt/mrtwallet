import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TronAccountPageView extends StatelessWidget {
  const TronAccountPageView({required this.chainAccount, super.key});
  final TronChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) => false,
      child: TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
        _Services(chainAccount),
        AccountTokensView(
            account: chainAccount,
            importPage: PageRouter.importTronToken,
            transferPage: PageRouter.tronTransfer),
        AccountTransactionActivityView(chainAccount)
      ]),
    );
  }
}

class _Services extends StatelessWidget {
  const _Services(this.chainAccount);
  final TronChain chainAccount;
  ITronAddress get account => chainAccount.address;
  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: chainAccount.service),
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppListTile(
              title: Text("multi_sig_addr".tr),
              subtitle: Text("establishing_multi_sig_addr".tr),
              onTap: () {
                context.to(PageRouter.tronMultiSigAddress,
                    argruments: chainAccount);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              title: Text("update_account_permission".tr),
              subtitle: Text("update_account_permissions".tr),
              onTap: () {
                if (account.accountInfo == null) {
                  context.showAlert("account_not_found".tr);
                  return;
                }
                final validator = LiveTransactionForm(
                    validator: TronAccountUpdatePermissionForm());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("update_account".tr),
              subtitle: Text("modify_account_name".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm(validator: TronUpdateAccountForm());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              title: Text("tron_stack_v2".tr),
              subtitle: Text("frozen_balance".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm(validator: TronFreezBalanceV2Form());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("tron_unstack_v2".tr),
              subtitle: Text("unfreeze_balance".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm(validator: TronUnFreezBalanceV2Form());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("delegated_resource".tr),
              subtitle: Text("delegate_resource_desc".tr),
              onTap: () {
                final validator = LiveTransactionForm(
                    validator: TronDelegatedResourceV2Form());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("undelegated_resource".tr),
              subtitle: Text("undelegated_resource_desc".tr),
              onTap: () {
                final validator = LiveTransactionForm(
                    validator: TronUnDelegatedResourceV2Form());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              title: Text("create_witness".tr),
              subtitle: Text("create_witness_desc".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm(validator: TronCreateWitnessForm());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("update_witness".tr),
              subtitle: Text("update_witness_desc".tr),
              onTap: () {
                if (account.accountInfo == null) {
                  context.showAlert("account_not_found".tr);
                  return;
                }
                final validator =
                    LiveTransactionForm(validator: TronUpdateWitnessForm());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
          ],
        ),
      )
    ]);
  }
}
