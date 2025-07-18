import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/types.dart';
import 'package:on_chain_wallet/future/wallet/network/aptos/web3/web3.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/web3/permission/permission.dart';
import 'package:on_chain_wallet/future/wallet/network/cosmos/web3/permission/permission.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/web3/web3.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/web3/permission/permission.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/web3/permission/permission.dart';
import 'package:on_chain_wallet/future/wallet/network/sui/web3/permission/permission.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/web3/permission/permission.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/web3/web3.dart';
import 'package:on_chain_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/client_info.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/web3/permission/ethereum_permission_view.dart';
import 'package:on_chain_wallet/future/wallet/web3/types/types.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';

class Web3PermissionUpdateView extends StatelessWidget {
  const Web3PermissionUpdateView(
      {required this.authenticated,
      required this.onPermissionUpdate,
      super.key});
  final Web3UpdatePermissionRequest authenticated;
  final ONWEB3PERMISSIONUPDATED onPermissionUpdate;

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      alignment: Alignment.center,
      padding: WidgetConstant.paddingHorizontal20,
      maxWidth: APPConst.dialogWidth,
      child: ClipRRect(
          borderRadius: WidgetConstant.border25,
          child: PasswordCheckerView(
              appbar: AppBar(
                title: Text('web3_permission'.tr,
                    style: context.textTheme.titleMedium),
              ),
              accsess: WalletAccsessType.unlock,
              onAccsess: (credential, password, network) {
                return Web3ApplicationPermissionView(
                  authenticated: authenticated,
                  onPermissionUpdate: onPermissionUpdate,
                );
              })),
    );
  }
}

class Web3ApplicationPermissionView extends StatelessWidget {
  final Web3UpdatePermissionRequest authenticated;
  final ONWEB3PERMISSIONUPDATED onPermissionUpdate;
  const Web3ApplicationPermissionView(
      {super.key,
      required this.authenticated,
      required this.onPermissionUpdate});

  @override
  Widget build(BuildContext context) {
    return Web3ApplicationPermissionInherited(
        authenticated: authenticated,
        child: _Web3ApplicationPermissionView(
            authenticated: authenticated,
            onPermissionUpdate: onPermissionUpdate));
  }
}

