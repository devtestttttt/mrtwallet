import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/sui.dart';
import 'package:on_chain/on_chain.dart';

enum SuiTransactionType {
  transfer,
  tokenTransfer;

  bool get isTokenTransfer => this == tokenTransfer;
}

abstract class SuiTransactionForm extends TransactionForm<SuiClient,
    ISuiAddress, WalletSuiNetwork, SuiChain> {
  BigInt get transferValue;
  DynamicVoid? onStimateChanged;
  SuiTransactionType get transactionType;

  @override
  String? validateError();

  Future<SuiProgrammableTransaction> createTransaction();

  SuiWalletTransaction toWalletTransaction({required String txId});
}

abstract class SuiWeb3Form<CLIENT extends SuiClient?,
        ADDRESS extends ISuiAddress?, PARAMS extends Web3SuiRequestParam>
    extends Web3Form<SuiAddress, CLIENT, ADDRESS, WalletSuiNetwork, SuiChain,
        ISuiAddress, Web3SuiChainAccount, Web3SuiChain, PARAMS> {
  abstract final Web3SuiRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
