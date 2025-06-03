import 'package:on_chain_wallet/future/wallet/network/forms/stellar/forms/core/stellar.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/stellar/stellar.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/params/models/transaction.dart';

class Web3StellarSendTransactionForm extends StellarWeb3Form<StellarClient,
    IStellarAddress, Web3StellarSendTransaction> {
  Web3StellarSendTransactionForm(this.request);
  @override
  @override
  Web3StellarRequest<Web3StellarSendTransactionResponse,
      Web3StellarSendTransaction> request;
}
