import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/solana/solana.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/web3/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'fields/sign_message.dart';

class SolanaWeb3GlobalFieldsView<RESPONSE,
    T extends Web3SolanaRequestParam<RESPONSE>> extends StatelessWidget {
  const SolanaWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SolanaRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      controller: () => Web3SolanaGlobalRequestController<RESPONSE, T>(
          walletProvider: wallet, request: request),
      showRequestAccount: false,
      builder: (context, controller) {
        return [
          _GlobalFieldsView(form: controller.form, controller: controller)
        ];
      },
      request: request,
    );
  }
}

class _GlobalFieldsView extends StatelessWidget {
  const _GlobalFieldsView({required this.form, required this.controller});
  final SolanaWeb3Form form;
  final Web3SolanaGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3SolanaRequestMethods.signMessage:
      case Web3SolanaRequestMethods.signIn:
        return SolanaWeb3SignMessageRequestView(
            request: form as Web3SolanaSignMessageForm);

      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
