import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class SetupTransactionFee extends StatefulWidget {
  const SetupTransactionFee(
      {super.key,
      required this.type,
      required this.network,
      required this.fees,
      this.customFee,
      this.max});
  final WalletNetwork network;
  final String? type;
  final BigInt? max;
  final BigInt? customFee;
  final Map<String, IntegerBalance> fees;
  @override
  State<SetupTransactionFee> createState() => _SetupTransactionFeeState();
}

class _SetupTransactionFeeState extends State<SetupTransactionFee>
    with SafeState {
  late String? type = widget.type;
  late final IntegerBalance feeRate = IntegerBalance.token(
      type != null ? BigInt.zero : widget.customFee ?? BigInt.zero,
      widget.network.token);

  void onChange(String? newType, {BigInt? customPrice}) {
    if (newType == null && customPrice == null) return;
    if (newType != null && customPrice != null) return;
    type = newType;
    feeRate.updateBalance(customPrice ?? BigInt.zero);
    updateState();
    onSetup();
  }

  void onSetup() {
    if (mounted) {
      context.pop((type, feeRate.balance));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "setup_transaction_fee".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("transacation_fee_desc".tr),
                WidgetConstant.height8,
                Text("transaction_fee_desc2".tr),
                WidgetConstant.height8,
                Text("transaction_fee_desc3".tr)
              ],
            )),
        ListView.separated(
            shrinkWrap: true,
            physics: WidgetConstant.noScrollPhysics,
            itemBuilder: (context, index) {
              final keys = widget.fees.keys.toList();
              return AppRadioListTile<String>(
                value: keys[index],
                title: Text(keys[index].camelCase),
                subtitle: CoinAndMarketPriceView(
                  balance: widget.fees[keys[index]]!,
                  disableTooltip: true,
                ),
                groupValue: type,
                onChanged: (value) {
                  onChange(value);
                },
              );
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: widget.fees.length),
        WidgetConstant.divider,
        Column(children: [
          AppListTile(
            onTap: () {
              context
                  .setupAmount(
                      token: widget.network.coinParam.token,
                      max: widget.max,
                      title: "transaction_fee".tr)
                  .then((value) {
                onChange(null, customPrice: value);
              });
            },
            title: Text("custom_fee".tr),
            leading: Radio(value: null, groupValue: type, onChanged: (_) {}),
            subtitle: type == null
                ? CoinAndMarketPriceView(
                    disableTooltip: true,
                    balance: feeRate,
                    style: context.textTheme.titleMedium)
                : null,
          ),
        ]),
        WidgetConstant.height40
      ],
    );
  }
}
