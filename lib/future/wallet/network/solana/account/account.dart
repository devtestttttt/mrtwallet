import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class SolanaAccountPageView extends StatelessWidget {
  const SolanaAccountPageView({required this.chainAccount, super.key});
  final SolanaChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _SolanaServices(chainAccount),
      AccountTokensView(
        account: chainAccount,
        importPage: PageRouter.importSPLTokens,
        transferPage: PageRouter.solanaTransfer,
      ),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _SolanaServices extends StatelessWidget {
  final SolanaChain account;
  const _SolanaServices(this.account);

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              title: Text("associated_token_program".tr),
              subtitle: Text("create_associated_token_account".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final validator =
                    LiveTransactionForm<SolanaCreateAssociatedTokenAccountForm>(
                        validator: SolanaCreateAssociatedTokenAccountForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("create_account".tr),
              subtitle: Text("solana_create_account_desc".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final validator = LiveTransactionForm<SolanaCreateAccountForm>(
                    validator: SolanaCreateAccountForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("initialize_mint".tr),
              subtitle: Text("initiailize_mint_desc".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final validator = LiveTransactionForm<SolanaInitializeMintForm>(
                    validator: SolanaInitializeMintForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("mint_to".tr),
              subtitle: Text("mint_to_desc".tr),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final validator = LiveTransactionForm<SolanaMintToForm>(
                    validator: SolanaMintToForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              trailing: const Icon(Icons.arrow_forward),
              title: Text("solana_key_conversion".tr),
              subtitle: Text("solana_key_conversion_desc".tr),
              onTap: () {
                context.to(PageRouter.solanaKeyConversion);
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
