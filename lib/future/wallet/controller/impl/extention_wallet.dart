import 'dart:async';
import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_bridge/models/models.dart';
import 'package:on_chain_bridge/web/web.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/controller/models/key.dart';
import 'package:on_chain_wallet/future/wallet/controller/models/login_history.dart';
import 'package:on_chain_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain_wallet/crypto/requets/messages/crypto/requests/chacha.dart';

// @JS("close")
// external void close();

class ExtentionSessionStorageConst {
  static const String key = "extention_setting";
  static const String history = "extention_history";
  static const String expireKey = "extention_expire";
  static const String extentionType = "popup";
  static const String normalTabType = "normal";
  static const List<int> keyTag = [23, 123, 21, 10];
  static const List<int> historyTag = [123, 21, 10, 21];
  static const String iframeName = "iframe";
  static const String viewQueryParameters = "view";
  static const String contextQueryParameters = "context";
  static const Map<String, dynamic> closeEvent = {
    "message": "close_iframe",
    "source": "wallet",
  };
}

enum ExtensionWalletContextType {
  action(0),
  sidePanel(1),
  popup(2),
  tab(3),
  sidebarAction(4);

  bool get isAction => this == action;
  bool get isSidePanel => this == sidePanel;
  bool get isSidebarAction => this == sidebarAction;
  bool get isTab => this == tab;
  final int value;
  const ExtensionWalletContextType(this.value);

  static ExtensionWalletContextType? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }

  static ExtensionWalletContextType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'invalid extension context type tag'));
  }
}

class ExtensionWalletContext {
  final ExtensionWalletContextType context;
  final int windowId;
  final String instanceId;
  final int? tabId;
  final bool iframe;
  const ExtensionWalletContext(
      {required this.context,
      required this.windowId,
      required this.instanceId,
      required this.tabId,
      required this.iframe});
  static const ExtensionWalletContext init = ExtensionWalletContext(
      context: ExtensionWalletContextType.action,
      windowId: 0,
      instanceId: '',
      tabId: null,
      iframe: false);
}

