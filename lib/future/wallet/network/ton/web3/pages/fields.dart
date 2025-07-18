import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/state.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/ton.dart';
import 'global.dart';
import 'transaction.dart';

class TonWeb3FieldsView extends StatelessWidget {
  const TonWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3TonRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3TonRequestMethods.requestAccounts:
        return TonWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3TonRequestMethods.signMessage:
        return TonWeb3GlobalFieldsView<Web3TonSignMessageResponse,
                Web3TonSignMessage>(
            request: request as Web3TonRequest<Web3TonSignMessageResponse,
                Web3TonSignMessage>,
            wallet: wallet);
      case Web3TonRequestMethods.sendTransaction:
      case Web3TonRequestMethods.signTransaction:
        return TonWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
