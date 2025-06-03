import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:on_chain/solana/solana.dart';

enum SolanaTransactionType {
  native("Native transfer"),
  spl("Token transfer"),
  createAssociatedTokenAccount("Create associated token account"),
  createAccount("Create account"),
  initializeMint("Initialize mint"),
  mintTo("Mint to");

  final String operationName;
  const SolanaTransactionType(this.operationName);
}

abstract class SolanaTransactionForm extends TransactionForm<SolanaClient,
    ISolanaAddress, WalletSolanaNetwork, SolanaChain> {
  BigInt get transferValue;
  SolanaTransactionType get mode;
  DynamicVoid? onStimateChanged;

  @override
  String? validateError();

  Future<List<TransactionInstruction>> instructions();

  SolanaWalletTransaction toWalletTransaction({required String txId});
}

abstract class SolanaWeb3Form<CLIENT extends SolanaClient?,
        ADDRESS extends ISolanaAddress?, PARAMS extends Web3SolanaRequestParam>
    extends Web3Form<
        SolAddress,
        CLIENT,
        ADDRESS,
        WalletSolanaNetwork,
        SolanaChain,
        ISolanaAddress,
        Web3SolanaChainAccount,
        Web3SolanaChain,
        PARAMS> {
  abstract final Web3SolanaRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
