import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/extension/app_extensions/context.dart'
    show QuickContextAccsess;
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class ContainerWithBorder extends StatelessWidget {
  const ContainerWithBorder(
      {super.key,
      this.child,
      this.padding = WidgetConstant.padding10,
      this.margin = WidgetConstant.padding5,
      this.onRemove,
      this.borderRadius,
      this.backgroundColor,
      this.onRemoveWidget,
      this.onRemoveIcon,
      this.validate = true,
      this.validateText,
      this.shadow = false,
      this.enableTap = true,
      this.iconAlginment = CrossAxisAlignment.center,
      this.onTapError,
      this.constraints = WidgetConstant.constraintsMinHeight60,
      this.errorIcon,
      this.hoverColor,
      this.focusColor});
  final Widget? child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final DynamicVoid? onRemove;
  final Widget? onRemoveWidget;
  final Widget? onRemoveIcon;
  final bool validate;
  final String? validateText;
  final bool shadow;
  final bool enableTap;
  final CrossAxisAlignment iconAlginment;
  final DynamicVoid? onTapError;
  final BoxConstraints? constraints;
  final IconData? errorIcon;
  final Color? focusColor;
  final Color? hoverColor;
  @override
  Widget build(BuildContext context) {
    final tap = enableTap && onRemove != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: borderRadius ?? WidgetConstant.border8,
          onTap: tap ? onRemove : null,
          mouseCursor: tap ? SystemMouseCursors.click : null,
          hoverColor: hoverColor,
          focusColor: focusColor,
          child: Container(
            padding: padding,
            margin: margin,
            constraints: constraints,
            decoration: BoxDecoration(
                color: backgroundColor ?? context.colors.primaryContainer,
                borderRadius: borderRadius ?? WidgetConstant.border8,
                boxShadow: !shadow
                    ? null
                    : [
                        BoxShadow(
                            color: context.colors.shadow,
                            blurRadius: 4,
                            spreadRadius: 0.2)
                      ],
                border: validate
                    ? null
                    : Border.all(
                        color: context.colors.error, width: 2, strokeAlign: 2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConditionalWidget(
                  enable: child != null,
                  onActive: (context) => Row(
                    crossAxisAlignment: iconAlginment,
                    children: [
                      Expanded(child: child!),
                      if (onRemove != null)
                        Row(
                          children: [
                            WidgetConstant.width8,
                            onRemoveWidget ??
                                IconButton(
                                    onPressed: onRemove,
                                    icon: onRemoveIcon ??
                                        Icon(Icons.remove_circle))
                          ],
                        )
                    ],
                  ),
                ),
                APPAnimatedSize(
                    isActive: !validate && validateText != null,
                    onActive: (context) => ErrorTextContainer(
                          error: validateText ?? "",
                          margin: WidgetConstant.padding5,
                          // padding: WidgetConstant.padding10,
                          oTapError: onTapError,
                          errorIcon: errorIcon,
                          showErrorIcon: onTapError != null,
                        ),
                    onDeactive: (context) => WidgetConstant.sizedBox)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AddOrEditIconWidget extends StatelessWidget {
  const AddOrEditIconWidget(this.edit, {this.color, super.key});
  final bool edit;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return switch (edit) {
      true => Icon(Icons.edit, color: color ?? context.onPrimaryContainer),
      _ => Icon(Icons.add_box, color: color ?? context.onPrimaryContainer)
    };
  }
}

class EditOrRemoveIconWidget extends StatelessWidget {
  const EditOrRemoveIconWidget(this.remove, {this.color, super.key});
  final bool remove;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return switch (remove) {
      true =>
        Icon(Icons.remove_circle, color: color ?? context.onPrimaryContainer),
      _ => Icon(Icons.edit, color: color ?? context.onPrimaryContainer)
    };
  }
}
