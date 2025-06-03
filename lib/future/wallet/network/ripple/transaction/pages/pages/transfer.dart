import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/pages/pages/ripple_tranaction_fields_view.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class RippleTransferTransactionView extends StatelessWidget {
  const RippleTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final RippleIssueToken? issueToken = context.getNullArgruments();
    return RippleTransactionFieldsView(
        field: LiveTransactionForm(
            validator: RipplePaymentForm(issueToken == null
                ? null
                : XRPPickedAssets.account(issueToken))));
  }
}
