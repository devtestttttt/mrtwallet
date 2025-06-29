import 'package:on_chain_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/solana/solana.dart';
import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3SolanaImpl<RESPONSE,
        T extends Web3SolanaRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletSolanaNetwork,
        SolanaClient,
        ISolanaAddress,
        SolanaChain,
        Web3SolanaChainAccount,
        Web3SolanaChain,
        T,
        Web3SolanaRequest<RESPONSE, T>> {
  Web3SolanaImpl({required super.walletProvider, required super.request});

  SolanaWeb3Form _buildForm() {
    switch (request.params.method) {
      case Web3SolanaRequestMethods.signMessage:
      case Web3SolanaRequestMethods.signIn:
        return Web3SolanaSignMessageForm(request: request.cast());
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.signAndSendAllTransactions:
      case Web3SolanaRequestMethods.sendTransaction:
      case Web3SolanaRequestMethods.signAllTransactions:
        return Web3SolanaSendTransactionForm(
            request: request as Web3SolanaRequest<
                List<Web3SolanaTransactionResponse>,
                Web3SolanaSendTransaction>);
      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm<SolanaWeb3Form> liveRequest =
      LiveTransactionForm(validator: _buildForm());
  SolanaWeb3Form get form => liveRequest.value;
}
