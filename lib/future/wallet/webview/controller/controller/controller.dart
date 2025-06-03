import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:on_chain_bridge/models/models.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/core/observer.dart';
import 'package:on_chain_wallet/future/wallet/controller/wallet/ui_wallet.dart';
import 'package:on_chain_wallet/future/wallet/webview/controller/controller/tab_controller.dart';
import 'package:on_chain_wallet/future/wallet/webview/controller/controller/tab_handler.dart';
import 'package:on_chain_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain_wallet/crypto/impl/worker_impl.dart';

enum WebViewScriptStatus {
  progress,
  active,
  failed,
  block;

  bool get inProgress => this == progress;
  static WebViewScriptStatus? fromJSWalletEvent(WalletEventTypes? event) {
    switch (event) {
      case WalletEventTypes.exception:
        return WebViewScriptStatus.failed;
      case WalletEventTypes.activation:
        return WebViewScriptStatus.active;
      default:
        return null;
    }
  }
}

class WebViewController
    with
        CryptoWokerImpl,
        Web3RequestControllerImpl,
        WebViewListener,
        WebViewTabImpl,
        HttpImpl {
  @override
  final WalletRouteObserver observer;
  final Cancelable _cancelable = Cancelable();
  final _lock = SynchronizedLock();
  @override
  final UIWallet walletCore;
  WebViewController({required this.walletCore, required this.observer});
  String? _pageScript;
  String? _webviewWalletScript;

  final bool enableBackForwardKey = PlatformInterface.isMacos;

  Future<String> _loadWebViewPageScript() async {
    if (kDebugMode) {
      if (PlatformInterface.appPlatform == AppPlatform.android) {
        return (await httpGet<String>("http://10.0.2.2:3000/webview_page"))
            .result;
      } else {
        return (await httpGet<String>("http://localhost:3000/webview_page"))
            .result;
      }
    }
    _pageScript ??=
        await PlatformUtils.loadAssetText(APPConst.assetWebviewPageScript);
    return _pageScript!;
  }

  Future<String> _loadWebViewScript() async {
    if (kDebugMode) {
      if (PlatformInterface.appPlatform == AppPlatform.android) {
        return (await httpGet<String>("http://10.0.2.2:3000/webview")).result;
      } else {
        return (await httpGet<String>("http://localhost:3000/webview")).result;
      }
    }
    _webviewWalletScript ??=
        await PlatformUtils.loadAssetText(APPConst.assetWebviewScript);
    return _webviewWalletScript!;
  }

  Future<T?> _loadScript<T>(
      {required String viewType, required String script}) async {
    final result =
        await webViewController.loadScript(viewType: viewType, script: script);
    if (result == null) return null;
    return StringUtils.tryToJson(result as String);
  }

  Future<void> _runPageScripts(String viewId) async {
    final tronWeb = await PlatformUtils.loadAssetText(APPConst.assetsTronWeb);
    await _loadScript(viewType: viewId, script: tronWeb);
    final script = await _loadWebViewPageScript();
    await _loadScript(viewType: viewId, script: script);
  }

  Future<bool> _postEvent(WalletEvent event) async {
    try {
      final result = await _loadScript<bool>(
          script:
              "onChain.onWebViewMessage(${StringUtils.fromJson(event.toJson())})",
          viewType: event.clientId);
      return result!;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Web3ClientInfo?> currentApllicationId() async {
    return lastEvent.value?.client;
  }

  @override
  Future<void> sendMessageToClient(
      Web3EncryptedMessage message, String applicationId) async {
    await _lock.synchronized(() async {
      final lastEvent = this.lastEvent.value;
      final lastEventUri = lastEvent?.evnet.url;
      if (lastEventUri != null) {
        final id = Web3APPAuthentication.toApplicationId(lastEventUri);
        if (id == applicationId) {
          final event = toResponseEvent(
              id: lastEvent!.evnet.viewId,
              type: WalletEventTypes.message,
              data: message.toCbor().encode());
          await _postEvent(event);
        }
      }
    });
  }

  Future<bool> _scriptInitialized(String viewType) async {
    final result =
        await _loadScript(script: "onChain.ethereum", viewType: viewType);
    return result != null;
  }

  static const bool isWorker = true;
  Future<WebViewScriptStatus?> _activeScript(WebViewEvent event) async {
    final applicationId =
        Web3APPAuthentication.toApplicationId(lastEvent.value?.evnet.url);
    onCloseClinet(applicationId);
    final auth = tabsAuthenticated[event.viewId];
    if (auth == null) return WebViewScriptStatus.failed;
    final client = createClientInfos(
        clientId: event.viewId,
        url: event.url,
        title: event.title,
        faviIcon: event.favicon);

    await _runPageScripts(event.viewId);
    bool result;
    if (isWorker) {
      final script = await _loadWebViewScript();
      final responseEvent = await getPageAuthenticated(
          clientId: auth.viewType, info: client, additional: script);
      result = await _postEvent(responseEvent);
    } else {
      final responseEvent = await getPageAuthenticated(
          clientId: auth.viewType, info: client, additional: null);
      result = await _postEvent(responseEvent);
      if (result) {
        updatePageScriptStatus(
            status: result
                ? WebViewScriptStatus.active
                : WebViewScriptStatus.failed,
            clientId: event.viewId);
      }
    }
    // final
    if (!result) {
      return WebViewScriptStatus.failed;
    }
    return null;
  }

  @override
  Future<void> switchTab(WebViewTabController controller) async {
    await super.switchTab(controller);
    final viewType = this.viewType;
    if (viewType == null) return;
    final inited = await _scriptInitialized(viewType);
    if (!inited) reload();
  }

  @override
  void onPageStart(WebViewEvent event) async {
    _cancelable.cancel();

    await _lock.synchronized(() async {
      super.onPageStart(event);
      final r = await MethodUtils.call(() async => await _activeScript(event),
          cancelable: _cancelable);
      if (r.hasError) {
        return;
      }
      if (r.result != null) {
        lastEvent.value?.updateStatus(r.result!);
        lastEvent.notify();
      }
    });
  }

  @override
  void onPageRequest(WebViewEvent event) async {
    if (event.request == null) return;
    if (isWorker) {
      final bool isWalletRequest = await _lock.synchronized(() async {
        final requestType =
            WebViewScriptStatus.fromJSWalletEvent(event.request?.type);
        if (requestType != null) {
          updatePageScriptStatus(
              status: requestType, clientId: event.request!.clientId);
          assert(requestType != WebViewScriptStatus.failed,
              'page script activation failed: ${StringUtils.tryDecode(event.request?.data)}');
          return false;
        }
        return true;
      });
      if (!isWalletRequest) return;
    }
    final client = createClientInfos(
        clientId: event.viewId,
        url: event.url,
        faviIcon: event.favicon,
        title: event.title);
    if (client == null) {
      await _postEvent(toResponseEvent(
          id: event.viewId,
          type: WalletEventTypes.exception,
          data: Web3RequestExceptionConst.invalidHost
              .toResponseMessage()
              .toCbor()
              .encode(),
          requestId: event.request!.requestId));
      return;
    }

    final request = Web3RequestApplicationInformation(
        info: client, request: event.request!);
    onWalletEvent(request);
    try {
      final responseEvent = await request.onCompleteRequest;
      final bool result = await _postEvent(responseEvent);
      if (result) {
        request.completeSuccess();
      } else {
        request.completeError();
      }
    } on Web3RejectException {
      return;
    }
  }

  @override
  Future<void> sendToClient(WalletEvent event) async {
    await _postEvent(event);
  }

  @override
  Future<void> dispose() async {
    webViewController.removeListener(this);
    _pageScript = null;
    _webviewWalletScript = null;
    await super.dispose();
  }
}
