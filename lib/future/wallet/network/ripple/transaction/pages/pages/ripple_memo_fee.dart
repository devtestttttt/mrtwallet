import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/setup_transaction_fee.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/pages/pages/create_ripple_memo.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/controller/impl/transaction_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/pages/pages/memo.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleMemoAndFeeView<T extends RippleTransactionImpl>
    extends StatelessWidget {
  const RippleMemoAndFeeView({super.key, required this.controller});
  final T controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        RippleMemosView(
          memos: controller.memos,
          onTapMemo: (memo) {
            controller.onSetupMemo(
                memo,
                (memo) => context.openMaxExtendSliverBottomSheet<XRPLMemo>(
                    "create_memo".tr,
                    child: CreateRippleMemoView(memo: memo)));
          },
          onCreateMemo: () {
            controller.onSetupMemo(
                null,
                (p0) => context.openMaxExtendSliverBottomSheet<XRPLMemo>(
                    "create_memo".tr,
                    child: const CreateRippleMemoView()));
          },
        ),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: () {
              context
                  .openSliverBottomSheet<(String?, BigInt?)>(
                "transaction_fee".tr,
                child: SetupTransactionFee(
                  fees: controller.fees,
                  network: controller.network,
                  type: controller.feeType?.name,
                  max: controller.account.address.address.currencyBalance,
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
                Text(controller.feeType?.name.camelCase ?? "custom_fee".tr,
                    style: context.onPrimaryTextTheme.labelLarge),
                CoinAndMarketPriceView(
                    balance: controller.fee,
                    style: context.onPrimaryTextTheme.titleMedium,
                    symbolColor: context.onPrimaryContainer),
              ],
            )),
      ],
    );
  }
}
