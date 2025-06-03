import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/transaction/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';

class StellarTransactionFeeView extends StatelessWidget {
  const StellarTransactionFeeView(this.controller, {super.key});
  final StellarTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        iconAlginment: controller.feeMode.isCustom
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        onRemove: () {
          context
              .openSliverBottomSheet<(String?, BigInt?)>(
            "transaction_fee".tr,
            child: SetupTransactionFee(
              fees: controller.fees,
              network: controller.network,
              type: controller.feeMode.name,
              max: controller.maximumFee,
              customFee: controller.fee?.balance,
            ),
          )
              .then((value) {
            controller.setFee(value?.$1, customFee: value?.$2);
          });
        },
        onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
        child: APPAnimatedSwitcher(
            width: context.mediaQuery.size.width,
            enable: controller.hasFee,
            widgets: {
              false: (c) => Text("estimating_fee_please_wait".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
              true: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.feeMode.name.camelCase,
                          style: context.onPrimaryTextTheme.labelLarge),
                      CoinAndMarketPriceView(
                        balance: controller.fee!,
                        style: context.onPrimaryTextTheme.titleMedium,
                        symbolColor: context.onPrimaryContainer,
                        showTokenImage: true,
                      ),
                      ErrorTextContainer(
                        verticalMargin: WidgetConstant.paddingVertical10,
                        error: controller.feeError,
                      ),
                    ],
                  ),
            }));
  }
}