class Web3ApplicationPermissionInherited extends InheritedWidget {
  final Web3UpdatePermissionRequest authenticated;
  const Web3ApplicationPermissionInherited(
      {super.key, required this.authenticated, required super.child});
  static Web3UpdatePermissionRequest of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
            Web3ApplicationPermissionInherited>()!
        .authenticated;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class _Web3ApplicationPermissionView extends StatefulWidget {
  final Web3UpdatePermissionRequest authenticated;
  final ONWEB3PERMISSIONUPDATED onPermissionUpdate;
  const _Web3ApplicationPermissionView(
      {required this.authenticated, required this.onPermissionUpdate});

  @override
  State<_Web3ApplicationPermissionView> createState() =>
      __Web3APPPermissionViewState();
}

class __Web3APPPermissionViewState extends State<_Web3ApplicationPermissionView>
    with SafeState {
  final GlobalKey<FormState> formKey = GlobalKey();
  Web3APPAuthentication get currentApplication => authenticated.authentication;
  Web3UpdatePermissionRequest get authenticated => widget.authenticated;
  Web3ClientInfo? get client => authenticated.client;
  late Web3APPAuthentication application;
  List<Web3AccountAcitvity> activities = [];
  String applicationName = "";
  // NetworkType? get lockedNetwork => widget.web3RequestController?.network;
  NetworkType chainType = NetworkType.ethereum;
  bool showUpdateButton = false;
  int _selectedIndex = 1;
  bool active = true;

  bool chainDisabled(NetworkType network) {
    return authenticated.networkDisabled(network);
  }

  void onChangeName(String v) {
    applicationName = v;
  }

  void onChangeActivation(bool? _) {
    active = !active;
    updateState();
  }

  String? validateApplicationName(String? v) {
    if (v == null || v.trim().length < 3) {
      return "application_name_validator".tr;
    }
    return null;
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  void findInitNetwork() {
    if (authenticated.hasLockedNetwork) {
      chainType = authenticated.lockedNetworks.first;
      final lockedNetworkIndex = Web3Const.supportedWeb3.indexOf(chainType);
      _selectedIndex = lockedNetworkIndex + 1;
    }
  }

  Future<void> onChangePermission() async {
    application = currentApplication.clone();
    applicationName = application.name;
    active = application.active;
    findInitNetwork();
    progressKey.backToIdle();
    showUpdateButton = true;
    updateState();
  }

  Future<void> onUpdateChainPermission() async {
    permissionState[_selectedIndex]?.currentState?.updateApplication();
    Web3APPAuthentication permission = application;
    final requiredChains = authenticated.requiredChainPermissions(permission);
    if (requiredChains.isNotEmpty) {
      final accept = await context.openSliverDialog(
          (context) => DialogTextView(
                text: "web3_dapp_update_permission_alert".tr.replaceOne(
                    requiredChains
                        .map((e) => e.network.networkName)
                        .join(", ")),
                buttonWidget: DialogDoubleButtonView(),
              ),
          'update_permission'.tr);
      if (accept != true) return;
    }
    if (requiredChains.isEmpty) {
      final requiredNetworks =
          authenticated.requiredNetworkPermissions(permission);
      if (requiredNetworks.isNotEmpty) {
        final accept = await context.openSliverDialog(
            (context) => DialogTextView(
                  text: "web3_dapp_update_permission_alert".tr.replaceOne(
                      requiredNetworks.map((e) => e.name).join(", ")),
                  buttonWidget: DialogDoubleButtonView(),
                ),
            'update_permission'.tr);
        if (accept != true) return;
      }
    }

    Web3APPAuthentication currentPermission = currentApplication;

    List<NetworkType> updatedNetwork = [];

    progressKey.progressText("updating_permission".tr);
    showUpdateButton = false;
    updateState();
    for (final i in Web3Const.supportedWeb3) {
      final updatePermission = permission.getChain(i);
      final oldPermission = currentPermission.getChain(i);
      if (updatePermission == null) continue;

      if (updatePermission == oldPermission) continue;
      if (!updatePermission.hasAccount) {
        if (oldPermission == null || !oldPermission.hasAccount) continue;
      }
      currentPermission.updateChainAccount(updatePermission.clone());
      updatedNetwork.add(i);
    }
    if (permission.name != applicationName) {
      currentPermission.updateApplicationName(applicationName);
      permission.updateApplicationName(applicationName);
    }
    if (permission.active != active) {
      currentPermission.toggleActive();
      permission.toggleActive();
      updatedNetwork = Web3Const.supportedWeb3.clone();
    }
    final close = await widget.onPermissionUpdate(updatedNetwork);
    showUpdateButton = !close;
    progressKey.success(backToIdle: !close);
    updateState();
  }

  void changeChain(int index) {
    if (index == 0) {
      _selectedIndex = 0;
      updateState();
      return;
    }
    permissionState[_selectedIndex]?.currentState?.updateApplication();
    chainType = Web3Const.supportedWeb3.elementAt(index - 1);
    _selectedIndex = index;
    updateState();
  }

  Future<void> clearActivities() async {
    final application = this.application;
    final r = await context.openSliverDialog<bool>(
        (context) => DialogTextView(
              text: "delete_all_activities_desc2".tr,
              buttonWidget: DialogDoubleButtonView(),
            ),
        'remove_activities'.tr);
    if (r != true) return;

    progressKey.progressText("updating_permission".tr);
    updateState();
    application.clearActivities();
    final update =
        (await context.wallet.wallet.updateWeb3Application(application));
    if (update.hasError) {
      progressKey.errorText(update.error!.tr);
    } else {
      progressKey.success();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async => onChangePermission());
  }

  @override
  void didUpdateWidget(covariant _Web3ApplicationPermissionView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  late final Map<int, GlobalKey<Web3PermissionState>> permissionState = {
    1: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_ethereumm"),
    2: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_tron"),
    3: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_solana"),
    4: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_ton"),
    5: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_stellar"),
    6: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_substrate"),
    7: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_aptos"),
    8: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_sui"),
    9: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_cosmos"),
    10: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_bitcoin"),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: APPAnimatedSwitcher<bool>(
          enable: showUpdateButton,
          duration: APPConst.animationDuraion,
          widgets: {
            true: (context) => FloatingActionButton.extended(
                onPressed: onUpdateChainPermission,
                label: Text("update_permission".tr),
                icon: const Icon(Icons.save)),
            false: (context) => WidgetConstant.sizedBox
          }),
      body: PageProgress(
        backToIdle: APPConst.oneSecoundDuration,
        initialStatus: StreamWidgetStatus.progress,
        key: progressKey,
        child: (context) => Row(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: APPConst.naviationRailWidth),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          useIndicator: true,
                          onDestinationSelected: changeChain,
                          labelType: NavigationRailLabelType.none,
                          destinations: [
                            const NavigationRailDestination(
                                icon: Icon(Icons.settings),
                                label: WidgetConstant.sizedBox),
                            _NavigationRailDestination(
                                image: APPConst.eth,
                                disabled: chainDisabled(NetworkType.ethereum)),
                            _NavigationRailDestination(
                                image: APPConst.trx,
                                disabled: chainDisabled(NetworkType.tron)),
                            _NavigationRailDestination(
                                image: APPConst.sol,
                                disabled: chainDisabled(NetworkType.solana)),
                            _NavigationRailDestination(
                                image: APPConst.ton,
                                disabled: chainDisabled(NetworkType.ton)),
                            _NavigationRailDestination(
                                image: APPConst.stellar,
                                disabled: chainDisabled(NetworkType.stellar)),
                            _NavigationRailDestination(
                                image: APPConst.polkadot,
                                disabled: chainDisabled(NetworkType.substrate)),
                            _NavigationRailDestination(
                                image: APPConst.aptos,
                                disabled: chainDisabled(NetworkType.aptos)),
                            _NavigationRailDestination(
                                image: APPConst.sui,
                                disabled: chainDisabled(NetworkType.sui)),
                            _NavigationRailDestination(
                                image: APPConst.atom,
                                disabled: chainDisabled(NetworkType.cosmos)),
                            _NavigationRailDestination(
                                image: APPConst.btc,
                                disabled: chainDisabled(
                                    NetworkType.bitcoinAndForked)),
                          ],
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                    ),
                  ),
                ),
                TappedTooltipView(
                  tooltipWidget: ToolTipView(
                      padding: WidgetConstant.padding5,
                      tooltipWidget: (context) => ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: APPConst.tooltipConstrainedWidth),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: WidgetConstant.border8),
                              padding: WidgetConstant.padding10,
                              child: Web3ApplicationView(
                                  permission: application, client: client))),
                      child: Padding(
                          padding: WidgetConstant.padding10,
                          child: CircleAPPImageView(application.icon,
                              radius: 20,
                              onError: (c) => const Icon(Icons.broken_image,
                                  size: APPConst.double40)))),
                ),
              ],
            ),
            Expanded(child: _APPPermissionWidget(state: this))
          ],
        ),
      ),
    );
  }
}

