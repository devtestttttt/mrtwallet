import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/transaction/controller/impl/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/transaction/pages/fee_select.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/networks/networks.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class EthereumGasFeeView extends StatelessWidget {
  const EthereumGasFeeView({super.key, required this.transaction});
  final ETHTransactionFeeImpl transaction;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: transaction.gasInited
                ? () {
                    context
                        .openSliverBottomSheet<
                                (
                                  EIP1559FeeSpeed speed,
                                  EthereumFee?
                                )>("transaction_fee".tr,
                            child: ETHEip1559GasViewSelectView(
                              transaction: transaction,
                            ))
                        .then((value) {
                      if (value == null) return;
                      transaction.setFee(value.$1, customFee: value.$2);
                    });
                  }
                : null,
            onRemoveIcon: ConditionalWidget(
              enable: transaction.gasInited,
              onActive: (context) => AddOrEditIconWidget(transaction.gasInited),
              onDeactive: (context) => APPCircularProgressIndicator(
                  color: context.onPrimaryContainer),
            ),
            child: APPAnimatedSwitcher(
              enable: transaction.gasInited,
              width: double.infinity,
              widgets: {
                true: (c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (transaction.network.coinParam.supportEIP1559)
                          Text(transaction.feeSpeed.value.tr,
                              style: context.onPrimaryTextTheme.labelLarge),
                        CoinAndMarketPriceView(
                          balance: transaction.currentEIP1559Fee!.fee,
                          style: context.onPrimaryTextTheme.titleMedium,
                          symbolColor: context.onPrimaryContainer,
                        )
                      ],
                    ),
                false: (c) => Text("retrieving_network_condition".tr,
                    style: context.onPrimaryTextTheme.bodyMedium)
              },
            )),
      ],
    );
  }
}
