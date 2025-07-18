import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/metadata/fields/fields.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/metadata/forms/metadata.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

import 'fee_info.dart';
import 'memo.dart';

class SubstrateTransactionFieldsView extends StatelessWidget {
  const SubstrateTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<SubstrateTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<SubstrateTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<SubstrateClient, ISubstrateAddress,
        SubstrateChain>(
      addressRequired: true,
      clientRequired: true,
      title: validator.validator.name.tr,
      childBulder: (wallet, account, client, address, onAccountChanged) =>
          StateBuilder<SubstrateTransactionStateController>(
              repositoryId: StateConst.substrate,
              controller: () => SubstrateTransactionStateController(
                  walletProvider: wallet,
                  apiProvider: client,
                  account: account,
                  validator: validator),
              builder: (controller) {
                return PageProgress(
                  key: controller.progressKey,
                  backToIdle: APPConst.oneSecoundDuration,
                  initialStatus: StreamWidgetStatus.progress,
                  initialWidget: ProgressWithTextView(
                      text: 'retrieving_network_condition'.tr),
                  child: (c) => UnfocusableChild(
                    child: CustomScrollView(
                      slivers: [
                        SliverConstraintsBoxView(
                            padding: WidgetConstant.padding20,
                            sliver: MultiSliver(children: [
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("account".tr,
                                        style: context.textTheme.titleMedium),
                                    WidgetConstant.height8,
                                    ContainerWithBorder(
                                      onRemoveIcon: Icon(Icons.edit,
                                          color: context.onPrimaryContainer),
                                      child: AddressDetailsView(
                                          address: controller.address,
                                          color: context.onPrimaryContainer,
                                          key: ValueKey<ISubstrateAddress?>(
                                              controller.address)),
                                      onRemove: () {
                                        context
                                            .selectOrSwitchAccount<
                                                    ISubstrateAddress>(
                                                account: controller.account,
                                                showMultiSig: true)
                                            .then(onAccountChanged);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              _SubstrateTransactionsFields(
                                  controller: controller,
                                  validator: controller.validator),
                              // _AdditonalFields(controller)
                            ])),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}

class _AdditonalFields extends StatelessWidget {
  final SubstrateTransactionStateController controller;
  final bool showMemo;
  final bool showFee;
  const _AdditonalFields(this.controller,
      {this.showMemo = true, this.showFee = true});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (showMemo) ...[
          WidgetConstant.height20,
          SubstrateTransactionMemoView(controller)
        ],
        if (showFee) ...[
          WidgetConstant.height20,
          SubstrateTransactionFeeView(controller),
        ],
        WidgetConstant.height20,
        ErrorTextContainer(error: controller.error),
        InsufficientBalanceErrorView(
            verticalMargin: WidgetConstant.paddingVertical10,
            balance: controller.remindAmount),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed:
                    controller.trIsReady ? controller.sendTransaction : null,
                child: Text("submit_extrinsic".tr))
          ],
        )
      ]),
    );
  }
}

class _SubstrateTransactionsFields extends StatelessWidget {
  const _SubstrateTransactionsFields(
      {required this.validator, required this.controller});
  final LiveTransactionForm<SubstrateTransactionForm> validator;
  final SubstrateTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    final field = validator.value;
    return switch (field.runtimeType) {
      const (SubstrateTransferForm) => _SubstrateTransactionTransferFields(
          controller: controller, field: field.cast()),
      const (SubstrateExtersincForm) => _SubstrateTransactionExtersincFields(
          controller: controller, field: field.cast()),
      _ => const SizedBox()
    };
  }
}

class _SubstrateTransactionExtersincFields extends StatelessWidget {
  const _SubstrateTransactionExtersincFields(
      {required this.field, required this.controller});
  final SubstrateExtersincForm field;
  final SubstrateTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return APPSliverAnimatedSwitcher<ExtrinsicPage>(
        enable: field.page,
        widgets: {
          ExtrinsicPage.createPayload: (context) =>
              _CreatePayload(field: field, controller: controller),
          ExtrinsicPage.createExtrinsic: (context) =>
              _CreateExtrinsic(controller: controller, field: field),
          ExtrinsicPage.showExtrinsic: (context) =>
              _ShowFinalExtrinsic(field: field, controller: controller)
        });
  }
}

