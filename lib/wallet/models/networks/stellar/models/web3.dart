import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/stellar/models/transaction.dart';
import 'package:stellar_dart/stellar_dart.dart';

import 'operations.dart';

enum StellarWeb3TransactionType {
  v1("version_1"),
  feeBump("fee_bump_transaction");

  const StellarWeb3TransactionType(this.translate);
  final String translate;
}

class StellarWeb3TransactionDetails {
  final StellarSorobanTransactionDetais? soroban;
  final StellarMemoDetils memo;
  final IntegerBalance fee;
  final StellarReceiptWithActivityStatus source;
  final StellarWeb3TransactionType type;
  final List<StellarTransactionOperationDetails> operations;
  final String contentStr;
  final Envelope envelope;
  StellarWeb3TransactionDetails(
      {required this.memo,
      required this.fee,
      required this.source,
      required this.envelope,
      required this.type,
      required this.soroban,
      required this.contentStr,
      required List<StellarTransactionOperationDetails> operations})
      : operations = operations.immutable;
}

class StellarSorobanTransactionDetais {
  final Map<String, dynamic> content;
  final String contentStr;
  final IntegerBalance feeSource;
  const StellarSorobanTransactionDetais._(
      {required this.content,
      required this.contentStr,
      required this.feeSource});
  factory StellarSorobanTransactionDetais(
      {required SorobanTransactionData sorobanData,
      required WalletStellarNetwork network}) {
    final content = sorobanData.resources.toJson();
    return StellarSorobanTransactionDetais._(
        content: content,
        contentStr: StringUtils.fromJson(content,
            indent: '  ', toStringEncodable: true),
        feeSource:
            IntegerBalance.token(sorobanData.resourceFee, network.token));
  }

  ///SorobanTransactionData
}
