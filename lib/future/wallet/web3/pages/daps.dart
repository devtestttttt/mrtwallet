import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/app.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:on_chain_wallet/future/wallet/web3/types/types.dart';
import 'package:on_chain_wallet/wallet/models/access/wallet_access.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:on_chain_wallet/wc/wallet/core/wallet.dart';

class ManageWeb3DapssView extends StatelessWidget {
  const ManageWeb3DapssView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      accsess: WalletAccsessType.unlock,
      title: "dapps_management".tr,
      onAccsess: (credential, password, network) {
        return _ManageWeb3DapssView();
      },
    );
  }
}

class _ManageWeb3DapssView extends StatefulWidget {
  const _ManageWeb3DapssView();

  @override
  State<_ManageWeb3DapssView> createState() =>
      _WalletConnectActiveSessionsState();
}

class _WalletConnectActiveSessionsState extends State<_ManageWeb3DapssView>
    with SafeState<_ManageWeb3DapssView>, ProgressMixin {
  Web3RequestControllerImpl? web3Controller;
  late Web3WalletConnectHandler walletConnect;

  late WalletProvider wallet;
  List<ShimmerAction<Web3DappInfo>> sessions = [];
  Future<void> loadSessions() async {
    final result = await wallet.wallet.getAllWeb3Applications();
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
      return;
    }
    sessions = result.result
        .map((e) => ShimmerAction<Web3DappInfo>(object: e))
        .toList();
    progressKey.backToIdle();
  }

  Future<void> resetDappAuthenticated(ShimmerAction<Web3DappInfo> app) async {
    final accept = await context.openSliverDialog<bool>(
        (context) => DialogTextView(
              text: "reset_dapp_desc".tr,
              buttonWidget: DialogDoubleButtonView(),
            ),
        'clear_dapp_permissions'.tr);
    if (accept != true) return;
    app.toggleAction();
    updateState();
    app.object.authentication.resetApp();
    if (app.object.authentication.active) {
      app.object.authentication.toggleActive();
    }
    await wallet.wallet.removeWeb3Application(app.object.authentication);
    switch (app.object.authentication.protocol) {
      case Web3APPProtocol.walletConnect:
        await walletConnect.removeSession(app.object.clientInfo);
        break;
      case Web3APPProtocol.injected:
        await web3Controller?.sendAuthenticatedToClient(app.object);
        break;
    }
    sessions.remove(app);
    app.toggleAction();
    updateState();
    context.showAlert("application_removed".tr);
  }

  Future<void> updateDappAuthenticated(Web3APPAuthentication authenticated,
      {List<NetworkType>? web3Networks, bool remove = false}) async {
    final updateResult = await wallet.wallet
        .updateWeb3Application(authenticated, web3Networks: web3Networks);
    switch (authenticated.protocol) {
      case Web3APPProtocol.walletConnect:
        if (!remove && authenticated.hasAnyPermission) {
          await walletConnect.updateAuthenticated(updateResult.result);
        } else {
          await walletConnect.removeSession(updateResult.result.clientInfo);
        }
        break;
      case Web3APPProtocol.injected:
        await web3Controller?.sendAuthenticatedToClient(updateResult.result);
        break;
    }
    context.showAlert("application_updated".tr);
  }

  Future<void> updateApplicationAuthenticated(
      ShimmerAction<Web3DappInfo> app) async {
    app.toggleAction();
    updateState();
    List<Chain> lockedChains = [];
    if (app.object.authentication.protocol.isWalletConnect) {
      final session = walletConnect.getSession(
          peerKey: app.object.authentication.applicationId);

      if (session != null) {
        final walletChain = wallet.wallet.getChains();
        final chainIds = await walletConnect.getSessionRequiredChainIds(
            session: session, auth: app.object.dappData);
        lockedChains = walletChain
            .where((e) => chainIds.contains(e.network.value))
            .toList();
      }
    }
    final request = Web3UpdatePermissionRequest(
        lockedChains: lockedChains, authentication: app.object.authentication);
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
    app.toggleAction();
    updateState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    wallet = context.wallet;
    walletConnect = wallet.wallet.walletConnect;
    if (wallet.appSetting.config.supportWebView) {
      web3Controller = wallet.webviewContoller;
    } else if (wallet.appSetting.config.isExtension) {
      web3Controller = wallet.wallet as Web3RequestControllerImpl;
    }
    loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
        key: progressKey,
        initialStatus: StreamWidgetStatus.progress,
        initialWidget:
            ProgressWithTextView(text: "loading_applications_please_wait".tr),
        child: (context) => CustomScrollView(slivers: [
              SliverConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                sliver: EmptyItemSliverWidgetView(
                  isEmpty: sessions.isEmpty,
                  itemBuilder: (context) {
                    return SliverList.separated(
                        itemBuilder: (context, index) {
                          final client = sessions[index];
                          final authentication = client.object.authentication;
                          return ShimmerActionView(
                            action: client,
                            onActive: (enable, context) {
                              return ContainerWithBorder(
                                onRemove: () {},
                                enableTap: false,
                                onRemoveWidget: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          tooltip: "clear_dapp_permissions".tr,
                                          onPressed: () {
                                            resetDappAuthenticated(client);
                                          },
                                          icon: Icon(Icons.remove_circle,
                                              color:
                                                  context.onPrimaryContainer)),
                                      IconButton(
                                          tooltip: "update_permission".tr,
                                          onPressed: () {
                                            updateApplicationAuthenticated(
                                                client);
                                          },
                                          icon: Icon(Icons.security,
                                              color:
                                                  context.onPrimaryContainer)),
                                    ]),
                                child: Row(
                                  children: [
                                    CircleAPPImageView(
                                      authentication.icon,
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
                                        OneLineTextWidget(authentication.name,
                                            style: context
                                                .onPrimaryTextTheme.labelLarge),
                                        OneLineTextWidget(
                                            authentication.url ??
                                                authentication.applicationId,
                                            style: context
                                                .onPrimaryTextTheme.bodyMedium),
                                      ],
                                    )),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        itemCount: sessions.length,
                        separatorBuilder: (context, index) =>
                            WidgetConstant.divider);
                  },
                ),
              )
            ]));
  }
}
