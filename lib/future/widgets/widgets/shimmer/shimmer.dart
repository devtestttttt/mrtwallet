import 'package:flutter/widgets.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/widgets/animated/animation.dart';
import 'package:on_chain_wallet/future/widgets/widgets/container_with_border.dart';
import 'package:on_chain_wallet/future/widgets/widgets/widget_constant.dart';

typedef SHIMMERBUILDER = Widget Function(bool enable, BuildContext context);

class ShimmerActionView extends StatelessWidget {
  final bool sliver;
  final SHIMMERBUILDER onActive;
  final ShimmerAction action;
  const ShimmerActionView({
    required this.action,
    required this.onActive,
    this.sliver = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(onActive: onActive, enable: !action.action, sliver: sliver);
  }
}

class Shimmer extends StatelessWidget {
  final bool sliver;
  final bool enable;
  final SHIMMERBUILDER onActive;
  const Shimmer(
      {required this.onActive,
      this.sliver = false,
      required this.enable,
      super.key});
  // final Widget shimmerBox;
  @override
  Widget build(BuildContext context) {
    if (sliver) {
      return APPSliverAnimatedSwitcher<bool>(enable: enable, widgets: {
        false: (context) => SliverIgnorePointer(
            sliver: SliverToBoxAdapter(
                child: ShimmerWidget(child: onActive(enable, context)))),
        true: (context) => onActive(enable, context)
      });
    }
    return APPAnimated(
        isActive: enable,
        onDeactive: (context) => IgnorePointer(
            child: ShimmerWidget(child: onActive(enable, context))),
        onActive: (context) => onActive(enable, context));
  }
}

class ShimmerWidget extends StatefulWidget {
  final Widget child;

  const ShimmerWidget({super.key, this.child = const ShimmerBox()});

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SafeState<ShimmerWidget>, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  context.colors.inverseSurface.wOpacity(0.1),
                  context.colors.inverseSurface.wOpacity(0.3),
                  context.colors.inverseSurface.wOpacity(0.5),
                  context.colors.inverseSurface.wOpacity(0.7),
                  context.colors.inverseSurface.wOpacity(0.9),
                ],
                stops: [0.1, 0.3, 0.6, 0.8, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: _GradientTransform(_animation.value),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: child);
      },
      child: widget.child,
    );
  }
}

class _GradientTransform extends GradientTransform {
  final double slideValue;
  const _GradientTransform(this.slideValue);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slideValue, 0.0, 0.0);
  }
}

class ShimmerBox extends StatelessWidget {
  final BoxConstraints? constraints;
  const ShimmerBox(
      {super.key, this.constraints = WidgetConstant.constraintsMinHeight60});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      constraints: constraints,
      child: Row(children: []),
    );
  }
}

class ShimmerAction<T> {
  final T object;
  bool _action = false;
  bool get action => _action;
  ShimmerAction({required this.object});
  void toggleAction() {
    _action = !action;
  }
}
