import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/cosmos/transaction/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

import 'fee.dart';
import 'ibc.dart';
import 'pick_token.dart';

class CosmosTransactionFieldsView extends StatelessWidget {
  const CosmosTransactionFieldsView({super.key, this.form});
  final LiveTransactionForm<CosmosTransactionForm>? form;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<CosmosTransactionForm> validator =
        form ?? context.getArgruments();
    return NetworkAccountControllerView<CosmosClient, ICosmosAddress,
        CosmosChain>(
      addressRequired: true,
      clientRequired: true,
      title: validator.validator.name.tr,
      childBulder: (wallet, account, client, address, onAccountChanged) =>
          StateBuilder<CosomosTransactionStateController>(
              repositoryId: StateConst.cosmos,
              controller: () => CosomosTransactionStateController(
                  walletProvider: wallet,
                  account: account,
                  apiProvider: client,
                  validator: validator),
              builder: (controller) {
                return PageProgress(
                  key: controller.progressKey,
                  backToIdle: APPConst.oneSecoundDuration,
                  initialStatus: StreamWidgetStatus.progress,
                  child: (c) => CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ConstraintsBoxView(
                          padding: WidgetConstant.padding20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("account".tr,
                                  style: context.textTheme.titleLarge),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                onRemoveIcon: Icon(Icons.edit,
                                    color: context.onPrimaryContainer),
                                child: AddressDetailsView(
                                    address: controller.address,
                                    color: context.onPrimaryContainer,
                                    key: ValueKey<ICosmosAddress?>(
                                        controller.address)),
                                onRemove: () {
                                  context
                                      .selectOrSwitchAccount<ICosmosAddress>(
                                          account: controller.account,
                                          showMultiSig: true)
                                      .then(onAccountChanged);
                                },
                              ),
                              WidgetConstant.height20,
                              _CosmosTransactionsFields(
                                  controller: controller,
                                  form: controller.validator.validator),
                              WidgetConstant.height20,
                              Text("transaction_fee".tr,
                                  style: context.textTheme.titleMedium),
                              Text("cost_for_transaction".tr),
                              WidgetConstant.height8,
                              _CosmosFeeView(controller: controller),
                              InsufficientBalanceErrorView(
                                  verticalMargin:
                                      WidgetConstant.paddingVertical10,
                                  balance: controller.remindAmount),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FixedElevatedButton(
                                      padding: WidgetConstant.paddingVertical40,
                                      onPressed: controller.trIsReady
                                          ? controller.sendTransaction
                                          : null,
                                      child: Text("send_transaction".tr))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
    );
  }
}

class _CosmosTransactionsFields extends StatelessWidget {
  const _CosmosTransactionsFields(
      {required this.form, required this.controller});
  final CosmosTransactionForm form;
  final CosomosTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return switch (form.runtimeType) {
      const (CosmosTransferForm) => _CosmosTransactionTransferFields(
          controller: controller, form: form as CosmosTransferForm),
      const (CosmosIbcTransferForm) => CosmosIbcTransferFields(
          controller: controller, form: form as CosmosIbcTransferForm),
      _ => throw UnimplementedError()
    };
  }
}

class _CosmosTransactionTransferFields extends StatelessWidget {
  const _CosmosTransactionTransferFields(
      {required this.controller, required this.form});
  final CosomosTransactionStateController controller;
  final CosmosTransferForm form;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
        Text("amount_for_each_output".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(form.destinations.value.length, (index) {
            final CosmosOutputWithBalance receiver =
                form.destinations.value[index];
            final Token transferToken =
                receiver.token?.token ?? controller.network.token;
            final hasTokenBalance =
                !(form.remindTokenAmounts[receiver.token]?.isNegative ?? false);
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              enableTap: false,
              onRemoveIcon:
                  Icon(Icons.remove_circle, color: context.onPrimaryContainer),
              validate: receiver.hasAmount && hasTokenBalance,
              onRemove: () {
                form.onRemoveReceiver(receiver);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openMaxExtendSliverBottomSheet<CW20Token>(
                            "transfer".tr,
                            centerContent: false,
                            bodyBuilder: (sc) => CosmosTransactionPickTokenView(
                              address: controller.address,
                              network: controller.network,
                              controller: sc,
                            ),
                          )
                          .then((e) => form.setToken(receiver, e));
                    },
                    backgroundColor: context.onPrimaryContainer,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    child: TokenDetailsWidget(
                        token: transferToken,
                        color: context.primaryContainer,
                        radius: APPConst.circleRadius25),
                  ),
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                          address: receiver.address,
                          color: context.primaryContainer)),
                  ContainerWithBorder(
                    onRemove: () {
                      final max = form.max(
                          address: controller.address,
                          fee: controller.fee.feeAmount.balance,
                          destination: receiver);
                      context
                          .setupAmount(token: transferToken, max: max)
                          .then((amount) {
                        form.setBalance(receiver, amount);
                      });
                    },
                    validate: receiver.hasAmount && hasTokenBalance,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinAndMarketPriceView(
                      balance: receiver.balance,
                      style: context.primaryTextTheme.titleMedium,
                      symbolColor: context.primaryContainer,
                      showTokenImage: true,
                    ),
                  ),
                  if (!hasTokenBalance)
                    InsufficientBalanceErrorView(
                        balance: form.remindTokenAmounts[receiver.token]!)
                ],
              ),
            );
          }),
        ),
        ContainerWithBorder(
          validate: form.destinations.hasValue,
          onRemove: () {
            context
                .selectAccount<CosmosBaseAddress>(
                    account: controller.account, multipleSelect: true)
                .then(
              (value) {
                form.setReceiver(addresses: value, network: controller.network);
              },
            );
          },
          onRemoveIcon: Icon(Icons.add_box, color: context.onPrimaryContainer),
          child: Text("tap_to_add_new_receipment".tr,
              style: context.onPrimaryTextTheme.bodyMedium),
        ),
        WidgetConstant.height20,
        Text("setup_memo".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemoveIcon: AddOrEditIconWidget(controller.hasMemo),
            onRemove: () {
              controller.onTapMemo((s) async {
                final result = await context.openSliverBottomSheet<String>(
                  "transaction_memo".tr,
                  child: StringWriterView(
                    defaultValue: controller.memo,
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
                  ),
                );
                return result;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(controller.memo ?? "tap_to_add_memo".tr,
                      style: context.onPrimaryTextTheme.bodyMedium),
                ),
              ],
            )),
      ],
    );
  }
}

