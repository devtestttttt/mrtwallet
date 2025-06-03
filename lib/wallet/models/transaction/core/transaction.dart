import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/euqatable/equatable.dart';
import 'package:on_chain_wallet/app/models/models/image.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/constant/constant.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

enum WalletTransactionType {
  send(0),
  web3(1);

  final int value;
  const WalletTransactionType(this.value);
  static WalletTransactionType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw WalletExceptionConst.dataVerificationFailed,
    );
  }
}

class WalletAccountTransactions<TRANSACTION extends ChainTransaction> {
  List<TRANSACTION> _transactions;
  List<TRANSACTION> get transactions => _transactions;
  WalletAccountTransactions._({required List<TRANSACTION> transactions})
      : _transactions = transactions.immutable;
  factory WalletAccountTransactions({required List<TRANSACTION> transactions}) {
    final txes = transactions.clone();
    txes.sort((a, b) => b.time.compareTo(a.time));
    return WalletAccountTransactions._(transactions: txes);
  }
  void addTx(TRANSACTION tx) {
    List<TRANSACTION> txes = _transactions.clone();
    if (_transactions.contains(tx)) {
      txes.remove(tx);
      txes = [tx, ...txes];
    } else {
      txes.add(tx);
    }
    txes.sort((a, b) => b.time.compareTo(a.time));
    _transactions = txes.toSet().toImutableList;
  }

  void removeTx(TRANSACTION tx) {
    final txes = _transactions.clone();
    txes.remove(tx);
    txes.sort((a, b) => a.time.compareTo(b.time));
    _transactions = txes.immutable;
  }
}

class WalletWeb3ClientTransaction with CborSerializable {
  final String name;
  final String applicationId;
  final APPImage? image;
  const WalletWeb3ClientTransaction(
      {required this.name, required this.applicationId, required this.image});

  factory WalletWeb3ClientTransaction.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: CborTagsConst.transactionWeb3Client);
    return WalletWeb3ClientTransaction(
        name: values.elementAs(0),
        applicationId: values.elementAs(1),
        image: values.elemetMybeAs<APPImage, CborTagValue>(
            2, (e) => APPImage.deserialize(obj: e)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([name, applicationId, image?.toCbor()]),
        CborTagsConst.transactionWeb3Client);
  }
}

enum WalletTransactionStatus {
  pending(0),
  block(1),
  failed(2),
  unknown(3);

  final int value;
  const WalletTransactionStatus(this.value);

  bool get inMempool => this == pending;
  bool get isUnknown => this == unknown;

  static WalletTransactionStatus fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: 'Invalid wallet transaction status'),
    );
  }
}

abstract class ChainTransaction with CborSerializable, Equatable {
  final WalletTransactionType type;
  final String txId;
  final DateTime time;
  final WalletTransactionAmount? totalOutput;

  final List<WalletTransactionOutput> outputs;
  final WalletWeb3ClientTransaction? web3Client;
  WalletTransactionStatus _status;
  WalletTransactionStatus get status => _status;

  ChainTransaction(
      {required this.txId,
      required this.time,
      this.web3Client,
      required WalletTransactionAmount? totalOutput,
      required List<WalletTransactionOutput> outputs,
      required WalletTransactionStatus status,
      this.type = WalletTransactionType.send})
      : outputs = outputs.immutable,
        _status = status,
        totalOutput = (totalOutput?.amount.isZero ?? true) ? null : totalOutput;
  static T deserialize<T extends ChainTransaction>(WalletNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final transaction = switch (network.type) {
      NetworkType.cardano => ADAWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.aptos => AptosWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.bitcoinAndForked ||
      NetworkType.bitcoinCash =>
        BitcoinWalletTransaction.deserialize(network.toNetwork(),
            bytes: bytes, cborHex: cborHex, object: object),
      NetworkType.cosmos => CosmosWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.ethereum => EthWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.monero => MoneroWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.solana => SolanaWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.stellar => StellarWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.substrate => SubstrateWalletTransaction.deserialize(
          network.toNetwork(),
          bytes: bytes,
          cborHex: cborHex,
          object: object),
      NetworkType.sui => SuiWalletTransaction.deserialize(network.toNetwork(),
          bytes: bytes, cborHex: cborHex, object: object),
      NetworkType.ton => TonWalletTransaction.deserialize(network.toNetwork(),
          bytes: bytes, cborHex: cborHex, object: object),
      NetworkType.tron => TronWalletTransaction.deserialize(network.toNetwork(),
          bytes: bytes, cborHex: cborHex, object: object),
      NetworkType.xrpl => XRPWalletTransaction.deserialize(network.toNetwork(),
          bytes: bytes, cborHex: cborHex, object: object),
      _ => throw WalletExceptionConst.networkDoesNotExist,
    };
    if (transaction is! T) {
      throw WalletException.invalidArgruments(
          ["$T,${transaction.runtimeType}"]);
    }
    return transaction;
  }

