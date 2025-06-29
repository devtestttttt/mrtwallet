import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_bridge/models/models.dart';
import 'package:on_chain_bridge/on_chain_bridge.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/core/observer.dart';
import 'package:on_chain_wallet/future/wallet/web3/controller/web3_request_controller.dart';
import 'package:on_chain_wallet/future/wallet/webview/controller/controller/tab_controller.dart';
import 'package:on_chain_wallet/future/wallet/webview/view/native_view.dart';
import 'package:on_chain_wallet/repository/models/models/webview_repository.dart';
import 'package:on_chain_wallet/crypto/impl/worker_impl.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';

class WebViewStateControllerConst {
  static const int viewIdLength = 12;
  static const String googleSerchUrl = "https://www.google.com/search?q=";
  static const String interfaceName = "onChain";
  static const String debug = "http://10.0.2.2:3000/";
  static const String google = "https://google.com/";
}

enum WebViewTabPage {
  init,
  browser,
  tabs,
  history,
  bookmarks,
  hide;
}

// class LastWeb3ActiveClient {
//   final WebViewEvent evnet;
//   Web3ActiveClient? _client;
//   Web3ActiveClient? get client => _client;

//   LastWeb3ActiveClient({required this.evnet});
//   WalletJSScriptStatus _web3Status = WalletJSScriptStatus.progress;
//   WalletJSScriptStatus get web3Status => _web3Status;
//   void updateStatus(WalletJSScriptStatus status) {
//     assert(_web3Status == WalletJSScriptStatus.progress,
//         "client status already updated.");
//     if (_web3Status != WalletJSScriptStatus.progress) return;
//     _web3Status = status;
//   }

//   void setClient(Web3ActiveClient? client) {
//     assert(_web3Status == WalletJSScriptStatus.progress,
//         "client status already updated.");
//     if (_web3Status != WalletJSScriptStatus.progress) return;
//     _client = client;
//   }
// }

