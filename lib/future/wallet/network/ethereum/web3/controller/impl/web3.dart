import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/ethereum/client/ethereum.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3EthereumImpl<RESPONSE,
        T extends Web3EthereumRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletEthereumNetwork,
        EthereumClient,
        IEthAddress,
        EthereumChain,
        Web3EthereumChainAccount,
        Web3EthereumChain,
        T,
        Web3EthereumRequest<RESPONSE, T>> {
  Web3EthereumImpl({required super.walletProvider, required super.request});
}
