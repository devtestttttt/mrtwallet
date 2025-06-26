import 'package:blockchain_utils/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/security/security.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class BackupWalletView extends StatelessWidget {
  const BackupWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (crendential, password, network) {
          return _BackupWallet(password: password);
        },
        title: "backup".tr,
        subtitle: PageTitleSubtitle(
            title: "backup_wallet".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("backup_wallet_desc".tr),
                WidgetConstant.height8,
                Text("enter_wallet_password_to_continue".tr),
              ],
            )));
  }
}

class _BackupWallet extends StatefulWidget {
  const _BackupWallet({required this.password});
  final String password;

  @override
  State<_BackupWallet> createState() => _BackupWalletState();
}

class _BackupWalletState extends State<_BackupWallet>
    with SafeState<_BackupWallet> {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  bool setupPassword = false;
  bool usePassphrase = false;
  bool dappPermissions = false;

  List<Chain> appChains = [];
  List<Chain> selectedChains = [];

  bool get hasChainBackup => selectedChains.isNotEmpty;

  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "_ChangePasswordView");

  final FocusNode nextFocus = FocusNode();
  String password = "";
  void onChangePassword(String v) {
    password = v;
  }

  String passphrase = "";

  void onChangePassPhrase(String v) {
    passphrase = v;
  }

  String? passPhraseValidator(String? value) {
    if (value?.isEmpty ?? true) return "passphrase_should_not_be_empty".tr;
    return null;
  }

  String? validator(String? value) {
    if (value == widget.password) {
      return "password_used_before".tr;
    }
    if (StrUtils.isStrongPassword(value)) {
      return null;
    }
    return "weak_password".tr;
  }

  String? confirmForm(String? value) {
    if (value != password) {
      return "p_does_not_match".tr;
    }
    return null;
  }

  void toggleSetupPassword() {
    setupPassword = !setupPassword;
    password = "";
    updateState();
  }

  void toggleDappPermissions() {
    dappPermissions = !dappPermissions;
    updateState();
  }

  void toggleUsePassphrase() {
    usePassphrase = !usePassphrase;
    passphrase = "";
    updateState();
  }

  Future<void> selectChains() async {
    final chains = await context.openDialogPage<List<Chain>>(
      '',
      child: (context) => _SelectBackupChains(
          chains: appChains, selectedChains: selectedChains),
    );
    if (chains == null) return;
    selectedChains = chains;
    updateState();
  }

  Future<void> setupbackup() async {
    if (!form.ready()) return;
    final options = GenerateWalletBackupOptions(
        chains: selectedChains,
        backupDapps: dappPermissions,
        passphrase: usePassphrase ? passphrase : null,
        newPassword: setupPassword ? password : null);
    await context.openSliverDialog(
        (ctx) => GenerateBackupView(
            data: "",
            password: widget.password,
            walletBackupOptions: options,
            type: WalletBackupTypes.walletV3),
        "backup_wallet".tr);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    appChains = context.wallet.wallet.getChains();
    selectedChains = appChains.clone();
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => Center(
        child: Form(
          key: form,
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverConstraintsBoxView(
                padding: WidgetConstant.padding20,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitleSubtitle(
                          title: "backup_wallet".tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("backup_wallet_desc1".tr),
                              AlertTextContainer(
                                message: "generate_backup_desc2".tr,
                                enableTap: false,
                              )
                            ],
                          )),
                      WidgetConstant.height20,
                      Text("backup_options".tr,
                          style: context.textTheme.titleMedium),
                      Text("backup_options_desc".tr),
                      WidgetConstant.height8,
                      AppCheckListTile(
                        value: true,
                        title: Text("mnemonic_seed_hd_wallet_elements".tr),
                        subtitle: Text("encrypted".tr),
                      ),
                      AppCheckListTile(
                        value: hasChainBackup,
                        title: Text("networks_and_addresses".tr),
                        subtitle: Text("non_encrypted".tr),
                        onChanged: (v) {
                          selectChains();
                        },
                      ),
                      AppCheckListTile(
                        value: dappPermissions,
                        title: Text("dapps_permissions".tr),
                        subtitle: Text("non_encrypted".tr),
                        onChanged: (v) {
                          toggleDappPermissions();
                        },
                      ),
                      AppSwitchListTile(
                        value: setupPassword,
                        title: Text("password".tr),
                        subtitle: ConditionalWidget(
                            enable: !setupPassword,
                            onDeactive: (context) =>
                                Text("use_new_password".tr),
                            onActive: (context) =>
                                Text("use_current_wallet_password".tr)),
                        onChanged: (v) {
                          toggleSetupPassword();
                        },
                      ),
                      APPAnimated(
                          isActive: setupPassword,
                          onActive: (context) {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetConstant.height20,
                                  AppTextField(
                                    obscureText: true,
                                    initialValue: password,
                                    onChanged: onChangePassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.go,
                                    disableContextMenu: true,
                                    nextFocus: nextFocus,
                                    validator: validator,
                                    label: "enter_new_password".tr,
                                    helperText: "password_desc".tr,
                                  ),
                                  AppTextField(
                                    obscureText: true,
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                    focusNode: nextFocus,
                                    disableContextMenu: true,
                                    validator: confirmForm,
                                    label: "c_password".tr,
                                  ),
                                ]);
                          },
                          onDeactive: (context) => WidgetConstant.sizedBox),
                      AppSwitchListTile(
                        value: usePassphrase,
                        title: Text("passphrase".tr),
                        subtitle: Text("enter_passphrase_desc".tr),
                        onChanged: (v) {
                          toggleUsePassphrase();
                        },
                      ),
                      AlertTextContainer(
                        message: "enter_passphrase_desc2".tr,
                        enableTap: false,
                      ),
                      APPAnimated(
                          isActive: usePassphrase,
                          onActive: (context) {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetConstant.height20,
                                  AppTextField(
                                      obscureText: true,
                                      initialValue: passphrase,
                                      onChanged: onChangePassPhrase,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      textInputAction: TextInputAction.done,
                                      disableContextMenu: true,
                                      validator: passPhraseValidator,
                                      label: "passphrase".tr),
                                ]);
                          },
                          onDeactive: (context) => WidgetConstant.sizedBox),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: WidgetConstant.paddingVertical20,
                            child: FilledButton.icon(
                                label: Text("create_backup".tr),
                                onPressed: setupbackup,
                                icon: const Icon(Icons.backup)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectBackupChains extends StatefulWidget {
  final List<Chain> chains;
  final List<Chain>? selectedChains;
  const _SelectBackupChains(
      {required this.chains, required this.selectedChains});

  @override
  State<_SelectBackupChains> createState() => _SelectBackupChainsState();
}

class _SelectBackupChainsState extends State<_SelectBackupChains>
    with SafeState<_SelectBackupChains> {
  List<Chain> get chains => widget.chains;
  List<Chain> selectedChains = [];
  bool get allSelected => selectedChains.length == chains.length;

  void toggleSelected(Chain chain) {
    final remove = selectedChains.remove(chain);
    if (!remove) {
      selectedChains.add(chain);
    }
    updateState();
  }

  void selectAll() {
    if (allSelected) {
      selectedChains = [];
    } else {
      selectedChains = chains.clone();
    }
    updateState();
  }

  void setup() {
    context.pop(selectedChains);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    selectedChains = (widget.selectedChains ?? widget.chains).clone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: setup,
        label: Text("setup_chains".tr),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: false,
            title: Text("select_network_for_backup".tr),
            actions: [
              TextButton.icon(
                onPressed: selectAll,
                label: Text("choose_all".tr),
                icon: ConditionalWidget(
                    enable: allSelected,
                    onActive: (context) => Icon(Icons.check_box),
                    onDeactive: (context) =>
                        Icon(Icons.check_box_outline_blank)),
              )
            ],
            pinned: true,
            floating: false,
          ),
          SliverConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            sliver: SliverList.builder(
              itemCount: chains.length,
              itemBuilder: (context, index) {
                final chain = chains[index];
                return ContainerWithBorder(
                  onRemove: () {
                    toggleSelected(chain);
                  },
                  onRemoveWidget: APPCheckBox(
                    ignoring: true,
                    backgroundColor: context.onPrimaryContainer,
                    color: context.primaryContainer,
                    onChanged: (p0) => toggleSelected(chain),
                    value: selectedChains.contains(chain),
                  ),
                  child: Row(
                    children: [
                      CircleTokenImageView(chain.network.token,
                          radius: APPConst.circleRadius12),
                      WidgetConstant.width8,
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(chain.network.type.name,
                                style: context.onPrimaryTextTheme.labelLarge),
                            Text(
                              chain.network.networkName,
                              style: context.onPrimaryTextTheme.bodyMedium,
                            ),
                          ]))
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
