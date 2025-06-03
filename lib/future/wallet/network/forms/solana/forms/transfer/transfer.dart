import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class SolanaTransferForm extends SolanaTransactionForm {
  SolanaTransferForm({required this.token, this.splToken});
  BigInt _transferValue = BigInt.zero;
  @override
  BigInt get transferValue => _transferValue;
  final Token token;
  final SolanaSPLToken? splToken;

  bool get isTokenTransfer => splToken != null;

  void checkAmount() {
    _transferValue =
        destination.value.fold(BigInt.zero, (p, c) => p + c.balance.balance);
  }

  BigInt max(SolanaOutputWithBalance receiver) {
    if (isTokenTransfer) {
      return splToken!.balance.balance - receiver.balance.balance;
    }
    return (address.address.currencyBalance -
        _transferValue +
        receiver.balance.balance);
  }

  final TransactionListFormField<SolanaOutputWithBalance> destination =
      TransactionListFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });

  @override
  String get name => "transfer".tr;
  void removeReceiver(SolanaOutputWithBalance destination) {
    this.destination.removeValue(destination);
    checkAmount();
    onChanged?.call();
  }

  void setupAccountAmount(SolanaOutputWithBalance destination, BigInt? amount) {
    if (amount == null) return;
    destination.updateBalance(amount);
    checkAmount();
    onChanged?.call();
  }

  String? filterAddress(SolAddress address) {
    if (address == this.address.networkAddress ||
        destination.value.any((e) => e.address.networkAddress == address)) {
      return "some_addresses_exist".tr;
    }
    return null;
  }

  void onAddRecever(
      List<ReceiptAddress<SolAddress>>? receiver, StringVoid onExists) {
    if (receiver == null) return;
    MethodUtils.after(() async {
      bool hasExistAccount = false;
      for (final i in receiver) {
        final r = SolanaOutputWithBalance(address: i, token: token);
        if (destination.value.contains(r) ||
            i.networkAddress == address.networkAddress) {
          hasExistAccount = true;
          continue;
        }
        destination.addValue(r);
      }
      if (hasExistAccount) onExists("some_addresses_exist".tr);
      onChanged?.call();
    });
  }

  @override
  String? validateError() {
    if (destination.isEmpty) {
      return "add_least_one_receipt".tr;
    }
    for (final i in destination.value) {
      if (!i.hasAmount) {
        return "input_for_each_entery".tr;
      }
      if (i.hasError) {
        return "invalid_address".tr;
      }
    }
    return null;
  }

  @override
  Future<List<TransactionInstruction>> instructions() async {
    final error = validateError();
    if (error != null) {
      throw WalletException(error);
    }
    final List<TransactionInstruction> instructions = [];
    for (final i in destination.value) {
      final instruction = await i.instruction(
          owner: address.networkAddress, client: client, token: splToken);
      instructions.addAll(instruction);
    }

    return instructions;
  }

  @override
  SolanaTransactionType get mode => isTokenTransfer
      ? SolanaTransactionType.spl
      : SolanaTransactionType.native;

  @override
  void close() {
    destination.clear();
    _transferValue = BigInt.zero;
    super.close();
  }

  @override
  late final bool enableSwitchAccount = !isTokenTransfer;

  @override
  SolanaWalletTransaction toWalletTransaction({required String txId}) {
    final outputs = destination.value
        .map((e) => SolanaWalletTransactionTransferOutput(
            to: e.address.networkAddress,
            amount: WalletTransactionIntegerAmount(
                amount: e.balance.balance,
                network: network,
                token: splToken?.token,
                tokenIdentifier: splToken?.mint.address)))
        .toList();
    final total = outputs.fold<BigInt>(
        BigInt.zero, (p, c) => p + c.amount.amount.balance);
    return SolanaWalletTransaction(
        txId: txId,
        outputs: outputs,
        totalOutput: WalletTransactionIntegerAmount(
            amount: total, network: network, token: splToken?.token),
        network: network);
  }
}
