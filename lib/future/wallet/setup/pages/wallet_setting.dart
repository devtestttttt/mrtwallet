import 'package:flutter/widgets.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/update_wallet_infos.dart';
import 'package:on_chain_wallet/future/wallet/setup/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/setting/setting.dart';
import 'package:on_chain_wallet/wallet/models/wallet/hd_wallet.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class CreateWalletSettingsView extends StatefulWidget {
  const CreateWalletSettingsView(this.wallet, {super.key});
  final HDWallet wallet;

  @override
  State<CreateWalletSettingsView> createState() =>
      _CreateWalletSettingsViewState();
}

class _CreateWalletSettingsViewState extends State<CreateWalletSettingsView>
    with SafeState<CreateWalletSettingsView> {
  late String name = widget.wallet.name;
  late bool reqPassword = widget.wallet.requiredPassword;
  late bool protectWallet = widget.wallet.protectWallet;
  late WalletLockTime locktime = widget.wallet.locktime;
  late List<String> walletIds;
  late SetupWalletController controller;
  void setup(WalletUpdateInfosData walletInfos) async {
    name = walletInfos.name;
    locktime = walletInfos.lockTime;
    reqPassword = walletInfos.requirmentPassword;
    protectWallet = walletInfos.protectWallet;
    await controller.setupHDWallet(walletInfos);
  }

  void onChangeLockTime(WalletLockTime? time) {
    if (time == null || !reqPassword) return;
    locktime = time;
  }

  void _init() {
    final walletProvider = context.watch<WalletProvider>(StateConst.main);
    walletIds = walletProvider.wallet.wallets.map((e) => e.name).toList();
    controller = context.watch<SetupWalletController>(StateConst.setup);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: controller.progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => UpdateWalletInfosWidget(
          name: name,
          locktime: locktime,
          requrmentPassword: reqPassword,
          exitsIds: walletIds,
          onUpdate: (update) => setup(update),
          protectWallet: protectWallet),
    );
  }
}
