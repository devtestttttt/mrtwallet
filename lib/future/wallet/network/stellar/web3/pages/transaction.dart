import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/transaction/pages/fields.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/transaction/pages/operations/operations.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/web3/controller/controller/transaction.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarWeb3TransactionFieldsView extends StatelessWidget {
  const StellarWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3StellarRequest<Web3StellarSendTransactionResponse,
      Web3StellarSendTransaction> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
        controller: () => Web3StellarTransactionRequestController(
            walletProvider: wallet, request: request),
        builder: (context, controller) {
          final info = controller.transactionInfo;
          return [
            SliverToBoxAdapter(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("transaction_version".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        onRemove: () {},
                        enableTap: false,
                        onRemoveWidget: IconButton(
                            onPressed: () {
                              context.openDialogPage(
                                "transaction".tr,
                                child: (context) => APPTextView(
                                    text: info.contentStr,
                                    title: "transaction".tr),
                              );
                            },
                            icon: Icon(Icons.data_object,
                                color: context.colors.onPrimaryContainer)),
                        child: Text(info.type.translate.tr,
                            style: context.colors.onPrimaryContainer
                                .bodyMedium(context))),
                    WidgetConstant.height20,
                    ReceiptAddressView(
                      title: "source_account".tr,
                      address: info.source.address,
                    ),
                    WidgetConstant.height20,
                    Text("operations".tr, style: context.textTheme.titleMedium),
                    Text("stellar_web3_signing_operations_desc".tr),
                    WidgetConstant.height8
                  ]),
            ),
            SliverPadding(
              padding: WidgetConstant.paddingHorizontal10,
              sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    final operation = info.operations.elementAt(index);
                    final String name =
                        operation.operation.body.operationType.translate.tr;

                    return Theme(
                      data: context.theme.copyWith(
                          dividerColor: context.colors.transparent,
                          hoverColor: context.colors.transparent,
                          splashColor: context.colors.transparent),
                      child: ContainerWithBorder(
                          iconAlginment: CrossAxisAlignment.start,
                          child: APPExpansionListTile(
                            tilePadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Expanded(
                                    child: Text(name,
                                        style: context
                                            .onPrimaryTextTheme.bodyMedium)),
                                if (operation.level == OperationLevel.high)
                                  TappedTooltipView(
                                      tooltipWidget: ToolTipView(
                                          message:
                                              "stellar_high_operation_desc2".tr,
                                          textStyle: context
                                              .colors.onErrorContainer
                                              .bodyMedium(context),
                                          duration: Duration.zero,
                                          backgroundColor:
                                              context.colors.errorContainer,
                                          child: Icon(Icons.warning,
                                              color: context.colors.error))),
                                IconButton(
                                    onPressed: () {
                                      context.openDialogPage(name,
                                          child: (context) => APPTextView(
                                              text:
                                                  operation.operationContentStr,
                                              title: name));
                                    },
                                    icon: Icon(Icons.data_object,
                                        color: context.onPrimaryContainer))
                              ],
                            ),
                            children: [
                              Container(
                                  padding: WidgetConstant.padding10,
                                  decoration: BoxDecoration(
                                      color: context.colors.surface,
                                      borderRadius: WidgetConstant.border8),
                                  child: _StellarGlobalTransactionOperationView(
                                      operation: operation))
                            ],
                          )),
                    );
                  },
                  itemCount: info.operations.length,
                  separatorBuilder: (context, index) => WidgetConstant.divider),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  Text("memo".tr, style: context.textTheme.titleMedium),
                  Text("memo_desc2".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.memo.memo.type.name.camelCase,
                          style: context.onPrimaryTextTheme.labelLarge,
                        ),
                        if (info.memo.val != null)
                          Text(
                            info.memo.val ?? '',
                            style: context.colors.onPrimaryContainer
                                .bodyMedium(context),
                          )
                      ],
                    ),
                  ),
                  if (info.soroban != null) ...[
                    WidgetConstant.height20,
                    Text("soroban_data".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        iconAlginment: CrossAxisAlignment.start,
                        child: APPExpansionListTile(
                          tilePadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text("content".tr,
                                    style:
                                        context.onPrimaryTextTheme.bodyMedium),
                              ),
                              IconButton(
                                  onPressed: () {
                                    context.openDialogPage(
                                      "soroban_data".tr,
                                      child: (context) => APPTextView(
                                          text: info.soroban!.contentStr,
                                          title: "soroban_data".tr),
                                    );
                                  },
                                  icon: Icon(Icons.data_object,
                                      color: context.colors.onPrimaryContainer))
                            ],
                          ),
                          children: [
                            Container(
                                padding: WidgetConstant.padding10,
                                decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    borderRadius: WidgetConstant.border8),
                                child: _SorobanTransactionData(
                                    soroban: info.soroban!,
                                    network: controller.network))
                          ],
                        )),
                  ],
                  WidgetConstant.height20,
                  Text("transaction_fee".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: CoinAndMarketPriceView(
                        balance: info.fee,
                        style: context.onPrimaryTextTheme.titleMedium,
                        symbolColor: context.onPrimaryContainer),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                          padding: WidgetConstant.paddingVertical40,
                          child: controller.isSendTransaction
                              ? Text("send_transaction".tr)
                              : Text("sign_transaction".tr),
                          onPressed: () {
                            controller.sendTransaction();
                          }),
                    ],
                  )
                ],
              ),
            )
          ];
        },
        request: request);
  }
}

