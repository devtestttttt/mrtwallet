import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/token_details_view.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class CosmosTransactionPickTokenView extends StatefulWidget {
  const CosmosTransactionPickTokenView(
      {required this.network,
      this.address,
      this.tokens,
      // this.title,
      required this.controller,
      super.key})
      : assert(address != null || tokens != null,
            "choose address or tokens to pick token");
  final ICosmosAddress? address;
  final WalletCosmosNetwork network;
  final List<CW20Token>? tokens;
  // final Widget? title;
  final ScrollController controller;

  @override
  State<CosmosTransactionPickTokenView> createState() =>
      _CosmosTransactionPickTokenViewState();
}

class _CosmosTransactionPickTokenViewState
    extends State<CosmosTransactionPickTokenView>
    with SafeState<CosmosTransactionPickTokenView> {
  List<CW20Token> tokens = [];
  CW20Token? networkToken;
  CW20Token buildNetworkToken() {
    return CW20Token.create(
        balance: widget.address!.address.currencyBalance,
        token: widget.network.token,
        denom: widget.network.coinParam.denom);
  }

  void buildTokens() {
    if (widget.address != null) {
      networkToken ??= buildNetworkToken();
      tokens = [networkToken!, ...widget.address!.tokens];
    } else {
      tokens = widget.tokens ?? [];
    }
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    buildTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('pick_token'.tr)),
      body: CustomScrollView(
        controller: widget.controller,
        slivers: [
          SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: MultiSliver(children: [
                SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageTitleSubtitle(
                            title: 'pick_token'.tr,
                            body: LargeTextView([
                              "cosmos_pick_token_transfer_desc".tr,
                              if (widget.tokens == null)
                                "cosmos_transfer_import_token_desc".tr
                            ])),
                      ]),
                ),
                EmptyItemSliverWidgetView(
                    isEmpty: tokens.isEmpty,
                    icon: Icons.token,
                    itemBuilder: (context) => SliverList.separated(
                          itemCount: tokens.length,
                          itemBuilder: (context, index) {
                            final token = tokens[index];
                            return TokenDetailsView(
                              onSelectIcon: WidgetConstant.sizedBox,
                              onSelect: () {
                                context.pop(token);
                              },
                              token: token,
                            );
                          },
                          separatorBuilder: (context, index) =>
                              WidgetConstant.divider,
                        ))
              ])),
        ],
      ),
    );
  }
}
