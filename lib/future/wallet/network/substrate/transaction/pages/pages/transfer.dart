import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'transaction.dart';

class SubstrateTransferTransactionView extends StatelessWidget {
  const SubstrateTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SubstrateTransactionFieldsView(
        field: LiveTransactionForm(validator: SubstrateTransferForm()));
  }
}
