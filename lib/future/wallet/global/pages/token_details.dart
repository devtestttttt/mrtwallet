import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/r.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

import 'package:on_chain_wallet/wallet/wallet.dart';

enum TokenAction { delete, transfer }

class TokenDetailsModalView<NETWORKADDRESS, TOKEN extends TokenCore,
    CHAINACCOUNT extends ChainAccount> extends StatelessWidget {
  const TokenDetailsModalView(
      {super.key,
      required this.token,
      required this.address,
      required this.transferPath,
      required this.account,
      this.transferArgruments});
  final TOKEN token;
  final CHAINACCOUNT address;
  final APPCHAINACCOUNT<CHAINACCOUNT> account;
  final String transferPath;
  final Object? transferArgruments;
  @override
  Widget build(BuildContext context) {
    return ChainStreamBuilder(
        allowNotify: [ChainNotify.token],
        builder: (context, chain, lastNotify) {
          final currentToken = address.tokens.whereType<TOKEN>().firstWhere(
              (e) => e.identifier == token.identifier,
              orElse: () => token);
          final addr = account.network.getAccountExplorer(currentToken.issuer);
          return CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverAppBar(
                title: Text("token_info".tr),
                leading: WidgetConstant.sizedBox,
                leadingWidth: 0,
                pinned: true,
                actions: [
                  if (addr != null)
                    LaunchBrowserIcon(url: addr, size: APPConst.double20),
                  IconButton(
                      onPressed: () {
                        context.openMaxExtendSliverBottomSheet<bool>(
                            "update_token".tr,
                            bodyBuilder: (scrollController) =>
                                UpdateTokenDetailsView(
                                    token: currentToken.token,
                                    accountToken: currentToken,
                                    account: account,
                                    address: address,
                                    scrollController: scrollController),
                            centerContent: false);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        context.openSliverDialog(
                            (ctx) => DialogTextView(
                                buttonWidget: AsyncDialogDoubleButtonView(
                                  firstButtonPressed: () => account
                                      .removeToken(
                                          token: currentToken, address: address)
                                      .then((value) {
                                    context.pop();
                                  }).catchError((_) {}),
                                ),
                                text: "remove_token_from_account".tr),
                            "remove_token".tr);
                      },
                      icon: Icon(Icons.delete, color: context.colors.error)),
                  const CloseButton(),
                  WidgetConstant.width8,
                ],
              ),
              SliverToBoxAdapter(
                child: ConstraintsBoxView(
                  padding: WidgetConstant.padding20,
                  child: _TokenDetailsView(
                    token: currentToken,
                    address: address,
                    transferPath: transferPath,
                    transferArgruments: transferArgruments,
                  ),
                ),
              ),
            ],
          );
        },
        account: account);
  }
}

class _TokenDetailsView extends StatelessWidget {
  const _TokenDetailsView(
      {required this.token,
      required this.address,
      required this.transferPath,
      this.transferArgruments});
  final TokenCore token;
  final ChainAccount address;
  final String transferPath;
  final Object? transferArgruments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child:
                    AddressDetailsView(address: address, showBalance: false)),
          ],
        ),
        WidgetConstant.divider,
        CircleTokenImageView(token.token, radius: 60),
        WidgetConstant.height8,
        Text(token.token.nameView, style: context.textTheme.labelLarge),
        WidgetConstant.height8,
        CoinAndMarketLivePriceView(
            liveBalance: token.streamBalance,
            style: context.textTheme.titleLarge),
        WidgetConstant.height20,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                context.offTo(transferPath,
                    argruments: transferArgruments ?? token);
              },
              child: const Icon(Icons.upload),
            ),
            WidgetConstant.width8,
            FloatingActionButton(
              onPressed: () {
                context.openDialogPage('',
                    child: (context) => BarcodeImageView(
                          data: address.address.toAddress,
                        ),
                    maxWidth: APPConst.qrCodeWidth);
              },
              child: const Icon(Icons.download),
            )
          ],
        )
      ],
    );
  }
}
