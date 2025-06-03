import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';

class BCHCashToken {
  BCHCashToken({required this.cashToken});
  final CashToken cashToken;
  late final IntegerBalance balance = IntegerBalance.token(cashToken.amount,
      Token(name: cashToken.category, symbol: cashToken.category, decimal: 0),
      immutable: true);
}
