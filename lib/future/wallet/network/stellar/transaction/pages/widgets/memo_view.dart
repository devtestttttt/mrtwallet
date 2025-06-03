import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/networks/networks.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

typedef OnTapMemo = Function(StellarMemo);

class StellarMemosView extends StatelessWidget {
  const StellarMemosView(
      {required this.memo, super.key, required this.onTapMemo});
  final StellarMemoDetils? memo;
  final DynamicVoid? onTapMemo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("memo".tr, style: context.textTheme.titleMedium),
        Text("memo_desc2".tr),
        WidgetConstant.height8,
        AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: ContainerWithBorder(
            onRemove: onTapMemo,
            onRemoveIcon: memo == null
                ? Icon(Icons.add_box, color: context.onPrimaryContainer)
                : Icon(Icons.edit, color: context.onPrimaryContainer),
            child: _StellarMemoView(memo),
          ),
        )
      ],
    );
  }
}

class _StellarMemoView extends StatelessWidget {
  const _StellarMemoView(this.memo);
  final StellarMemoDetils? memo;
  @override
  Widget build(BuildContext context) {
    if (memo == null) {
      return Text(
        "tap_to_create_memo".tr,
        style: context.onPrimaryTextTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(memo!.memo.type.name.camelCase,
            style: context.onPrimaryTextTheme.labelLarge),
        Text(memo?.val ?? '', style: context.onPrimaryTextTheme.bodyMedium)
      ],
    );
  }
}