class _APPPermissionWidget extends StatelessWidget {
  const _APPPermissionWidget({required this.state});
  final __Web3APPPermissionViewState state;

  @override
  Widget build(BuildContext context) {
    final application = state.application;
    return DefaultTabController(
      length: 2,
      child: CustomScrollView(
        slivers: [
          SliverPinnedHeaderSurface(
              child: ErrorTextContainer(
                  error:
                      application.active ? null : "client_disabled_desc".tr)),
          APPSliverAnimatedSwitcher<int>(
              enable: state._selectedIndex,
              widgets: {
                0: (context) => _APPSettingView(state),
                1: (context) => EthereumWeb3PermissionView(
                    key: state.permissionState[1], application: application),
                2: (context) => TronWeb3PermissionView(
                    key: state.permissionState[2], application: application),
                3: (context) => SolanaWeb3PermissionView(
                    key: state.permissionState[3], application: application),
                4: (context) => TonWeb3PermissionView(
                    key: state.permissionState[4], application: application),
                5: (context) => StellarWeb3PermissionView(
                    key: state.permissionState[5], application: application),
                6: (context) => SubstrateWeb3PermissionView(
                    key: state.permissionState[6], application: application),
                7: (context) => AptosWeb3PermissionView(
                    key: state.permissionState[7], application: application),
                8: (context) => SuiWeb3PermissionView(
                    key: state.permissionState[8], application: application),
                9: (context) => CosmosWeb3PermissionView(
                    key: state.permissionState[9], application: application),
                10: (context) => BitcoinWeb3PermissionView(
                    key: state.permissionState[10], application: application)
              }),
          WidgetConstant.sliverPaddingVertial40,
        ],
      ),
    );
  }
}

