part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class RippleIssueToken extends TokenCore<DecimalBalance, NonDecimalToken> {
  RippleIssueToken._(
      {required super.balance,
      required super.token,
      required this.issuer,
      required super.updated,
      required this.assetCode})
      : super._();
  factory RippleIssueToken.create(
      {required String balance,
      required NonDecimalToken token,
      required String issuer,
      required String assetCode}) {
    return RippleIssueToken._(
        balance: DecimalBalance.fromString(balance, token, immutable: true),
        token: token,
        issuer: issuer,
        updated: DateTime.now(),
        assetCode: assetCode);
  }
  factory RippleIssueToken.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.ripple.tag);

    final NonDecimalToken token =
        NonDecimalToken.deserialize(obj: cbor.getCborTag(0));
    final String issuer = cbor.elementAs(1);
    final String assetCode = cbor.elementAs(2);
    final DecimalBalance balance =
        DecimalBalance.fromString(cbor.elementAs(3), token, immutable: true);
    final DateTime updated = cbor.elementAs(4);
    return RippleIssueToken._(
        balance: balance,
        token: token,
        issuer: issuer,
        updated: updated,
        assetCode: assetCode);
  }
  @override
  RippleIssueToken updateToken(Token updateToken) {
    return RippleIssueToken.create(
        balance: streamBalance.value.price,
        token: NonDecimalToken(
            name: updateToken.name,
            symbol: updateToken.symbol,
            assetLogo: updateToken.assetLogo,
            market: updateToken.market),
        issuer: issuer,
        assetCode: assetCode);
  }

  BigRational get currencyBalance => streamBalance.value.balance;

  @override
  final String issuer;
  final String assetCode;

  void _updateBalance([BigRational? updateBalance]) {
    if (streamBalance.value._internalUpdateBalance(updateBalance)) {
      _updated = DateTime.now().toLocal();
      streamBalance.notify();
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          issuer,
          assetCode,
          streamBalance.value.balance.toDecimal(),
          CborEpochIntValue(_updated)
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [issuer, assetCode];

  @override
  final String? type = null;
  @override
  TokenCoreType get tokenType => TokenCoreType.ripple;
  @override
  String get identifier => '$issuer-$assetCode';
}
