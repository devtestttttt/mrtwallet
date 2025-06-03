import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/pages/pages/payment_fields.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/pages/pages/ripple_memo_fee.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/pages/pages/account_set_fields.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/pages/pages/ripple_global_transaction_fields.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

import 'signer_list_fields.dart';

class RippleTransactionFieldsView extends StatelessWidget {
  const RippleTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<RippleTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<RippleTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<RippleClient, IXRPAddress, RippleChain>(
      title: validator.validator.name.tr,
      addressRequired: true,
      clientRequired: true,
      childBulder: (wallet, account, client, address, onAccountChanged) =>
          StateBuilder<RippleTransactionStateController>(
              repositoryId: StateConst.ripple,
              controller: () => RippleTransactionStateController(
                  walletProvider: wallet,
                  account: account,
                  validator: validator,
                  apiProvider: client),
              builder: (controller) {
                return PageProgress(
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
                                onRemove: controller.form.enableSwitchAccount
                                    ? () {
                                        context
                                            .selectOrSwitchAccount<IXRPAddress>(
                                                account: controller.account,
                                                showMultiSig: true)
                                            .then(onAccountChanged);
                                      }
                                    : null,
                                child: AddressDetailsView(
                                    address: controller.address,
                                    color: context.colors.onPrimaryContainer,
                                    key: ValueKey<IXRPAddress?>(
                                        controller.address)),
                              ),
                              WidgetConstant.height20,
                              PageTitleSubtitle(
                                  title: validator.validator.name.tr,
                                  body: TextAndLinkView(
                                      text: validator
                                          .validator.validatorDescription.tr,
                                      url: validator.validator.helperUri)),
                              _RippleFormFields(controller: controller),
                              RippleMemoAndFeeView(controller: controller),
                              ErrorTextContainer(
                                  error: controller.fieldsError?.tr,
                                  verticalMargin:
                                      WidgetConstant.paddingVertical10),
                              InsufficientBalanceErrorView(
                                  verticalMargin:
                                      WidgetConstant.paddingVertical10,
                                  balance: controller.remindAmount),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ButtonProgress(
                                    key: controller.buttonKey,
                                    backToIdle: APPConst.oneSecoundDuration,
                                    child: (context) => FixedElevatedButton(
                                      padding: WidgetConstant.paddingVertical40,
                                      activePress: controller.trIsReady,
                                      onPressed: () {
                                        controller.sendTr();
                                      },
                                      child: Text("send_transaction".tr),
                                    ),
                                  ),
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

class _RippleFormFields extends StatelessWidget {
  final RippleTransactionStateController controller;
  const _RippleFormFields({
    required this.controller,
  });
  LiveTransactionForm<RippleTransactionForm> get validator =>
      controller.validator;
  ChainAccount get address => controller.address;
  RippleChain get account => controller.account;
  @override
  Widget build(BuildContext context) {
    final RippleTransactionForm fields = validator.value;
    switch (fields.transactionType) {
      case XRPLTransactionType.accountSet:
        return RippleAccountSetFieldsView(
          account: account,
          address: address,
          validator: fields as RippleAccountSetForm,
        );
      case XRPLTransactionType.payment:
        return RipplePaymentFieldsView(
          account: account,
          address: address,
          validator: fields as RipplePaymentForm,
          client: controller.apiProvider,
        );
      case XRPLTransactionType.signerListSet:
        return RippleSetSignerListFieldsView(
          account: account,
          address: address,
          validator: fields as RippleSignerListForm,
        );
      default:
        return Column(
          children: List.generate(fields.fields.length, (index) {
            final field = fields.fields[index];
            final bool isLastIndex = index == fields.fields.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fields.fields[index].name.tr,
                    style: context.textTheme.titleMedium),
                Text(fields.fields[index].subject!.tr),
                WidgetConstant.height8,
                RippleGlobalTransactionFieldsView(
                  field: field,
                  account: account,
                  address: address,
                  validator: validator.validator,
                ),
                if (!isLastIndex) WidgetConstant.height20,
              ],
            );
          }),
        );
    }
  }
}
