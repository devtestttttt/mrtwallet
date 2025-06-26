import 'package:blockchain_utils/bip/address/xlm_addr.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/worker.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';

class PickFromAccountAssets extends StatefulWidget {
  final StellarAccountResponse accountInfo;
  final StellarChain chain;
  final bool allowNativeAssets;

  const PickFromAccountAssets(
      {required this.accountInfo,
      required this.chain,
      this.allowNativeAssets = true,
      super.key});

  @override
  State<PickFromAccountAssets> createState() => _PickFromAccountAssetsState();
}

class _PickFromAccountAssetsState extends State<PickFromAccountAssets>
    with SafeState<PickFromAccountAssets> {
  List<StellarIssueToken> tokens = [];
  late final natvieAsset = StellarPickedIssueAsset(
      asset: StellarAssetNative(),
      network: widget.chain.network,
      issueToken: null,
      tokenBalance: IntegerBalance.token(
          widget.accountInfo.nativeBalance, widget.chain.network.token));
  List<StellarIssueToken> addressTokens = [];

  @override
  void onInitOnce() {
    super.onInitOnce();
    addressTokens = widget.chain.address.tokens;
    tokens = widget.accountInfo.issueAssetBalances.map((e) {
      return addressTokens.firstWhere(
          (i) =>
              i.assetCode == e.assetCode &&
              i.issuer == e.assetIssuer &&
              i.assetType == e.assetType.assetType,
          orElse: () => e.toIssueToken());
    }).toList();
  }

  void onTapAsset(StellarIssueToken asset) {
    final stellarAsset = asset.toStellarAsset();
    final pickedAsset = StellarPickedIssueAsset(
        asset: stellarAsset,
        network: widget.chain.network,
        issueToken: asset,
        tokenBalance: asset.balance);
    context.pop(pickedAsset);
  }

  void onTapNativeAsset() {
    context.pop(natvieAsset);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.allowNativeAssets) ...[
          ContainerWithBorder(
              onRemove: onTapNativeAsset,
              onRemoveWidget: WidgetConstant.sizedBox,
              child: TokenDetailsWidget(
                token: natvieAsset.token,
                balance: natvieAsset.tokenBalance,
                color: context.colors.onPrimaryContainer,
                radius: APPConst.circleRadius25,
              )),
          if (tokens.isNotEmpty) WidgetConstant.divider,
        ],
        if (!widget.allowNativeAssets && tokens.isEmpty) ...[
          const Icon(Icons.hourglass_empty, size: APPConst.double80),
          WidgetConstant.height8,
          Text("assets_not_found_in_account".tr),
        ],
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final asset = tokens[index];
              return TokenDetailsView(
                  token: asset,
                  onSelect: () => onTapAsset(asset),
                  onSelectWidget: WidgetConstant.sizedBox,
                  radius: APPConst.circleRadius25);
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: tokens.length)
      ],
    );
  }
}

class StellarPickAssetView extends StatefulWidget {
  final StellarChain chain;
  const StellarPickAssetView({required this.chain, super.key});

  @override
  State<StellarPickAssetView> createState() => _StellarPickAssetViewState();
}

