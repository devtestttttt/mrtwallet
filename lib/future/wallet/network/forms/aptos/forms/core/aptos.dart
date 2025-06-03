import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:on_chain/on_chain.dart';

enum AptosTransactionType {
  transfer,
  tokenTransfer;

  bool get isTokenTransfer => this == tokenTransfer;
}

abstract class AptosTransactionForm extends TransactionForm<AptosClient,
    IAptosAddress, WalletAptosNetwork, AptosChain> {
  BigInt get transferValue;
  DynamicVoid? onStimateChanged;
  AptosTransactionType get transactionType;

  @override
  String? validateError();

  AptosTransactionPayload createTransaction();

  AptosWalletTransaction toWalletTransaction({required String txId});
}

abstract class AptosWeb3Form<ADDRESS extends IAptosAddress?,
        CLIENT extends AptosClient?, PARAMS extends Web3AptosRequestParam>
    extends Web3Form<
        AptosAddress,
        CLIENT,
        ADDRESS,
        WalletAptosNetwork,
        AptosChain,
        IAptosAddress,
        Web3AptosChainAccount,
        Web3AptosChain,
        PARAMS> {
  abstract final Web3AptosRequest<dynamic, PARAMS> request;
  @override
  String get name => request.params.method.name;

  DynamicVoid? onStimateChanged;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
