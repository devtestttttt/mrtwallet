import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart' show APPConst;
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/widgets/animated/animation.dart';

import 'conditional_widget.dart';
import 'widget_constant.dart';

typedef OnItemBuilder = Widget Function();

class EmptyItemSliverWidgetView extends StatelessWidget {
  const EmptyItemSliverWidgetView(
      {required this.isEmpty,
      required this.itemBuilder,
      this.onEmpty,
      super.key,
      this.icon,
      this.subject});
  final bool isEmpty;
  final IconData? icon;
  final String? subject;
  final WidgetContext itemBuilder;
  final WidgetContext? onEmpty;
  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
        onActive: (context) => SliverFillRemaining(
            child: onEmpty?.call(context) ?? NoItemFoundWidget(icon: icon)),
        onDeactive: itemBuilder,
        enable: isEmpty);
  }
}

class EmptyItemWidgetView extends StatelessWidget {
  const EmptyItemWidgetView({
    required this.isEmpty,
    required this.itemBuilder,
    super.key,
    this.icon,
    this.subject,
  });
  final bool isEmpty;
  final IconData? icon;
  final String? subject;
  final OnItemBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher(
        height: context.mediaQuery.size.height,
        enable: isEmpty,
        widgets: {
          true: (c) => Row(
                children: [
                  Expanded(
                    child: NoItemFoundWidget(),
                  ),
                ],
              ),
          false: (c) => itemBuilder()
        });
  }
}

class NoItemFoundWidget extends StatelessWidget {
  const NoItemFoundWidget({this.icon, super.key});
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? Icons.hourglass_empty, size: APPConst.double80),
        WidgetConstant.height8,
        Text("no_items_found".tr),
      ],
    );
  }
}
