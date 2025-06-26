import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:on_chain_bridge/models/models.dart';
import 'package:on_chain_bridge/models/size/models/size.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

void main() async {
  runZonedGuarded(_runApplication, (error, stack) {
    Logg.error("Guarded $error $stack");
  });
}

class APPHTTPConfig extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _configDesktop(APPSetting setting) async {
  if (!PlatformInterface.appPlatform.isDesktop) return;
  await PlatformInterface.instance.desktop.init();
  await PlatformInterface.instance.desktop.waitUntilReadyToShow();
  await PlatformInterface.instance.desktop.setMaximumSize(const WidgetSize(
      width: APPConst.desktopAppWidth, height: APPConst.desktopAppHeight));
  if (setting.size?.devicePixelRatio != null) {
    final size = setting.size!;
    await PlatformInterface.instance.desktop
        .setBounds(pixelRatio: size.devicePixelRatio!, bounds: size);
  }
}

Future<APPSetting> _readSetting() async {
  final config = await PlatformInterface.instance.getConfig();
  final setting = await PlatformInterface.instance
      .readSecure(StorageConst.fullAppSettingStorageId);
  return APPSetting.deserialize(config, hex: setting);
}

Future<void> _runApplication() async {
  HttpOverrides.global = APPHTTPConfig();
  WidgetsFlutterBinding.ensureInitialized();
  final setting = await _readSetting();
  await _configDesktop(setting);
  ThemeController.fromAppSetting(setting);
  runApp(StateRepository(child: MyBTC(setting: setting)));
}

class MyBTC extends StatelessWidget {
  const MyBTC({super.key, required this.setting});
  final APPSetting setting;

  @override
  Widget build(BuildContext context) {
    return StateBuilder<WalletProvider>(
      controller: () => WalletProvider(
          appSetting: setting,
          observer: StateRepository.walletObserver(context),
          navigatorKey: StateRepository.navigatorKey(context)),
      removable: false,
      stateId: StateConst.main,
      repositoryId: StateConst.main,
      builder: (m) {
        return MaterialApp(
            scaffoldMessengerKey: StateRepository.messengerKey(context),
            title: APPConst.name,
            scrollBehavior: AppScrollBehavior(PlatformInterface.appPlatform),
            builder: (context, child) {
              double? maxWidth;
              if (PlatformInterface.appPlatform.isDesktop) {
                maxWidth = APPConst.desktopAppWidth;
              }
              // else if (PlatformInterface.isWeb) {
              //   maxWidth = APPConst.maxViewWidth;
              // }
              ThemeController.updatePrimary(context.theme);
              return MediaQuery(
                  data: context.mediaQuery
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: maxWidth == null
                      ? child!
                      : ConstraintsBoxView(maxWidth: maxWidth, child: child!));
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeController.appTheme,
            darkTheme: ThemeController.appTheme,
            locale: ThemeController.materialLocale,
            onGenerateRoute: PageRouter.onGenerateRoute,
            initialRoute: PageRouter.home,
            navigatorObservers: [StateRepository.walletObserver(context)],
            showSemanticsDebugger: false,
            debugShowCheckedModeBanner: false,
            color: ThemeController.appTheme.colorScheme.primary,
            navigatorKey: StateRepository.navigatorKey(context));
      },
    );
  }
}
