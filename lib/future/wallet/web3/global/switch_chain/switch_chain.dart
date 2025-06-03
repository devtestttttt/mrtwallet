import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/app.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/web3/global/switch_chain/controller/controller.dart';
import 'package:on_chain_wallet/wallet/web3/networks/global/params/core/core.dart';

class GlobalWeb3SwitchChainView extends StatelessWidget {
  final Web3GlobalRequest<dynamic> request;
  final WalletProvider wallet;
  const GlobalWeb3SwitchChainView(
      {super.key, required this.wallet, required this.request});

  @override
  Widget build(BuildContext context) {
    return Web3GlobalPageRequestControllerView(
        controller: () => Web3GlobalRequestSwotchNetworkStateController(
            request: request, wallet: wallet),
        builder: (context, controller) {
          return ConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitleSubtitle(
                    title: "switch_chain"
                        .tr
                        .replaceOne(controller.newChain.network.networkName),
                    body: Text("switch_chain_desc".tr)),
                WidgetConstant.height20,
                Text("current_chain".tr, style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  child: Row(
                    children: [
                      CircleTokenImageView(controller.chain.network.token,
                          radius: APPConst.circleRadius25),
                      WidgetConstant.width8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.chain.network.networkName,
                                style: context.onPrimaryTextTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                WidgetConstant.height20,
                Text("requested_chain".tr,
                    style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                ContainerWithBorder(
                  child: Row(
                    children: [
                      CircleTokenImageView(controller.newChain.network.token,
                          radius: APPConst.circleRadius25),
                      WidgetConstant.width8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.newChain.network.networkName,
                                style: context.onPrimaryTextTheme.bodyMedium)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical40,
                        child: Text("agree".tr),
                        onPressed: () {
                          controller.confirm();
                        })
                  ],
                )
              ],
            ),
          );
        },
        request: request);
  }
}
