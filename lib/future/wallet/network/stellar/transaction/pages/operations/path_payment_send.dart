import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/transaction/pages/widgets/pick_asset.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/stellar/stellar.dart';
import 'package:on_chain_wallet/wallet/constant/networks/stellar.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'operation_destination_tracker.dart';

class PathPaymentStrictSendOperationView extends StatefulWidget {
  final StellarTransactionStateController controller;
  final StellarPathPaymentStrictSendOperation? operation;
  const PathPaymentStrictSendOperationView(
      {required this.controller, this.operation, super.key});

  @override
  State<PathPaymentStrictSendOperationView> createState() =>
      _PathPaymentStrictSendOperationViewState();
}

class _PathPaymentStrictSendOperationViewState
    extends State<PathPaymentStrictSendOperationView>
    with SafeState, StellarOperationDestinationTracker {
  StellarTransactionStateController get controller => widget.controller;
  StellarChain get chain => controller.account;
  @override
  StellarPickedIssueAsset? asset;
  StellarPickedIssueAsset? destAssets;
  bool get isNative => asset?.asset.type.isNative ?? false;
  late IntegerBalance amount = IntegerBalance.zero(chain.network.token);
  late IntegerBalance destMin = IntegerBalance.zero(chain.network.token);
  late IntegerBalance remindAmount = IntegerBalance.zero(chain.network.token);
  @override
  StellarClient get client => controller.apiProvider;
  BigInt maximumAmount = BigInt.zero;

  List<StellarPickedIssueAsset> paths = [];
  bool isReady = false;
  bool showLimit = false;

  void calculateMaximumAmount() {
    assert(asset != null, "asset should not be null.");
    final sameOperations = controller.customOperations
        .where((e) => e.asset?.asset == asset?.asset && e != widget.operation);
    final totalStroop = sameOperations.fold(BigInt.zero, (p, c) => p + c.value);
    if (isNative) {
      maximumAmount = chain.address.address.currencyBalance -
          (totalStroop + (controller.fee?.balance ?? BigInt.zero));
      return;
    }
    if (asset!.tokenBalance == null) {
      maximumAmount = StellarConst.maxIssueAmount;
    } else {
      maximumAmount = asset!.tokenBalance!.balance - totalStroop;
    }
  }

  void calculateRemindAmount() {
    assert(asset != null, "asset should not be null.");
    final remind = maximumAmount - amount.balance;
    remindAmount.updateBalance(remind);
  }

  void pickAssets(StellarPickedIssueAsset? asset) {
    if (asset == null) return;
    this.asset = asset;
    showLimit = this.asset != null;
    remindAmount = IntegerBalance.zero(asset.token);
    amount = IntegerBalance.zero(asset.token);
    calculateMaximumAmount();
    calculateRemindAmount();
    checkIsReady();
    updateState();
  }

  void pickDestAssets(StellarPickedIssueAsset? destAssets) {
    if (destAssets == null) return;
    this.destAssets = destAssets;
    destMin = IntegerBalance.zero(destAssets.token);
    calculateMaximumAmount();
    calculateRemindAmount();
    checkIsReady();
    updateState();
  }

  void setupAmount(BigInt? amount) {
    if (amount == null) return;
    this.amount.updateBalance(amount);
    calculateRemindAmount();
    checkIsReady();
    updateState();
  }

  void addToPathList(StellarPickedIssueAsset? path) {
    if (path == null) return;
    if (paths.length >= 5) {
      return;
    }
    final hasAny = paths.any((e) => e.asset == path.asset);
    if (hasAny || destAssets?.asset == path.asset) {
      context.showAlert("path_already_exist".tr);
      return;
    }
    paths.add(path);
    updateState();
  }

  void removeFromPathList(StellarPickedIssueAsset path) {
    paths.remove(path);
    updateState();
  }

  void stupDestAmount(BigInt? amount) {
    if (amount == null) return;
    destMin.updateBalance(amount);
    updateState();
  }

  void setupOperation() {
    if (!isReady) return;
    final operation = StellarPathPaymentStrictSendOperation(
        asset: asset!,
        sendAmount: amount,
        destination: receiver!,
        destMin: destMin,
        destAsset: destAssets!,
        paths: paths);
    context.pop(operation);
  }

  void checkIsReady() {
    isReady = asset != null &&
        receiver != null &&
        !amount.isNegative &&
        !remindAmount.isNegative &&
        destAssets != null &&
        !destMin.isNegative;
  }

  void init() {
    final operation = widget.operation;
    if (operation == null) return;
    receiver = operation.destination;
    trackActivity(receiver!);
    asset = operation.asset;
    destAssets = operation.destAsset;
    amount = IntegerBalance.zero(operation.asset.token);
    remindAmount = IntegerBalance.zero(operation.asset.token);
    destMin = IntegerBalance.zero(operation.destAsset.token);
    amount.updateBalance(operation.sendAmount.balance);
    destMin.updateBalance(operation.destMin.balance);
    paths.addAll(operation.paths);
    showLimit = asset != null;
    calculateMaximumAmount();
    calculateRemindAmount();
    checkIsReady();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "stellar_path_payment_strict_send".tr,
            body: LargeTextView([
              "stellar_path_payment_strict_send_desc".tr,
              if (widget.operation != null) ...[
                "remove_operation_close_page_desc".tr,
              ]
            ])),
        Text("send_asset".tr, style: context.textTheme.titleMedium),
        Text("stellar_path_send_send_asset_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: asset != null,
          onRemoveIcon: AddOrEditIconWidget(asset != null),
          child: asset == null
              ? Text("tap_to_select_or_create_asset".tr,
                  style: context.onPrimaryTextTheme.bodyMedium)
              : TokenDetailsWidget(
                  token: asset!.asset.type.isNative
                      ? asset!.token
                      : asset!.currentToken,
                  balance:
                      asset!.asset.type.isNative ? null : asset?.tokenBalance,
                  liveBalance: asset!.asset.type.isNative
                      ? chain.address.address.balance
                      : null,
                  color: context.onPrimaryContainer,
                  radius: APPConst.circleRadius25,
                  tokenAddress: asset!.issuer,
                ),
          onRemove: () {
            context
                .openSliverDialog<StellarPickedIssueAsset>(
                    (c) => PickFromAccountAssets(
                        accountInfo: controller.accountInfo, chain: chain),
                    "assets".tr,
                    content: (context) => [
                          IconButton(
                            tooltip: "create_assets".tr,
                            icon: const Icon(Icons.add_box),
                            onPressed: () {
                              context.pop();
                              this
                                  .context
                                  .openSliverBottomSheet<
                                          StellarPickedIssueAsset>(
                                      "pick_an_asset".tr,
                                      child: StellarPickAssetView(chain: chain))
                                  .then(pickAssets);
                            },
                          )
                        ])
                .then(pickAssets);
          },
        ),
        WidgetConstant.height20,
        APPAnimatedSwitcher<bool>(
            enable: showLimit, widgets: {true: (context) => _Amount(this)}),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FixedElevatedButton(
              padding: WidgetConstant.paddingVertical40,
              onPressed: isReady ? setupOperation : null,
              child: Text("setup_operation".tr))
        ])
      ],
    );
  }
}

