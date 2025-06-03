import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class SuiWeb3SwitchChainView extends StatelessWidget {
  const SuiWeb3SwitchChainView({required this.request, super.key});
  final Web3SuiSwitchSuiChain request;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "switch_chain"
                  .tr
                  .replaceOne(request.newChain.network.networkName),
              body: Text("switch_chain_desc".tr)),
          Text("current_chain".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Row(
              children: [
                CircleTokenImageView(request.request.chain.network.token,
                    radius: APPConst.circleRadius25),
                WidgetConstant.width8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.request.chain.network.networkName,
                          style: context.onPrimaryTextTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          WidgetConstant.height20,
          Text("requested_chain".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Row(
              children: [
                CircleTokenImageView(request.newChain.network.token,
                    radius: APPConst.circleRadius25),
                WidgetConstant.width8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.newChain.network.networkName,
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
                    request.confirmRequest();
                  })
            ],
          )
        ],
      ),
    );
  }
}
