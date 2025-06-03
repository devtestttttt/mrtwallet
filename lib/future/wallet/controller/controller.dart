import 'dart:async';
import 'package:flutter/material.dart';
import 'package:on_chain_bridge/models/size/models/rect.dart';
import 'package:on_chain_wallet/app/core.dart'
    show APPSetting, APPWalletSetting, StateConst, StorageConst;
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/core/observer.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/app/models/models/currencies.dart';
import 'package:on_chain_wallet/future/tools/frame_tracker/desktop_frame_tracker.dart';
import 'package:on_chain_wallet/future/wallet/controller/tabs/tabs.dart';
import 'package:on_chain_wallet/repository/repository.dart';
import 'wallet/ui_wallet.dart';
import 'wallet/cross/cross.dart'
    if (dart.library.js_interop) 'wallet/cross/web.dart'
    if (dart.library.io) 'wallet/cross/io.dart';

enum APPStatusType {
  init,
  ready,
  failed;
}

class APPStatus {
  final APPStatusType status;
  final String? error;
  const APPStatus._({required this.status, this.error});
  factory APPStatus.error(String error) {
    return APPStatus._(status: APPStatusType.failed, error: error);
  }
  static const APPStatus init = APPStatus._(status: APPStatusType.init);
  static const APPStatus ready = APPStatus._(status: APPStatusType.ready);
}

class WalletProvider extends StateController
    with
        BaseRepository,
        APPRepository,
        DesktopFrameTracker,
        WalletProviderTabController {
  WalletProvider(
      {required APPSetting appSetting,
      required this.observer,
      required GlobalKey<NavigatorState> navigatorKey})
      : _appSetting = appSetting,
        wallet = uiWallet(navigatorKey, appSetting.config.storageVersion);

  APPStatus _status = APPStatus.init;

  APPStatus get appStatus => _status;

  ThemeData get theme => ThemeController.appTheme;
  @override
  GlobalKey<NavigatorState>? get navigatorKey => wallet.navigatorKey;
  @override
  final WalletRouteObserver observer;
  @override
  final UIWallet wallet;
  APPSetting _appSetting;
  @override
  APPSetting get appSetting => _appSetting;

  void toggleBrightness() {
    ThemeController.toggleBrightness();
    notify(StateConst.main);
    notify();
    _appSetting = _appSetting.copyWith(
        appBrightness: ThemeController.appBrightness,
        appColor: ThemeController.appColorHex);
    saveAppSetting(_appSetting);
  }

  void changeColor(Color color) {
    ThemeController.changeColor(color);
    notify(StateConst.main);
    _appSetting = _appSetting.copyWith(
        appBrightness: ThemeController.appBrightness,
        appColor: ThemeController.appColorHex);
    saveAppSetting(_appSetting);
  }

  @override
  void updateWalletSetting(APPWalletSetting setting) {
    _appSetting = _appSetting.copyWith(walletSetting: setting);
    saveAppSetting(_appSetting);
  }

  void changeCurrency(Currency? currency) {
    if (currency == null || _appSetting.currency == currency) return;
    wallet.currency.changeCurrency(currency);
    _appSetting = _appSetting.copyWith(currency: currency);
    saveAppSetting(_appSetting);
  }

  Future<void> _initWallet() async {
    final init = await MethodUtils.call(() async {
      wallet.currency.changeCurrency(appSetting.currency);
      return await wallet.init();
    });
    if (init.hasError) {
      _status = APPStatus.error(init.error!.tr);
    } else {
      _status = APPStatus.ready;
    }
    notify();
  }

  @override
  Future<void> onUpdateFrame(WidgetRect rect) async {
    _appSetting = _appSetting.copyWith(size: rect);
    await saveAppSetting(_appSetting);
  }

  @override
  void close() {
    super.close();
    wallet.dispose();
  }

  @override
  void ready() {
    super.ready();
    _initWallet();
  }

  @override
  String get repositoryStorageId => StorageConst.appStorageKeyId;

  @override
  bool get supportWebView => _appSetting.config.supportWebView;
}
