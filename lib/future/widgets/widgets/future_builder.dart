import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/typdef/typedef.dart';

import 'animated/widgets/animated_switcher.dart';

class APPFutureBuilder<T> extends StatelessWidget {
  const APPFutureBuilder(
      {this.onData,
      this.onError,
      this.onProgress,
      required this.future,
      super.key});
  final WidgetDataContext<T>? onData;
  final WidgetErrContext? onError;
  final WidgetContext? onProgress;
  final Future<T> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        return APPAnimatedSwitcher(enable: snapshot.connectionState, widgets: {
          ConnectionState.waiting: (context) =>
              onProgress?.call(context) ?? const CircularProgressIndicator(),
          ConnectionState.done: (context) {
            return switch (snapshot.hasData) {
              false => onError?.call(context, snapshot.error!),
              true => onData?.call(context, snapshot.data as T)
            };
          }
        });
      },
    );
  }
}
