import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/wallet/setting/color_selector.dart';
import 'package:on_chain_wallet/future/wallet/start/pages/drawer_view.dart';
import 'package:on_chain_wallet/future/wallet/start/pages/platform_widgets/widgets.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/models/wallet/hd_wallet.dart';

class WalletLoginPageView extends StatefulWidget {
  const WalletLoginPageView({super.key});

  @override
  State<WalletLoginPageView> createState() => _WalletLoginPageViewState();
}

class _WalletLoginPageViewState extends State<WalletLoginPageView>
    with SafeState<WalletLoginPageView> {
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(debugLabel: "WalletLoginPageView");
  final GlobalKey<StreamWidgetState> buttonKey =
      GlobalKey<StreamWidgetState>(debugLabel: "WalletLoginPageView_1");
  late WalletProvider wallet;
  String? _error;
  String password = "";
  void onChange(String v) {
    password = v;
    resetError();
  }

  void resetError() {
    if (_error != null) {
      updateState(() {
        _error = null;
      });
    }
  }

  void unlock() async {
    if (!formKey.ready()) return;
    buttonKey.process();
    final login = await wallet.wallet.login(password);
    buttonKey.fromMethodResult(login);
    _error = login.error?.tr;
    updateState(() {});
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    wallet = context.watch<WalletProvider>(StateConst.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        title: Text(wallet.wallet.wallet.name),
        actions: [
          WidgetConstant.width8,
          BrightnessToggleIcon(
              onToggleBrightness: () => wallet.toggleBrightness(),
              brightness: ThemeController.appTheme.brightness),
          ColorSelectorIconView(
            (p0) {
              if (p0 == null) return;
              return wallet.changeColor(p0);
            },
          ),
          appbarWidgets(false),
        ],
        leading: IconButton(
            onPressed: () {
              context
                  .openSliverDialog<HDWallet>(
                      (c) => SwitchWalletView(
                            wallets: wallet.wallet.wallets,
                            selectedWallet: wallet.wallet.wallet,
                          ),
                      "switch_wallets".tr,
                      content: (c) => [
                            IconButton(
                                onPressed: () {
                                  context.offTo(PageRouter.createWallet);
                                },
                                icon: const Icon(Icons.add))
                          ])
                  .then((e) {
                if (e == null) return;
                wallet.wallet.switchWallet(e);
              });
            },
            icon: const Icon(Icons.account_balance_wallet_rounded)),
      ),
      body: UnfocusableChild(
        child: ConstraintsBoxView(
          padding: WidgetConstant.padding20,
          alignment: Alignment.center,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CircleAssetsImageView(APPConst.logo),
                  WidgetConstant.height20,
                  AppTextField(
                    obscureText: true,
                    onChanged: onChange,
                    label: "password".tr,
                    disableContextMenu: true,
                    error: _error,
                    validator: (v) {
                      if (StrUtils.isStrongPassword(v)) {
                        return null;
                      }
                      return "password_validator".tr;
                    },
                  ),
                  ButtonProgress(
                    padding: WidgetConstant.paddingVertical40,
                    child: (context) => FixedElevatedButton(
                      onPressed: unlock,
                      child: Text("unlock".tr),
                    ),
                    backToIdle: APPConst.oneSecoundDuration,
                    key: buttonKey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
