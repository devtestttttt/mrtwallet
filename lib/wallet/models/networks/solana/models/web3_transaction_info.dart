import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/params/models/transaction.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain/solana/src/borsh_serialization/program_layout.dart';

class SolanaWeb3TransactionInstructionInfo {
  final ProgramLayout layout;
  final SolAddress programAddress;
  final Map<String, dynamic>? content;

  SolanaWeb3TransactionInstructionInfo(
      {required this.layout,
      required this.programAddress,
      Map<String, dynamic>? content})
      : content = content?.imutable;
}

enum SolanaWeb3KnownTransactionInstructionType { transfer }

abstract class SolanaWeb3KnownTransactionInstruction {
  final SolanaWeb3KnownTransactionInstructionType type;
  const SolanaWeb3KnownTransactionInstruction({required this.type});
}

class SolanaWeb3TransactionTransferTokenInstruction
    extends SolanaWeb3KnownTransactionInstruction {
  final SolAddress to;
  final IntegerBalance amount;
  const SolanaWeb3TransactionTransferTokenInstruction(
      {required this.to, required this.amount})
      : super(type: SolanaWeb3KnownTransactionInstructionType.transfer);
}

class SolanaWeb3TransactionInfo {
  final Web3SolanaSendTransactionOptions? sendTransactionOptions;
  SolanaTransaction _transaction;
  SolanaTransaction get transaction => _transaction;
  final IntegerBalance accountChange;
  final SolAddress feePayer;
  final ISolanaAddress signer;
  final List<SolanaWeb3TransactionInstructionInfo> instructions;
  SolanaWeb3SimulationStatus _status = SolanaWeb3SimulationStatus.idle;
  SolanaWeb3SimulationStatus get status => _status;
  SolanaWeb3FeeStatus _feeStatus = SolanaWeb3FeeStatus.idle;
  SolanaWeb3FeeStatus get feeStatus => _feeStatus;
  late final SimulateTranasctionResponse _simulate;
  SimulateTranasctionResponse get simulateInfo => _simulate;
  bool get canUpdateBlockHash => _transaction.signers.length == 1;

  final IntegerBalance fee;

  void setFeeErr() {
    _feeStatus = SolanaWeb3FeeStatus.error;
  }

  void setFeePending() {
    _feeStatus = SolanaWeb3FeeStatus.pending;
  }

  void setFee(BigInt? fee) {
    if (this.fee.isZero) {
      this.fee.updateBalance(fee);
    }
    if (this.fee.isZero) {
      setFeeErr();
    } else {
      _feeStatus = SolanaWeb3FeeStatus.success;
    }
  }

  void setSimulateErr() {
    _status = SolanaWeb3SimulationStatus.error;
  }

  void setSimulatePending() {
    _status = SolanaWeb3SimulationStatus.pending;
  }

  void setSimulateSuccess(SimulateTranasctionResponse simulate) {
    if (status == SolanaWeb3SimulationStatus.success ||
        status == SolanaWeb3SimulationStatus.simulateError) {
      return;
    }
    _simulate = simulate;
    if (_simulate.err != null) {
      _status = SolanaWeb3SimulationStatus.simulateError;
    } else {
      _status = SolanaWeb3SimulationStatus.success;
    }
  }

  void updateTransaction(SolanaTransaction transaction) {
    if (transaction.signers.length != 1) return;
    final signer = transaction.signers[0];
    if (this.signer.networkAddress != signer) return;
    if (!CompareUtils.iterableIsEqual(transaction.message.compiledInstructions,
        this.transaction.message.compiledInstructions)) {
      return;
    }
    _transaction = transaction;
  }

  SolanaWeb3TransactionInfo._({
    required SolanaTransaction transaction,
    required this.accountChange,
    required this.feePayer,
    required List<SolanaWeb3TransactionInstructionInfo> instructions,
    required this.fee,
    required this.signer,
    this.sendTransactionOptions,
  })  : instructions = instructions.imutable,
        _transaction = transaction;
  factory SolanaWeb3TransactionInfo({
    required SolanaTransaction transaction,
    required ISolanaAddress signer,
    Web3SolanaSendTransactionOptions? sendTransactionOptions,
    required WalletSolanaNetwork network,
  }) {
    final accounts = transaction.message.accountKeys;
    final List<SolanaWeb3TransactionInstructionInfo> instructions = [];
    for (final i in transaction.message.compiledInstructions) {
      final programId = accounts[i.programIdIndex];
      final layout = ProgramLayout.fromBytes(
          programId: programId, instructionBytes: i.data);

      final content = layout.toJson();
      final instructionInfo = SolanaWeb3TransactionInstructionInfo(
          layout: layout,
          programAddress: programId,
          content: content.isEmpty ? null : content);
      instructions.add(instructionInfo);
    }
    return SolanaWeb3TransactionInfo._(
        transaction: transaction,
        accountChange: IntegerBalance.zero(network.token),
        feePayer: accounts[0],
        instructions: instructions,
        fee: IntegerBalance.zero(network.token),
        signer: signer,
        sendTransactionOptions: sendTransactionOptions);
  }
}

class SolanaWeb3SignedTransactionInfo {
  final SolanaWeb3TransactionInfo info;
  final List<int> signature;
  SolanaWeb3SignedTransactionInfo(
      {required this.info, required List<int> signature})
      : signature = signature.asImmutableBytes;
}

enum SolanaWeb3SimulationStatus {
  error,
  simulateError,
  success,
  pending,
  idle;

  bool get canRetry => this == idle || this == error;
  bool get isError => this == error;
  bool get isSuccess => this == success;
  bool get isPending => this == pending;
  bool get hasSimulateError => this == error || this == simulateError;
}

enum SolanaWeb3FeeStatus {
  error,
  success,
  pending,
  idle;

  bool get canRetry => this == idle || this == error;
  bool get isError => this == error;
  bool get isPending => this == pending;
}
