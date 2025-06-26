import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/models/personal_sign.dart';

class EthereumWeb3PersonalSignRequestView extends StatelessWidget {
  const EthereumWeb3PersonalSignRequestView({required this.request, super.key});
  final Web3EthereumPersonalSignForm request;
  Web3EthreumPersonalSign get param => request.request.params;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConditionalWidget(
              enable: request.isEthSign,
              onActive: (context) => ErrorTextContainer(
                  error: "sign_message_private_key_desc".tr)),
          Text("message".tr, style: context.textTheme.titleMedium),
          TextAndLinkView(
              text: "eth_personal_sign_desc".tr,
              url: LinkConst.aboutEthereumPersonalSign,
              linkDesc: "read_more".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              onRemove: () {},
              onRemoveWidget:
                  CopyTextIcon(dataToCopy: param.message, isSensitive: false),
              enableTap: false,
              child: Text(param.message,
                  style:
                      context.colors.onPrimaryContainer.bodyMedium(context))),
          if (param.content != null) ...[
            WidgetConstant.height20,
            Text("content".tr, style: context.textTheme.titleMedium),
            ContainerWithBorder(
                onRemove: () {},
                onRemoveWidget: CopyTextIcon(
                    dataToCopy: param.content ?? "", isSensitive: false),
                enableTap: false,
                child: SelectableText(
                  param.content ?? "",
                  style: context.colors.onPrimaryContainer.bodyMedium(context),
                  minLines: 1,
                  maxLines: 5,
                )),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  child: Text("sign_message".tr),
                  onPressed: () {
                    request.signMessage(confirm: () async {
                      return context.openSliverDialog<bool>(
                          (ctx) => DialogTextView(
                              widget: Column(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: context.colors.error,
                                    size: APPConst.double80,
                                  ),
                                  WidgetConstant.height8,
                                  ContainerWithBorder(
                                      backgroundColor:
                                          context.colors.errorContainer,
                                      enableTap: false,
                                      child: Text(
                                          "sign_message_private_key_desc".tr,
                                          style: context.colors.onErrorContainer
                                              .bodyMedium(context))),
                                ],
                              ),
                              buttonWidget: const AsyncDialogDoubleButtonView(),
                              text: "sign_message_private_key_desc".tr),
                          "sign_message".tr);
                    });
                  })
            ],
          )
        ],
      ),
    );
  }
}
