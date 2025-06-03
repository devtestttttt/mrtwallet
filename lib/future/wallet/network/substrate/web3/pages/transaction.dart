import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/pages/pages/fee_info.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/web3/controller/controller/transaction.dart';
import 'package:on_chain_wallet/wallet/models/networks/substrate/models/transaction_output.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';

class SubstrateWeb3TransactionFieldsView extends StatelessWidget {
  const SubstrateWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SubstrateRequest<Web3SubstrateSendTransactionResponse,
      Web3SubstrateSendTransaction> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
        controller: () => Web3SubstrateTransactionRequestController(
            walletProvider: wallet, request: request),
        builder: (context, controller) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("operations".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ...List.generate(controller.methods.length, (i) {
                    final method = controller.methods[i];
                    return switch (method.type) {
                      SubstrateKnownCallMethodsType.unknown =>
                        _UnknownMethodView(method as SubstrateUnknownMethod),
                      SubstrateKnownCallMethodsType.transfer =>
                        _TransferMethodView(
                            method: method as SubstrateTransferMethod,
                            controller: controller),
                      SubstrateKnownCallMethodsType.remark =>
                        _RemarkMethodView(method as SubstrateRemarkMethod)
                    };
                  }),
                  WidgetConstant.height20,
                ],
              ),
            ),
            SliverToBoxAdapter(
                child: SubstrateShowPayloadInfoWidget(
                    payload: controller.extrinsicInfo)),
            SliverToBoxAdapter(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubstrateTransactionFeeView(controller),
                InsufficientBalanceErrorView(balance: controller.remindAmount),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FixedElevatedButton(
                      activePress: controller.isReady,
                      padding: WidgetConstant.paddingVertical40,
                      onPressed: () {
                        controller.signAndSendTransaction();
                      },
                      child: Text("sign_transaction".tr))
                ])
              ],
            )),
          ];
        },
        request: request);
  }
}

class _RemarkMethodView extends StatelessWidget {
  final SubstrateRemarkMethod method;
  const _RemarkMethodView(this.method);

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      title: Text('remark'.tr, style: context.onPrimaryTextTheme.bodyMedium),
      children: [
        ContainerWithBorder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('data'.tr, style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: LargeTextContainer(
                    text: method.data, color: context.primaryContainer),
              ),
              ConditionalWidget(
                  enable: method.content != null,
                  onActive: (context) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WidgetConstant.height20,
                            Text('content'.tr,
                                style: context.onPrimaryTextTheme.titleMedium),
                            WidgetConstant.height8,
                            ContainerWithBorder(
                              backgroundColor: context.onPrimaryContainer,
                              child: LargeTextContainer(
                                  text: method.content!,
                                  color: context.primaryContainer),
                            ),
                          ]))
            ],
          ),
        )
      ],
    );
  }
}

class _TransferMethodView extends StatelessWidget {
  final SubstrateTransferMethod method;
  final Web3SubstrateTransactionRequestController controller;
  const _TransferMethodView({required this.method, required this.controller});

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      title: Text(
        'transfer'.tr,
        style: context.onPrimaryTextTheme.bodyMedium,
      ),
      children: [
        ContainerWithBorder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('receiver_address'.tr,
                  style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                onRemove: () {},
                enableTap: false,
                onRemoveIcon: CopyTextIcon(
                  dataToCopy: method.receiver.view,
                  color: context.primaryContainer,
                ),
                child: ReceiptAddressDetailsView(
                    address: method.receiver, color: context.primaryContainer),
              ),
              WidgetConstant.height20,
              Text('amount'.tr, style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: CoinAndMarketPriceView(
                  balance: method.amount,
                  style: context.primaryTextTheme.titleMedium,
                  symbolColor: context.primaryContainer,
                  showTokenImage: true,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _UnknownMethodView extends StatelessWidget {
  final SubstrateUnknownMethod method;
  const _UnknownMethodView(this.method);

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      title: Text('unknown'.tr, style: context.onPrimaryTextTheme.bodyMedium),
      children: [
        ContainerWithBorder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('content'.tr, style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: LargeTextContainer(
                    text: method.content, color: context.primaryContainer),
              ),
            ],
          ),
        )
      ],
    );
  }
}
