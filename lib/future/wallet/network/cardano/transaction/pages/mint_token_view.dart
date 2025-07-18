import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class CardanoMintTokenView extends StatefulWidget {
  final ADAChain account;
  const CardanoMintTokenView(this.account, {super.key});
  @override
  State<CardanoMintTokenView> createState() => _CardanoMintTokenViewState();
}

class _CardanoMintTokenViewState extends State<CardanoMintTokenView>
    with SafeState {
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "CardanoMintTokenView");
  final GlobalKey<FormState> formKey =
      GlobalKey(debugLabel: "CardanoMintTokenView");
  ReceiptAddress<ADAAddress>? owmnerReceiptView;
  ICardanoAddress? ownerAccount;

  bool fieldsIsReady = false;

  void checkFildsReady() {
    fieldsIsReady = !totalSupply.isZero &&
        owmnerReceiptView != null &&
        (assetName.trim().isNotEmpty);
    updateState();
  }

  String? validateShellyAddress(ICardanoAddress addr) {
    if (addr.networkAddress.isByron || addr.networkAddress.isRewardAddress) {
      return "byron_reward_does_not_support_minting_token".tr;
    }
    return null;
  }

  void setPolicyId(ICardanoAddress? addr) {
    if (addr == null) return;
    final err = validateShellyAddress(addr);
    if (err != null) {
      context.showAlert(err);
      return;
    }
    ownerAccount = addr;
    owmnerReceiptView = ReceiptAddress(
        view: addr.networkAddress.address,
        type: addr.type,
        networkAddress: addr.networkAddress,
        account: addr);
    checkFildsReady();
  }

  String assetName = "";
  BigRational totalSupply = BigRational.zero;
  String totalSupplyStr = "";

  void setSupply(BigRational? supply) {
    if (supply == null ||
        supply.isNegative ||
        supply.isZero ||
        supply > BlockchainConst.maxSupply) {
      return;
    }
    totalSupply = supply;
    totalSupplyStr = totalSupply.toDecimal();
    checkFildsReady();
  }

  void onChangeAssetsName(String v) {
    assetName = v;
    final isReady = !totalSupply.isZero &&
        owmnerReceiptView != null &&
        (assetName.trim().isNotEmpty);
    if (isReady != fieldsIsReady) {
      checkFildsReady();
    }
  }

  String? validator(String? v) {
    final int length = v?.length ?? 0;
    if (length < 1) {
      return "ada_asset_name_validator".tr;
    }
    return null;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  ADAMintInfo buildAsset() {
    return ADAMintInfo(
        owner: ownerAccount!.networkAddress,
        pubKeyBytes: ownerAccount!.addressDetails.publicKey,
        assets:
            Assets({AssetName.fromString(assetName): totalSupply.toBigInt()}),
        script: ownerAccount!.addressDetails.toNativeScript());
  }

  void onSubmit() {
    if (!formKey.ready()) return;
    checkFildsReady();
    if (!fieldsIsReady) return;
    context.pop(buildAsset());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PageTitleSubtitle(
          //     title: "create_a_new_token".tr,
          //     body: Text("ada_create_new_token_desc".tr)),
          // WidgetConstant.height20,
          ReceiptAddressView(
            title: "owner".tr,
            subtitle: "owner_of_token".tr,
            onTap: () {
              context
                  .selectOrSwitchAccount<ICardanoAddress>(
                      account: widget.account,
                      showMultiSig: true,
                      filter: validateShellyAddress)
                  .then(setPolicyId);
            },
            address: owmnerReceiptView,
          ),
          WidgetConstant.height20,
          Text("asset_name".tr, style: context.textTheme.titleMedium),
          Text("name_of_token".tr),
          WidgetConstant.height8,
          AppTextField(
              label: "asset_name".tr,
              initialValue: assetName,
              validator: validator,
              suffixIcon: PasteTextIcon(
                onPaste: onPaste,
                isSensitive: false,
              ),
              onChanged: onChangeAssetsName,
              key: textFieldKey),
          WidgetConstant.height20,
          Text("total_supply".tr, style: context.textTheme.titleMedium),
          Text("total_supply_desc".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemoveIcon: AddOrEditIconWidget(totalSupply.isZero),
            validate: !totalSupply.isZero,
            child: Text(
              totalSupply.isZero
                  ? "tap_to_input_total_supply".tr
                  : totalSupplyStr,
              style: context.onPrimaryTextTheme.bodyMedium,
            ),
            onRemove: () {
              context
                  .openSliverBottomSheet<BigRational>(
                    "create_a_new_token".tr,
                    child: NumberWriteView(
                      allowDecimal: false,
                      max: BlockchainConst.maxSupply,
                      min: BigRational.one,
                      allowSign: false,
                      title: PageTitleSubtitle(
                          title: "total_supply".tr,
                          body: Text("total_supply_desc".tr)),
                      buttonText: "setup_supply".tr,
                      label: "create_a_new_token".tr,
                    ),
                  )
                  .then(setSupply);
            },
          ),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                onPressed: fieldsIsReady ? onSubmit : null,
                child: Text("setup_mint".tr),
              )
            ],
          ),
        ],
      ),
    );
  }
}
