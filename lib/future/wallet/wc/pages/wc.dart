import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/web3/types/types.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:on_chain_wallet/wc/core/types/exception.dart';
import 'package:on_chain_wallet/wc/wallet/core/wallet.dart';
import 'package:on_chain_wallet/wc/wc.dart';

enum _PairingStatus {
  idle,
  connecting;

  bool get isIdle => this == idle;
}

class WalletConnectView extends StatefulWidget {
  const WalletConnectView({super.key});

  @override
  State<WalletConnectView> createState() => _WalletConnectViewState();
}

class _WalletConnectViewState extends State<WalletConnectView>
    with SafeState<WalletConnectView>, ProgressMixin {
  late WalletProvider wallet;
  late Web3WalletConnectHandler walletConnect;
  WcRpcSocketStatus get status => walletConnect.connectionStatus.value;

  List<ShimmerAction<Web3ClientInfo>> sessions = [];
  Future<void> loadSessions() async {
    final result = await walletConnect.getActiveSessions();
    sessions =
        result.map((e) => ShimmerAction<Web3ClientInfo>(object: e)).toList();
    progressKey.backToIdle();
  }

  Future<void> connect(
      {required Uri pairUrl, required Cancelable cancelable}) async {
    await walletConnect.pair(pairUrl, cancelable: cancelable);
    // await loadSessions();
    context.backToCurrent();
  }

  Future<void> onRemoveSession(ShimmerAction<Web3ClientInfo> session) async {
    session.setAction(true);
    updateState();
    final accept = await context.openSliverDialog((context) {
      return DialogTextView(
          text: "remove_session_desc".tr,
          buttonWidget: DialogDoubleButtonView());
    }, "remove_session".tr);
    if (accept != true) return;
    await walletConnect.removeSession(session.object);
    sessions.remove(session);
    session.setAction(false);
    updateState();
    context.showAlert('session_has_been_removed'.tr);
  }

  Future<void> updateDappAuthenticated(Web3APPAuthentication authenticated,
      {List<NetworkType>? web3Networks, bool remove = false}) async {
    final updateResult = await wallet.wallet
        .updateWeb3Application(authenticated, web3Networks: web3Networks);
    if (!remove && authenticated.hasAnyPermission) {
      await walletConnect.updateAuthenticated(updateResult.result);
    } else {
      await walletConnect.removeSession(updateResult.result.clientInfo);
    }
    context.showAlert("application_updated".tr);
  }

  Future<void> updateApplicationAuthenticated(
      ShimmerAction<Web3ClientInfo> client) async {
    client.setAction(true);
    final app = (await wallet.wallet.getWeb3Dapp(client.object)).result;
    updateState();
    List<Chain> lockedChains = [];
    final session =
        walletConnect.getSession(peerKey: app.authentication.applicationId);
    if (session != null) {
      final walletChain = wallet.wallet.getChains();
      final chainIds = await walletConnect.getSessionRequiredChainIds(
          session: session, auth: app.dappData);
      lockedChains =
          walletChain.where((e) => chainIds.contains(e.network.value)).toList();
    }
    final request = Web3UpdatePermissionRequest(
        lockedChains: lockedChains, authentication: app.authentication);
    await context.openDialogPage(
      "update_permission".tr,
      fullWidget: (context) => Web3PermissionUpdateView(
          authenticated: request,
          onPermissionUpdate: (networks) async {
            await updateDappAuthenticated(request.authentication,
                remove: !request.haveRequiredPermissions());
            return false;
          }),
    );
    client.setAction(false);
    updateState();
  }

  Future<void> newPair() async {
    if (!status.isConnect) return;
    await context.openDialogPage<bool>('',
        child: (context) => _ConnectPairingView(this),
        routeName: PageRouter.walletConnectPairing);
  }

  void toggleConnection() {
    if (status.isDispose) {
      walletConnect.connect();
    } else {
      walletConnect.dispose();
    }
  }

  Future<void> _onSessionUpdated(var _) async {
    await loadSessions();
    updateState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    wallet = context.wallet;
    walletConnect = wallet.wallet.walletConnect;
    walletConnect.onSessionUpdated.stream.listen(_onSessionUpdated);
    loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('wallet_connect_management'.tr)),
      body: PageProgress(
          key: progressKey,
          initialStatus: StreamWidgetStatus.progress,
          initialWidget:
              ProgressWithTextView(text: "loading_sessions_please_wait".tr),
          child: (context) {
            return CustomScrollView(
              slivers: [
                SliverConstraintsBoxView(
                    sliver: APPStreamBuilder(
                  value: walletConnect.connectionStatus,
                  builder: (context, value) => MultiSliver(children: [
                    SliverToBoxAdapter(
                      child: Column(children: [
                        AppSwitchListTile(
                          value: !value.isDispose,
                          onChanged: (p0) => toggleConnection(),
                          title: Text("enable_wallet_connect".tr),
                          subtitle: Text(value.tr.tr),
                          leading: APPAnimatedSwitcher<WcRpcSocketStatus>(
                              enable: value,
                              widgets: {
                                WcRpcSocketStatus.connect: (context) =>
                                    Icon(Icons.link),
                                WcRpcSocketStatus.disconnect: (context) =>
                                    Icon(Icons.link_off),
                                WcRpcSocketStatus.pending: (context) =>
                                    Icon(Icons.sync),
                                WcRpcSocketStatus.dispose: (context) =>
                                    Icon(Icons.block),
                                WcRpcSocketStatus.noNetwork: (context) =>
                                    Icon(Icons.block),
                              }),
                        ),
                        APPAnimated(
                            isActive: !value.isDispose,
                            onActive: (context) => AppListTile(
                                title: Text("pair_with_new_client".tr),
                                subtitle:
                                    Text("tap_to_pair_with_new_client".tr),
                                leading: Icon(Icons.add_box),
                                onTap: newPair),
                            onDeactive: (context) => WidgetConstant.sizedBox),
                        WidgetConstant.height20,
                      ]),
                    ),
                    SliverVisibility(
                        visible: sessions.isNotEmpty && !value.isDispose,
                        sliver: MultiSliver(children: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("sessions".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                              ],
                            ),
                          ),
                          SliverList.separated(
                              itemBuilder: (context, index) {
                                final obj = sessions[index];
                                final client = sessions[index].object;
                                return Shimmer(
                                    onActive: (enable, context) {
                                      return ContainerWithBorder(
                                        onRemove: () {},
                                        enableTap: false,
                                        onRemoveWidget: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                  tooltip: "remove_session".tr,
                                                  onPressed: () =>
                                                      onRemoveSession(obj),
                                                  icon: Icon(
                                                      Icons.remove_circle,
                                                      color: context
                                                          .onPrimaryContainer)),
                                              IconButton(
                                                  tooltip:
                                                      "update_permission".tr,
                                                  onPressed: () {
                                                    updateApplicationAuthenticated(
                                                        obj);
                                                  },
                                                  icon: Icon(Icons.security,
                                                      color: context
                                                          .onPrimaryContainer)),
                                            ]),
                                        child: Row(
                                          children: [
                                            CircleAPPImageView(
                                              client.image,
                                              radius: APPConst.circleRadius25,
                                              onError: (c) => const Icon(
                                                  Icons.broken_image,
                                                  size: APPConst.double40),
                                            ),
                                            WidgetConstant.width8,
                                            Flexible(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                OneLineTextWidget(client.name,
                                                    style: context
                                                        .onPrimaryTextTheme
                                                        .labelLarge),
                                                OneLineTextWidget(client.url,
                                                    style: context
                                                        .onPrimaryTextTheme
                                                        .bodyMedium),
                                              ],
                                            )),
                                          ],
                                        ),
                                      );
                                    },
                                    enable: !obj.action);
                              },
                              itemCount: sessions.length,
                              separatorBuilder: (context, index) =>
                                  WidgetConstant.divider)
                        ]))
                  ]),
                )),
              ],
            );
          }),
    );
  }
}

