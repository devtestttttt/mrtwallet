import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/web3/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/web3/pages/fields/personal_sign.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/web3/pages/fields/typded_data_sign.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/ethereum/ethereum.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class EthereumWeb3GlobalFieldsView<RESPONSE,
    T extends Web3EthereumRequestParam<RESPONSE>> extends StatelessWidget {
  const EthereumWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3EthereumRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      controller: () => Web3EthereumGlobalRequestController<RESPONSE, T>(
          walletProvider: wallet, request: request),
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
  final EthereumWeb3Form form;
  final Web3EthereumGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3EthereumRequestMethods.typedData:
        return EthereumWeb3TypedDataSignRequestView(
            request: form as Web3EthereumSignTypedDataForm);
      case Web3EthereumRequestMethods.persoalSign:
      case Web3EthereumRequestMethods.ethSign:
        return EthereumWeb3PersonalSignRequestView(
            request: form as Web3EthereumPersonalSignForm);
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
