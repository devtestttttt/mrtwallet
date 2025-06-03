import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/transaction/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/transaction/pages/gas_fee.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class EthereumTransactionFieldsView extends StatelessWidget {
  const EthereumTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<EthereumTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<EthereumTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<EthereumClient, IEthAddress,
        EthereumChain>(
      addressRequired: true,
      clientRequired: true,
      title: validator.validator.name.tr,
      childBulder: (wallet, account, client, address, onAccountChanged) =>
          StateBuilder<EthereumTransactionStateController>(
              controller: () => EthereumTransactionStateController(
                  walletProvider: wallet,
                  account: account,
                  apiProvider: client,
                  validator: validator),
              repositoryId: StateConst.ethereum,
              builder: (controller) {
                return PageProgress(
                  key: controller.progressKey,
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
                                onRemove: controller.form.enableSwitchAccount
                                    ? () {
                                        context
                                            .selectOrSwitchAccount<IEthAddress>(
                                                account: controller.account,
                                                showMultiSig: true)
                                            .then(onAccountChanged);
                                      }
                                    : null,
                                child: AddressDetailsView(
                                    address: controller.address,
                                    color: context.onPrimaryContainer,
                                    key: ValueKey<IEthAddress?>(
                                        controller.address)),
                              ),
                              WidgetConstant.height20,
                              _ETHTransactionFileds(
                                  account: account,
                                  validator: controller.validator),
                              WidgetConstant.height20,
                              Text("setup_memo".tr,
                                  style: context.textTheme.titleMedium),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                  onRemoveIcon: AddOrEditIconWidget(
                                    controller.hasMemo,
                                  ),
                                  onRemove: () {
                                    controller.onTapMemo((s) async {
                                      final result = await context
                                          .openSliverBottomSheet<String>(
                                        "transaction_memo".tr,
                                        child: StringWriterView(
                                          defaultValue: controller.memo,
                                          title: PageTitleSubtitle(
                                              title: "setup_memo".tr,
                                              body: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                        child: controller.hasMemo
                                            ? Text(controller.memo ?? "",
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .bodyMedium)
                                            : Text("tap_to_add_memo".tr,
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .bodyMedium),
                                      ),
                                    ],
                                  )),
                              WidgetConstant.height20,
                              EthereumGasFeeView(transaction: controller),
                              WidgetConstant.height20,
                              InsufficientBalanceErrorView(
                                  verticalMargin:
                                      WidgetConstant.paddingVertical10,
                                  balance: controller.remindAmount),
                              ErrorTextContainer(
                                  error: controller.error,
                                  verticalMargin:
                                      WidgetConstant.paddingVertical10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FixedElevatedButton(
                                    padding: WidgetConstant.paddingVertical20,
                                    onPressed: controller.trIsReady
                                        ? controller.sedTransaction
                                        : null,
                                    child: Text("send_transaction".tr),
                                  )
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

class _ETHTransactionFileds extends StatelessWidget {
  const _ETHTransactionFileds({required this.validator, required this.account});
  final LiveTransactionForm<EthereumTransactionForm> validator;
  final EthereumChain account;
  @override
  Widget build(BuildContext context) {
    final field = validator.value as EthereumTransferForm;
    switch (field.mode) {
      case ETHTransactionMode.transfer:
      case ETHTransactionMode.erc20Transfer:
        return _ETHTransactionTransferFields(field: field, account: account);
      default:
        return WidgetConstant.sizedBox;
    }
  }
}

class _ETHTransactionTransferFields extends StatelessWidget {
  const _ETHTransactionTransferFields(
      {required this.field, required this.account});
  final EthereumTransferForm field;
  final EthereumChain account;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConditionalWidget(
          enable: field.erc20Token != null,
          onActive: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleMedium),
              WidgetConstant.height8,
              TokenDetailsView(
                  token: field.erc20Token!,
                  onSelectWidget: WidgetConstant.sizedBox),
              WidgetConstant.height20
            ],
          ),
        ),
        ReceiptAddressView(
          address: field.destination.value,
          subtitle: "receiver_address_desc".tr,
          onTap: () {
            context.selectAccount<ETHAddress>(account: account).then(
              (value) {
                field.setValue(field.destination, value?.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: field.amount.value,
          subtitle: "input_the_amout".tr,
          validate: field.amount.isCompleted,
          onTap: () {
            context
                .setupAmount(
                    token: field.token,
                    max: field.erc20Token?.balance.balance ??
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
