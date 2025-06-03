import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class MoneroAccountPageView extends StatelessWidget {
  const MoneroAccountPageView({required this.chainAccount, super.key});
  final MoneroChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _MoneroServices(chainAccount),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _MoneroServices extends StatelessWidget {
  const _MoneroServices(this.account);
  final MoneroChain account;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: Column(children: [
          AppListTile(
            leading: const Icon(Icons.sync),
            title: Text("sync_options".tr),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("monero_sync_options_desc".tr),
                ConditionalWidget(
                  onActive: (context) => ErrorTextContainer(
                      enableTap: false,
                      showErrorIcon: false,
                      error: "chain_synchronization_disabled_desc".tr),
                  enable: !account.syncIsActive,
                )
              ],
            ),
            onTap: () {
              context.to(PageRouter.moneroSyncOptions);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.sync),
            title: Text("sync_information".tr),
            subtitle: Text("view_account_block_sync".tr),
            onTap: () {
              context.to(PageRouter.moneroAccountSync);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.password),
            title: Text("monero_mnemonic".tr),
            subtitle: Text("generate_monero_private_key".tr),
            onTap: () {
              context.to(PageRouter.moneroMnemonic);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.handshake),
            title: Text("generate_transaction_proof".tr),
            subtitle: Text("monero_tx_proof_desc3".tr),
            onTap: () {
              context.to(PageRouter.moneroGenerateProof);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.verified),
            title: Text("verify_transaction_proof".tr),
            subtitle: Text("monero_verify_proof_desc".tr),
            onTap: () {
              context.to(PageRouter.moneroVerifyProof);
            },
          ),
        ]),
      )
    ]);
  }
}

class MoneroAppBarActionView extends StatelessWidget {
  const MoneroAppBarActionView(this.chain, {super.key});
  final MoneroChain chain;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return switch (chain.config.status) {
      MoneroChainStatus.outputReceived => AccountAppbarActionView(
          onHide: chain.hideStatus,
          onAction: () {
            context.openDialogPage(
              "",
              child: (context) {
                return PasswordCheckerView(
                  accsess: WalletAccsessType.unlock,
                  onWalletAccess: (password) async {
                    wallet.wallet.moneroUpdatePendingTxes(account: chain);
                    return null;
                  },
                );
              },
            );
          },
          text: "account_tx_detected_desc".tr),
      _ => WidgetConstant.sizedBox
    };
  }
}
