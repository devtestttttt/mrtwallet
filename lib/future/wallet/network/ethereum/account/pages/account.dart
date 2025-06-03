import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';

class ETHAccountPageView extends StatelessWidget {
  const ETHAccountPageView({required this.chainAccount, super.key});
  final EthereumChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _EtherumServices(chainAccount),
      AccountTokensView(
          account: chainAccount,
          importPage: PageRouter.importERC20Token,
          transferPage: PageRouter.ethereumTransaction),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _EtherumServices extends StatelessWidget {
  final EthereumChain account;
  const _EtherumServices(this.account);

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
    ]);
  }
}
