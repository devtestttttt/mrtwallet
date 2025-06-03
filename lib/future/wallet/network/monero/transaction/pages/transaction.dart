import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/transaction/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/transaction/controller/impl/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/monero/monero.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class MoneroTransferTransactionView extends StatelessWidget {
  const MoneroTransferTransactionView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<MoneroClient, IMoneroAddress,
        MoneroChain>(
      addressRequired: true,
      clientRequired: true,
      title: "send_transaction".tr,
      childBulder: (wallet, account, client, address, onAccountChanged) =>
          StateBuilder<MoneroTransactionStateController>(
              repositoryId: StateConst.monero,
              controller: () => MoneroTransactionStateController(
                  walletProvider: wallet,
                  account: account,
                  apiProvider: client),
              builder: (controller) {
                return PopScope(
                  canPop: controller.canPop,
                  onPopInvokedWithResult: controller.onPop,
                  child: PageProgress(
                    key: controller.progressKey,
                    initialStatus: PageProgressStatus.progress,
                    backToIdle: APPConst.oneSecoundDuration,
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
                                      key: ValueKey<IMoneroAddress?>(
                                          controller.address)),
                                  onRemove: () {
                                    context
                                        .selectOrSwitchAccount<IMoneroAddress>(
                                            account: controller.account,
                                            showMultiSig: true)
                                        .then(onAccountChanged);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        APPSliverAnimatedSwitcher<MoneroTxPage>(
                            enable: controller.page,
                            widgets: {
                              MoneroTxPage.utxo: (context) =>
                                  _SelectUtxos(controller),
                              MoneroTxPage.send: (context) =>
                                  _SendTransaction(controller),
                            })
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}

class _SendTransaction extends StatelessWidget {
  final MoneroTransactionStateController controller;
  const _SendTransaction(this.controller);

  @override
  Widget build(BuildContext context) {
    return SliverConstraintsBoxView(
      padding: WidgetConstant.paddingHorizontal20,
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("spendable_amount".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            ContainerWithBorder(
                child: CoinAndMarketPriceView(
              balance: controller.spendableAmount,
              style: context.onPrimaryTextTheme.titleMedium,
              symbolColor: context.onPrimaryContainer,
            )),
            WidgetConstant.height20,
            WidgetConstant.height20,
            Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
            Text("amount_for_each_output".tr),
            WidgetConstant.height8,
            Column(
              children: List.generate(controller.receivers.length, (index) {
                return ContainerWithBorder(
                  iconAlginment: CrossAxisAlignment.start,
                  onRemoveIcon: Icon(Icons.remove_circle,
                      color: context.onPrimaryContainer),
                  validate: controller.receivers[index].hasAmount,
                  enableTap: false,
                  onRemove: () {
                    controller
                        .onRemoveReceiver(controller.receivers[index].address);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          child: ReceiptAddressDetailsView(
                            address: controller.receivers[index].address,
                            color: context.primaryContainer,
                          )),
                      ContainerWithBorder(
                        backgroundColor: context.onPrimaryContainer,
                        onRemove: () {
                          context
                              .setupAmount(
                                  token: controller.network.coinParam.token,
                                  max: controller.remindAmount.balance +
                                      controller
                                          .receivers[index].amount.balance)
                              .then((amount) {
                            controller.setupAccountAmount(
                                controller
                                    .receivers[index].address.networkAddress,
                                amount);
                          });
                        },
                        validate: controller.receivers[index].hasAmount,
                        onRemoveIcon:
                            Icon(Icons.edit, color: context.primaryContainer),
                        child: CoinAndMarketPriceView(
                          balance: controller.receivers[index].amount,
                          style: context.primaryTextTheme.titleMedium,
                          symbolColor: context.primaryContainer,
                        ),
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
                      .selectAccount<MoneroAddress>(
                          account: controller.account, multipleSelect: true)
                      .then(
                    (value) {
                      controller.onAddRecever(value, (String err) {
                        context.showAlert(err);
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
                        style: context.primaryTextTheme.titleMedium)),
                ContainerWithBorder(
                  validate: !controller.remindAmount.isNegative,
                  onRemoveIcon:
                      Icon(Icons.edit, color: context.primaryContainer),
                  backgroundColor: context.onPrimaryContainer,
                  validateText: "transaction_Insufficient_balance".tr,
                  onRemove: () {
                    context
                        .selectOrSwitchAccount<IMoneroAddress>(
                            account: controller.account, showMultiSig: true)
                        .then(
                      (value) {
                        controller.changeAccount(
                          value,
                          () {
                            context.showAlert("address_already_exist".tr);
                          },
                        );
                      },
                    );
                  },
                  child: ReceiptAddressDetailsView(
                    address: controller.change,
                    color: context.primaryContainer,
                  ),
                ),
              ],
            )),
            WidgetConstant.height20,
            Text("transaction_fee".tr, style: context.textTheme.titleMedium),
            Text("cost_for_transaction".tr),
            WidgetConstant.height8,
            ContainerWithBorder(
              validateText: controller.feeError?.tr,
              validate: controller.feeError == null,
              onRemove: () {
                context
                    .openSliverBottomSheet<(String?, BigInt?)>(
                  "transaction_fee".tr,
                  child: SetupTransactionFee(
                    fees: controller.fees,
                    network: controller.network,
                    type: controller.priority?.name,
                    max: controller.spendableAmount.balance,
                    customFee: controller.fee.balance,
                  ),
                )
                    .then((value) {
                  controller.setFee(value?.$1, customFee: value?.$2);
                });
              },
              onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.priority?.name.camelCase ?? "custom_fee".tr,
                      style: context.onPrimaryTextTheme.labelLarge),
                  CoinAndMarketPriceView(
                      balance: controller.fee,
                      style: context.onPrimaryTextTheme.titleMedium,
                      symbolColor: context.onPrimaryContainer)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                    activePress: controller.txReady,
                    padding: WidgetConstant.paddingVertical40,
                    onPressed: () => controller.signTransaction(),
                    child: Text("send_transaction".tr))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SelectUtxos extends StatelessWidget {
  final MoneroTransactionStateController controller;
  const _SelectUtxos(this.controller);

  @override
  Widget build(BuildContext context) {
    return SliverConstraintsBoxView(
        padding: WidgetConstant.padding20,
        sliver: MultiSliver(children: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("utxos".tr, style: context.textTheme.titleMedium),
                LargeTextView([
                  "choose_utxos_each_account".tr,
                  "monero_select_utxo_desc".tr
                ]),
                WidgetConstant.height8,
              ],
            ),
          ),
          SliverList.separated(
            itemBuilder: (context, index) {
              final utxosInfo = controller.utxos[index];
              final utxos = utxosInfo.utxos;
              return ContainerWithBorder(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("account".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                          address: utxosInfo.address,
                          color: context.primaryContainer)),
                  WidgetConstant.height20,
                  Text("utxos".tr,
                      style: context.onPrimaryTextTheme.titleMedium),
                  WidgetConstant.height8,
                  ListView.separated(
                      shrinkWrap: true,
                      physics: WidgetConstant.noScrollPhysics,
                      itemBuilder: (context, pos) {
                        final utxo = utxos[pos];
                        final bool selected = controller
                            .selectedUtxos[utxosInfo.address]!
                            .contains(utxo.output);
                        final bool canSpent = !utxo.output.needUpdate;
                        final bool inPool = utxo.output.status.inPool;
                        return ContainerWithBorder(
                            validate: canSpent,
                            backgroundColor: context.onPrimaryContainer,
                            validateText: inPool
                                ? "spent_in_pool".tr
                                : 'monero_utxo_lake_of_confirmatins_desc'.tr,
                            onRemove: canSpent
                                ? () {
                                    controller.addOrRemoveUtxo(
                                      address: utxosInfo.address,
                                      utxo: utxo.output,
                                      onError: () => context.showAlert(
                                          "transaction_input_exceeds_16_desc"
                                              .tr),
                                    );
                                  }
                                : null,
                            onRemoveIcon: APPCheckBox(
                              value: selected,
                              onChanged: (e) {},
                              backgroundColor: context.primaryContainer,
                              color: context.onPrimaryContainer,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OneLineTextWidget(utxo.output.keyImage,
                                    style: context.primaryTextTheme.bodyMedium),
                                CoinAndMarketPriceView(
                                    balance: utxo.amount,
                                    style: context.primaryTextTheme.titleMedium,
                                    symbolColor: context.primaryContainer)
                              ],
                            ));
                      },
                      separatorBuilder: (context, index) =>
                          Divider(color: context.primaryContainer),
                      itemCount: utxos.length)
                ],
              ));
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: controller.utxos.length,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical40,
                        activePress: controller.utxosIsReay,
                        onPressed: () {
                          controller.goToSend();
                        },
                        child: Text("continue".tr))
                  ],
                )
              ],
            ),
          ),
        ]));
  }
}
