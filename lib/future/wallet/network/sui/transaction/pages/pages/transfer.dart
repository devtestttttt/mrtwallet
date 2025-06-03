import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'transaction.dart';

class SuiTransferTransactionView extends StatelessWidget {
  const SuiTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final SuiToken? token = context.getNullArgruments();
    return SuiTransactionFieldsView(
        field: LiveTransactionForm(validator: SuiTransferForm(token)));
  }
}
