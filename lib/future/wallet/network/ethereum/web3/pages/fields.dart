import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/state.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'fields/add_ethereum_chains.dart';
import 'transaction.dart';

class EthereumWeb3FieldsView extends StatelessWidget {
  const EthereumWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3EthereumRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3EthereumRequestMethods.persoalSign:
      case Web3EthereumRequestMethods.ethSign:
        return EthereumWeb3GlobalFieldsView<String, Web3EthreumPersonalSign>(
          request:
              request as Web3EthereumRequest<String, Web3EthreumPersonalSign>,
          wallet: wallet,
        );
      case Web3EthereumRequestMethods.typedData:
        return EthereumWeb3GlobalFieldsView<String, Web3EthreumTypdedData>(
            request:
                request as Web3EthereumRequest<String, Web3EthreumTypdedData>,
            wallet: wallet);
      case Web3EthereumRequestMethods.addEthereumChain:
        return EthereumWeb3AddEthereumChainView(
          request:
              request as Web3EthereumRequest<String, Web3EthereumAddNewChain>,
          wallet: wallet,
        );
      case Web3EthereumRequestMethods.requestAccounts:
        return EthereumWeb3GlobalFieldsView(
          request: request,
          wallet: wallet,
        );
      case Web3EthereumRequestMethods.switchEthereumChain:
        return EthereumWeb3GlobalFieldsView(
          request: request,
          wallet: wallet,
        );
      case Web3EthereumRequestMethods.sendTransaction:
        return EthereumWeb3TransactionFieldsView(
          request: request
              as Web3EthereumRequest<String, Web3EthreumSendTransaction>,
          wallet: wallet,
        );
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
