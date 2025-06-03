import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

enum BitcoinCashOprations { mint, burn, send }

abstract class BitcoinCashTokenOperation {
  BigInt get networkAmount;
  BigInt get tokenAmount;
  BitcoinBaseOutput toOutputs({String? utxosHash});
  bool get isReady;
  BitcoinOutputWithBalance get receiver;
  bool get isBurnable;
  BitcoinCashTokenOperation copyWith();
}

class BitcoinCashTransactionTokenOperation {
  factory BitcoinCashTransactionTokenOperation(
      {required CashToken cashToken,
      required String? utxoHash,
      required WalletBitcoinNetwork network}) {
    return BitcoinCashTransactionTokenOperation._(
        cashToken: BCHCashToken(cashToken: cashToken),
        utxoHash: utxoHash,
        nativeToken: network.token);
  }
  BitcoinCashTransactionTokenOperation._({
    required this.cashToken,
    required this.utxoHash,
    required this.nativeToken,
    List<BitcoinCashTokenOperation> operations = const [],
  }) : operation = List<BitcoinCashTokenOperation>.unmodifiable(operations);
  final Token nativeToken;
  final BCHCashToken cashToken;
  final String? utxoHash;
  Token get token => cashToken.balance.token;
  final List<BitcoinCashTokenOperation> operation;
  late final IntegerBalance totalAmount = IntegerBalance.token(
      operation.fold(BigInt.zero,
          (previousValue, element) => previousValue + element.networkAmount),
      nativeToken);
  late final IntegerBalance totalTokenAmount = IntegerBalance.token(
      operation.fold(BigInt.zero,
          (previousValue, element) => previousValue + element.tokenAmount),
      token);
  bool get isComplete => operation.isNotEmpty;
  List<BitcoinBaseOutput> outputs() {
    return operation.map((e) => e.toOutputs(utxosHash: utxoHash)).toList();
  }

  BitcoinCashTransactionTokenOperation copyWith(
      {BCHCashToken? cashToken,
      List<BitcoinCashTokenOperation>? operation,
      String? utxoHash,
      Token? nativeToken}) {
    return BitcoinCashTransactionTokenOperation._(
        cashToken: cashToken ?? this.cashToken,
        operations: operation ?? this.operation,
        utxoHash: utxoHash ?? this.utxoHash,
        nativeToken: nativeToken ?? this.nativeToken);
  }
}

class SpendBitcoinCashTokenOperation implements BitcoinCashTokenOperation {
  SpendBitcoinCashTokenOperation({required this.receiver});
  @override
  final BitcoinOutputWithBalance receiver;

  @override
  BitcoinBaseOutput toOutputs({String? utxosHash}) {
    return receiver.toOutput(utxoHash: utxosHash);
  }

  @override
  BigInt get networkAmount => receiver.balance.balance;

  @override
  BigInt get tokenAmount => receiver.tokenBalance?.balance ?? BigInt.zero;

  @override
  bool get isReady => receiver.isReady;

  @override
  bool get isBurnable => false;

  @override
  BitcoinCashTokenOperation copyWith() {
    return SpendBitcoinCashTokenOperation(receiver: receiver.copyWith());
  }
}

class BurnableBitcoinCashTokenOperation implements BitcoinCashTokenOperation {
  BurnableBitcoinCashTokenOperation({required this.receiver});
  @override
  final BitcoinBurnableUtxoWithBalance receiver;
  @override
  BurnableBitcoinCashTokenOperation copyWith() {
    return BurnableBitcoinCashTokenOperation(receiver: receiver.copyWith());
  }

  @override
  BitcoinBaseOutput toOutputs({String? utxosHash}) {
    return receiver.toOutput(utxoHash: utxosHash);
  }

  @override
  BigInt get networkAmount => BigInt.zero;

  @override
  BigInt get tokenAmount => receiver.tokenBalance?.balance ?? BigInt.zero;

  @override
  bool get isReady => receiver.isReady;
  @override
  bool get isBurnable => true;
}
