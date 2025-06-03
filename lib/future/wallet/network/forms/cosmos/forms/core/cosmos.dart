import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/cosmos/cosmos.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/cosmos/models/transaction_output.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/cosmos.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/cosmos.dart';

abstract class CosmosTransactionForm extends TransactionForm<CosmosClient,
    ICosmosAddress, WalletCosmosNetwork, CosmosChain> {
  BigInt get callValue;

  CosmosWalletTransaction toWalletTransaction(String txId);
  @override
  String? validateError();
  List<ServiceMessage> messages();
  void setFeeToken(CosmosTransactionFeeInfo fee) {}
}

abstract class CosmosWeb3Form<CLIENT extends CosmosClient?,
        ADDRESS extends ICosmosAddress?, PARAMS extends Web3CosmosRequestParam>
    extends Web3Form<
        CosmosBaseAddress,
        CLIENT,
        ADDRESS,
        WalletCosmosNetwork,
        CosmosChain,
        ICosmosAddress,
        Web3CosmosChainAccount,
        Web3CosmosChain,
        PARAMS> {
  abstract final Web3CosmosRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }

  @override
  void close() {
    super.close();
    onCompleteForm = null;
  }
}
