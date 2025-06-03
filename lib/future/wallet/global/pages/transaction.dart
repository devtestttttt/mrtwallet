import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/transaction/transaction.dart';

class TransactionView extends StatelessWidget {
  final ChainTransaction transaction;
  final Chain chain;
  const TransactionView(
      {required this.transaction, required this.chain, super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      onRemove: () {
        context.openSliverDialog((context) {
          return TransactionModalView(transaction: transaction, chain: chain);
        }, "transaction".tr,
            content: (c) => [
                  IconButton(
                      onPressed: () {
                        context.openSliverDialog(
                            (ctx) => DialogTextView(
                                buttonWidget: AsyncDialogDoubleButtonView(
                                    firstButtonPressed: () => chain
                                            .removeTransaction(
                                                address: chain.address,
                                                transaction: transaction)
                                            .then((e) {
                                          ctx.pop();
                                        })),
                                text: "remove_transaction_from_account".tr),
                            'remove_transaction'.tr);
                      },
                      icon: Icon(Icons.delete))
                ]);
      },
      onRemoveIcon: ConditionalWidgets(
        enable: transaction.type,
        widgets: {
          WalletTransactionType.send: (context) =>
              Icon(Icons.upload, color: context.onPrimaryContainer),
          WalletTransactionType.web3: (context) =>
              Icon(Icons.upload, color: context.onPrimaryContainer),
        },
      ),
      child: Row(
        children: [
          Expanded(
            child: ConditionalWidget(
              enable: transaction.totalOutput != null,
              onActive: (context) => CoinAndMarketPriceView(
                balance: transaction.totalOutput!.amount,
                showTokenImage: true,
                style: context.onPrimaryTextTheme.titleMedium,
                symbolColor: context.onPrimaryContainer,
              ),
              onDeactive: (context) => OneLineTextWidget(transaction.txId,
                  style: context.onPrimaryTextTheme.bodyMedium),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(transaction.status.name.tr,
                  style: context.onPrimaryTextTheme.labelMedium),
              Text(transaction.time.toDateAndTime(),
                  style: context.onPrimaryTextTheme.bodySmall),
            ],
          )
        ],
      ),
    );
  }
}

class TransactionModalView extends StatelessWidget {
  final ChainTransaction transaction;
  final Chain chain;
  const TransactionModalView(
      {required this.transaction, required this.chain, super.key});

  @override
  Widget build(BuildContext context) {
    final txUrl = chain.network.getTransactionExplorer(transaction.txId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_id".tr,
            style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {},
          enableTap: false,
          onRemoveIcon:
              LaunchBrowserIcon(url: txUrl, color: context.onPrimaryContainer),
          child: CopyableTextWidget(
              text: transaction.txId, color: context.onPrimaryContainer),
        ),
        WidgetConstant.height20,
        Text("status".tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: Text(transaction.status.name.tr,
              style: context.onPrimaryTextTheme.bodyMedium),
        ),
        WidgetConstant.height20,
        ConditionalWidget(
            enable: transaction.totalOutput != null,
            onActive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("total_amount".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      onRemoveIcon: ConditionalWidgets(
                        enable: transaction.type,
                        widgets: {
                          WalletTransactionType.send: (context) => Icon(
                                Icons.upload,
                                color: context.onPrimaryContainer,
                              ),
                          WalletTransactionType.web3: (context) => Icon(
                                Icons.upload,
                                color: context.onPrimaryContainer,
                              ),
                        },
                      ),
                      child: CoinAndMarketPriceView(
                          balance: transaction.totalOutput!.amount,
                          showTokenImage: true,
                          style: context.onPrimaryTextTheme.titleMedium,
                          symbolColor: context.onPrimaryContainer),
                    ),
                    WidgetConstant.height20,
                  ],
                )),
        ConditionalWidget(
            enable: transaction.outputs.isNotEmpty,
            onActive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("outputs".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ListView.separated(
                        itemBuilder: (context, index) {
                          final output = transaction.outputs[index];
                          return switch (output.type) {
                            WalletTransactionOutputType.transfer =>
                              TransactionTransferOutputView(
                                  output:
                                      output as WalletTransactionTransferOutput,
                                  transaction: transaction),
                            WalletTransactionOutputType.operation =>
                              TransactionOperationOutputView(
                                  output: output
                                      as WalletTransactionOperationOutput),
                            _ => WidgetConstant.sizedBox
                          };
                        },
                        separatorBuilder: (context, index) =>
                            WidgetConstant.divider,
                        itemCount: transaction.outputs.length,
                        shrinkWrap: true,
                        physics: WidgetConstant.noScrollPhysics),
                  ],
                ))
      ],
    );
  }
}

class TransactionOperationOutputView extends StatelessWidget {
  const TransactionOperationOutputView({required this.output, super.key});
  final WalletTransactionOperationOutput output;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerWithBorder(
              backgroundColor: context.onPrimaryContainer,
              child: Text('operation'.tr,
                  style: context.primaryTextTheme.bodyMedium)),
          ContainerWithBorder(
              backgroundColor: context.onPrimaryContainer,
              child: Text(output.name,
                  style: context.primaryTextTheme.bodyMedium)),
          ConditionalWidget(
            enable: output.content != null,
            onActive: (context) => ContainerWithBorder(
              backgroundColor: context.onPrimaryContainer,
              child: LargeTextContainer(
                  text: output.content!, color: context.primaryContainer),
            ),
          )
        ],
      ),
    );
  }
}

class TransactionTransferOutputView extends StatelessWidget {
  const TransactionTransferOutputView(
      {required this.output, required this.transaction, super.key});
  final WalletTransactionTransferOutput output;
  final ChainTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerWithBorder(
              backgroundColor: context.onPrimaryContainer,
              child: Text('transfer'.tr,
                  style: context.primaryTextTheme.bodyMedium)),
          ContainerWithBorder(
              backgroundColor: context.onPrimaryContainer,
              child: CopyableTextWidget(
                  text: output.address, color: context.primaryContainer)),
          ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CoinAndMarketPriceView(
              balance: output.amount.amount,
              showTokenImage: true,
              style: context.primaryTextTheme.titleMedium,
              symbolColor: context.primaryContainer,
            ),
          ),
          switch (output.runtimeType) {
            const (MoneroWalletTransactionOutput) => _MoneroOutputView(
                output: output as MoneroWalletTransactionOutput,
                transaction: transaction as MoneroWalletTransaction,
              ),
            _ => WidgetConstant.sizedBox
          }
        ],
      ),
    );
  }
}

class _MoneroOutputView extends StatelessWidget {
  const _MoneroOutputView({required this.output, required this.transaction});
  final MoneroWalletTransactionOutput output;
  final MoneroWalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        Text("proof".tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            onRemoveIcon:
                Icon(Icons.handshake, color: context.primaryContainer),
            onRemove: () {
              context.to(PageRouter.moneroGenerateProof,
                  argruments: transaction.generateProofRequest(output));
            },
            child: Text("tap_to_generate_transaction_proof".tr,
                style: context.primaryTextTheme.bodyMedium)),
      ],
    );
  }
}

/// moneroGenerateProof
