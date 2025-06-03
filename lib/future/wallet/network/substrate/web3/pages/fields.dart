import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'global.dart';
import 'transaction.dart';

class SubstrateWeb3FieldsView extends StatelessWidget {
  const SubstrateWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3SubstrateRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3SubstrateRequestMethods.requestAccounts:
        return SubstrateWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3SubstrateRequestMethods.signMessage:
        return SubstrateWeb3GlobalFieldsView<Map<String, dynamic>,
            Web3SubstrateSignMessage>(request: request.cast(), wallet: wallet);
      case Web3SubstrateRequestMethods.addSubstrateChain:
        return SubstrateWeb3GlobalFieldsView<bool, Web3SubstrateAddNewChain>(
            request: request.cast(), wallet: wallet);
      case Web3SubstrateRequestMethods.signTransaction:
        return SubstrateWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
