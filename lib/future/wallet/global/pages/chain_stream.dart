import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

typedef CHAINSTREAMBUILER<T extends Chain> = Widget Function(
    BuildContext context, T chain, ChainNotify? lastNotify);

class ChainStreamBuilder<T extends Chain> extends StatefulWidget {
  final T account;
  final List<ChainNotify>? allowNotify;
  final CHAINSTREAMBUILER builder;
  const ChainStreamBuilder(
      {required this.builder,
      required this.account,
      this.allowNotify,
      super.key});

  @override
  State<ChainStreamBuilder> createState() => _ChainStreamBuilderState<T>();
}

class _ChainStreamBuilderState<T extends Chain>
    extends State<ChainStreamBuilder<T>> with SafeState<ChainStreamBuilder<T>> {
  ChainNotify? lastProgressNotify;
  late T account = widget.account;
  StreamSubscription<ChainEvent>? _subscription;
  void onChainNotify(ChainEvent notify) {
    if (widget.allowNotify?.contains(notify.type) ?? true) {
      if (notify.status == ChainNotifyStatus.progress) {
        lastProgressNotify = notify.type;
      } else {
        lastProgressNotify = null;
      }
      updateState();
    }
  }

  void diposeStream() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    _subscription = account.stream.listen(onChainNotify);
  }

  @override
  void safeDispose() {
    super.safeDispose();
    diposeStream();
  }

  @override
  void didUpdateWidget(covariant ChainStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (account != widget.account) {
      account = widget.account;
      diposeStream();
      _subscription = account.stream.listen(onChainNotify);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, account, lastProgressNotify);
  }
}
