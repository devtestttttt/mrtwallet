import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/nfts/networks/ripple.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';

class RippleNFTokenView extends StatelessWidget {
  const RippleNFTokenView({required this.nft, super.key});
  final RippleNFToken nft;
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("nfts_id".tr, style: context.onPrimaryTextTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
                text: nft.nftokenId, color: context.primaryContainer),
          ),
          if (nft.uri != null) ...[
            Text("uri".tr, style: context.onPrimaryTextTheme.titleMedium),
            WidgetConstant.height8,
            ContainerWithBorder(
              backgroundColor: context.onPrimaryContainer,
              child: CopyableTextWidget(
                  text: nft.uri ?? "", color: context.primaryContainer),
            ),
          ],
          Divider(color: context.onPrimaryContainer),
          AppListTile(
            title: const Text("NFTokenBurn"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              final validator = LiveTransactionForm<RippeBurnTokenForm>(
                  validator: RippeBurnTokenForm(offerID: nft.nftokenId));
              context.to(PageRouter.rippleTransaction, argruments: validator);
            },
          ),
          AppListTile(
            title: const Text("NFTokenCreateOffer"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              final validator = LiveTransactionForm<RippleCreateOfferForm>(
                  validator: RippleCreateOfferForm(offerID: nft.nftokenId));
              context.to(PageRouter.rippleTransaction, argruments: validator);
            },
          ),
          AppListTile(
            title: const Text("NFTokenCancelOffer"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              final validator = LiveTransactionForm<RippleCancelOfferForm>(
                  validator: RippleCancelOfferForm(offerID: nft.nftokenId));
              context.to(PageRouter.rippleTransaction, argruments: validator);
            },
          ),
        ],
      ),
    );
  }
}
