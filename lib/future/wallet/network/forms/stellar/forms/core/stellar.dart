import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';

abstract class StellarTransactionForm extends TransactionForm<StellarClient,
    IStellarAddress, WalletStellarNetwork, StellarChain> {
  BigInt get callValue;
  DynamicVoid? onReadyField;
  @override
  String? validateError();
  List<Operation> toOperations();
  int get operations;
  bool get hasUnknowReceipt;
}

abstract class StellarWeb3Form<
        CLIENT extends StellarClient?,
        ADDRESS extends IStellarAddress?,
        PARAMS extends Web3StellarRequestParam>
    extends Web3Form<
        StellarAddress,
        CLIENT,
        ADDRESS,
        WalletStellarNetwork,
        StellarChain,
        IStellarAddress,
        Web3StellarChainAccount,
        Web3StellarChain,
        PARAMS> {
  abstract final Web3StellarRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
