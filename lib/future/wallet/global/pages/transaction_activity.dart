import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class AccountTransactionActivityView extends StatefulWidget {
  final Chain chain;
  const AccountTransactionActivityView(this.chain, {super.key});

  @override
  State<AccountTransactionActivityView> createState() =>
      _AccountTransactionActivityViewState();
}

class _AccountTransactionActivityViewState
    extends State<AccountTransactionActivityView>
    with SafeState<AccountTransactionActivityView> {
  Chain get account => widget.chain;
  @override
  Widget build(BuildContext context) {
    return ChainStreamBuilder(
        allowNotify: [ChainNotify.transaction],
        builder: (context, chain, lastNotify) {
          final transaction = account.address.transactions;
          return AccountTabbarScrollWidget(slivers: [
            EmptyItemSliverWidgetView(
              isEmpty: transaction.isEmpty,
              itemBuilder: (context) {
                return SliverList.separated(
                    itemBuilder: (context, index) {
                      return TransactionView(
                          transaction: transaction[index], chain: widget.chain);
                    },
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemCount: transaction.length);
              },
            )
          ]);
        },
        account: account);
  }
}