class _ConnectPairingView extends StatefulWidget {
  final _WalletConnectViewState state;
  const _ConnectPairingView(this.state);

  @override
  State<_ConnectPairingView> createState() => _ConnectPairingViewState();
}

class _ConnectPairingViewState extends State<_ConnectPairingView>
    with SafeState<_ConnectPairingView> {
  late WalletProvider wallet;
  // late Web3WalletConnectHandler walletConnect;
  final GlobalKey<AppTextFieldState> fieldKey = GlobalKey<AppTextFieldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Cancelable cancelable = Cancelable();
  String? error;
  void onBarcodeScanner(String url) {
    fieldKey.currentState?.updateText(url);
  }

  void onChangeUrl(String v) {
    pairUrl = v;
  }

  String pairUrl = "";
  StreamValue<WcRpcSocketStatus> get status =>
      widget.state.walletConnect.connectionStatus;

  String? onValidatePairUrl(String? v) {
    if (v == null) return "invalid_pairing_url".tr;
    try {
      WalletConnectUtils.parseUri(Uri.parse(v));
      return null;
    } on WalletConnectException catch (e) {
      return e.message.tr;
    } catch (e) {
      return "invalid_pairing_url".tr;
    }
  }

  _PairingStatus pairingStatus = _PairingStatus.idle;

  Future<void> connect() async {
    if (!formKey.ready()) return;

    cancelable.dispose();
    error = null;
    pairingStatus = _PairingStatus.connecting;
    updateState();
    final url = Uri.parse(pairUrl);
    final result = await MethodUtils.call(
        () => widget.state.connect(pairUrl: url, cancelable: cancelable));
    if (result.isCancel) return;
    if (result.hasError) {
      error = result.error!.tr;
      pairingStatus = _PairingStatus.idle;
      fieldKey.currentState?.clear();
      updateState();
    }
  }

  void disconnect() {
    cancelable.cancel();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    wallet = context.wallet;
  }

  @override
  void safeDispose() {
    super.safeDispose();
    cancelable.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            title: Text("pair_with_new_client".tr),
            centerTitle: false,
            actions: [
              APPStreamBuilder(
                value: status,
                builder: (context, value) => TappedTooltipView(
                  tooltipWidget: ToolTipView(
                    message: value.tr.tr,
                    child: IgnorePointer(
                      child: IconButton(
                        onPressed: () {},
                        icon: APPAnimatedSwitcher<WcRpcSocketStatus>(
                            enable: value,
                            widgets: {
                              WcRpcSocketStatus.connect: (context) =>
                                  Icon(Icons.link),
                              WcRpcSocketStatus.disconnect: (context) =>
                                  Icon(Icons.link_off),
                              WcRpcSocketStatus.pending: (context) =>
                                  Icon(Icons.sync),
                              WcRpcSocketStatus.dispose: (context) =>
                                  Icon(Icons.block),
                              WcRpcSocketStatus.noNetwork: (context) =>
                                  Icon(Icons.block),
                            }),
                      ),
                    ),
                  ),
                ),
              ),
              WidgetConstant.width8,
            ],
          ),
          SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: MultiSliver(children: [
                SliverToBoxAdapter(
                  child: APPStreamBuilder(
                    value: status,
                    builder: (context, value) {
                      return Shimmer(
                          enable: pairingStatus.isIdle,
                          onActive: (enable, context) {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("pairing_url".tr,
                                      style: context.textTheme.titleMedium),
                                  Text("enter_pairing_url_for_connect".tr),
                                  WidgetConstant.height8,
                                  AppTextField(
                                      key: fieldKey,
                                      validator: onValidatePairUrl,
                                      label: 'pairing_url'.tr,
                                      prefixIcon: Icon(Icons.insert_link),
                                      initialValue: pairUrl,
                                      onChanged: onChangeUrl,
                                      pasteIcon: true,
                                      readOnly: !pairingStatus.isIdle,
                                      maxLines: 2,
                                      suffixIcon: Row(children: [
                                        BarcodeScannerIconView(
                                            onBarcodeScanner),
                                      ])),
                                  ErrorTextContainer(error: error),
                                  Padding(
                                    padding: WidgetConstant.paddingVertical40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FixedElevatedButton(
                                            activePress: value.isConnect,
                                            onPressed: connect,
                                            child: ConditionalWidget(
                                              onActive: (context) =>
                                                  Text("connect".tr),
                                              enable: enable,
                                              onDeactive: (context) => Text(
                                                  "pairing_please_wait".tr),
                                            )),
                                      ],
                                    ),
                                  ),
                                ]);
                          });
                    },
                  ),
                ),
              ])),
        ],
      ),
    );
  }
}
