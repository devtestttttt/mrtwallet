import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'transaction.dart';

class SolanaTransferTransactionView extends StatelessWidget {
  const SolanaTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final SolanaChain? chain = context.getNullArgruments();
    final SolanaSPLToken? splToken = context.getNullArgruments();

    return SolanaTransactionFieldsView(
        field: LiveTransactionForm(
            validator: SolanaTransferForm(
                token: chain?.network.coinParam.token ?? splToken!.token,
                splToken: splToken)));
  }
}
