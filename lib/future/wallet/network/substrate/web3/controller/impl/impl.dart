import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/web3/controller/controller.dart';
import 'package:on_chain_wallet/wallet/api/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3SubstrateImpl<RESPONSE,
        T extends Web3SubstrateRequestParam<RESPONSE>>
    extends Web3NetworkRequestControllerState<
        RESPONSE,
        WalletSubstrateNetwork,
        SubstrateClient,
        ISubstrateAddress,
        SubstrateChain,
        Web3SubstrateChainAccount,
        Web3SubstrateChain,
        T,
        Web3SubstrateRequest<RESPONSE, T>> {
  Web3SubstrateImpl({required super.walletProvider, required super.request});

  SubstrateWeb3Form _buildForm() {
    switch (request.params.method) {
      case Web3SubstrateRequestMethods.signMessage:
        return Web3SubstrateSignMessageForm<T>(request: request);
      case Web3SubstrateRequestMethods.addSubstrateChain:
        final param = request.params.cast<Web3SubstrateAddNewChain>();
        final chain = walletProvider.wallet
            .getChains<SubstrateChain>()
            .firstWhereOrNull(
                (e) => e.network.genesisBlock == param.genesisHash);
        return Web3SubstrateAddNewChainForm(
            request: request.cast(), chain: chain);

      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm<SubstrateWeb3Form> liveRequest =
      LiveTransactionForm(validator: _buildForm());
  SubstrateWeb3Form get form => liveRequest.value;
}
