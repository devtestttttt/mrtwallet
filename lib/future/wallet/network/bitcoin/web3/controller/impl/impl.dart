import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3BitcoinImpl<RESPONSE,
        T extends Web3BitcoinRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletBitcoinNetwork,
        BitcoinClient,
        IBitcoinAddress,
        BitcoinChain,
        Web3BitcoinChainAccount,
        Web3BitcoinChain,
        T,
        Web3BitcoinRequest<RESPONSE, T>> {
  Web3BitcoinImpl({required super.walletProvider, required super.request});
}