  void updateStatus(WalletTransactionStatus status) {
    if (_status != WalletTransactionStatus.pending ||
        status == WalletTransactionStatus.pending) {
      return;
    }
    _status = status;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          txId,
          time,
          totalOutput?.toCbor(),
          CborListValue.fixedLength(outputs.map((e) => e.toCbor()).toList()),
          web3Client?.toCbor(),
          type.value,
          status.value
        ]),
        network.tag);
  }

  NetworkType get network;

  @override
  List get variabels => [txId];
}

enum WalletTransactionOutputType {
  transfer(CborTagsConst.transactionOutputTransfer),
  contract(CborTagsConst.transactionOutputOperation),
  operation(CborTagsConst.transactionOutputContract);

  const WalletTransactionOutputType(this.tag);
  final List<int> tag;

  static WalletTransactionOutputType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(tag, e.tag),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'invalid transaction output tag'));
  }
}

abstract class WalletTransactionOutput with CborSerializable {
  final WalletTransactionOutputType type;
  const WalletTransactionOutput({required this.type});
}

abstract class WalletTransactionOperationOutput
    extends WalletTransactionOutput {
  final String name;
  final String? content;
  final WalletTransactionAmount? amount;
  const WalletTransactionOperationOutput(
      {required this.name, this.content, this.amount})
      : super(type: WalletTransactionOutputType.operation);
}

abstract class WalletTransactionTransferOutput<NETWORKADDRESS>
    extends WalletTransactionOutput {
  final NETWORKADDRESS to;
  final WalletTransactionAmount amount;
  String get address;

  const WalletTransactionTransferOutput(
      {required this.to, required this.amount})
      : super(type: WalletTransactionOutputType.transfer);
}

enum WalletTransactionAmountType {
  integer(CborTagsConst.transactionIntegerAmount),
  decimals(CborTagsConst.transactionDecimalsAmount);

  final List<int> tag;
  const WalletTransactionAmountType(this.tag);

  static WalletTransactionAmountType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(tag, e.tag),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'invalid transaction amount tag'));
  }
}

abstract class WalletTransactionAmount<AMOUNT extends BalanceCore,
    TOKEN extends APPToken> with CborSerializable {
  final AMOUNT amount;
  final TOKEN? token;
  final String? tokenIdentifier;
  final WalletTransactionAmountType type;
  bool get isNativeToken => token == null;
  const WalletTransactionAmount(
      {required this.amount,
      required this.token,
      required this.tokenIdentifier,
      required this.type});

  factory WalletTransactionAmount.deserialize(WalletNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborTagValue values =
        CborSerializable.decode(cborBytes: bytes, hex: cborHex, object: object);
    final type = WalletTransactionAmountType.fromTag(values.tags);
    final WalletTransactionAmount amount = switch (type) {
      WalletTransactionAmountType.integer =>
        WalletTransactionIntegerAmount.deserialize(network,
            bytes: bytes, cborHex: cborHex, object: object),
      WalletTransactionAmountType.decimals =>
        WalletTransactionDecimalsAmount.deserialize(
            bytes: bytes, cborHex: cborHex, object: object),
    };
    if (amount is! WalletTransactionAmount<AMOUNT, TOKEN>) {
      throw WalletException.invalidArgruments([
        amount.runtimeType.toString(),
        "${WalletTransactionAmount<AMOUNT, TOKEN>}"
      ]);
    }
    return amount;
  }
}

class WalletTransactionIntegerAmount
    extends WalletTransactionAmount<IntegerBalance, Token> {
  WalletTransactionIntegerAmount(
      {required BigInt amount,
      required WalletNetwork network,
      super.token,
      super.tokenIdentifier})
      : super(
            type: WalletTransactionAmountType.integer,
            amount: IntegerBalance.token(amount, token ?? network.token,
                allowNegative: false, immutable: true));
  factory WalletTransactionIntegerAmount.deserialize(WalletNetwork network,
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionAmountType.integer.tag);
    return WalletTransactionIntegerAmount(
        amount: values.elementAs(0),
        token: values.elemetMybeAs<Token, CborTagValue>(
            1, (e) => Token.deserialize(obj: e)),
        tokenIdentifier: values.elementAs(2),
        network: network);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [amount.balance, token?.toCbor(), tokenIdentifier]),
        type.tag);
  }
}

class WalletTransactionDecimalsAmount
    extends WalletTransactionAmount<DecimalBalance, NonDecimalToken> {
  WalletTransactionDecimalsAmount(
      {required String amount,
      required NonDecimalToken super.token,
      super.tokenIdentifier})
      : super(
            type: WalletTransactionAmountType.decimals,
            amount: DecimalBalance.fromString(amount, token));
  factory WalletTransactionDecimalsAmount.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: WalletTransactionAmountType.decimals.tag);
    return WalletTransactionDecimalsAmount(
        amount: values.elementAs(0),
        token:
            NonDecimalToken.deserialize(obj: values.elementAs<CborTagValue>(1)),
        tokenIdentifier: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [amount.price, token?.toCbor(), tokenIdentifier]),
        type.tag);
  }
}