class _ShowFinalExtrinsic extends StatelessWidget {
  ExtrinsicInfo? get payload => field.extrinsicInfo;
  final SubstrateExtersincForm field;
  final SubstrateTransactionStateController controller;
  const _ShowFinalExtrinsic({required this.field, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (payload == null) return WidgetConstant.sliverSizedBox;
    return MultiSliver(children: [
      SubstrateShowPayloadInfoView(
          payload: payload!.payload, onEditPayload: field.editPayload),
      SliverToBoxAdapter(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("extrinsic".tr, style: context.textTheme.titleMedium),
          if (field.signedTx) Text("fake_extrinsic_signature_desc".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: CopyableTextWidget(
                  text: payload!.serializedExtrinsic,
                  color: context.onPrimaryContainer,
                  maxLines: 3)),
        ],
      )),
      _AdditonalFields(controller, showMemo: false, showFee: field.signedTx),
    ]);
  }
}

class _CreateExtrinsic extends StatelessWidget {
  ExtrinsicPayloadInfo get payload => field.payloadInfo;
  List<MetadataFormValidator>? get forms => field.extrinsicValidators;
  final SubstrateExtersincForm field;
  final SubstrateTransactionStateController controller;
  const _CreateExtrinsic({required this.controller, required this.field});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SubstrateShowPayloadInfoView(
          payload: payload, onEditPayload: field.editPayload),
      if (forms != null)
        ...forms!.map((i) => SubstrateMetadataValidatorView(
              validator: i,
              account: controller.account,
              metadata: controller.metadata,
            )),
      SliverToBoxAdapter(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ErrorTextContainer(error: controller.error),
        FixedElevatedButton(
            padding: WidgetConstant.paddingVertical40,
            onPressed: () {
              controller.createMetadataExtrinsic();
            },
            child: Text("create_extrinsic".tr))
      ]))
    ]);
  }
}

class SubstrateShowPayloadInfoWidget extends StatelessWidget {
  final ExtrinsicPayloadInfo payload;
  final Color? color;
  final Color? primaryColor;
  const SubstrateShowPayloadInfoWidget(
      {super.key, required this.payload, this.color, this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("payload_info".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: LargeTextContainer(
                color: context.onPrimaryContainer, text: payload.payloadInfo!)),
        WidgetConstant.height20,
        Text("serialized_call".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: LargeTextContainer(
                text: payload.method, color: context.onPrimaryContainer)),
        WidgetConstant.height20,
        Text("serialized_data".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: LargeTextContainer(
                text: payload.serializedExtrinsic,
                color: context.onPrimaryContainer)),
        WidgetConstant.height20,
        ConditionalWidget(
            enable: payload.payload != payload.serializedExtrinsic,
            onActive: (context) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("payload".tr, style: context.textTheme.titleMedium),
                  Text("serialized_data_hash".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      child: LargeTextContainer(
                          text: payload.payload,
                          color: context.onPrimaryContainer)),
                  WidgetConstant.height20,
                ])),
      ],
    );
  }
}

