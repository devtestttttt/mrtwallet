import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/tron/models/tron_fee.dart';
import 'package:on_chain/tron/src/models/contract/base_contract/transaction_type.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TronFeeDetailsView extends StatelessWidget {
  const TronFeeDetailsView({super.key, required this.transaction});
  final TronTransactionFeeIMpl transaction;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: APPConst.animationDuraion,
      child: _TronTransactionFeeView(
          key: ValueKey(
              "${transaction.loadingFee}/${transaction.consumedFee == null}"),
          transaction: transaction),
    );
  }
}

class _TronTransactionFeeView extends StatelessWidget {
  const _TronTransactionFeeView({super.key, required this.transaction});
  final TronTransactionFeeIMpl transaction;
  @override
  Widget build(BuildContext context) {
    if (!transaction.loadingFee &&
        transaction.consumedFee == null &&
        transaction.feeCalculationError == null) {
      return WidgetConstant.sizedBox;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("total_burn".tr),
        WidgetConstant.height8,
        ConditionalWidget(
          // enable: true,
          enable: transaction.consumedFee == null &&
              transaction.feeCalculationError == null,
          onActive: (context) => ContainerWithBorder(
            onRemove: () {},
            enableTap: false,
            onRemoveWidget:
                APPCircularProgressIndicator(color: context.onPrimaryContainer),
            child: Text("retrieving_network_condition".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          ),
          onDeactive: (context) => ConditionalWidget(
              enable: transaction.feeCalculationError == null,
              onDeactive: (context) => ContainerWithBorder(
                    backgroundColor: context.colors.errorContainer,
                    onTapError: () {
                      transaction.calculateFee();
                    },
                    onRemoveIcon: Icon(Icons.refresh,
                        color: context.colors.onErrorContainer),
                    child: Text(transaction.feeCalculationError!.tr,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.onErrorContainer)),
                  ),
              onActive: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TronFeeInfoWidget(
                          consumedFee: transaction.consumedFee!,
                          network: transaction.network),
                      if (transaction.field.type ==
                          TransactionContractType.triggerSmartContract) ...[
                        WidgetConstant.height20,
                        Text("fee_limit".tr,
                            style: context.textTheme.titleMedium),
                        Text("tron_fee_limit_desc".tr),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                          onRemoveIcon: Icon(
                            Icons.edit,
                            color: context.onPrimaryContainer,
                          ),
                          validateText: "low_fee_limit_desc".tr,
                          validate: !transaction.consumedFee!.feeLimitError,
                          onRemove: () {
                            transaction.setCustomFeeLimit(() async {
                              return context.setupAmount(
                                  title: "fee_limit".tr,
                                  token: transaction.network.coinParam.token,
                                  max: transaction
                                      .address.address.currencyBalance);
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  transaction
                                      .consumedFee!.feeLimitType.value.tr,
                                  style: context.onPrimaryTextTheme.labelLarge),
                              CoinAndMarketPriceView(
                                  balance: transaction.consumedFee!.feeLimit,
                                  style: context.onPrimaryTextTheme.titleMedium,
                                  showTokenImage: true,
                                  symbolColor: context.onPrimaryContainer),
                            ],
                          ),
                        )
                      ]
                    ],
                  )),
        ),
        WidgetConstant.height20,
      ],
    );
  }
}

class TronFeeInfoWidget extends StatelessWidget {
  const TronFeeInfoWidget(
      {required this.consumedFee, required this.network, super.key});
  final TronFee consumedFee;
  final WalletTronNetwork network;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CoinAndMarketPriceView(
            balance: consumedFee.totalBurn,
            style: context.onPrimaryTextTheme.titleMedium,
            symbolColor: context.colors.onPrimaryContainer,
            showTokenImage: true,
          ),
        ),
        WidgetConstant.width8,
        ToolTipView(
          mode: TooltipTriggerMode.tap,
          waitDuration: null,
          tooltipWidget: (c) => Container(
            constraints: const BoxConstraints(
                maxWidth: APPConst.tooltipConstrainedWidth),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "bandwidth".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    RichText(
                        text: TextSpan(
                            style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onTertiaryContainer),
                            children: [
                          TextSpan(
                              text: consumedFee.consumedBandwidth.toString()),
                          const TextSpan(text: "/"),
                          TextSpan(
                              text: consumedFee.stackedBandWidth.toString()),
                        ])),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "energy".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    RichText(
                        text: TextSpan(
                            style: context.colors.onTertiaryContainer
                                .bodyMedium(context),
                            children: [
                          TextSpan(
                              text: consumedFee.connsumedEnergy.toString()),
                          const TextSpan(text: "/"),
                          TextSpan(text: consumedFee.stackedEnergy.toString()),
                        ])),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "trx_burned_for_resource".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    CoinAndMarketPriceView(
                        balance: consumedFee.burnedForResource,
                        symbolColor: context.colors.onTertiaryContainer,
                        style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.onTertiaryContainer))
                  ],
                ),
                Divider(color: context.colors.onTertiaryContainer),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "total_burn".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    CoinAndMarketPriceView(
                      balance: consumedFee.totalBurn,
                      style: context.textTheme.labelLarge
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                      symbolColor: context.colors.onTertiaryContainer,
                    ),
                  ],
                ),
                Divider(color: context.colors.onTertiaryContainer),
                Text(
                  [
                    "1. Issue a TRC10 token: 1,024 TRX",
                    "2. Apply to be an SR candidate: 9,999 TRX",
                    "3. Create a Bancor transaction: 1,024 TRX",
                    "4. Update the account permission: 100 TRX",
                    "5. Activate the account: 1 TRX",
                    "6. Multi-sig transaction: 1 TRX",
                    "7. Transaction note: 1 TRX"
                  ].join("\n"),
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colors.onTertiaryContainer),
                )
              ],
            ),
          ),
          child: Icon(
            Icons.help,
            color: context.onPrimaryContainer,
          ),
        )
      ],
    ));
  }
}
