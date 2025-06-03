import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/cosmos/forms/core/cosmos.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/cosmos/forms/import_chain/import.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/cosmos/cosmos.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/cosmos.dart';

class Web3CosmosAddNewChainForm extends CosmosWeb3Form<CosmosClient?,
    ICosmosAddress?, Web3CosmosAddNewChain> {
  Web3CosmosAddNewChainForm({required this.request});
  final CosmosAddNewChainFrom form = CosmosAddNewChainFrom();

  @override
  Web3CosmosRequest<bool, Web3CosmosAddNewChain> request;

  void importChain() {
    onCompleteForm?.call(true);
  }

  @override
  Future<void> initForm(
      {required CosmosChain account,
      required ICosmosAddress? address,
      required WalletCosmosNetwork network,
      required CosmosClient? client}) async {
    await super.initForm(
        account: account, address: address, network: network, client: client);
    await MethodUtils.call(() => form.initForm());
    form.onChanged = onChanged;
    final params = request.params;
    form.buildFromWeb3Request(
        chainId: params.chainId,
        rpc: params.rpc,
        feeTokens: params.feeTokens,
        nativeToken: params.nativeToken,
        name: params.name);
  }
}
