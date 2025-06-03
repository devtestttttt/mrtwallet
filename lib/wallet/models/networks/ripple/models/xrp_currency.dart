import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class XRPCurrencyAmount {
  const XRPCurrencyAmount(
      {required this.amount, required this.price, required this.token});

  final CurrencyAmount amount;
  final BalanceCore price;
  final APPToken token;
}
