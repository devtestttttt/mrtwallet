import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

import '../../../token/token/token.dart';

class XRPIssueToken {
  final XRPAddress issuer;
  final String symbol;
  final String balance;
  const XRPIssueToken(
      {required this.issuer, required this.symbol, required this.balance});
  XRPIssueToken.fromJson(Map<String, dynamic> json)
      : issuer = XRPAddress(json["issuer"]),
        balance = json["value"],
        symbol = json["currency"];
  @override
  String toString() {
    return "{name: $symbol, issuer: $issuer, balance: $balance}";
  }
}

class XRPPickedAssets {
  final RippleIssueToken? accountToken;
  final XRPAddress issuer;
  final NonDecimalToken token;
  bool get isAccountToken => accountToken != null;
  const XRPPickedAssets._(
      {required this.accountToken, required this.token, required this.issuer});
  factory XRPPickedAssets.account(RippleIssueToken token) {
    return XRPPickedAssets._(
        accountToken: token,
        token: token.token,
        issuer: XRPAddress(token.issuer));
  }
  factory XRPPickedAssets.create(XRPIssueToken token) {
    return XRPPickedAssets._(
        accountToken: null,
        token: NonDecimalToken(name: token.symbol, symbol: token.symbol),
        issuer: token.issuer);
  }
}
