import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/resource_v2/forms/delegated_resource.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/tron/src/address/tron_address.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TronDelegatedResourceFieldsView extends StatelessWidget {
  const TronDelegatedResourceFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronDelegatedResourceV2Form validator;

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
          value: validator.resource.value,
          onChanged: (p0) {
            validator.setValue(validator.resource, p0);
          },
        ),
        AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: validator.resource.hasValue
              ? Column(
                  key: ValueKey(validator.resource.value),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("delegatable_amount".tr,
                        style: context.textTheme.titleMedium),
                    Text("delegatable_amount_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: CoinAndMarketPriceView(
                            balance: validator.maxResourceBalance.amoumt,
                            showTokenImage: true,
                            symbolColor: context.onPrimaryContainer,
                            style: context.onPrimaryTextTheme.titleMedium)),
                    WidgetConstant.height20,
                    ReceiptAddressView(
                      address: validator.destination.value,
                      subtitle: "resource_receiver_address".tr,
                      title: "receiver_address".tr,
                      onTap: () {
                        context
                            .selectAccount<TronAddress>(
                                account: account,
                                title: "resource_receiver_address".tr)
                            .then(
                          (value) {
                            validator.setValue(
                                validator.destination, value?.firstOrNull);
                          },
                        );
                      },
                    ),
                    WidgetConstant.height20,
                    TransactionAmountView(
                      amount: validator.amount.value,
                      subtitle: "resource_delegated_amount".tr,
                      title: "amount".tr,
                      validate: validator.amount.isCompleted,
                      onTap: () {
                        context
                            .setupAmount(
                                token: account.network.coinParam.token,
                                max:
                                    validator.maxResourceBalance.amoumt.balance)
                            .then((value) {
                          if (value == null) {
                            validator.setValue(validator.amount, null);
                          } else {
                            validator.setValue(
                                validator.amount,
                                IntegerBalance.token(
                                    value, account.network.token));
                          }
                        });
                      },
                      token: account.network.coinParam.token,
                    ),
                    WidgetConstant.height20,
                    Text("lock".tr, style: context.textTheme.titleMedium),
                    Text("tron_delegate_resource_lock_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: Switch(
                      value: validator.lock.value ?? false,
                      onChanged: (value) {
                        validator.setLockPerid(value);
                      },
                    )),
                    if (validator.lock.value ?? false)
                      AnimatedSize(
                        duration: APPConst.animationDuraion,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WidgetConstant.height20,
                            Text("lock_period".tr,
                                style: context.textTheme.titleMedium),
                            Text("tron_delegate_lock_time_desc".tr),
                            WidgetConstant.height8,
                            ContainerWithBorder(
                                onRemoveIcon: Icon(Icons.edit,
                                    color: context.onPrimaryContainer),
                                onRemove: () {
                                  context
                                      .openSliverBottomSheet<BigRational>(
                                        "delegated_resource".tr,
                                        child: NumberWriteView(
                                          defaultValue:
                                              validator.lockPeriod.value,
                                          max: TronUtils.maxDelegatedLockPeriod,
                                          allowDecimal: false,
                                          allowSign: false,
                                          title: PageTitleSubtitle(
                                              title: "lock_period".tr,
                                              body: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "tron_delegate_lock_time_desc"
                                                          .tr),
                                                ],
                                              )),
                                          buttonText: "setup_input".tr,
                                          label: "lock_period".tr,
                                        ),
                                      )
                                      .then((value) => validator.setValue(
                                          validator.lockPeriod, value));
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: RichText(
                                            text: TextSpan(
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .bodyMedium,
                                                children: [
                                          if (validator.lockPeriod.value ==
                                              null)
                                            TextSpan(
                                                text: "tap_to_input_value".tr)
                                          else ...[
                                            TextSpan(
                                                text: validator.lockPeriod.value
                                                    ?.toString()
                                                    .to3Digits),
                                            TextSpan(
                                                style: context
                                                    .onPrimaryTextTheme
                                                    .bodySmall,
                                                text:
                                                    " (${TronUtils.delegatedLockPeriodToDateTime(validator.lockPeriod.value!.toBigInt()).toDateAndTime()})")
                                          ],
                                        ]))),
                                    ToolTipView(
                                      message:
                                          "tron_delegate_lock_time_desc2".tr,
                                      waitDuration: null,
                                      child: Icon(
                                        Icons.help,
                                        color: context.onPrimaryContainer,
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        ),
                      )
                  ],
                )
              : WidgetConstant.sizedBox,
        )
      ],
    );
  }
}
