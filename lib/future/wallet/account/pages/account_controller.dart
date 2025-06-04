import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

import 'package:on_chain_wallet/wallet/wallet.dart';

typedef PageChainBuilder<CL extends NetworkClient?,
        CHAINACCOUNT extends ChainAccount?, T extends Chain>
    = Widget Function(
        WalletProvider wallet,
        T account,
        CL client,
        CHAINACCOUNT? address,
        OnNetworkAccountChange<CHAINACCOUNT> onAccountChanged);

typedef OnNetworkAccountChange<CHAINACCOUNT extends ChainAccount?> = void
    Function(CHAINACCOUNT? address);

class NetworkAccountControllerView<
    CL extends NetworkClient?,
    CHAINACCOUNT extends ChainAccount?,
    T extends Chain> extends StatefulWidget {
  const NetworkAccountControllerView({
    super.key,
    required this.childBulder,
    this.account,
    this.title,
    required this.addressRequired,
    this.clientRequired = true,
    this.initAccount = false,
  });
  final PageChainBuilder<CL, CHAINACCOUNT, T> childBulder;
  final String? title;
  final bool addressRequired;
  final bool clientRequired;
  final T? account;
  final bool initAccount;

  @override
  State<NetworkAccountControllerView> createState() =>
      _NetworkAccountControllerViewState<CL, CHAINACCOUNT, T>();
}

class _NetworkAccountControllerViewState<CL extends NetworkClient?,
        CHAINACCOUNT extends ChainAccount?, T extends Chain>
    extends State<NetworkAccountControllerView<CL, CHAINACCOUNT, T>>
    with SafeState<NetworkAccountControllerView<CL, CHAINACCOUNT, T>> {
  late WalletProvider wallet;
  Chain? account;
  ChainAccount? address;
  NetworkClient? client;

  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();
  void switchAccount(ChainAccount? updateAddress) async {
    final account = this.account;
    if (updateAddress == null ||
        account == null ||
        updateAddress == account.address) {
      return;
    }
    progressKey.progressText("switch_account".tr);
    final result = await MethodUtils.call(
        () async => await account.switchAccount(updateAddress));
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
      return;
    }
    this.address = updateAddress;
    progressKey.backToIdle();
    // updateState();
  }

  Future<void> _checkAccounts() async {
    try {
      progressKey.progressText("page_retrieval_requirment".tr);
      this.account = null;
      this.client = null;
      this.address = null;

      final accout = widget.account ?? wallet.wallet.currentChain;
      final address = accout.haveAddress ? accout.address : null;
      if (widget.addressRequired && address == null) {
        progressKey.errorText("page_required_address".tr, backToIdle: false);
        return;
      }
      NetworkClient? client;
      if (widget.clientRequired) {
        progressKey.progressText("node_connectiong_please_wait".tr);
        client = await accout.clientOrNull();
        if (client == null) {
          progressKey.errorText("node_connection_error".tr, backToIdle: false);
          return;
        }
      }
      if (accout is! T ||
          widget.addressRequired && address is! CHAINACCOUNT ||
          widget.clientRequired && client is! CL) {
        progressKey.errorText("requested_chain_differs".tr, backToIdle: false);
        return;
      }
      if (widget.initAccount) {
        await accout.init();
      }
      this.account = accout;
      this.client = client;
      this.address = address;
      Logg.log("client ${this.client.runtimeType}");
      progressKey.backToIdle();
    } finally {
      updateState();
    }
  }

  PreferredSizeWidget? appBar() {
    if (widget.title == null) {
      if (progressKey.hasError) {
        return AppBar();
      }
      return null;
    }

    return AppBar(title: Text(widget.title ?? ''));
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    wallet = context.watch<WalletProvider>(StateConst.main);
    MethodUtils.after(() => _checkAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: PageProgress(
          initialStatus: StreamWidgetStatus.progress,
          backToIdle: APPConst.milliseconds100,
          initialWidget:
              ProgressWithTextView(text: "page_retrieval_requirment".tr),
          key: progressKey,
          child: (c) {
            return widget.childBulder(wallet, account!.cast<T>(), client as CL,
                address as CHAINACCOUNT, switchAccount);
          }),
    );
  }
}
