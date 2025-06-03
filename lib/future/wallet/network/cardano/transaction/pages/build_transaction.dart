import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/cardano/transaction/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/cardano/transaction/controller/impl/transaction.dart';
import 'package:on_chain_wallet/future/wallet/network/cardano/transaction/pages/utxo_view.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'send_transaction.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class SendCardanoTransactionView extends StatelessWidget {
  const SendCardanoTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<CardanoClient, ICardanoAddress,
            ADAChain>(
        addressRequired: true,
        clientRequired: true,
        childBulder: (wallet, account, client, address, onAccountChanged) {
          return StateBuilder<CardanoTransactionStateController>(
            controller: () => CardanoTransactionStateController(
                walletProvider: wallet, account: account, apiProvider: client),
            repositoryId: StateConst.cardano,
            builder: (controller) {
              return PageProgress(
                key: controller.progressKey,
                initialStatus: StreamWidgetStatus.progress,
                backToIdle: APPConst.oneSecoundDuration,
                child: (c) => Scaffold(
                  floatingActionButton:
                      APPAnimatedSwitcher(enable: controller.page, widgets: {
                    CardanoTransactionPages.send: (context) => null,
                    CardanoTransactionPages.account: (context) =>
                        APPAnimatedSize(
                            isActive: controller.hasSpender,
                            onActive: (context) =>
                                FloatingActionButton.extended(
                                    onPressed: controller.hasSpender
                                        ? controller.fetchUtxos
                                        : null,
                                    label: Text("get_unspent_transaction".tr)),
                            onDeactive: (context) => WidgetConstant.sizedBox),
                    CardanoTransactionPages.utxo: (context) => APPAnimatedSize(
                          isActive: controller.canBuildTransaction,
                          onActive: (context) => FloatingActionButton.extended(
                              onPressed: controller.canBuildTransaction
                                  ? controller.onSetupUtxo
                                  : null,
                              label: Text("setup_recipients".tr)),
                          onDeactive: (context) => WidgetConstant.sizedBox,
                        ),
                  }),
                  body: CustomScrollView(
                    slivers: [
                      SliverConstraintsBoxView(
                        padding: WidgetConstant.paddingHorizontal20,
                        sliver: APPSliverAnimatedSwitcher(
                            enable: controller.page,
                            widgets: {
                              CardanoTransactionPages.send: (context) =>
                                  CardanoBuildTransactionView(
                                      controller: controller),
                              CardanoTransactionPages.utxo: (context) =>
                                  CardanoTransactionUtxoView(
                                      controller: controller),
                              CardanoTransactionPages.account: (context) =>
                                  _SelectAccountUtxo(controller: controller),
                            }),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        title: "build_transacation".tr);
  }
}

class _SelectAccountUtxo extends StatefulWidget {
  const _SelectAccountUtxo({required this.controller});
  final CardanoTransactionImpl controller;

  @override
  State<_SelectAccountUtxo> createState() => _SelectAccountUtxoState();
}

class _SelectAccountUtxoState extends State<_SelectAccountUtxo> with SafeState {
  late final List<ICardanoAddress> addresses = widget.controller.addresses
      .where((e) => !e.isRewardAddress)
      .toList()
    ..sort((a, b) => a == widget.controller.address ? 0 : 1);
  late final ICardanoAddress currentAccount = addresses.first;

  bool showAll = false;

  void toggleShowAll() {
    showAll = !showAll;
    setState(() {});
    if (!showAll) {
      bool alert = false;
      for (final i in addresses) {
        if (i == currentAccount || i.networkAddress.isRewardAddress) continue;
        if (widget.controller.addressSelected(i)) {
          widget.controller.addSpender(
            i,
            (p0) {
              context.showAlert(p0.tr);
            },
          );
          alert = true;
        }
      }
      if (alert) {
        context.showAlert("accounts_removed_from_spending_list".tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleSubtitle(
                title: "create_and_send_network_transaction"
                    .tr
                    .replaceOne(widget.controller.network.coinParam.token.name),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("spend_multiple_account_desc".tr),
                    WidgetConstant.height20,
                  ],
                )),
            Text("accounts".tr, style: context.textTheme.titleMedium),
            Text("please_selected_acc_spend"
                .tr
                .replaceOne(widget.controller.network.coinParam.token.name)),
            WidgetConstant.height8,
            AppSwitchListTile(
              value: showAll,
              title: Text("display_all_account".tr),
              subtitle: Text("spending_from_multiple_account".tr),
              onChanged: (p0) => toggleShowAll(),
            ),
            WidgetConstant.height8,
            ContainerWithBorder(
                backgroundColor: context.colors.secondary,
                validateText: "lacks_an_utxos".tr,
                onRemoveIcon: APPCheckBox(
                    backgroundColor: context.colors.onSecondary,
                    color: context.colors.secondary,
                    value: widget.controller.addressSelected(currentAccount),
                    onChanged: (v) {
                      widget.controller.addressSelected(currentAccount);
                    }),
                onRemove: () {
                  widget.controller.addSpender(
                    currentAccount,
                    (p0) {
                      context.showAlert(p0.tr);
                    },
                  );
                },
                child: AddressDetailsView(
                  address: currentAccount,
                  color: context.colors.onSecondary,
                )),
          ],
        ),
      ),
      APPSliverAnimatedSwitcher(enable: showAll, widgets: {
        true: (context) => SliverList.separated(
              itemBuilder: (context, index) {
                final bool isSelected = currentAccount == addresses[index];
                if (isSelected) return WidgetConstant.sizedBox;
                final balance = addresses[index].address.currencyBalance;
                final bool canSpend = balance > BigInt.zero;

                return ContainerWithBorder(
                    validate: canSpend,
                    validateText: "lacks_an_utxos".tr,
                    onRemoveIcon: Checkbox(
                      value:
                          widget.controller.addressSelected(addresses[index]),
                      onChanged: (value) {
                        widget.controller.addSpender(
                          addresses[index],
                          (p0) {
                            context.showAlert(p0.tr);
                          },
                        );
                      },
                    ),
                    onRemove: () {
                      widget.controller.addSpender(
                        addresses[index],
                        (p0) {
                          context.showAlert(p0.tr);
                        },
                      );
                    },
                    child: AddressDetailsView(
                        address: addresses[index],
                        color: context.onPrimaryContainer));
              },
              itemCount: addresses.length,
              separatorBuilder: (context, index) => WidgetConstant.divider,
            ),
      }),
      WidgetConstant.sliverPaddingVertial20,
    ]);
  }
}
