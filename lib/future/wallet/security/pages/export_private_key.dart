import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/utils/ripple/ripple.dart';
import 'package:on_chain_wallet/future/tools/secure_state/secure_state.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/address_details.dart';
import 'package:on_chain_wallet/future/wallet/security/security.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/crypto/keys/keys.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain/sui/sui.dart';
import 'package:on_chain/aptos/aptos.dart';

class AccountPrivteKeyView extends StatelessWidget {
  const AccountPrivteKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    ChainAccount? account;
    EncryptedCustomKey? customKey;
    String? password;
    final args = context.getDynamicArgs();
    if (args is ChainAccount) {
      account = args;
    } else {
      args as (EncryptedCustomKey, String);
      customKey = args.$1;
      password = args.$2;
    }

    return PasswordCheckerView(
        accsess: WalletAccsessType.extendedKey,
        account: account,
        password: password,
        importedKey: customKey,
        onAccsess: (crendential, password, network) {
          return _AccountPrivateKeyView(
              keys: crendential.whereType<CryptoPrivateKeyData>().toList(),
              password: password,
              account: account,
              network: wallet.wallet.network,
              customKey: customKey);
        },
        title: "export_private_key".tr,
        subtitle: PageTitleSubtitle(
            title: "private_key".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("export_private_key_desc".tr),
                WidgetConstant.height8,
                Text("enter_wallet_password_to_continue".tr),
              ],
            )));
  }
}

class _AccountPrivateKeyView extends StatefulWidget {
  const _AccountPrivateKeyView({
    required this.keys,
    required this.password,
    required this.account,
    required this.network,
    required this.customKey,
  });
  final List<CryptoPrivateKeyData> keys;
  final String password;
  final ChainAccount? account;
  final EncryptedCustomKey? customKey;
  final WalletNetwork network;
  @override
  State<_AccountPrivateKeyView> createState() => _AccountPrivateKeyViewState();
}

class _AccountPrivateKeyViewState extends State<_AccountPrivateKeyView>
    with SafeState<_AccountPrivateKeyView>, SecureState {
  List<PrivateKeysView> keys = [];
  WalletNetwork get network => widget.network;
  late PrivateKeysView key;
  bool hasMultipleKey = false;
  String? get keyName => widget.customKey?.name;

  void onChangeKey(PrivateKeysView? changeKey) {
    if (key == changeKey || changeKey == null) return;
    key = changeKey;
    init();
    updateState();
  }

  PrivateKeysView toNetworkKeyFormat(PrivateKeysView key) {
    switch (network.type) {
      case NetworkType.xrpl:
        return key.copyWith(
            inNetworkStyle: MethodUtils.nullOnException(() =>
                RippleUtils.toRipplePrivateKey(key.privateKey, key.curve)));
      case NetworkType.sui:
        return key.copyWith(
            inNetworkStyle: MethodUtils.nullOnException(() =>
                SuiCryptoUtils.encodeSuiSecretKey(key.privateKeyBytes(),
                    type: key.curve)));
      case NetworkType.aptos:
        return key.copyWith(
            inNetworkStyle: MethodUtils.nullOnException(() =>
                AptosCryptoUtils.encodeAptosPrivateKey(key.privateKeyBytes(),
                    type: key.curve)));
      default:
        return key;
    }
  }

  void init() {
    keys = widget.keys.map((e) => toNetworkKeyFormat(e.toViewKey)).toList();
    key = keys.first;
    hasMultipleKey = keys.length > 1;
  }

  @override
  void onInitOnce() {
    init();
    super.onInitOnce();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PageTitleSubtitle(
                    title: "private_key".tr,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text("export_private_key_desc".tr)],
                    )),
                if (hasMultipleKey) ...[
                  Text("private_keys".tr, style: context.textTheme.titleMedium),
                  Text("switch_between_keys".tr),
                  WidgetConstant.height8,
                  AppDropDownBottom(
                      onChanged: onChangeKey,
                      items: {for (final i in keys) i: Text(i.keyName.tr)},
                      hint: "key_name".tr,
                      value: key),
                  WidgetConstant.height20,
                ],
                if (widget.account != null && !hasMultipleKey) ...[
                  Text("address_details".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: CopyableTextWidget(
                      text: widget.account!.address.toAddress,
                      widget: AddressDetailsView(
                          address: widget.account!,
                          color: context.onPrimaryContainer),
                    ),
                  ),
                  WidgetConstant.height20,
                ],
                if (keyName != null) ...[
                  Text("key_name".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      child: Text(keyName ?? "",
                          style: context.onPrimaryTextTheme.bodyMedium)),
                  WidgetConstant.height20,
                ],
                AnimatedSwitcher(
                  duration: APPConst.animationDuraion,
                  child: _KeysView(
                      privateKey: key, state: this, key: ValueKey(key)),
                ),
                WidgetConstant.height20
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KeysView extends StatelessWidget {
  final PrivateKeysView privateKey;
  const _KeysView({required this.privateKey, required this.state, super.key});
  final _AccountPrivateKeyViewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HiddenKeyView(
            title: "private_key".tr,
            subtitle: privateKey.curve.name.camelCase,
            keyData: privateKey.privateKey,
            password: state.widget.password,
            type: WalletBackupTypes.privatekey),
        if (privateKey.extendKey != null) ...[
          WidgetConstant.height20,
          _HiddenKeyView(
              title: "extended_private_key".tr,
              keyData: privateKey.extendKey!,
              password: state.widget.password,
              type: WalletBackupTypes.extendedKey),
        ],
        if (privateKey.wif != null) ...[
          WidgetConstant.height20,
          _HiddenKeyView(
              title: "wif".tr,
              keyData: privateKey.wif!,
              password: state.widget.password,
              type: WalletBackupTypes.wif),
        ],
        if (privateKey.inNetworkStyle != null) ...[
          WidgetConstant.height20,
          _HiddenKeyView(
            title: "n_style".tr.replaceOne(state.network.type.name),
            keyData: privateKey.inNetworkStyle!,
          ),
        ],
        ConditionalWidget(
            onActive: (context) =>
                _MoneroKeysView(privateKey: privateKey.cast(), state: state),
            enable: privateKey.keyType == CryptoPrivateKeyDataType.monero)
      ],
    );
  }
}

class _MoneroKeysView extends StatelessWidget {
  final MoneroPrivateKeysView privateKey;
  const _MoneroKeysView({required this.privateKey, required this.state});
  final _AccountPrivateKeyViewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        _HiddenKeyView(
            title: "spend_private_key".tr,
            keyData: privateKey.spendPrivateKey,
            password: state.widget.password,
            type: WalletBackupTypes.privatekey),
        WidgetConstant.height20,
        _HiddenKeyView(
            title: "view_private_key".tr,
            keyData: privateKey.viewPrivateKey,
            password: state.widget.password,
            type: WalletBackupTypes.privatekey),
      ],
    );
  }
}

class _HiddenKeyView extends StatelessWidget {
  final String title;
  final String keyData;
  final String? subtitle;
  final WalletBackupTypes? type;
  final String? password;
  const _HiddenKeyView(
      {required this.title,
      required this.keyData,
      this.subtitle,
      this.type,
      this.password});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleMedium),
        if (subtitle != null) Text(subtitle!),
        WidgetConstant.height8,
        SecureContentView(
          content: keyData,
          backupType: type,
          password: password,
        ),
      ],
    );
  }
}