class _StellarPickAssetViewState extends State<StellarPickAssetView>
    with SafeState {
  final GlobalKey<FormState> formKey = GlobalKey();
  late final List<AssetType> supportedAssets = [
    AssetType.creditAlphanum12,
    AssetType.creditAlphanum4,
    AssetType.poolShare
  ];

  String? assetName;

  late final Map<AssetType, Widget> dropDownWidget = {
    for (final i in supportedAssets) i: Text(i.name)
  };
  AssetType assetType = AssetType.creditAlphanum12;
  ReceiptAddress<StellarAddress>? issueAddress;

  void onSetIssueAddress(ReceiptAddress<StellarAddress>? issueAddress) {
    if (issueAddress == null) return;
    if (issueAddress.networkAddress.type == XlmAddrTypes.contract) {
      context.showAlert("asset_issue_address_validator".tr);
      return;
    }
    this.issueAddress = issueAddress;
    _checkIsReady();
    updateState();
  }

  void onChangeAssetType(AssetType? assetType) {
    this.assetType = assetType ?? this.assetType;
    _checkIsReady();
    updateState();
  }

  bool _isReady = false;
  void _checkIsReady() {
    _isReady = assetType == AssetType.native ||
        assetType == AssetType.poolShare ||
        issueAddress != null;
  }

  bool get isReady => _isReady;

  void onChangeAssetName(String v) {
    assetName = v;
  }

  void setup() {
    if (!formKey.ready()) return;
    if (!isReady) return;
    final StellarAsset? asset = StellarUtils.tryToAssets(assetType,
        code: assetName, issuer: issueAddress?.networkAddress.toPublicKey());
    if (asset == null) return;
    final pickedAsset = StellarPickedIssueAsset(
        asset: asset, network: widget.chain.network, issueToken: null);
    context.pop(pickedAsset);
  }

  String? validateAssetName(String? v) {
    if (assetType == AssetType.native) {
      return null;
    }
    final isValid =
        StellarHelper.isValidIssueAsset(code: v ?? '', type: assetType);
    if (isValid) {
      return null;
    }
    switch (assetType) {
      case AssetType.creditAlphanum4:
        return "stellar_invalid_asset4_validator".tr;
      case AssetType.creditAlphanum12:
        return "stellar_invalid_asset12_validator".tr;
      case AssetType.poolShare:
        return "32bytes_hex_validator_desc".tr;

      default:
        throw UnimplementedError();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIsReady();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("asset_type".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          AppDropDownBottom<AssetType>(
            items: dropDownWidget,
            value: assetType,
            onChanged: onChangeAssetType,
            hint: "asset_type".tr,
          ),
          WidgetConstant.height20,
          APPAnimatedSwitcher<AssetType>(enable: assetType, widgets: {
            AssetType.creditAlphanum12: (c) => _PickAssetIssuer(this),
            AssetType.creditAlphanum4: (c) => _PickAssetIssuer(this),
            AssetType.poolShare: (c) => _PickAssetPoolId(this)
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: isReady
                      ? () {
                          setup();
                        }
                      : null,
                  child: Text("setup_asset".tr))
            ],
          )
        ],
      ),
    );
  }
}

class _PickAssetIssuer extends StatelessWidget {
  final _StellarPickAssetViewState state;
  const _PickAssetIssuer(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("asset_name".tr, style: context.textTheme.titleMedium),
      AppTextField(
        label: "asset_name".tr,
        onChanged: state.onChangeAssetName,
        validator: state.validateAssetName,
      ),
      WidgetConstant.height20,
      Text("issuer".tr, style: context.textTheme.titleMedium),
      Text("token_issuer".tr),
      WidgetConstant.height8,
      ContainerWithBorder(
          validate: state.issueAddress != null,
          onRemove: () {
            context
                .selectAccount<StellarAddress>(account: state.widget.chain)
                .then(
              (value) {
                state.onSetIssueAddress(value?.firstOrNull);
              },
            );
          },
          onRemoveIcon: AddOrEditIconWidget(state.issueAddress != null),
          child: ConditionalWidget(
              onActive: (context) => ReceiptAddressDetailsView(
                    address: state.issueAddress!,
                    color: context.onPrimaryContainer,
                  ),
              enable: state.issueAddress != null,
              onDeactive: (context) => Text(
                    "tap_to_choose_address".tr,
                    style: context.onPrimaryTextTheme.bodyMedium,
                  ))),
    ]);
  }
}

class _PickAssetPoolId extends StatelessWidget {
  final _StellarPickAssetViewState state;
  const _PickAssetPoolId(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("pool_id".tr, style: context.textTheme.titleMedium),
      Text("stellar_liquidity_pool_id_desc".tr),
      WidgetConstant.height8,
      AppTextField(
        label: "pool_id".tr,
        onChanged: state.onChangeAssetName,
        validator: state.validateAssetName,
        minlines: 2,
        maxLines: 3,
        helperText: "32bytes_hex_validator_desc".tr,
        initialValue: state.assetName,
      ),
    ]);
  }
}
