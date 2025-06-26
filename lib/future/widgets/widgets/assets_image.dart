import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/image/memory_image.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart'
    show APPToken;

class CircleAssetsImageView extends StatelessWidget {
  const CircleAssetsImageView(this.assetPath,
      {this.radius = 120,
      this.backgroundColor = Colors.transparent,
      this.foregroundColor,
      super.key});
  final APPImage assetPath;
  final double radius;
  final Color backgroundColor;
  final Color? foregroundColor;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: CacheMemoryImageProvider(assetPath),
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onBackgroundImageError: (e, d) {},
    );
  }
}

class CircleAPPImageView extends StatelessWidget {
  const CircleAPPImageView(this.image,
      {this.onProgress,
      this.onError,
      this.radius = 120,
      super.key,
      this.onNull = "U",
      this.imageColor});
  final APPImageInfo? image;
  final double radius;
  final String? onNull;
  final FuncWidgetContext? onProgress;
  final FuncWidgetContext? onError;
  final Color? imageColor;

  @override
  Widget build(BuildContext context) {
    final name = onNull ?? "U";

    if (image == null) {
      return _CircleAPPImageView(
          radius: radius, onNull: name, child: onError?.call(context));
    }
    return ClipOval(
      child: Image(
          color: imageColor,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress != null && onProgress != null) {
              return onProgress!.call(context);
            }
            if (loadingProgress == null) {
              return _CircleAPPImageView(
                  radius: radius, onNull: name, child: child);
            }
            return _CircleAPPImageView(
                radius: radius, onNull: name, child: null);
          },
          image: CacheMemoryImageProvider(image!),
          errorBuilder: (context, error, stackTrace) {
            return _CircleAPPImageView(
                radius: radius, onNull: name, child: onError?.call(context));
          }),
    );
  }
}

class _CircleAPPImageView extends StatelessWidget {
  const _CircleAPPImageView(
      {this.child, required this.radius, required this.onNull});
  final double radius;
  final String onNull;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
            color: child != null
                ? context.colors.transparent
                : context.colors.primaryContainer,
            shape: BoxShape.circle),
        width: size,
        height: size,
        child: Center(
          child: child ??
              Text(
                onNull,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: radius,
                ),
              ),
        ),
      ),
    );
  }
}

class CircleTokenImageView extends StatelessWidget {
  const CircleTokenImageView(this.token, {this.radius = 120, super.key});
  final APPToken token;
  final double radius;

  @override
  Widget build(BuildContext context) {
    String symbol = (token.symbol.nullOnEmpty?[0] ?? 'U').toUpperCase();
    return CircleAPPImageView(token.assetLogo, onNull: symbol, radius: radius);
  }
}
