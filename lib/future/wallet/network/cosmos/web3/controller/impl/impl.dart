import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3CosmosImpl<RESPONSE,
        T extends Web3CosmosRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletCosmosNetwork,
        CosmosClient,
        ICosmosAddress,
        CosmosChain,
        Web3CosmosChainAccount,
        Web3CosmosChain,
        T,
        Web3CosmosRequest<RESPONSE, T>> {
  Web3CosmosImpl({required super.walletProvider, required super.request});
}
