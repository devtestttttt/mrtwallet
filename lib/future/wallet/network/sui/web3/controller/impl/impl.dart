import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3SuiImpl<RESPONSE, T extends Web3SuiRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletSuiNetwork,
        SuiClient,
        ISuiAddress,
        SuiChain,
        Web3SuiChainAccount,
        Web3SuiChain,
        T,
        Web3SuiRequest<RESPONSE, T>> {
  Web3SuiImpl({required super.walletProvider, required super.request});
}
