import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart' show Chain, WalletNetwork;
import 'package:on_chain_wallet/crypto/worker.dart';

typedef _OnGenerateDerivation = Future<AddressDerivationIndex?> Function();

class SetupDerivationModeView extends StatefulWidget {
  final CryptoCoins coin;
  final List<CryptoCoins> networkCoins;
  final Chain chainAccout;
  final AddressDerivationIndex? defaultDerivation;
  final Widget? title;
  final List<EncryptedCustomKey> customKeys;
  final SeedTypes seedGenerationType;
  const SetupDerivationModeView(
      {super.key,
      required this.coin,
      required this.chainAccout,
      required this.customKeys,
      this.networkCoins = const [],
      this.defaultDerivation,
      this.title,
      required this.seedGenerationType});

  @override
  State<SetupDerivationModeView> createState() =>
      _SetupDerivationModeView2State();
}

class _SetupDerivationModeView2State extends State<SetupDerivationModeView>
    with SafeState {
  EncryptedCustomKey? selectedCustomKey;
  bool get allowDerivation => !isImportedKey;
  bool get isImportedKey => selectedCustomKey != null;
  WalletNetwork get network => chainAccount.network;
  Chain get chainAccount => widget.chainAccout;
  late CryptoCoins coin = widget.coin;
  late final bool useByronLegacyDeriavation =
      coin.proposal == CustomProposal.cip0019;

  List<EncryptedCustomKey> get customKeys => widget.customKeys;
  bool get derivationStandard => customKeyIndex == null;
  AddressDerivationIndex? customKeyIndex;

  final generateAddressKey = GlobalKey();

  AddressDerivationIndex derivationkey(CryptoCoins coin) {
    if (selectedCustomKey != null) {
      assert(customKeyIndex == null, "must be null.");
      final keyIndex = switch (coin.proposal) {
        SubstratePropoosal.substrate =>
          SubstrateAddressIndex(currencyCoin: coin as SubstrateCoins),
        _ => Bip32AddressIndex(
            currencyCoin: coin, seedGeneration: widget.seedGenerationType)
      };
      return keyIndex.asImportedKey(selectedCustomKey!.id);
    }
    return customKeyIndex ?? nextDerivation;
  }

  AddressDerivationIndex get nextDerivation {
    if (widget.defaultDerivation != null) {
      return widget.defaultDerivation!;
    }
    final nextDerive = chainAccount.nextDerive(coin, widget.seedGenerationType);
    return nextDerive;
  }

  void onChangeCustomKey(EncryptedCustomKey? newSelected) {
    if (newSelected == null) {
      selectedCustomKey = null;
      coin = widget.coin;
    } else {
      bool canUseKey = false;
      coin = widget.coin;

      if (newSelected.coin.conf.type == coin.conf.type) {
        selectedCustomKey = newSelected;
        canUseKey = true;
      } else {
        CryptoCoins? findCoin = MethodUtils.nullOnException(() =>
            widget.networkCoins.firstWhere(
                (element) => element.conf.type == newSelected.coin.conf.type));
        findCoin ??= coin;
        if (newSelected.coin.conf.type == findCoin.conf.type) {
          selectedCustomKey = newSelected;
          coin = findCoin;
          canUseKey = true;
        }
      }
      if (canUseKey) {
        customKeyIndex = null;
      } else {
        context.showAlert("unsuported_key".tr);
      }
    }
    updateState();
  }

  void onChangeDerivation(_OnGenerateDerivation onGenerateDerivation) async {
    if (derivationStandard) {
      customKeyIndex = await onGenerateDerivation();
    } else {
      customKeyIndex = null;
    }
    updateState();
  }

  void onSubmit() {
    final key = derivationkey(coin);
    context.pop(key);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async {
      generateAddressKey.ensureKeyVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AlertTextContainer(
            message: "custom_key_derivation_desc".tr, enableTap: false),
        WidgetConstant.height20,
        Text("derivation_path".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        // APPAnimatedSwitcher(enable: enable, widgets: widgets),
        ContainerWithBorder(
          onRemove: allowDerivation
              ? () {
                  onChangeDerivation(
                    () async {
                      if (useByronLegacyDeriavation) {
                        return context.openSliverBottomSheet<Bip32AddressIndex>(
                            "key_derivation".tr,
                            child: ByronLegacyKeyDerivationView(
                                coin: coin, curve: coin.conf.type));
                      }
                      return context.openMaxExtendSliverBottomSheet<
                              AddressDerivationIndex>("key_derivation".tr,
                          child: Bip32KeyDerivationView(
                              coin: coin,
                              curve: coin.conf.type,
                              network: network,
                              defaultPath: nextDerivation.hdPath,
                              seedGeneration: widget.seedGenerationType),
                          centerContent: false);
                    },
                  );
                }
              : null,
          onRemoveIcon:
              ConditionalWidgets<bool>(enable: derivationStandard, widgets: {
            true: (e) =>
                Icon(Icons.edit, color: context.colors.onPrimaryContainer),
            false: (e) => Icon(Icons.remove_circle,
                color: context.colors.onPrimaryContainer)
          }),
          child: APPAnimatedSwitcher(
              width: double.infinity,
              enable: isImportedKey,
              widgets: {
                true: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("non_derivation".tr,
                            style: context.textTheme.labelLarge),
                        Text("import_key_derivation_desc2".tr),
                        ErrorTextContainer(
                            error: "key_derivation_disabled_desc".tr,
                            showErrorIcon: false)
                      ],
                    ),
                false: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            derivationStandard
                                ? "standard_derivation".tr
                                : "custom_derivation".tr,
                            style: context.textTheme.labelLarge),
                        AddressDrivationInfo(customKeyIndex ?? nextDerivation)
                      ],
                    )
              }),
        ),
        WidgetConstant.height20,
        Text(
          "select_creation_type".tr,
          style: context.textTheme.titleMedium,
        ),
        Text("generate_from_hd_wallet".tr),
        WidgetConstant.height8,
        RadioListTile<EncryptedCustomKey?>(
            value: null,
            groupValue: selectedCustomKey,
            onChanged: onChangeCustomKey,
            title: Text("hd_wallet".tr),
            subtitle: Text("generate_from_hd_wallet".tr)),
        Column(
          children: List.generate(customKeys.length, (index) {
            final key = customKeys[index];

            return RadioListTile(
              value: key,
              groupValue: selectedCustomKey,
              onChanged: onChangeCustomKey,
              title: OneLineTextWidget(key.name ?? key.publicKey),
              subtitle:
                  Text("imported_at".tr.replaceOne(key.created.toString())),
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                key: generateAddressKey,
                padding: WidgetConstant.paddingVertical40,
                onPressed: onSubmit,
                child: Text("generate_address".tr))
          ],
        )
      ],
    );
  }
}
