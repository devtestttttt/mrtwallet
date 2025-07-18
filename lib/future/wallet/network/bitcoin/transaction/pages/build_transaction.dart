import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/transaction/pages/ordering/transaction_ordering_view.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class BitcoinBuildTransactionView extends StatelessWidget {
  const BitcoinBuildTransactionView({super.key, required this.controller});
  final BitcoinStateController controller;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("spendable_amount".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: AnimatedSwitcher(
              duration: APPConst.animationDuraion,
              child: Row(
                key: ValueKey(controller.spendableAmount.price),
                children: [
                  Expanded(
                    child: CoinAndMarketPriceView(
                        balance: controller.spendableAmount,
                        symbolColor: context.colors.onPrimaryContainer,
                        style: context.colors.onPrimaryContainer
                            .titleMedium(context)),
                  ),
                ],
              ),
            ),
          ),
          WidgetConstant.height20,
          Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
          Text("amount_for_each_output".tr),
          WidgetConstant.height8,
          Column(
            children: List.generate(controller.receivers.length, (index) {
              final BitcoinOutputWithBalance receinver =
                  controller.receivers[index];
              return ContainerWithBorder(
                iconAlginment: CrossAxisAlignment.start,
                onRemoveWidget: IconButton(
                    onPressed: () {
                      controller.removeReceiver(receinver.address);
                    },
                    icon: Icon(Icons.remove_circle,
                        color: context.colors.onPrimaryContainer)),
                validate: receinver.hasAmount,
                enableTap: false,
                onRemove: () {
                  //
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerWithBorder(
                        backgroundColor: context.onPrimaryContainer,
                        child: ReceiptAddressDetailsView(
                            address: receinver.address,
                            color: context.primaryContainer)),
                    ContainerWithBorder(
                      onRemove: () {
                        context
                            .setupAmount(
                                token: controller.network.coinParam.token,
                                max: controller.remindAmount.balance +
                                    receinver.balance.balance,
                                min: controller.minimumOutput)
                            .then((amount) {
                          controller.setupAccountAmount(receinver, amount);
                        });
                      },
                      validate: receinver.hasAmount,
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.primaryContainer),
                      backgroundColor: context.onPrimaryContainer,
                      child: CoinAndMarketPriceView(
                          balance: receinver.balance,
                          showTokenImage: true,
                          style: context.primaryTextTheme.titleMedium,
                          symbolColor: context.primaryContainer),
                    )
                  ],
                ),
              );
            }),
          ),
          ContainerWithBorder(
              validate: controller.receivers.isNotEmpty,
              onRemove: () {
                context
                    .selectAccount<BitcoinBaseAddress>(
                        account: controller.account, multipleSelect: true)
                    .then(
                  (value) {
                    controller.onAddRecever(value, () {
                      context.showAlert("some_addresses_exist".tr);
                    });
                  },
                );
              },
              onRemoveIcon:
                  Icon(Icons.add_box, color: context.onPrimaryContainer),
              child: Text("tap_to_add_new_receipment".tr,
                  style: context.onPrimaryTextTheme.bodyMedium)),
          WidgetConstant.height20,
          Text("remaining_amount".tr, style: context.textTheme.titleMedium),
          Text("remaining_amount_and_receiver".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CoinAndMarketPriceView(
                      balance: controller.remindAmount,
                      symbolColor: context.primaryContainer,
                      style: context.primaryTextTheme.titleMedium,
                      showTokenImage: true)),
              ContainerWithBorder(
                validate: !controller.remindAmount.isNegative,
                onRemoveIcon: Icon(Icons.edit, color: context.primaryContainer),
                backgroundColor: context.onPrimaryContainer,
                validateText: "transaction_Insufficient_balance".tr,
                onRemove: () {
                  context
                      .selectOrSwitchAccount<IBitcoinAddress>(
                          account: controller.account, showMultiSig: true)
                      .then(controller.changeAccount);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.onChangeAddress.type.value,
                        style: context.primaryTextTheme.labelLarge),
                    OneLineTextWidget(controller.onChangeAddressView,
                        style: context.primaryTextTheme.bodyMedium)
                  ],
                ),
              ),
            ],
          )),
          ConditionalWidget(
              enable: controller.supportRbf,
              onActive: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetConstant.height20,
                      Text("replace_by_fee".tr,
                          style: context.textTheme.titleMedium),
                      Text("rbf_desc".tr),
                      Text("bitcoin_rbf_error".tr),
                      WidgetConstant.height8,
                      InkWell(
                        borderRadius: WidgetConstant.border8,
                        onTap: () {
                          controller.toggleRbf(false);
                        },
                        child: ContainerWithBorder(
                            child: Row(
                          children: [
                            Expanded(
                              child: Text("replace_by_fee".tr,
                                  style: context.colors.onPrimaryContainer
                                      .bodyMedium(context)),
                            ),
                            Switch(
                                value: controller.rbf,
                                onChanged: controller.toggleRbf),
                          ],
                        )),
                      ),
                    ],
                  )),
          WidgetConstant.height20,
          Text("setup_memo".tr, style: context.textTheme.titleMedium),
          Text("memo_desc2".tr),
          WidgetConstant.height8,
          ...List.generate(controller.memoScripts.length, (index) {
            return ContainerWithBorder(
                onRemoveIcon: Icon(Icons.remove_circle,
                    color: context.onPrimaryContainer),
                onRemove: () {
                  controller.onRemoveMemo(controller.memoScripts[index]);
                },
                child: Text(controller.memoScripts[index].memo,
                    style: context.onPrimaryTextTheme.bodyMedium));
          }),
          APPAnimatedSize(
              isActive: controller.allowAddMemo,
              onActive: (context) => ContainerWithBorder(
                  onRemoveIcon:
                      Icon(Icons.add_box, color: context.onPrimaryContainer),
                  onRemove: () {
                    controller.onTapMemo(() async {
                      final result =
                          await context.openSliverBottomSheet<String>(
                        "transaction_memo".tr,
                        child: StringWriterView(
                          title: PageTitleSubtitle(
                              title: "setup_memo".tr,
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("memo_desc1".tr),
                                  WidgetConstant.height8,
                                  Text("empty_desc".tr),
                                ],
                              )),
                          buttonText: "setup_memo".tr,
                          label: "memo".tr,
                          customForm: controller.onValidateMemo,
                        ),
                      );

                      return result;
                    });
                  },
                  child: Text("tap_to_add_memo".tr,
                      style: context.onPrimaryTextTheme.bodyMedium)),
              onDeactive: (context) => WidgetConstant.sizedBox),
          WidgetConstant.height20,
          Text("transaction_ordering".tr, style: context.textTheme.titleMedium),
          Text("transaction_ordering_desc".tr),
          ContainerWithBorder(
              child: AppDropDownBottom(
            key: ValueKey<TransactionOrdering>(controller.ordering),
            fillColor: context.colors.transparent,
            contentPadding: EdgeInsets.zero,
            items: {
              for (final i in TransactionOrdering.values)
                i: Text(
                  i.name.tr,
                  style: context.onPrimaryTextTheme.bodyMedium,
                )
            },
            selectedItemBuilder: {
              for (final i in TransactionOrdering.values)
                i: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.name.tr),
                    Text(i.desc.tr, style: context.textTheme.bodySmall)
                  ],
                )
            },
            value: controller.ordering,
            onChanged: (p0) {
              controller.onChangeOrdering(p0, (p0, p1) async {
                return context.openSliverBottomSheet("transaction_ordering".tr,
                    bodyBuilder: (c) => TransactionOrderingView(
                        inputs: p0,
                        outputs: p1,
                        network: controller.network,
                        controller: c),
                    initiaalExtend: 1);
              });
            },
          )),
          WidgetConstant.height20,
          Text("transaction_fee".tr, style: context.textTheme.titleMedium),
          Text("cost_for_transaction".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            validateText: controller.feeError?.tr,
            validate: controller.isFeeValid,
            onRemove: () {
              context
                  .openSliverBottomSheet<(String?, BigInt?)>(
                "transaction_fee".tr,
                child: SetupTransactionFee(
                    fees: controller.fees,
                    network: controller.network,
                    type: controller.feeRateType?.name,
                    max: controller.sumOfSelectedUtxo.balance,
                    customFee: controller.transactionFee.balance),
              )
                  .then((value) {
                controller.setFee(value?.$1, customFee: value?.$2);
              });
            },
            onRemoveIcon: const Icon(Icons.edit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.feeRateType?.name.camelCase ?? "custom_fee".tr,
                    style: context.onPrimaryTextTheme.labelLarge),
                CoinAndMarketPriceView(
                  balance: controller.transactionFee,
                  style: context.onPrimaryTextTheme.titleMedium,
                  symbolColor: context.onPrimaryContainer,
                ),
                if (controller.feePerByteDesc != null)
                  Text(controller.feePerByteDesc ?? '',
                      style: context.onPrimaryTextTheme.bodySmall)
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: controller.trReady
                      ? () {
                          controller.sendTransaction();
                        }
                      : null,
                  child: Text("send_transaction".tr)),
            ],
          )
        ],
      ),
    );
  }
}
