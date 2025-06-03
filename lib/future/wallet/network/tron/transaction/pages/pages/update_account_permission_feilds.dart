import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/account/forms/update_account_permission.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TronAccountUpdatePermissionFieldsView extends StatelessWidget {
  const TronAccountUpdatePermissionFieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final ChainAccount address;
  final TronChain account;
  final TronAccountUpdatePermissionForm validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("permissions".tr, style: context.textTheme.titleMedium),
        Text("tron_permission_desc".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          value: validator.permissionId,
          key: ValueKey(validator.permissionId),
          items: {
            for (final i in validator.permissions)
              i.id ?? 0: RichText(
                  text: TextSpan(
                      style: context.textTheme.bodyMedium,
                      text: i.type.name.camelCase,
                      children: [
                    if (i.permissionName != null)
                      TextSpan(
                          text: " (${i.permissionName}) ",
                          style: context.textTheme.bodySmall)
                  ])),
            -1: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.add),
                WidgetConstant.width8,
                Text("new_active_permission".tr,
                    style: context.textTheme.bodySmall)
              ],
            )
          },
          // label: "permissions".tr,
          onChanged: (p0) {
            validator.setPermission(
              p0,
              () {
                context.showAlert("tron_permission_validator1".tr);
              },
            );
          },
          hint: "permissions".tr,
        ),
        APPAnimatedSize(
          duration: APPConst.animationDuraion,
          isActive: validator.selectedPermission != null,
          onActive: (context) => _EditPermissionView(
            permission: validator.selectedPermission!,
            validator: validator,
            key: ValueKey(validator.selectedPermission),
            account: account,
          ),
          onDeactive: (context) => WidgetConstant.sizedBox,
        )
      ],
    );
  }
}

class _EditPermissionView extends StatelessWidget {
  const _EditPermissionView(
      {super.key,
      required this.permission,
      required this.validator,
      required this.account});
  final AccountPermission permission;
  final TronAccountUpdatePermissionForm validator;
  final TronChain account;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("permission_type".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Text(permission.type.name.camelCase,
                style: context.onPrimaryTextTheme.bodyMedium)),
        WidgetConstant.height20,
        Text("permission_name".tr, style: context.textTheme.titleMedium),
        Text("input_the_permission_name".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: const Icon(Icons.edit),
          onRemove: () {
            context
                .openSliverBottomSheet<String>(
                  "update_account_permission".tr,
                  child: StringWriterView(
                    defaultValue: permission.permissionName,
                    title: PageTitleSubtitle(
                        title: "permission_name".tr,
                        body: Text("input_the_permission_name".tr)),
                    buttonText: "setup_input".tr,
                    label: "permission_name".tr,
                  ),
                )
                .then(validator.updatePermissionName);
          },
          child: Text(
            permission.permissionName ?? "tap_to_input_value".tr,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
        ),
        WidgetConstant.height20,
        Text("threshold".tr, style: context.textTheme.titleMedium),
        Text("tron_threshhold_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: NumberTextField(
                label: "threshold".tr,
                onChange: validator.onUpdateTheresHold,
                defaultValue: validator.selectedPermission!.threshold.toInt(),
                max: TronUtils.maxPermissionThreshhold,
                min: 1)),
        if (!permission.isWitnessPermission) ...[
          WidgetConstant.height20,
          Text("operations".tr, style: context.textTheme.titleMedium),
          Text("tron_operations_desc".tr),
          WidgetConstant.height8,
          if (permission.isActivePermission) ...[
            AppSwitchListTile(
              value: validator.allOperationSelected,
              onChanged: (p0) {
                validator.clearOrSelectAll();
              },
              title: Text("choose_all".tr),
            ),
          ],
          ContainerWithBorder(
            child: ConditionalWidgets(
                enable: validator.operations != null,
                widgets: {
                  false: (context) => Text(
                        "all_operations".tr,
                        style: context.onPrimaryTextTheme.bodyMedium,
                      ),
                  true: (context) => Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 2.5,
                        spacing: 2.5,
                        children: List.generate(
                            TransactionContractType.values.length,
                            (index) => Chip(
                                deleteIcon: IgnorePointer(
                                  child: Checkbox(
                                    value: validator.operations!.contains(
                                        TransactionContractType.values[index]),
                                    onChanged: (value) {},
                                  ),
                                ),
                                onDeleted: () {
                                  validator.addOrRemoveOperation(
                                    TransactionContractType.values[index],
                                    () {
                                      context
                                          .showAlert("operation_disabled".tr);
                                    },
                                  );
                                },
                                label: SizedBox(
                                  width: 80,
                                  child: ToolTipView(
                                    waitDuration: APPConst.animationDuraion,
                                    message: TransactionContractType
                                        .values[index].name,
                                    child: OneLineTextWidget(
                                        TransactionContractType
                                            .values[index].name,
                                        style: context
                                            .onPrimaryTextTheme.bodySmall),
                                  ),
                                ))),
                      )
                }),
          ),
        ],
        WidgetConstant.height20,
        Text("tron_permission_key".tr, style: context.textTheme.titleMedium),
        Text("tron_permission_key_desc".tr),
        WidgetConstant.height8,
        ...List.generate(validator.selectedPermission!.keys.length, (index) {
          return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              enableTap: false,
              onRemove: () {
                validator
                    .removeSigner(validator.selectedPermission!.keys[index]);
              },
              onRemoveIcon:
                  Icon(Icons.remove_circle, color: context.onPrimaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OneLineTextWidget(
                      validator.selectedPermission!.keys[index].address
                          .toAddress(),
                      style: context.onPrimaryTextTheme.bodyMedium),
                  Divider(color: context.onPrimaryContainer),
                  NumberTextField(
                      label: "weight".tr,
                      onChange: (p0) {
                        validator.updateKeyThereshHold(
                            validator.selectedPermission!.keys[index], p0);
                      },
                      max: TronUtils.maxPermissionThreshhold,
                      defaultValue: validator
                          .selectedPermission!.keys[index].weight
                          .toInt(),
                      min: 1),
                ],
              ));
        }),
        if (validator.selectedPermission!.keys.length < 5)
          ContainerWithBorder(
            onRemoveIcon:
                Icon(Icons.add_box, color: context.onPrimaryContainer),
            child: Text("tap_to_input_new_signer".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
            onRemove: () {
              context
                  .selectAccount<TronAddress>(
                      account: account, title: "signer".tr)
                  .then(
                (value) {
                  validator.addNewSigner(value?.firstOrNull, () {
                    context.showAlert("signer_already_exist".tr);
                  });
                },
              );
            },
          ),
        ErrorTextContainer(
            error: validator.permissionError?.tr,
            verticalMargin: WidgetConstant.paddingVertical20),
        Padding(
          padding: WidgetConstant.paddingVertical20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton.icon(
                onPressed: validator.savePermission,
                label: Text("Update permission".tr),
                icon: const Icon(Icons.save),
              ),
              if (permission.isActivePermission) ...[
                WidgetConstant.width8,
                FixedElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: Text("remove_permission".tr),
                  onPressed: validator.removePermission,
                )
              ]
            ],
          ),
        )
      ],
    );
  }
}
