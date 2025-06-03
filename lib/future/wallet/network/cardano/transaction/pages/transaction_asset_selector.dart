import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/app.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

typedef _OnSelectAssets = Future<BigInt?> Function(BigInt? value);

class CardanoTransactionAssetSelectorView extends StatefulWidget {
  const CardanoTransactionAssetSelectorView(
      {super.key,
      required this.totalAssets,
      required this.remindAsset,
      required this.receiver,
      required this.controller});
  final UtxoMultiAsset totalAssets;
  final UtxoMultiAsset remindAsset;
  final CardanoOutputWithBalance receiver;
  final ScrollController controller;

  @override
  State<CardanoTransactionAssetSelectorView> createState() =>
      _CardanoTransactionAssetSelectorViewState();
}

class _CardanoTransactionAssetSelectorViewState
    extends State<CardanoTransactionAssetSelectorView>
    with SafeState<CardanoTransactionAssetSelectorView> {
  List<_AssetWithPolicyId> toAssetsWithPolicyId() {
    final destinationAssets = widget.receiver.asset;
    final List<_AssetWithPolicyId> assets = [];
    for (final i in widget.totalAssets.assets.entries) {
      for (final b in i.value.assets.entries) {
        final destinationAssetBalance =
            destinationAssets.assets[i.key]?.assets[b.key]?.balance ??
                BigInt.zero;
        final remainAmount =
            (widget.remindAsset.assets[i.key]?.assets[b.key]?.balance ??
                BigInt.zero);
        final totalRemain = remainAmount + destinationAssetBalance;
        if (totalRemain == BigInt.zero) continue;
        final asset = _AssetWithPolicyId(
            name: b.key,
            policyID: i.key,
            decimal: b.value.currencyDecimal,
            pickAmount: IntegerBalance.token(
                destinationAssetBalance, b.value.token, allowNegative: false),
            remainAmount: IntegerBalance.token(totalRemain, b.value.token,
                allowNegative: false, immutable: true));
        assets.add(asset);
      }
    }
    return assets;
  }

  List<_AssetWithPolicyId> assets = [];

  void onSelectAsset(
      _AssetWithPolicyId assets, _OnSelectAssets onSelectAssets) async {
    final val = await onSelectAssets(assets.remainAmount.balance);
    if (val == null || val > assets.remainAmount.balance) return;
    if (val > assets.remainAmount.balance) return;
    assets.pickAmount.updateBalance(val);
    updateState();
  }

  UtxoMultiAsset toAsset() {
    final Map<PolicyID, UtxoAssets> assets = {};
    for (final i in this.assets) {
      if (i.pickAmount.isZero) continue;
      assert(i.pickAmount.balance <= i.remainAmount.balance);
      final UtxoAssets utxoAsset =
          UtxoAssets({i.name: i.pickAmount.clone(immutable: true)});
      if (assets.containsKey(i.policyID)) {
        assets[i.policyID] = assets[i.policyID]! + utxoAsset;
      } else {
        assets[i.policyID] = utxoAsset;
      }
    }
    return UtxoMultiAsset(assets);
  }

  void onSetup() {
    context.pop(toAsset());
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    assets = toAssetsWithPolicyId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("setup_asset_amount".tr)),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: onSetup, label: Text("setup_recipient_assets".tr)),
      body: CustomScrollView(
        controller: widget.controller,
        slivers: [
          SliverToBoxAdapter(
            child: ConstraintsBoxView(
              padding: WidgetConstant.padding20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitleSubtitle(
                      title: "receiver".tr,
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReceiptAddressView(
                              address: widget.receiver.address, title: null),
                          ErrorTextContainer(
                              error: "assets_balance_not_supported_desc".tr,
                              enableTap: false),
                        ],
                      )),
                  WidgetConstant.height20,
                  Text("assets".tr, style: context.textTheme.titleMedium),
                  Text("set_amount_for_each_assets_or_zero".tr),
                  WidgetConstant.height8,
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: assets.length,
                    physics: WidgetConstant.noScrollPhysics,
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemBuilder: (c, index) {
                      final asset = assets[index];
                      return ContainerWithBorder(
                          child: Column(
                        children: [
                          ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            child: TokenDetailsWidget(
                                token: asset.remainAmount.token,
                                radius: APPConst.circleRadius25,
                                balance: asset.remainAmount,
                                color: context.primaryContainer),
                          ),
                          ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            onRemove: () {
                              onSelectAsset(asset, (max) async {
                                return await context.setupAmount(
                                    token: asset.remainAmount.token, max: max);
                              });
                            },
                            onRemoveIcon: AddOrEditIconWidget(
                              asset.pickAmount.largerThanZero,
                              color: context.primaryContainer,
                            ),
                            child: CoinAndMarketPriceView(
                                balance: asset.pickAmount,
                                style: context.primaryTextTheme.titleMedium,
                                symbolColor: context.primaryContainer),
                          ),
                        ],
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
          WidgetConstant.sliverPaddingVertial40,
        ],
      ),
    );
  }
}

class _AssetWithPolicyId {
  final AssetName name;
  final PolicyID policyID;
  final int decimal;
  final IntegerBalance remainAmount;
  final IntegerBalance pickAmount;
  _AssetWithPolicyId(
      {required this.name,
      required this.policyID,
      required this.decimal,
      required this.remainAmount,
      required this.pickAmount});
}