class _APPSettingView extends StatelessWidget {
  const _APPSettingView(this.state);
  final __Web3APPPermissionViewState state;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: WidgetConstant.padding20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Web3ApplicationView(
                permission: state.application, client: state.client),
            WidgetConstant.height20,
            Text("application_name".tr, style: context.textTheme.titleMedium),
            Text("edit_application_name_desc".tr),
            WidgetConstant.height8,
            AppTextField(
                label: "application_name".tr,
                onChanged: state.onChangeName,
                validator: state.validateApplicationName,
                hint: "application_name".tr,
                initialValue: state.applicationName),
            ConditionalWidget(
                enable: state.application.protocol.isInjected,
                onActive: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetConstant.height20,
                          AppSwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text("web3_activation".tr,
                                  style: context.textTheme.titleMedium),
                              subtitle: Text("web3_activation_desc".tr),
                              maxLine: 3,
                              value: state.active,
                              onChanged: state.onChangeActivation),
                        ])),
            AppListTile(
              contentPadding: EdgeInsets.zero,
              onTap: state.clearActivities,
              title: Text("remove_activities".tr,
                  style: context.textTheme.titleMedium),
              subtitle: Text("delete_all_activities_desc".tr),
              trailing: Icon(Icons.delete_forever, color: context.colors.error),
            )
          ],
        ),
      ),
    );
  }
}

class Web3ActivityViewItem {
  final String name;
  final Web3AccountAcitvity activity;
  final ReceiptAddress? address;
  final String? url;
  const Web3ActivityViewItem({
    required this.name,
    required this.activity,
    required this.url,
    this.address,
  });
}

