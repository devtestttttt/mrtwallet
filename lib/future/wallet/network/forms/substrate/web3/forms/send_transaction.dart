import 'package:on_chain_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/substrate/client/substrate.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';

class Web3SubstrateSendTransactionForm extends SubstrateWeb3Form<
    SubstrateClient, ISubstrateAddress, Web3SubstrateSendTransaction> {
  Web3SubstrateSendTransactionForm(this.request);
  @override
  Web3SubstrateRequest<Web3SubstrateSendTransactionResponse,
      Web3SubstrateSendTransaction> request;
}