class SubstrateShowPayloadInfoView extends StatelessWidget {
  final ExtrinsicPayloadInfo payload;
  final DynamicVoid? onEditPayload;
  const SubstrateShowPayloadInfoView(
      {super.key, required this.payload, required this.onEditPayload});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("payload".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            iconAlginment: CrossAxisAlignment.start,
            onRemove: onEditPayload,
            onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
            child: APPExpansionListTile(
              title: Text("payload_info".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
              tilePadding: EdgeInsets.zero,
              children: [
                ContainerWithBorder(
                  backgroundColor: context.colors.surface,
                  child: SubstrateShowPayloadInfoWidget(payload: payload),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePayload extends StatelessWidget {
  List<MetadataFormValidator> get forms => field.extrinsicPayloadValidators;
  final SubstrateExtersincForm field;
  const _CreatePayload({required this.field, required this.controller});
  final SubstrateTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppCheckListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("unsigned_transaction".tr,
                    style: context.textTheme.titleMedium),
                subtitle: Text("unsigned_extrinsic_desc".tr),
                value: !field.signedTx,
                onChanged: field.toggleSignedTx)
          ],
        ),
      ),
      ...forms.map((i) => SubstrateMetadataValidatorView(
            validator: i,
            account: controller.account,
            metadata: controller.metadata,
          )),
      SliverToBoxAdapter(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
          child: ButtonProgress(
              backToIdle: APPConst.twoSecoundDuration,
              child: (context) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                          padding: WidgetConstant.paddingVertical40,
                          onPressed: () {
                            field.createPayload();
                          },
                          child: Text("create_payload".tr)),
                    ],
                  ),
              onError: (context, result) {
                return ErrorTextContainer(
                  error: result?.tr,
                  enableTap: false,
                  oTapError: () {
                    field.createPayload();
                  },
                );
              },
              key: field.payloadProgressKey),
        )
      ]))
    ]);
  }
}

class _SubstrateTransactionTransferFields extends StatelessWidget {
  const _SubstrateTransactionTransferFields(
      {required this.controller, required this.field});
  final SubstrateTransactionStateController controller;
  final SubstrateTransferForm field;
  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetConstant.height20,
            Text("method_name".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            AppDropDownBottom(items: {
              for (final i in field.metadata.transferTypes)
                i: Text(i.name.camelCase)
            }, value: field.method, onChanged: field.onChangeTransferMethod),
            WidgetConstant.height20,
            Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
            Text("amount_for_each_output".tr),
            WidgetConstant.height8,
            Column(
              children: List.generate(field.destination.value.length, (index) {
                final SubstrateOutputWithBalance receiver =
                    field.destination.value[index];
                return ContainerWithBorder(
                  iconAlginment: CrossAxisAlignment.start,
                  enableTap: false,
                  onRemoveIcon: Icon(
                    Icons.remove_circle,
                    color: context.onPrimaryContainer,
                  ),
                  validate: receiver.hasAmount,
                  onRemove: () {
                    field.onRemoveReceiver(receiver);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerWithBorder(
                          backgroundColor: context.colors.onPrimaryContainer,
                          child: ReceiptAddressDetailsView(
                            address: receiver.address,
                            color: context.primaryContainer,
                          )),
                      ContainerWithBorder(
                        onRemove: () {
                          context
                              .setupAmount(
                                  token: field.network.coinParam.token,
                                  max: field.maxTransfer(
                                      account: controller.address,
                                      receiver: receiver))
                              .then((amount) {
                            field.setBalance(
                                address: receiver, balance: amount);
                          });
                        },
                        validate: receiver.hasAmount,
                        onRemoveIcon:
                            Icon(Icons.edit, color: context.primaryContainer),
                        backgroundColor: context.onPrimaryContainer,
                        child: CoinAndMarketPriceView(
                            balance: receiver.balance,
                            style: context.primaryTextTheme.titleMedium,
                            symbolColor: context.colors.primaryContainer,
                            showTokenImage: true),
                      ),
                    ],
                  ),
                );
              }),
            ),
            APPAnimatedSize(
                isActive: field.enableDestinationField,
                onActive: (context) => ContainerWithBorder(
                    validate: field.destination.hasValue,
                    onRemove: () {
                      context
                          .selectAccount<BaseSubstrateAddress>(
                              account: controller.account,
                              multipleSelect: field.metadata.supportBatch)
                          .then(
                        (value) {
                          if (value == null) return;
                          field.setReceiver(
                              addresses: value,
                              onExists: () {
                                context.showAlert("some_addresses_exist".tr);
                              });
                        },
                      );
                    },
                    onRemoveIcon:
                        Icon(Icons.add_box, color: context.onPrimaryContainer),
                    child: Text("tap_to_add_new_receipment".tr,
                        style: context.onPrimaryTextTheme.bodyMedium)),
                onDeactive: (context) => WidgetConstant.sizedBox)
          ],
        ),
      ),
      _AdditonalFields(controller, showMemo: controller.supportMemo)
    ]);
  }
}
