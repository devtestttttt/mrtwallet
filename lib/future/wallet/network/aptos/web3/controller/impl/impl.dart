import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3AptosImpl<RESPONSE,
        T extends Web3AptosRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletAptosNetwork,
        AptosClient,
        IAptosAddress,
        AptosChain,
        Web3AptosChainAccount,
        Web3AptosChain,
        T,
        Web3AptosRequest<RESPONSE, T>> {
  Web3AptosImpl({required super.walletProvider, required super.request});
}
