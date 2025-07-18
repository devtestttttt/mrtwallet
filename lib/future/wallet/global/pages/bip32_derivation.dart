import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/bip/ecc/curve/elliptic_curve_types.dart';
import 'package:blockchain_utils/bip/substrate/substrate.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart' show WalletException;
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/crypto/utils/utils.dart';
import 'package:on_chain_wallet/wallet/wallet.dart'
    show BlockchainConst, WalletNetwork;
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

class Bip32KeyDerivationView extends StatefulWidget {
  const Bip32KeyDerivationView(
      {super.key,
      required this.coin,
      required this.curve,
      required this.network,
      required this.defaultPath,
      required this.seedGeneration});
  final CryptoCoins coin;
  final EllipticCurveTypes curve;
  final SeedTypes seedGeneration;
  final WalletNetwork network;
  final String? defaultPath;

  @override
  State<Bip32KeyDerivationView> createState() => _Bip32KeyDerivationViewState();
}

class _Bip32KeyDerivationViewState extends State<Bip32KeyDerivationView>
    with SafeState<Bip32KeyDerivationView> {
  String path = "";
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "_Bip32KeyDerivationViewState_form");
  final GlobalKey<AppTextFieldState> pathTextFieldKey =
      GlobalKey<AppTextFieldState>(
          debugLabel: "_Bip32KeyDerivationViewState_pathTextFieldKey");
  late final bool isSupportNoneHardend;
  late final bool isSubstrate;

  void onSubmit() {
    if (!form.ready()) return;
    AddressDerivationIndex keyIndex;
    if (isSubstrate) {
      keyIndex = SubstrateAddressIndex.fromPath(
          currencyCoin: widget.coin as SubstrateCoins, substratePath: path);
    } else {
      keyIndex = Bip32AddressIndex.fromPath(
          path: path,
          currencyCoin: widget.coin,
          seedGeneration: widget.seedGeneration);
    }

    context.pop(keyIndex);
  }

  void onChangePath(String v) {
    path = v;
  }

  String? _validatorBip32(String? v) {
    if (path.trim().isEmpty) return null;
    try {
      final parse = BlockchainAddressUtils.praseBip32Path(path);
      if (parse.isEmpty) return null;
      if (!isSupportNoneHardend &&
          parse.any((element) => !element.isHardened)) {
        return "ed25519_support_derivation_desc".tr;
      }
      if (parse.length > BlockchainConst.maxBip32LevelIndex) {
        throw WalletException("hd_wallet_path_max_indeqxes"
            .tr
            .replaceOne(BlockchainConst.maxBip32LevelIndex.toString()));
      }
    } catch (e) {
      return "invalid_hd_wallet_derivation_path".tr;
    }
    return null;
  }

  String? _validatorSubstrate(String? v) {
    if (path.trim().isEmpty) return null;
    try {
      BlockchainAddressUtils.praseSubstratePath(path);
      return null;
    } catch (e) {
      return "invalid_substrate_path".tr;
    }
  }

  String? validator(String? v) {
    if (isSubstrate) {
      return _validatorSubstrate(v);
    }
    return _validatorBip32(v);
  }

  void onPaste(String v) {
    pathTextFieldKey.currentState?.updateText(v);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    path = widget.defaultPath ?? "";
    isSubstrate = widget.coin.proposal == SubstratePropoosal.substrate;
    isSupportNoneHardend = widget.curve != EllipticCurveTypes.ed25519;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlertTextContainer(
              message: "custom_key_derivation_desc".tr, enableTap: false),
          WidgetConstant.height20,
          Text("derivation_path".tr, style: context.textTheme.titleMedium),
          if (isSubstrate)
            Text("hd_wallet_substrate_hardened_desc".tr)
          else
            Text("hd_wallet_hardened_desc".tr),
          WidgetConstant.height8,
          AppTextField(
            onChanged: onChangePath,
            initialValue: path,
            suffixIcon: PasteTextIcon(onPaste: onPaste, isSensitive: false),
            validator: validator,
            key: pathTextFieldKey,
            label: "derivation_path".tr,
            hint: "derivation_path".tr,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: onSubmit,
                child: Text("setup_derivation_path".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}
