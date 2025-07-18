import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/network.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

enum AccountPageAppbarStatus {
  provider(true),
  action(true),
  none(false);

  final bool hasAction;
  const AccountPageAppbarStatus(this.hasAction);
  double get appbarHeight => hasAction ? kToolbarHeight : 0;
}

class NetworkClientConnectionSliverHeaderDelegate extends StatelessWidget {
  final WalletProvider wallet;
  final Chain chain;
  const NetworkClientConnectionSliverHeaderDelegate(
      {required this.wallet, required this.chain, super.key});

  static AccountPageAppbarStatus detectStatus(Chain chain) {
    final serviceConnect = chain.serviceStatus.isConnect;
    if (serviceConnect) {
      if (chain.config.hasAction) {
        return AccountPageAppbarStatus.action;
      }
      return AccountPageAppbarStatus.none;
    }
    return AccountPageAppbarStatus.provider;
  }

  @override
  Widget build(BuildContext context) {
    final appbarStatus = detectStatus(chain);
    return APPSliverAnimatedSwitcher(
      enable: appbarStatus.hasAction,
      widgets: {
        true: (context) => SliverAppBar(
              pinned: true,
              centerTitle: false,
              actions: [],
              toolbarHeight: appbarStatus.appbarHeight,
              automaticallyImplyLeading: false,
              flexibleSpace: Material(
                elevation: 25,
                color: context.colors.transparent,
                type: MaterialType.button,
                child: ConditionalWidgets<AccountPageAppbarStatus>(
                    enable: appbarStatus,
                    widgets: {
                      AccountPageAppbarStatus.provider: (context) =>
                          _AppbarProviderStatus(
                            wallet: wallet,
                            chain: chain,
                          ),
                      AccountPageAppbarStatus.action: (context) =>
                          _AppbarPageAction(chain: chain)
                    }),
              ),
            ),
      },
    );
  }
}

class _AppbarProviderStatus extends StatelessWidget {
  const _AppbarProviderStatus({required this.wallet, required this.chain});
  final Chain chain;
  final WalletProvider wallet;
  WalletNetwork get network => chain.network;
  void onSwitchNetwork(BuildContext context) {
    context.openSliverDialog<ProviderIdentifier>(
        (ctx) => SelectProviderView(), "service_provider".tr);
  }

  NodeClientStatus? get status => chain.serviceStatus;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: WidgetConstant.padding5,
      color: (status?.isPending ?? false)
          ? context.colors.tertiaryContainer
          : context.colors.errorContainer,
      child: APPAnimatedSwitcher(enable: status, widgets: {
        null: (c) => _NoProvider(
              () {
                onSwitchNetwork(context);
              },
            ),
        NodeClientStatus.disconnect: (c) => _DisconnectStatus(
            onTry: () => chain.clientOrNull(),
            onEdit: () => onSwitchNetwork(context)),
        NodeClientStatus.pending: (c) => const _PendingStatus(),
        NodeClientStatus.connect: (c) => WidgetConstant.sizedBox
      }),
    );
  }
}

class _AppbarPageAction extends StatelessWidget {
  const _AppbarPageAction({required this.chain});
  final Chain chain;
  @override
  Widget build(BuildContext context) {
    return switch (chain.network.type) {
      NetworkType.monero => MoneroAppBarActionView(chain.cast()),
      _ => WidgetConstant.sizedBox
    };
  }
}

class _NoProvider extends StatelessWidget {
  const _NoProvider(this.onTry);
  final DynamicVoid onTry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OneLineTextWidget(
                "network_no_provider_detected".tr,
                style: context.textTheme.labelLarge
                    ?.copyWith(color: context.colors.onErrorContainer),
              )
            ],
          ),
        ),
        IconButton(
            onPressed: onTry,
            icon: Icon(Icons.add, color: context.colors.onErrorContainer))
      ],
    );
  }
}

class _DisconnectStatus extends StatelessWidget {
  const _DisconnectStatus({required this.onEdit, required this.onTry});
  final DynamicVoid onTry;
  final DynamicVoid onEdit;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTry,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OneLineTextWidget(
                  "connection_attempt_unsuccessful".tr,
                  style: context.textTheme.labelLarge
                      ?.copyWith(color: context.colors.onErrorContainer),
                ),
                OneLineTextWidget(
                  "node_connection_desc".tr,
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colors.onErrorContainer),
                )
              ],
            ),
          ),
        ),
        IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: context.colors.onErrorContainer))
      ],
    );
  }
}

class _PendingStatus extends StatelessWidget {
  const _PendingStatus();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OneLineTextWidget("node_connectiong_please_wait".tr,
                              style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colors.onTertiaryContainer)),
                          OneLineTextWidget("node_connection_desc".tr,
                              style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onErrorContainer))
                        ],
                      ),
                    ),
                    WidgetConstant.width8,
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                          color: context.colors.onTertiaryContainer),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