mixin WebViewTabImpl on CryptoWokerImpl, WebViewListener {
  WalletRouteObserver get observer;
  bool get inited => _page != WebViewTabPage.init;
  final StreamValue<bool> notifier = StreamValue<bool>(false);
  final TextEditingController textController = TextEditingController();

  String get _website {
    if (kDebugMode) {
      return WebViewStateControllerConst.debug;
    }
    return WebViewStateControllerConst.google;
  }

  Future<void> onTapTextFeield(FutureNullString onTap) async {
    final url = await onTap();
    if (url == null) return;

    textController.text = url;

    webViewController.openUrl(viewType: viewType!, url: url);
  }

  final _tabLocker = SynchronizedLock();
  final PlatformWebView webViewController = PlatformInterface.instance.webView;
  final WebViewRepository _storage = WebViewRepository();
  final Map<String, WebViewTabController> tabsAuthenticated = {};
  final GlobalKey searchBarKey = GlobalKey();
  List<WebViewTab> get histories => _storage.histories;
  List<WebViewTab> get bookmarks => _storage.bookmarks;

  WebViewTabController get controller => tabsAuthenticated[_currentViewId]!;
  WebViewTab get tab => controller.tab.value;

  int get tabsLength => tabsAuthenticated.length;
  List<WebViewTabController> get controllers =>
      tabsAuthenticated.values.toList();
  StreamValue<LastWeb3ActiveClient> get latestClient;

  final StreamValue<double?> _progress = StreamValue<double?>(null);
  final StreamValue<PageNavigatorStatus> navigatorStatus =
      StreamValue(PageNavigatorStatus(false, false));
  StreamValue<double?> get progress => _progress;
  String? _currentViewId;
  @override
  String? get viewType => _currentViewId;
  WebViewTabPage _page = WebViewTabPage.init;
  WebViewTabPage get page => _page;
  bool get inBrowser => _page == WebViewTabPage.browser;
  bool get isHide => _page == WebViewTabPage.hide;

  void removeHistory(WebViewTab tab) async {
    _tabLocker.synchronized(() async {
      await _storage.removeHistory(tab);
      if (histories.isEmpty) {
        backToBorwser();
      }
    });
  }

  void openTabPage(WebViewTab tab) {
    textController.text = tab.url;
    // textField.currentState?.updateText(tab.url);
    webViewController.openUrl(viewType: viewType!, url: tab.url);
    backToBorwser();
  }

  void clearHistory() {
    _tabLocker.synchronized(() async {
      await _storage.clearHistory();
    });
    backToBorwser();
  }

  void removeBookmars(WebViewTab tab) async {
    await _tabLocker.synchronized(() async {
      await _storage.removeBookmark(tab);
    });
    controller.setBookmark(tab, false);
    if (bookmarks.isEmpty) {
      backToBorwser();
    } else {
      notifier.notify();
    }
  }

  void clearBookmark() {
    _tabLocker.synchronized(() async {
      await _storage.clearBookmark();
    });

    backToBorwser();
  }

  void backToBorwser() {
    _page = WebViewTabPage.browser;
    notifier.notify();
  }

  void showOpenTabs() {
    _page = WebViewTabPage.tabs;
    notifier.notify();
  }

  void showHistories() {
    _page = WebViewTabPage.history;
    notifier.notify();
  }

  void showBookmarks() {
    _page = WebViewTabPage.bookmarks;
    notifier.notify();
  }

  Future<void> _navigatorStatus() async {
    final view = viewType;
    if (view == null) return;
    final canGoBack = await webViewController.canGoBack(view);
    final canGoForward = await webViewController.canGoForward(view);
    navigatorStatus.value = PageNavigatorStatus(canGoBack, canGoForward);
  }

  Future<void> goBack() async {
    if (viewType == null) return;
    await webViewController.goBack(viewType!);
  }

  bool onBackButton() {
    if (!inBrowser) {
      backToBorwser();
      return false;
    }
    if (navigatorStatus.value.back) {
      goBack();
      return false;
    }
    return true;
  }

  Future<void> goForward() async {
    if (viewType == null) return;
    await webViewController.goForward(viewType!);
  }

  Future<void> reload() async {
    if (viewType == null) return;
    if (kDebugMode) {
      await webViewController.clearCache(viewType!);
    }
    webViewController.reload(viewType!);
  }

  WebViewTab _eventToTab(WebViewEvent event) {
    APPImage? image = APPImage.network(event.favicon);
    image ??= APPImage.faviIcon(event.url!);
    return WebViewTab(
        url: event.url!,
        title: event.title,
        id: controller.tabId,
        image: image);
  }

  Future<APPAndroidViewController> _initContiller(String viewId,
      {String? url}) async {
    await webViewController.init(viewId,
        url: url ?? _website,
        jsInterface: WebViewStateControllerConst.interfaceName);
    final controller = await APPAndroidViewController.create(viewType: viewId);
    return controller;
  }

  Future<WebViewTabController> _buildController() async {
    final viewId = await crypto.generateRandomHex(
        length: WebViewStateControllerConst.viewIdLength,
        existsKeys:
            tabsAuthenticated.values.map((e) => e.viewTypeBytes).toList());
    final key = await crypto.generateRandomBytes();
    final controller = await _initContiller(viewId);
    final tab = WebViewTab(
        id: viewId,
        url: _website,
        title: null,
        image: APPImage.faviIcon(_website));
    final auth = WebViewTabController(
        controller: controller, viewId: viewId, key: key, tab: tab);
    tabsAuthenticated[auth.viewId] = auth;
    return auth;
  }

  Future<void> _initializeController(WebViewTabController tab) async {
    if (_currentViewId != null) {
      webViewController.removeListener(this);
    }
    _currentViewId = tab.viewId;
    webViewController.addListener(this);
  }

  Future<void> _initWebView() async {
    await _storage.initRepository();
    final tabs = _storage.tabs;
    for (final i in tabs) {
      final key = await crypto.generateRandomBytes();
      final tabId = await crypto.generateRandomHex(
          length: WebViewStateControllerConst.viewIdLength,
          existsKeys:
              tabsAuthenticated.values.map((e) => e.viewTypeBytes).toList());
      final controller = await _initContiller(tabId, url: i.url);
      final auth = WebViewTabController(
          controller: controller, viewId: tabId, key: key, tab: i);
      tabsAuthenticated[tabId] = auth;
    }
    WebViewTabController controller;
    if (tabsAuthenticated.isNotEmpty) {
      final lastest = _storage.lastTab;
      controller = tabsAuthenticated.values.firstWhere(
          (e) => e.tab.value == lastest,
          orElse: () => tabsAuthenticated.values.first);
    } else {
      controller = await _buildController();
      await _storage.updateTab(controller.tab.value);
    }
    await _initializeController(controller);
    _page = WebViewTabPage.browser;
    notifier.notify();
  }

  Future<void> removeTab(WebViewTabController auth) async {
    await _storage.removeTab(auth.tab.value);
    final remove = tabsAuthenticated.remove(auth.viewId);
    final last = _storage.lastTab;
    final WebViewTabController? authenticated =
        tabsAuthenticated.values.firstWhereOrNull((e) => e.tabId == last?.id);
    if (authenticated != null) {
      await _initializeController(authenticated);
      if (last == null) {
        backToBorwser();
      }
    } else {
      await newTab((v) {});
    }
    notifier.notify();
    remove?.dispose();
  }

  Future<void> addOrRemoveFromBookMark(WebViewTab newTab) async {
    await _storage.addOrRemoveFromBookMark(newTab);
    controller.setBookmark(tab, _storage.inBokmark(newTab));
  }

  Future<void> newTab(IntVoid reachedLimit) async {
    await _tabLocker.synchronized(() async {
      if (tabsAuthenticated.length > WebViewStorageType.tab.maxStorageLength) {
        reachedLimit(WebViewStorageType.tab.maxStorageLength);
        return;
      }
      final newController = await _buildController();
      await _storage.updateTab(newController.tab.value);
      await _initializeController(newController);
      backToBorwser();
    });
  }

  Future<void> switchTab(WebViewTabController controller) async {
    await _tabLocker.synchronized(() async {
      if (controller.viewId == viewType) {
        backToBorwser();
        return;
      }
      if (!tabsAuthenticated.containsKey(controller.viewId)) return;
      await _initializeController(controller);
      backToBorwser();
    });
  }

  Future<void> onPop(DynamicVoid callBack) async {
    if (!inBrowser) {
      backToBorwser();
      return;
    }
    callBack();
  }

  Web3ClientInfo? createClientInfos(
      {required String? clientId,
      required String? url,
      required String? title,
      required String? faviIcon});

  @override
  void onPageStart(WebViewEvent event) {
    _navigatorStatus();
    final String? url = event.url;
    final lastUrl = latestClient.value.url;
    latestClient.value =
        LastWeb3ActiveClient(identifier: event.viewId, url: event.url);
    if (url == null) return;
    textController.text = url;
    _tabLocker.synchronized(() async {
      final WebViewTab tab = _eventToTab(event);
      final inBokmark = _storage.inBokmark(tab);
      controller.setTab(tab, inBokmark);
      final bool changed = url != lastUrl;
      if (changed) {
        _storage.updateTab(tab);
      }
    });
  }

  @override
  void onPageFinished(WebViewEvent event) async {
    if (event.url == null) return;
    _progress.value = null;
    final WebViewTab tab = _eventToTab(event);
    await _storage.saveHistory(tab);
  }

  @override
  void onPageProgress(WebViewEvent event) {
    if (event.progress == null) {
      return;
    }
    _progress.value = (event.progress! / 100);
  }

  @override
  void onPageError(WebViewEvent event) {
    _progress.value = null;
  }

  void _onPushListener(Route route, Route? previousRoute) {
    if (isHide) return;
    final name = route.settings.name;
    final current = previousRoute?.settings.name;
    if (name == PageRouter.settingMenu || name == PageRouter.webviewMenu) {
      return;
    }
    if (current == '/') {
      _page = WebViewTabPage.hide;
      MethodUtils.after(() async => notifier.notify(),
          duration: APPConst.animationDuraion);
    }
  }

  void _onPopListener(Route route, Route? previousRoute) {
    final current = previousRoute?.settings.name;
    if (!isHide) return;
    if (current == '/') {
      _page = WebViewTabPage.browser;
      notifier.notify();
    }
  }

  Future<void> dispose() async {
    observer.removePopListener(_onPopListener);
    observer.removePushListener(_onPushListener);
    latestClient.dispose();
    navigatorStatus.dispose();
    _progress.dispose();
    notifier.dispose();
    for (final i in tabsAuthenticated.values) {
      i.dispose();
    }
  }

  Future<void> init() async {
    await _initWebView();
    observer.addPopListener(_onPopListener);
    observer.addPushListener(_onPushListener);
  }
}

class PageNavigatorStatus {
  final bool back;
  final bool forward;
  const PageNavigatorStatus(this.back, this.forward);
}