class _Amount extends StatelessWidget {
  final _PathPaymentStrictSendOperationViewState state;
  const _Amount(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionAmountView(
          amount: state.amount,
          token: state.asset!.token,
          title: "send_amount".tr,
          subtitle: "stellar_path_receive_send_amount_desc".tr,
          onTap: () {
            context
                .setupAmount(
                    token: state.asset!.token, max: state.maximumAmount)
                .then(state.setupAmount);
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          enableTap: state.receiver == null,
          title: "destination".tr,
          subtitle: "stellar_path_send_destination_desc".tr,
          address: state.receiver?.address,
          onEditWidget: state.receiver == null
              ? null
              : Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          context
                              .selectAccount<StellarAddress>(
                                  account: state.chain, title: "destination".tr)
                              .then((v) => state.setReceiver(v?.firstOrNull));
                        },
                        icon: Icon(Icons.edit,
                            color: context.colors.onPrimaryContainer)),
                    IconButton(
                        tooltip: state.receiver!.status.message?.tr,
                        onPressed: () {
                          state.trackActivity(state.receiver!);
                        },
                        icon: StatusIconWidget(
                          status: state.receiver!.status.toProgressStatus,
                          size: APPConst.iconSize,
                          onSuccessIcon: state.receiver!.status.isInactive
                              ? Icon(Icons.no_accounts_rounded,
                                  color: context.colors.onPrimaryContainer)
                              : Icon(Icons.account_circle,
                                  color: context.colors.onPrimaryContainer),
                        ))
                  ],
                ),
          onTap: () {
            context
                .selectAccount<StellarAddress>(
                    account: state.chain, title: "destination".tr)
                .then((v) => state.setReceiver(v?.firstOrNull));
          },
        ),
        WidgetConstant.height20,
        Text("destination_asset".tr, style: context.textTheme.titleMedium),
        LargeTextView(["stellar_path_send_dest_asset_desc".tr], maxLine: 2),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: state.destAssets != null,
          iconAlginment: state.destAssets == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          onRemoveIcon: AddOrEditIconWidget(state.destAssets != null),
          child: state.destAssets == null
              ? Text("tap_to_select_or_create_asset".tr,
                  style: context.onPrimaryTextTheme.bodyMedium)
              : TokenDetailsWidget(
                  token: state.destAssets!.token,
                  radius: APPConst.circleRadius25,
                  color: context.onPrimaryContainer,
                  tokenAddress: state.destAssets!.issuer),
          onRemove: () {
            context
                .openSliverDialog<StellarPickedIssueAsset>(
                    (c) => PickFromAccountAssets(
                        accountInfo: state.controller.accountInfo,
                        chain: state.chain),
                    "assets".tr,
                    content: (c) => [
                          IconButton(
                            tooltip: "create_assets".tr,
                            icon: const Icon(Icons.add_box),
                            onPressed: () {
                              c.pop();
                              context
                                  .openSliverBottomSheet<
                                          StellarPickedIssueAsset>(
                                      "pick_an_asset".tr,
                                      child: StellarPickAssetView(
                                          chain: state.chain))
                                  .then(state.pickDestAssets);
                            },
                          )
                        ])
                .then(state.pickDestAssets);
          },
        ),
        APPAnimatedSwitcher(enable: state.destAssets == null, widgets: {
          false: (c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  TransactionAmountView(
                    amount: state.destMin,
                    token: state.destAssets!.token,
                    title: "minimum_destination_amount".tr,
                    subtitle: "stellar_path_send_dest_min_desc".tr,
                    onTap: () {
                      context
                          .setupAmount(
                              token: state.destAssets!.token,
                              max: StellarConst.maxIssueAmount)
                          .then(state.stupDestAmount);
                    },
                  ),
                  WidgetConstant.height20,
                  Text("path".tr, style: context.textTheme.titleMedium),
                  LargeTextView(["stellar_path_send_path_desc".tr], maxLine: 2),
                  WidgetConstant.height8,
                  ...List.generate(state.paths.length, (index) {
                    final asset = state.paths.elementAt(index);
                    return ContainerWithBorder(
                      onRemoveIcon: Icon(Icons.remove_circle,
                          color: context.colors.onPrimaryContainer),
                      child: TokenDetailsWidget(
                          token: asset.token,
                          radius: APPConst.circleRadius25,
                          color: context.onPrimaryContainer,
                          tokenAddress: asset.issuer),
                      onRemove: () {
                        state.removeFromPathList(asset);
                      },
                    );
                  }),
                  APPAnimatedSwitcher<
                      bool>(enable: state.paths.length < 5, widgets: {
                    true: (c) => ContainerWithBorder(
                          onRemoveIcon: Icon(Icons.add_box,
                              color: context.onPrimaryContainer),
                          child: Text("tap_to_select_or_create_asset".tr,
                              style: context.onPrimaryTextTheme.bodyMedium),
                          onRemove: () {
                            context
                                .openSliverDialog<StellarPickedIssueAsset>(
                                    (c) => PickFromAccountAssets(
                                        accountInfo:
                                            state.controller.accountInfo,
                                        chain: state.chain),
                                    "assets".tr,
                                    content: (c) => [
                                          IconButton(
                                            tooltip: "create_assets".tr,
                                            icon: const Icon(Icons.add_box),
                                            onPressed: () {
                                              c.pop();
                                              context
                                                  .openSliverBottomSheet<
                                                          StellarPickedIssueAsset>(
                                                      "pick_an_asset".tr,
                                                      child:
                                                          StellarPickAssetView(
                                                              chain:
                                                                  state.chain))
                                                  .then(state.addToPathList);
                                            },
                                          )
                                        ])
                                .then(state.addToPathList);
                          },
                        ),
                  })
                ],
              )
        }),
        InsufficientBalanceErrorView(
            verticalMargin: WidgetConstant.paddingVertical10,
            balance: state.remindAmount),
        ErrorTextContainer(
            margin: WidgetConstant.paddingVertical10,
            error: state.destinationInactiveError ?? state.pathLimitError),
      ],
    );
  }
}
