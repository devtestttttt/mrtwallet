import 'package:on_chain_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/ton/ton.dart';
import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3TonImpl<RESPONSE, T extends Web3TonRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletTonNetwork,
        TonClient,
        ITonAddress,
        TheOpenNetworkChain,
        Web3TonChainAccount,
        Web3TonChain,
        T,
        Web3TonRequest<RESPONSE, T>> {
  Web3TonImpl({required super.walletProvider, required super.request});

  TonWeb3Form _buildForm() {
    switch (request.params.method) {
      case Web3TonRequestMethods.signMessage:
        return Web3TonSignMessageForm<T>(request: request);
      case Web3TonRequestMethods.sendTransaction:
      case Web3TonRequestMethods.signTransaction:
        return Web3TonSendTransactionForm(
            request: request as Web3TonRequest<Web3TonSendTransactionResponse,
                Web3TonSendTransaction>);
      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm<TonWeb3Form> liveRequest =
      LiveTransactionForm(validator: _buildForm());
  TonWeb3Form get form => liveRequest.value;
}
