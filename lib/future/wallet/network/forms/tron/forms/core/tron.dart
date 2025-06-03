import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/permission/models/permission.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';

abstract class TronTransactionForm extends TransactionForm<TronClient,
    ITronAddress, WalletTronNetwork, TronChain> {
  BigInt get callValue;
  BigInt get tokenValue;
  @override
  String? validateError();
  TransactionContractType get type;
  DynamicVoid? onStimateChanged;
  TronAddress? get destinationAccount;
  TronAddress? get smartContractAddress;
  TronBaseContract toContract();
  TronWalletTransaction toWalletTransaction({required String txId});
  bool get showTxInfo => true;
}

abstract class TronTransactionOperationForm extends TronTransactionForm {
  @override
  TronWalletTransaction toWalletTransaction({required String txId}) {
    return TronWalletTransaction(
        txId: txId,
        network: network,
        totalOutput:
            WalletTransactionIntegerAmount(amount: callValue, network: network),
        // totalInput: callValue,
        outputs: [TronWalletTransactionOperationOutput(name: type.name)]);
  }
}

abstract class TronWeb3Form<CLIENT extends TronClient?,
        ADDRESS extends ITronAddress?, PARAMS extends Web3TronRequestParam>
    extends Web3Form<TronAddress, CLIENT, ADDRESS, WalletTronNetwork, TronChain,
        ITronAddress, Web3TronChainAccount, Web3TronChain, PARAMS> {
  abstract final Web3TronRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
