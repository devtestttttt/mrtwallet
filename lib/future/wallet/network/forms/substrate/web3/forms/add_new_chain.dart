import 'package:on_chain_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/substrate/client/substrate.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';

class Web3SubstrateAddNewChainForm extends SubstrateWeb3Form<SubstrateClient?,
    ISubstrateAddress?, Web3SubstrateAddNewChain> {
  Web3SubstrateAddNewChainForm({required this.request, required this.chain});

  final SubstrateChain? chain;

  @override
  Web3SubstrateRequest<bool, Web3SubstrateAddNewChain> request;
  Web3SubstrateAddNewChain get params => request.params;
}
