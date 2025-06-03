import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/typdef/typedef.dart';
import 'package:on_chain_wallet/future/widgets/widgets/sliver/widgets/animated_switcher.dart';
import 'package:on_chain_wallet/future/widgets/widgets/widget_constant.dart';

class APPAnimatedSwitcher<T> extends StatelessWidget {
  const APPAnimatedSwitcher(
      {required this.enable,
      required this.widgets,
      this.defaultBuilder,
      this.height,
      this.width,
      this.transitionBuilder,
      this.duration = APPConst.animationDuraion,
      super.key});
  final double? height;
  final double? width;
  final T? enable;
  final Map<T?, WidgetContextNullable> widgets;
  final WidgetContextNullable? defaultBuilder;
  final Duration duration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: transitionBuilder ??
          (child, animation) {
            return FadeTransition(
                // key: ValueKey<Key?>(child.key),
                opacity: animation,
                child: child);
          },
      child: _Wrap(
          widgets[enable]?.call(context) ??
              defaultBuilder?.call(context) ??
              WidgetConstant.sizedBox,
          // key: ValueKey(enable),
          height: height,
          width: width),
    );
  }
}

class APPSliverAnimatedSwitcher<T> extends StatelessWidget {
  const APPSliverAnimatedSwitcher(
      {required this.enable,
      required this.widgets,
      this.defaultWidget,
      this.duration = APPConst.animationDuraion,
      super.key});
  final WidgetContext? defaultWidget;
  final T? enable;
  final Map<T?, WidgetContext> widgets;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedSwitcher(
      duration: duration,
      child: _WrapSliver(
          widgets[enable]?.call(context) ??
              defaultWidget?.call(context) ??
              const SliverToBoxAdapter(),
          key: ValueKey<T?>(enable)),
    );
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap(this.widget, {this.height, this.width});
  final Widget widget;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width, child: widget);
  }
}

class _WrapSliver extends StatelessWidget {
  const _WrapSliver(this.sliver, {super.key});
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return sliver;
  }
}

class APPAnimated extends StatelessWidget {
  const APPAnimated(
      {required this.isActive,
      required this.onActive,
      required this.onDeactive,
      this.duration = APPConst.animationDuraion,
      this.alignment = Alignment.topCenter,
      super.key});
  final bool isActive;
  final WidgetContextNullable onActive;
  final WidgetContextNullable onDeactive;
  final Duration duration;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: isActive ? onActive(context) : onDeactive(context),
    );
  }
}
