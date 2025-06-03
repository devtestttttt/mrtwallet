import 'package:on_chain_wallet/wallet/api/client/networks/ton/client/ton.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/ton.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart' as ton_dart;

enum TonTransactionType { ton, jetton }

abstract class TonTransactionForm extends TransactionForm<TonClient,
    ITonAddress, WalletTonNetwork, TheOpenNetworkChain> {
  TonTransactionForm();
  BigInt get callValue;
  @override
  String? validateError();
  List<ton_dart.MessageRelaxed> toMessages();
  TonWalletTransaction toWalletTransaction({required String txId});
}

abstract class TonWeb3Form<CLIENT extends TonClient?,
        ADDRESS extends ITonAddress?, PARAMS extends Web3TonRequestParam>
    extends Web3Form<
        ton_dart.TonAddress,
        CLIENT,
        ADDRESS,
        WalletTonNetwork,
        TheOpenNetworkChain,
        ITonAddress,
        Web3TonChainAccount,
        Web3TonChain,
        PARAMS> {
  abstract final Web3TonRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
