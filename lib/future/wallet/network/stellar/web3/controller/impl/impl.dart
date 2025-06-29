import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3StellarImpl<RESPONSE,
        T extends Web3StellarRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletStellarNetwork,
        StellarClient,
        IStellarAddress,
        StellarChain,
        Web3StellarChainAccount,
        Web3StellarChain,
        T,
        Web3StellarRequest<RESPONSE, T>> {
  Web3StellarImpl({required super.walletProvider, required super.request});

  StellarWeb3Form _buildForm() {
    switch (request.params.method) {
      case Web3StellarRequestMethods.signMessage:
        return Web3StellarSignMessageForm<T>(request: request);

      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm<StellarWeb3Form> liveRequest =
      LiveTransactionForm(validator: _buildForm());
  StellarWeb3Form get form => liveRequest.value;
}