mixin ExtentionWalletHandler on Web3RequestControllerImpl {
  ExtensionWalletContext _context = ExtensionWalletContext.init;
  ExtensionWalletContext get context => _context;
  final StreamValue<Web3ClientInfo?> latestClient = StreamValue(null);
  final sessionStorage = extension.storage.session;
  GlobalKey<NavigatorState> get navigatorKey;
  StreamSubscription<int>? _onWalletExpireTime;
  List<ExtensionWalletContextType> _supportedActions = [];
  List<ExtensionWalletContextType> get supportedActions => _supportedActions;

  @override
  Future<Web3ClientInfo?> currentApllicationId() async {
    if (jsWindow.navigator.isFirefox && isMozila) {
      List<ChromeWindow> windows = await extension.windows.getAll_(
        populate: true,
        windowTypes: [ExtentionSessionStorageConst.normalTabType],
      );
      for (final w in windows) {
        final tabs = w.tabs?.toDart ?? [];
        for (final i in tabs) {
          if (!i.active) continue;
          final client = createClientInfos(
              clientId: i.id?.toString(),
              url: i.url,
              title: i.title,
              faviIcon: i.favIconUrl);
          if (client == null) continue;
          return client;
        }
      }
      return null;
      // final window
    }
    ChromeWindow window = await extension.windows.getLastFocused_(
      populate: true,
      windowTypes: [ExtentionSessionStorageConst.normalTabType],
    );
    final tabs = window.tabs?.toDart ?? [];
    for (final i in tabs) {
      if (!i.active) continue;
      final client = createClientInfos(
          clientId: i.id?.toString(),
          url: i.url,
          title: i.title,
          faviIcon: i.favIconUrl);
      if (client == null) continue;
      return client;
    }
    return null;
  }

  void _onTick(int _) {
    final t = walletCore.reminingWalletTime;
    if (t == null) return;
    final expire = DateTime.now().add(Duration(seconds: t));
    _saveExpireTime(expire);
  }

  Future<void> _saveExpireTime(DateTime expire) async {
    await sessionStorage.setStorage_(ExtentionSessionStorageConst.expireKey,
        expire.secondsSinceEpoch.toString());
  }

  void _disposeExpireChecker() {
    _onWalletExpireTime?.cancel();
    _onWalletExpireTime = null;
  }

  void _buildTimerChecker() {
    _disposeExpireChecker();
    _onWalletExpireTime =
        Stream<int>.periodic(const Duration(seconds: 10), (e) => e)
            .listen(_onTick);
  }

  Future<void> clearLoginHistory() async {
    await sessionStorage.removeMultiple_([
      ExtentionSessionStorageConst.history,
      ExtentionSessionStorageConst.key,
      ExtentionSessionStorageConst.expireKey
    ]);
    _disposeExpireChecker();
  }

  Future<void> saveLoginHistory(String key) async {
    final int? reminig = walletCore.reminingWalletTime;
    if (reminig == null) return;
    final expire = DateTime.now().add(Duration(seconds: reminig));
    final walletKey = ExtentionWalletKey(key);
    final encryptionKey = ExtentionKey.generate();
    final encrypt = await crypto.cryptoMainRequest(CryptoRequestEncryptChacha(
        message: walletKey.toCbor().encode(),
        key: encryptionKey.keyBytes,
        nonce: encryptionKey.nonceBytes));
    await sessionStorage.setMultipleStorage_({
      ExtentionSessionStorageConst.key: encryptionKey.toCbor().toCborHex(),
      ExtentionSessionStorageConst.history: encrypt.encryptedHex,
      ExtentionSessionStorageConst.expireKey:
          expire.secondsSinceEpoch.toString(),
    });
    _buildTimerChecker();
  }

  Future<String?> getLoginHistory() async {
    final history = await MethodUtils.call(() async {
      final keys = await sessionStorage.getMultipleStorage_([
        ExtentionSessionStorageConst.key,
        ExtentionSessionStorageConst.history,
        ExtentionSessionStorageConst.expireKey
      ]);
      final expireTime = QuickDateTimeFormater.fromSecondsSinceEpoch(
          int.parse(keys[ExtentionSessionStorageConst.expireKey]!));
      final ExtentionKey key =
          ExtentionKey.deserialize(hex: keys[ExtentionSessionStorageConst.key]);
      final decrypt = await crypto.cryptoMainRequest(
          CryptoRequestDecryptChacha.fromHex(
              message: keys[ExtentionSessionStorageConst.history]!,
              key: key.key,
              nonce: key.nonce));
      final walletKey =
          ExtentionWalletKey.deserialize(bytes: decrypt.decrypted);
      if (expireTime.isAfterNow) {
        return walletKey.key;
      }
      await clearLoginHistory();
      return null;
    });
    if (history.hasResult) {
      return history.result;
    }
    return null;
  }

  void _closeSelf() {
    if (context.context == ExtensionWalletContextType.sidebarAction) {
      extension.sidebarAction.close_();
    } else if (context.iframe) {
      jsWindow.parent
          ?.postMessage(ExtentionSessionStorageConst.closeEvent.jsify());
    } else {
      jsWindow.close();
    }
  }

  bool _onRuntimeMessage(
      JSWalletEvent? message, MessageSender sender, JSFunction sendResponse) {
    final event = message?.toEvent();
    if (event == null) return false;
    switch (event.type) {
      case WalletEventTypes.openExtension:
        sendResponse.callAsFunction(
            null,
            WalletEvent(
                    target: WalletEventTarget.wallet,
                    type: WalletEventTypes.ping,
                    requestId: 'wallet _onRuntimeMessage')
                .toJsEvent());
        _focusCurrent();
        return true;
      case WalletEventTypes.close:
        if (event.clientId == context.instanceId) return false;
        final instance = StringUtils.tryDecode(event.data);
        if (instance == context.instanceId) {
          _closeSelf();
        }
        break;
      case WalletEventTypes.windowId:
        if (event.clientId == context.instanceId) return false;
        if (event.platform == null) return false;
        final contextType = ExtensionWalletContextType.fromName(event.platform);
        if (context.context != contextType) return false;
        sendResponse.callAsFunction(
            null,
            WalletEvent(
                    type: WalletEventTypes.windowId,
                    target: WalletEventTarget.wallet,
                    clientId: context.instanceId)
                .toJsEvent());
        return true;
      case WalletEventTypes.tabId:
        _onAuthTabMessage(sender.tab)
            .then((e) => sendResponse.callAsFunction(null, e.toJsEvent()));
        return true;
      default:
        break;
    }
    return false;
  }

  Future<WalletEvent> _onAuthTabMessage(ChromeTab? tab) async {
    // final tab = sender.tab;
    final client = createClientInfos(
        clientId: tab?.id.toString(),
        url: tab?.url,
        faviIcon: tab?.favIconUrl,
        title: tab?.title);
    if (client == null) {
      return WalletEvent(
          clientId: "${tab?.id ?? -1}",
          data: Web3RequestExceptionConst.invalidHost
              .toResponseMessage()
              .toCbor()
              .encode(),
          requestId: "",
          type: WalletEventTypes.exception,
          target: WalletEventTarget.wallet);
    }
    final auth = await walletCore.getWeb3Authenticated(client);
    return WalletEvent(
        clientId: "${tab?.id ?? -1}",
        data: auth.hasResult
            ? auth.result.toCbor().encode()
            : Web3RequestExceptionConst.fromException(auth.exception!)
                .toResponseMessage()
                .toCbor()
                .encode(),
        requestId: "",
        type: auth.hasResult
            ? WalletEventTypes.activation
            : WalletEventTypes.exception,
        target: WalletEventTarget.wallet);
  }

  void _onMessage(JSWalletEvent message, RuntimePort port) async {
    try {
      final event = message.toEvent();
      if (event == null || event.target != WalletEventTarget.external) return;
      if (event.type == WalletEventTypes.ping) {
        port.postMessage(message);
        return;
      }
      final tab = await _getTab(idStr: event.clientId);

      final Web3ClientInfo? client = createClientInfos(
          clientId: tab?.id?.toString(),
          url: tab?.url,
          faviIcon: tab?.favIconUrl,
          title: tab?.title);
      if (client == null) {
        port.postMessage(toResponseEvent(
                id: "${tab?.id ?? -1}",
                type: WalletEventTypes.exception,
                data: Web3RequestExceptionConst.invalidHost
                    .toResponseMessage()
                    .toCbor()
                    .encode(),
                requestId: event.requestId)
            .toJsEvent());

        return;
      }
      _focusCurrent();
      final request =
          Web3RequestApplicationInformation(info: client, request: event);
      onWalletEvent(request);
      void onDisconnect(RuntimePort port) {
        if (request.isClosed) return;
        request.completeError();
      }

      port.onDisconnect.addListener(onDisconnect.toJS);
      final responseEvent = await request.onCompleteRequest;
      port.postMessage(responseEvent.toJsEvent());
      request.completeSuccess();
      port.onDisconnect.removeListener(onDisconnect.toJS);
      await extension.tabs.update_(int.parse(event.clientId), active: true);
      // ignore: empty_catches
    } catch (_) {}
  }

  void _onConnet(RuntimePort port) {
    port.onMessage.addListener(_onMessage.toJS);
  }

  void _onActivateChain(ActiveInfo info) {
    final tabInfo =
        extension.tabs.query_(windowId: info.windowId, active: true);
    tabInfo.then(_updateTabs);
  }

  void _updateTabs(List<ChromeTab> tabs) async {
    for (final i in tabs) {
      final client = createClientInfos(
          clientId: i.id?.toString(),
          url: i.url,
          title: i.title,
          faviIcon: i.favIconUrl);
      if (client == null) continue;
      final permission = await walletCore.getWeb3Permission(client);
      if (permission.hasResult) {
        final event = toResponseEvent(
            id: "${i.id}",
            type: WalletEventTypes.message,
            data: permission.result.toCbor().encode());
        sendToClient(event);
      }
    }
  }

  Future<void> initContext() async {
    final parse = Uri.tryParse(jsWindow.location.search ?? '');
    final context = ExtensionWalletContextType.fromName(parse
        ?.queryParameters[ExtentionSessionStorageConst.contextQueryParameters]);
    final window = (await _getWindow());
    final windowId = window.id;
    if (windowId == null || context == null) {
      throw WalletException('initialize_app_failed');
    }
    int? tabId;
    if (context.isTab) {
      final tab = window.tabs?.toDart.firstWhereNullable(
          (e) => e.url?.contains(jsWindow.location.href) ?? false);
      tabId = tab?.id;
      if (tabId == null) {
        throw WalletException('initialize_app_failed');
      }
    }
    final isIframe = parse?.queryParameters[
            ExtentionSessionStorageConst.viewQueryParameters] ==
        ExtentionSessionStorageConst.iframeName;
    _context = ExtensionWalletContext(
        context: context,
        windowId: windowId,
        instanceId: UUID.generateUUIDv4(),
        tabId: tabId,
        iframe: isIframe);
    _supportedActions = [
      ExtensionWalletContextType.popup,
      ExtensionWalletContextType.tab,
      if (extension.sidePanelNullable?.openFunc != null)
        ExtensionWalletContextType.sidePanel,
      if (extension.sidebarActionNullable?.openFunc != null ||
          oprNullable?.sidebarActionNullable?.openFunc != null)
        ExtensionWalletContextType.sidebarAction,
    ].immutable;

    final exists = await _getAllActiveIntance();
    if (exists.isEmpty) return;
    await navigatorKey.currentContext?.openSliverDialog<bool>(
        (context) => DuplicateExtensionInstanceAlert(),
        'duplicate_wallet_instance'.tr,
        dismissible: false);
    _closeSelf();
    throw WalletException('initialize_app_failed');
  }

  Web3ClientInfo? _createClientInfosFromTab(ChromeTab? tab) {
    if (tab == null) return null;
    final id = tab.id;
    if (id == null || id.isNegative || id == context.tabId) return null;
    return createClientInfos(
        clientId: "$id",
        url: tab.url,
        title: tab.title,
        faviIcon: tab.favIconUrl);
  }

  void _onTabActive(ActiveInfo info) async {
    if (context.context == ExtensionWalletContextType.popup &&
        info.windowId == context.windowId) {
      return null;
    }
    if (context.context == ExtensionWalletContextType.tab &&
        info.tabId == context.tabId) {
      return null;
    }

    final tab = await _getTab(id: info.tabId);
    latestClient.value = _createClientInfosFromTab(tab);
  }

  void _onTabUpdate(int id, ChangeInfo info, ChromeTab tab) async {
    if (context.context == ExtensionWalletContextType.popup &&
        tab.windowId == context.windowId) {
      return null;
    }
    if (context.context == ExtensionWalletContextType.tab &&
        id == context.tabId) {
      return null;
    }
    latestClient.value = _createClientInfosFromTab(tab);
  }

  void _onWindowFocusChanged(int windowId) async {
    if (context.context == ExtensionWalletContextType.popup &&
        windowId == context.windowId) {
      return null;
    }
    final tab = await _getLatestWindowTab(windowId);
    if (context.context == ExtensionWalletContextType.tab &&
        tab?.id == context.tabId) {
      return null;
    }
    latestClient.value = _createClientInfosFromTab(tab);
  }

  Future<void> initExtension() async {
    extension.runtime.onMessage.addListener(_onRuntimeMessage.toJS);
    extension.runtime.onConnect.addListener(_onConnet.toJS);
    extension.tabs.onActivated.addListener(_onActivateChain.toJS);
    extension.runtime.sendMessage_(
        message: WalletEvent(
            target: WalletEventTarget.wallet,
            type: WalletEventTypes.ping,
            requestId: 'initExtension'));
    extension.tabs.onActivated.addListener(_onTabActive.toJS);
    extension.tabs.onUpdated.addListener(_onTabUpdate.toJS);
    extension.windows.onFocusChanged.addListener(_onWindowFocusChanged.toJS);
  }

  @override
  Future<void> sendMessageToClient(
      Web3EncryptedMessage message, String applicationId) async {
    List<ChromeWindow> windows = await extension.windows.getAll_(
        populate: true,
        windowTypes: [ExtentionSessionStorageConst.normalTabType]);
    for (final w in windows) {
      final tabs = w.tabs?.toDart ?? [];
      for (final i in tabs) {
        if (!i.active) continue;
        if (i.id == null) continue;
        final id = Web3APPAuthentication.toApplicationId(i.url);
        if (id == applicationId) {
          final event = toResponseEvent(
              id: "${i.id}",
              type: WalletEventTypes.message,
              data: message.toCbor().encode());
          sendToClient(event);
        }
      }
    }
  }

  @override
  Future<void> sendToClient(WalletEvent event) async {
    await extension.tabs
        .sendMessage_(
            tabId: int.parse(event.clientId), message: event.toJsEvent())
        .timeout(APPConst.tenSecoundDuration, onTimeout: () => null)
        .catchError((e) {
      return null;
    });
  }

  Future<ChromeWindow> _getWindow() async {
    return await extension.windows.getCurrent_(populate: true);
  }

  Future<ChromeTab?> _getTab({String? idStr, int? id}) async {
    if (idStr == null && id == null) return null;
    id ??= IntUtils.tryParse(idStr);
    if (id == null) return null;
    try {
      return await extension.tabs.get_(id);
    } catch (_) {
      return null;
    }
  }

  Future<ChromeTab?> _getLatestWindowTab(int windowId) async {
    try {
      final tab = await extension.tabs.query_(active: true, windowId: windowId);
      return tab.firstOrNull;
    } catch (_) {
      return null;
    }
  }

  Future<void> _focusCurrent() async {
    switch (context.context) {
      case ExtensionWalletContextType.sidePanel:
      case ExtensionWalletContextType.popup:
        await extension.windows.update_(context.windowId, focused: true);
        break;
      case ExtensionWalletContextType.tab:
        await extension.windows.update_(context.windowId, focused: true);
        await extension.tabs.update_(context.tabId, active: true);
        break;
      default:
    }
  }

  Future<List<String>> _getAllActiveIntance() async {
    final List<String> existsContext = [];
    for (final i in ExtensionWalletContextType.values) {
      final r = await MethodUtils.call(() async {
        return await extension.runtime.sendMessage_(
            message: WalletEvent(
                target: WalletEventTarget.wallet,
                type: WalletEventTypes.windowId,
                clientId: context.instanceId,
                platform: i.name));
      });
      final event = r.resultOrNull;
      if (event == null) continue;
      existsContext.add(event.clientId);
    }
    return existsContext;
  }

  final _lock = SynchronizedLock();
  Future<void> openPopup(ExtensionWalletContextType context) async {
    if (context == ExtensionWalletContextType.action) return;
    await _lock.synchronized(() async {
      switch (context) {
        case ExtensionWalletContextType.sidePanel:
          await extension.sidePanel.open_(windowId: this.context.windowId);
          break;
        case ExtensionWalletContextType.sidebarAction:
          if (extension.sidebarActionNullable?.openFunc != null) {
            await extension.sidebarAction.open_();
          } else {
            await oprNullable?.sidebarAction.open_();
          }
          break;
        case ExtensionWalletContextType.tab:
          await extension.tabs.create_(
              url: "${extension.runtime.getURL("index.html")}?context=tab");
          break;
        default:
          final info = await extension.windows.getCurrent_(populate: true);
          final newLeft = IntUtils.max(0, info.left! + 100);
          final newTop = IntUtils.max(0, info.top! + 100);
          final newWidth = IntUtils.min(info.width!, 400);
          final newHeight = IntUtils.min(info.height!, 600);
          await extension.windows.create_(
              url: "${extension.runtime.getURL("index.html")}?context=popup",
              type: ExtentionSessionStorageConst.extentionType,
              width: newWidth,
              height: newHeight,
              top: newTop,
              focused: true,
              left: newLeft);
          break;
      }
      _closeSelf();
    });
  }
}
