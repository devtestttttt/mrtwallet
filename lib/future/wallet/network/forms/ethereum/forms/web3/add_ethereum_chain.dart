import 'package:on_chain_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/ethereum/client/ethereum.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/models/add_eth_chain.dart';

class Web3EthereumAddNewChainForm extends EthereumWeb3Form<EthereumClient?,
    IEthAddress?, Web3EthereumAddNewChain> {
  Web3EthereumAddNewChainForm({required this.request});

  @override
  Web3EthereumRequest<dynamic, Web3EthereumAddNewChain> request;
}
