import 'package:on_chain_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/ethereum/client/ethereum.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/models/personal_sign.dart';

class Web3EthereumPersonalSignForm extends EthereumWeb3Form<EthereumClient?,
    IEthAddress, Web3EthreumPersonalSign> {
  Web3EthereumPersonalSignForm({required this.request});

  @override
  Web3EthereumRequest<dynamic, Web3EthreumPersonalSign> request;
}
