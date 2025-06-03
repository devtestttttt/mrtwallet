import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class RippleAccountPageView extends StatelessWidget {
  const RippleAccountPageView({required this.chainAccount, super.key});
  final RippleChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _RippleServicesView(chainAccount: chainAccount),
      AccountTokensView(
        account: chainAccount,
        transferPage: PageRouter.rippleTransfer,
        importPage: PageRouter.rippleAddToken,
      ),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _RippleServicesView extends StatelessWidget {
  const _RippleServicesView({required this.chainAccount});
  final RippleChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(
      slivers: [
        AccountManageProviderIcon(service: chainAccount.service),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!chainAccount.address.multiSigAccount) ...[
                AppListTile(
                  title: Text("multi_sig_addr".tr),
                  subtitle: Text("establishing_multi_sig_addr".tr),
                  onTap: () {
                    context.to(PageRouter.rippleMultisigAddress,
                        argruments: chainAccount);
                  },
                ),
                WidgetConstant.divider
              ],
              AppListTile(
                title: Text("trust_set".tr),
                subtitle: Text("tust_line_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleTrustSetForm>(
                      validator: RippleTrustSetForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: Text("account_set".tr),
                subtitle: Text("account_set_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleAccountSetForm>(
                      validator: RippleAccountSetForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                  onTap: () {
                    context.to(PageRouter.rippleAddNfts);
                  },
                  title: Text("manage_nfts".tr),
                  subtitle: Text("manage_nfts_desc".tr)),
              AppListTile(
                title: const Text("NFTokenMint"),
                subtitle: Text("ripple_mint_nftoken_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleMintTokenForm>(
                      validator: RippleMintTokenForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("NFTokenBurn"),
                subtitle: Text("ripple_nftoken_burn_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippeBurnTokenForm>(
                      validator: RippeBurnTokenForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("NFTokenCreateOffer"),
                subtitle: Text("ripple_create_nftoken_offer_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleCreateOfferForm>(
                      validator: RippleCreateOfferForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("NFTokenCancelOffer"),
                subtitle: Text("ripple_nftoken_cancel_offer_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleCancelOfferForm>(
                      validator: RippleCancelOfferForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: const Text("EscrowCreate"),
                subtitle: Text("ripple_escrow_create_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleEscrowCreateForm>(
                      validator: RippleEscrowCreateForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("EscrowFinish"),
                subtitle: Text("ripple_escrow_finish_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleEscrowFinishForm>(
                      validator: RippleEscrowFinishForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("EscrowCancel"),
                subtitle: Text("ripple_escrow_cancel_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleEscrowCancelForm>(
                      validator: RippleEscrowCancelForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: const Text("SetRegularKey"),
                subtitle: Text("ripple_regular_key_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleRegularKeyForm>(
                      validator: RippleRegularKeyForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: const Text("SignerListSet"),
                subtitle: Text("ripple_set_signer_list_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleSignerListForm>(
                      validator: RippleSignerListForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: Text("ripple_key_conversion".tr),
                subtitle: Text("ripple_key_conversion_desc".tr),
                onTap: () {
                  context.to(PageRouter.rippleKeyConversion);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
