import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/solana/solana.dart';
import 'package:on_chain_wallet/wallet/models/networks/solana/models/web3_transaction_info.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaSendTransactionForm extends SolanaWeb3Form<SolanaClient,
    ISolanaAddress, Web3SolanaSendTransaction> {
  Web3SolanaSendTransactionForm({required this.request});
  List<SolanaWeb3TransactionInfo> _transactions = [];
  List<SolanaWeb3TransactionInfo> get transaction => _transactions;
  late SolanaClient _client;
  late final IntegerBalance fee =
      IntegerBalance.zero(request.chain.network.token);

  Future<void> simulate(SolanaWeb3TransactionInfo transaction) async {
    if (transaction.status.canRetry) {
      transaction.setSimulatePending();
      onChanged?.call();
      final preflightCommitment =
          transaction.sendTransactionOptions?.preflightCommitment;
      final slot = transaction.sendTransactionOptions?.minContextSlot;
      final result = await MethodUtils.call(() async => await _client.simulate(
          transaction: transaction.transaction,
          account: transaction.signer.networkAddress,
          minContextSlot: slot == null ? null : MinContextSlot(slot: slot),
          commitment: preflightCommitment == null
              ? Commitment.processed
              : Commitment.fromName(preflightCommitment)));
      if (result.hasError) {
        transaction.setSimulateErr();
      } else {
        transaction.setSimulateSuccess(result.result);
        if (transaction.simulateInfo.accounts?.isNotEmpty ?? false) {
          transaction.accountChange
              .updateBalance(transaction.simulateInfo.accounts?[0]?.lamports);
        }
      }
    }
    onChanged?.call();
  }

  Future<void> getFee(SolanaWeb3TransactionInfo transaction) async {
    if (transaction.feeStatus.canRetry) {
      transaction.setFeePending();
      onChanged?.call();
      final result = await MethodUtils.call(
          () async => await _client.getFee(transaction.transaction));
      if (result.hasError) {
        transaction.setFeeErr();
      } else {
        transaction.setFee(result.result);
      }
    }
    final totalFee =
        _transactions.fold(BigInt.zero, (p, c) => p + c.fee.balance);
    fee.updateBalance(totalFee);
    onChanged?.call();
  }

  Future<void> replateBlockHash() async {
    SolAddress? blockHash;
    for (final i in transaction) {
      if (!i.canUpdateBlockHash) continue;
      blockHash ??= await _client.getBlockHash();
      final updateMessage =
          i.transaction.message.copyWith(recentBlockhash: blockHash);
      final newTransaction = SolanaTransaction.fromMessage(updateMessage);
      i.updateTransaction(newTransaction);
    }
  }

  @override
  Future<void> initForm(
      {required SolanaChain account,
      required ISolanaAddress address,
      required WalletSolanaNetwork network,
      required SolanaClient client,
      List<SolanaWeb3TransactionInfo> transactions = const []}) async {
    await super.initForm(
        account: account, address: address, network: network, client: client);
    _transactions = transactions;
    _client = client;
    for (final i in _transactions) {
      simulate(i);
      getFee(i);
    }
  }

  @override
  Web3SolanaRequest<List<Web3SolanaTransactionResponse>,
      Web3SolanaSendTransaction> request;
}