class _StellarGlobalTransactionOperationView extends StatelessWidget {
  final StellarTransactionOperationDetails operation;
  const _StellarGlobalTransactionOperationView({required this.operation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("accessibility".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: switch (operation.level) {
            OperationLevel.high => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("stellar_high_operation_desc".tr,
                      style: context.onPrimaryTextTheme.bodyMedium),
                  ErrorTextContainer(error: "stellar_high_operation_desc2".tr)
                ],
              ),
            OperationLevel.medium => Text("stellar_medium_operation_desc".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
            _ => Text("stellar_low_operation_desc".tr,
                style: context.onPrimaryTextTheme.bodyMedium),
          },
        ),
        if (operation.sourceAccount != null) ...[
          WidgetConstant.height20,
          ReceiptAddressView(
              title: "source_account".tr,
              address: operation.sourceAccount!.address),
        ],
        if (operation.operationInfo != null) ...[
          WidgetConstant.height20,
          StellarTransactionOperationView(operation: operation.operationInfo!)
        ] else
          ...List.generate(operation.operationContent.length, (index) {
            final key = operation.operationContent.keys.elementAt(index);
            final value = operation.operationContent[key];
            if (value == null) {
              return WidgetConstant.sizedBox;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height20,
                Text(key.camelCase, style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  constraints: null,
                  child: CopyTextIcon(
                    dataToCopy: value.toString(),
                    isSensitive: false,
                    color: context.colors.onPrimaryContainer,
                    widget: SelectableText(value.toString(),
                        style: context.onPrimaryTextTheme.bodyMedium,
                        maxLines: 4,
                        minLines: 1),
                  ),
                ),
              ],
            );
          })
      ],
    );
  }
}

class _SorobanTransactionData extends StatelessWidget {
  final StellarSorobanTransactionDetais soroban;
  final WalletStellarNetwork network;
  const _SorobanTransactionData({required this.soroban, required this.network});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("fee_source".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          constraints: null,
          child: CoinAndMarketPriceView(
              balance: soroban.feeSource,
              style: context.onPrimaryTextTheme.titleMedium,
              symbolColor: context.colors.onPrimaryContainer),
        ),
        Column(
            children: List.generate(soroban.content.length, (index) {
          final key = soroban.content.keys.elementAt(index);
          final value = soroban.content[key];
          if (value == null) {
            return WidgetConstant.sizedBox;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetConstant.height20,
              Text(key.camelCase, style: context.textTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                constraints: null,
                child: CopyTextIcon(
                  dataToCopy: value.toString(),
                  isSensitive: false,
                  color: context.onPrimaryContainer,
                  widget: SelectableText(value.toString(),
                      style: context.onPrimaryTextTheme.bodyMedium,
                      maxLines: 4,
                      minLines: 1),
                ),
              ),
            ],
          );
        })),
      ],
    );
  }
}
