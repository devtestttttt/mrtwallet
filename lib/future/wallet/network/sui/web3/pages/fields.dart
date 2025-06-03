import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/state.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'global.dart';
import 'transaction.dart';

class SuiWeb3FieldsView extends StatelessWidget {
  const SuiWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3SuiRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3SuiRequestMethods.requestAccounts:
        return SuiWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
        return SuiWeb3GlobalFieldsView<Map<String, dynamic>,
                Web3SuiSignMessage>(
            request: request
                as Web3SuiRequest<Map<String, dynamic>, Web3SuiSignMessage>,
            wallet: wallet);
      case Web3SuiRequestMethods.signTransaction:
      case Web3SuiRequestMethods.signAndExecuteTransaction:
      case Web3SuiRequestMethods.signTransactionBlock:
      case Web3SuiRequestMethods.signAndExecuteTransactionBlock:
        return SuiWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
