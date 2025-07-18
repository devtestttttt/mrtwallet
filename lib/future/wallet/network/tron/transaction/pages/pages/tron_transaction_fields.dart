import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/transaction/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/on_chain.dart';
import 'create_witness.dart';
import 'delegated_resource.dart';
import 'frozen_balance_v2.dart';
import 'tron_fee_details_view.dart';
import 'undelegated_resource.dart';
import 'unfreez_balance_v2.dart';
import 'update_account.dart';
import 'update_account_permission_feilds.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class TronTransactionFieldsView extends StatelessWidget {
  const TronTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<TronTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<TronTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<TronClient, ITronAddress, TronChain>(
      title: validator.validator.name.tr,
      addressRequired: true,
      clientRequired: true,
      childBulder: (wallet, account, client, address, onAccountChanged) =>
          StateBuilder<TronTransactionStateController>(
              repositoryId: StateConst.tron,
              controller: () => TronTransactionStateController(
                  walletProvider: wallet,
                  account: account,
                  apiProvider: client,
                  validator: validator),
              builder: (controller) {
                return PageProgress(
                  key: controller.progressKey,
                  initialStatus: PageProgressStatus.progress,
                  initialWidget: ProgressWithTextView(
                      text: "retrieving_network_condition".tr),
                  backToIdle: APPConst.oneSecoundDuration,
                  child: (c) => UnfocusableChild(
                    child: CustomScrollView(
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
                                  onRemove: controller.field.enableSwitchAccount
                                      ? () {
                                          context
                                              .selectOrSwitchAccount<
                                                  ITronAddress>(
                                                account: controller.account,
                                                showMultiSig: true,
                                              )
                                              .then(onAccountChanged);
                                        }
                                      : null,
                                  child: AddressDetailsView(
                                      address: controller.address,
                                      color: context.onPrimaryContainer,
                                      key: ValueKey<ITronAddress?>(
                                          controller.address)),
                                ),
                                WidgetConstant.height20,
                                _TronTransactionFields(
                                    account: account,
                                    validator: controller.validator,
                                    address: controller.address),
                                APPAnimatedSize(
                                    isActive: controller.showTxInfo,
                                    onActive: (context) {
                                      return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            WidgetConstant.height20,
                                            Text("setup_memo".tr,
                                                style: context
                                                    .textTheme.titleMedium),
                                            WidgetConstant.height8,
                                            ContainerWithBorder(
                                                onRemoveIcon:
                                                    AddOrEditIconWidget(
                                                        controller.hasMemo),
                                                onRemove: () {
                                                  controller
                                                      .onTapMemo((s) async {
                                                    final result = await context
                                                        .openSliverBottomSheet<
                                                            String>(
                                                      "transaction_memo".tr,
                                                      child: StringWriterView(
                                                        defaultValue:
                                                            controller.memo,
                                                        title:
                                                            PageTitleSubtitle(
                                                                title:
                                                                    "setup_memo"
                                                                        .tr,
                                                                body: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text("memo_desc1"
                                                                        .tr),
                                                                    WidgetConstant
                                                                        .height8,
                                                                    Text("empty_desc"
                                                                        .tr),
                                                                  ],
                                                                )),
                                                        buttonText:
                                                            "setup_memo".tr,
                                                        label: "memo".tr,
                                                      ),
                                                    );
                                                    return result;
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: controller.hasMemo
                                                          ? Text(
                                                              controller.memo ??
                                                                  "",
                                                              style: context
                                                                  .onPrimaryTextTheme
                                                                  .bodyMedium)
                                                          : Text(
                                                              "tap_to_add_memo"
                                                                  .tr,
                                                              style: context
                                                                  .onPrimaryTextTheme
                                                                  .labelLarge),
                                                    ),
                                                  ],
                                                )),
                                            WidgetConstant.height20,
                                            TronFeeDetailsView(
                                                transaction: controller),
                                            InsufficientBalanceErrorView(
                                                verticalMargin: WidgetConstant
                                                    .paddingVertical10,
                                                balance:
                                                    controller.remindAmount),
                                            ErrorTextContainer(
                                                error: controller.error,
                                                verticalMargin: WidgetConstant
                                                    .paddingVertical10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FixedElevatedButton(
                                                  padding: WidgetConstant
                                                      .paddingVertical20,
                                                  onPressed:
                                                      controller.trIsReady
                                                          ? controller
                                                              .sedTransaction
                                                          : null,
                                                  child: Text(
                                                      "send_transaction".tr),
                                                )
                                              ],
                                            )
                                          ]);
                                    },
                                    onDeactive: (context) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ErrorTextContainer(
                                                error: controller.error,
                                                verticalMargin: WidgetConstant
                                                    .paddingVertical10),
                                          ],
                                        )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}

