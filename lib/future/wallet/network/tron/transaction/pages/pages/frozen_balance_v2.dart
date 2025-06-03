import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/resource_v2/forms/freez_balance_v2.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/utils/tron/tron.dart';

class TronFreezBalanceV2FieldsView extends StatelessWidget {
  const TronFreezBalanceV2FieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronFreezBalanceV2Form validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("resource".tr, style: context.textTheme.titleMedium),
        Text("trx_stake_type".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: {
            for (final i in TronUtils.tronFrozenReosurce)
              i: Text(i.name.toLowerCase().camelCase)
          },
          hint: "resource".tr,
          onChanged: (p0) {
            validator.setValue(validator.resource, p0);
          },
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: validator.amount.value,
          subtitle: "trx_stake_amount".tr,
          title: "frozen_balance".tr,
          validate: validator.amount.isCompleted,
          onTap: () {
            context
                .setupAmount(
                    token: account.network.coinParam.token,
                    max: account.address.address.currencyBalance)
                .then((value) {
              if (value == null) {
                validator.setValue(validator.amount, null);
              } else {
                validator.setValue(validator.amount,
                    IntegerBalance.token(value, account.network.token));
              }
            });
          },
          token: account.network.coinParam.token,
        ),
      ],
    );
  }
}
