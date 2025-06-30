import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wc/wc.dart';

class WalletConnectIcon extends StatelessWidget {
  const WalletConnectIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.wallet;
    return APPStreamBuilder(
      value: wallet.wallet.walletConnect.connectionStatus,
      builder: (context, value) {
        return IconButton(
            onPressed: () {
              context.to(PageRouter.walletConnect);
            },
            icon: SizedBox.fromSize(
              size: WidgetConstant.circularProgressIndicatorSize,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Opacity(
                        opacity: value.isDispose ? APPConst.disabledOpacity : 1,
                        child: Icon(CustomIcons.wc2)),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: APPAnimatedSwitcher<
                          WcRpcSocketStatus>(enable: value, widgets: {
                        WcRpcSocketStatus.connect: (context) =>
                            Icon(Icons.link, size: APPConst.circleRadius12),
                        WcRpcSocketStatus.disconnect: (context) =>
                            Icon(Icons.link_off, size: APPConst.circleRadius12),
                        WcRpcSocketStatus.pending: (context) =>
                            Icon(Icons.sync, size: APPConst.circleRadius12),
                        WcRpcSocketStatus.dispose: (context) =>
                            Icon(Icons.block, size: APPConst.circleRadius12),
                        WcRpcSocketStatus.noNetwork: (context) =>
                            Icon(Icons.block, size: APPConst.circleRadius12),
                      }))
                ],
              ),
            ));
      },
    );
  }
}
