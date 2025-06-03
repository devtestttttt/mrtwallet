import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/app.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/transaction/pages/widgets/pick_asset.dart';
import 'package:on_chain_wallet/wallet/constant/networks/stellar.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/stellar/stellar.dart';

class ChangeTrustOperationView extends StatefulWidget {
  final StellarTransactionStateController controller;
  final StellarChangeTrustOperation? operation;
  const ChangeTrustOperationView(
      {required this.controller, this.operation, super.key});

  @override
  State<ChangeTrustOperationView> createState() =>
      _ChangeTrustOperationViewState();
}

class _ChangeTrustOperationViewState extends State<ChangeTrustOperationView>
    with SafeState {
  StellarTransactionStateController get controller => widget.controller;
  StellarChain get chain => controller.account;
  StellarPickedIssueAsset? asset;
  late IntegerBalance limit = IntegerBalance.zero(chain.network.token);
  void pickAssets(StellarPickedIssueAsset? asset) {
    if (asset == null || asset.asset.type.isNative) return;
    limit = IntegerBalance.zero(asset.token);
    this.asset = asset;
    showLimit = this.asset != null;
    limit.updateBalance(BigInt.zero);
    updateState();
  }

  void setupAmount(BigInt? amount) {
    if (amount == null) return;
    limit.updateBalance(amount);
    updateState();
  }

  void setupOperation() {
    if (asset == null) return;
    final operation = StellarChangeTrustOperation(asset: asset!, limit: limit);
    context.pop(operation);
  }

  bool showLimit = false;

  void init() {
    final operation = widget.operation;
    if (operation == null) return;
    asset = operation.asset;
    limit = IntegerBalance.zero(operation.asset.token);
    limit.updateBalance(operation.limit.balance);
    showLimit = asset != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "change_trust".tr,
            body: LargeTextView([
              "change_trust_desc".tr,
              "stellar_change_trust_limit_zero_desc".tr,
              if (widget.operation != null)
                "remove_operation_close_page_desc".tr
            ])),
        Text("asset".tr, style: context.textTheme.titleMedium),
        Text("modify_trust_line_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: AddOrEditIconWidget(asset != null),
          child: asset == null
              ? Text("tap_to_select_or_create_asset".tr,
                  style: context.onPrimaryTextTheme.bodyMedium)
              : TokenDetailsWidget(
                  token: asset!.token,
                  color: context.onPrimaryContainer,
                  radius: APPConst.circleRadius25,
                ),
          onRemove: () {
            context
                .openSliverDialog<StellarPickedIssueAsset>(
                    (c) => PickFromAccountAssets(
                          accountInfo: controller.accountInfo,
                          chain: chain,
                          allowNativeAssets: false,
                        ),
                    "assets".tr,
                    content: (context) => [
                          IconButton(
                            tooltip: "create_assets".tr,
                            icon: const Icon(Icons.add_box),
                            onPressed: () {
                              context.pop();
                              this
                                  .context
                                  .openSliverBottomSheet<
                                          StellarPickedIssueAsset>(
                                      "pick_an_asset".tr,
                                      child: StellarPickAssetView(chain: chain))
                                  .then(pickAssets);
                            },
                          )
                        ])
                .then(pickAssets);
          },
        ),
        WidgetConstant.height20,
        APPAnimatedSwitcher<bool>(
            enable: showLimit, widgets: {true: (c) => _ChangeTrustLimit(this)}),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FixedElevatedButton(
              padding: WidgetConstant.paddingVertical40,
              onPressed: asset != null ? setupOperation : null,
              child: Text("setup_operation".tr))
        ])
      ],
    );
  }
}

class _ChangeTrustLimit extends StatelessWidget {
  final _ChangeTrustOperationViewState state;
  const _ChangeTrustLimit(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("limit".tr, style: context.textTheme.titleMedium),
        Text("change_trust_limit".tr),
        Text("stellar_change_trust_limit_zero_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: !state.limit.isNegative,
          onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
          child: CoinAndMarketPriceView(
            balance: state.limit,
            style: context.onPrimaryTextTheme.titleMedium,
            symbolColor: context.onPrimaryContainer,
            showTokenImage: true,
          ),
          onRemove: () {
            context
                .setupAmount(
                    token: state.asset!.token, max: StellarConst.maxIssueAmount)
                .then(state.setupAmount);
          },
        )
      ],
    );
  }
}