mixin Web3PermissionState<
    T extends StatefulWidget,
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    ADDRESS extends NETWORKCHAINACCOUNT<NETWORKADDRESS>,
    CHAINACCOUT extends Web3ChainAccount<NETWORKADDRESS>,
    WEB3CHAIN extends Web3Chain<NETWORKADDRESS, CHAIN, ADDRESS, CHAINACCOUT,
        WalletNetwork>> on SafeState<T> {
  List<DropdownMenuItem<CHAIN>> menuItems = [];
  WEB3CHAIN createNewChainPermission();
  CHAINACCOUT createNewAccountPermission(ADDRESS address, bool defaultAddress);
  WEB3CHAIN getPermission() {
    final WEB3CHAIN newPermission = createNewChainPermission();
    final List<CHAINACCOUT> accounts = [];
    for (final i in permissions.entries) {
      if (i.value.isEmpty) continue;
      final defaultAddresses = i.value.where((e) => e.defaultAddress);
      if (defaultAddresses.isEmpty) {
        i.value.first.changeDefault(true);
      } else if (defaultAddresses.length > 1) {
        for (final e in i.value) {
          e.changeDefault(false);
        }
        i.value.first.changeDefault(true);
      }
      accounts.addAll(i.value);
    }
    newPermission.updateChainAccount(accounts);
    return newPermission;
  }

  late final WEB3CHAIN permission;
  late final List<CHAIN> chains;
  Map<CHAIN, List<CHAINACCOUT>> permissions = {};
  late CHAIN chain;
  List<CHAINACCOUT> get chainPermission => permissions[chain]!;
  List<Web3ActivityViewItem> activities = [];
  Web3APPAuthentication get application;
  NetworkType get type;

  late Web3UpdatePermissionRequest authenticated;
  bool chainDisabled(CHAIN chain) {
    return authenticated.chainDisabled(chain);
  }

  void updateActivities() {
    activities = application.activities
        .where((e) => e.id == chain.network.value)
        .map((e) {
      return Web3ActivityViewItem(
          activity: e,
          address: e.address == null
              ? null
              : chain.getReceiptAddress(e.address!) ??
                  ReceiptAddress(view: e.address!, networkAddress: e),
          name: e.method.camelCase,
          url: e.path);
    }).toList();
  }

  void onChangeDefaultPermission(CHAINACCOUT? address) {
    if (address == null) return;
    if (address.defaultAddress) return;
    for (final e in chainPermission) {
      e.changeDefault(false);
    }
    address.changeDefault(true);
    updateState();
  }

  CHAINACCOUT? hasPermission(ADDRESS address) {
    return chainPermission.firstWhereOrNull((e) =>
        e.address == address.networkAddress && e.keyIndex == address.keyIndex);
  }

  void addAccount(ADDRESS address) {
    final exists = hasPermission(address);
    if (exists != null) {
      chainPermission.remove(exists);
    } else {
      final newPrimission =
          createNewAccountPermission(address, chainPermission.isEmpty);
      chainPermission.add(newPrimission);
    }
    if (chainPermission.isNotEmpty &&
        !chainPermission.any((e) => e.defaultAddress)) {
      chainPermission[0].changeDefault(true);
    }

    updateState();
  }

  void onChangeChain(CHAIN? updateChain) {
    chain = updateChain ?? chain;
    updateActivities();
    updateState();
  }

  void updateApplication() {
    final permission = getPermission();
    application.updateChainAccount(permission);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    authenticated = Web3ApplicationPermissionInherited.of(context);
    permission = application.getChainFromNetworkType<WEB3CHAIN>(type,
        allowDisable: true);
    final wallet = context.wallet;
    chains = wallet.wallet.getChains().whereType<CHAIN>().toList();
    menuItems = chains.map((e) {
      return _ChainDropDownItems(
          chain: e, disabled: authenticated.chainDisabled(e));
    }).toList();
    final chain = permission.getCurrentPermissionChain(chains, null);
    if (authenticated.chainDisabled(chain)) {
      this.chain = authenticated.lockedChains.whereType<CHAIN>().first;
    } else {
      this.chain = chain;
    }
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    updateActivities();
  }
}

class _NavigationRailDestination extends NavigationRailDestination {
  _NavigationRailDestination({required APPImage image, required super.disabled})
      : super(
            label: WidgetConstant.sizedBox,
            icon: Opacity(
                opacity: disabled ? 0.3 : 1,
                child: CircleAssetsImageView(image, radius: 15)));
}

class _ChainDropDownItems<CHAIN extends Chain> extends DropdownMenuItem<CHAIN> {
  _ChainDropDownItems({required CHAIN chain, required bool disabled})
      : super(
            child: _ChainDropDownItemWidget(chain: chain, disabled: disabled),
            enabled: !disabled,
            value: chain);
}

class _ChainDropDownItemWidget extends StatelessWidget {
  final Chain chain;
  final bool disabled;
  const _ChainDropDownItemWidget({required this.chain, required this.disabled})
      : super();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? APPConst.disabledOpacity : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAPPImageView(chain.network.token.assetLogo, radius: 15),
          WidgetConstant.width8,
          Flexible(
            child: OneLineTextWidget(chain.network.token.name,
                style: context.textTheme.labelLarge),
          )
        ],
      ),
    );
  }
}