class _TronTransactionFields extends StatelessWidget {
  const _TronTransactionFields(
      {required this.validator, required this.account, required this.address});
  final LiveTransactionForm<TronTransactionForm> validator;
  final TronChain account;
  final ITronAddress address;
  @override
  Widget build(BuildContext context) {
    final field = validator.value;
    switch (field.type) {
      case TransactionContractType.accountPermissionUpdateContract:
        return TronAccountUpdatePermissionFieldsView(
            account: account, address: address, validator: field.cast());
      case TransactionContractType.transferContract:
      case TransactionContractType.transferAssetContract:
      case TransactionContractType.triggerSmartContract:
        return _TronTransactionTransferFields(
            field: field.cast(), account: account);
      case TransactionContractType.freezeBalanceV2Contract:
        return TronFreezBalanceV2FieldsView(
            account: account, address: address, validator: field.cast());
      case TransactionContractType.unfreezeBalanceV2Contract:
        return TronUnFreezBalanceV2FieldsView(
            account: account, address: address, validator: field.cast());
      case TransactionContractType.delegateResourceContract:
        return TronDelegatedResourceFieldsView(
            account: account, address: address, validator: field.cast());
      case TransactionContractType.unDelegateResourceContract:
        return TronUnDelegatedResourceFieldsView(
            account: account, address: address, validator: field.cast());
      case TransactionContractType.witnessCreateContract:
      case TransactionContractType.witnessUpdateContract:
        return TronCreateWitnessFieldsView(
            account: account, address: address, validator: field.cast());
      case TransactionContractType.accountUpdateContract:
        return TronUpdateAccountFieldsView(
            account: account, address: address, validator: field.cast());
      default:
        return WidgetConstant.sizedBox;
    }
  }
}

class _TronTransactionTransferFields extends StatelessWidget {
  const _TronTransactionTransferFields(
      {required this.field, required this.account});
  final TronTransferForm field;
  final TronChain account;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConditionalWidget(
            enable: field.transferToken != null,
            onActive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("token_transfer".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    TokenDetailsView(
                        token: field.transferToken!,
                        onSelectWidget: WidgetConstant.sizedBox),
                    WidgetConstant.height20
                  ],
                )),
        ReceiptAddressView(
          address: field.destination.value,
          subtitle: "receiver_address_desc".tr,
          onTap: () {
            context
                .selectAccount<TronAddress>(
                    account: account, onFilterAccount: field.filterAddress)
                .then(
              (value) {
                field.setValue(field.destination, value?.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height8,
        TransactionAmountView(
          amount: field.amount.value,
          subtitle: "input_the_amout".tr,
          validate: field.amount.isCompleted,
          onTap: () {
            context
                .setupAmount(
                    token: field.token,
                    max: field.transferToken?.balance.balance ??
                        account.address.address.currencyBalance)
                .then((value) {
              if (value == null) {
                field.setValue(field.amount, null);
              } else {
                field.setValue(
                    field.amount, IntegerBalance.token(value, field.token));
              }
            });
          },
          token: field.token,
        ),
      ],
    );
  }
}
