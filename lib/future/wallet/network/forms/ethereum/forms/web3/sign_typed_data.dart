import 'package:on_chain_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/ethereum/client/ethereum.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/models/sign_typed_data.dart';

class Web3EthereumSignTypedDataForm extends EthereumWeb3Form<EthereumClient?,
    IEthAddress, Web3EthreumTypdedData> {
  Web3EthereumSignTypedDataForm({required this.request});

  @override
  Web3EthereumRequest<dynamic, Web3EthreumTypdedData> request;
}