class _CosmosFeeView extends StatelessWidget {
  final CosomosTransactionStateController controller;
  const _CosmosFeeView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerWithBorder(
            onRemove: controller.hasMultipleFeeToken
                ? () {
                    context
                        .openMaxExtendSliverBottomSheet<CW20Token>(
                          "fee_token".tr,
                          centerContent: false,
                          bodyBuilder: (sc) => CosmosTransactionPickTokenView(
                              tokens: controller.feeTokens,
                              network: controller.network,
                              controller: sc),
                        )
                        .then(controller.setFeeToken);
                  }
                : null,
            onRemoveIcon: EditOrRemoveIconWidget(controller.hasMultipleFeeToken,
                color: context.primaryContainer),
            backgroundColor: context.onPrimaryContainer,
            child: TokenDetailsWidget(
              token: controller.fee.token,
              color: context.primaryContainer,
              radius: APPConst.circleRadius25,
            ),
          ),
          ContainerWithBorder(
            onRemoveIcon: ButtonProgress(
              color: context.primaryContainer,
              child: (context) => EditOrRemoveIconWidget(
                  controller.fee.feeType.isManually,
                  color: context.primaryContainer),
              key: controller.feeProgressKey,
            ),
            backgroundColor: context.onPrimaryContainer,
            validateText: controller.feeError?.tr,
            validate: controller.feeError == null && controller.hasFee,
            onTapError: () {
              controller.simulateTr();
            },
            onRemove: () {
              controller.setupFee(
                onSetupFee: (fee) => context
                    .openSliverBottomSheet<CosmosFeeInfo>("setup_custom_fee".tr,
                        child: CosmosSetTransferFeeView(fee: fee)),
                onRemoveFee: () => context.openSliverDialog(
                    (context) => DialogTextView(
                        text: "switch_to_automatic_fee_desc".tr,
                        buttonWidget: const DialogDoubleButtonView()),
                    "automatically_setup_fee".tr),
              );

              // ;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.fee.feeType.name.tr,
                    style: context.primaryTextTheme.labelLarge),
                CoinAndMarketPriceView(
                    balance: controller.fee.feeAmount,
                    style: context.primaryTextTheme.titleMedium,
                    symbolColor: context.primaryContainer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
