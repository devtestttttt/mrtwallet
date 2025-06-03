import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/tron/client/tron.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3TronImpl<RESPONSE, T extends Web3TronRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletTronNetwork,
        TronClient,
        ITronAddress,
        TronChain,
        Web3TronChainAccount,
        Web3TronChain,
        T,
        Web3TronRequest<RESPONSE, T>> {
  Web3TronImpl({required super.walletProvider, required super.request});
}
