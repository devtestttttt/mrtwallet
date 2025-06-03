part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class CW20Token extends TokenCore<IntegerBalance, Token> {
  CW20Token._(
      {required super.balance,
      required super.token,
      required super.updated,
      required this.denom})
      : super._();
  factory CW20Token.create(
      {required BigInt balance, required Token token, required String denom}) {
    return CW20Token._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        updated: DateTime.now(),
        denom: denom);
  }
  factory CW20Token.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.cw20.tag);

    final Token token = Token.deserialize(obj: values.getCborTag(0));
    final IntegerBalance balance =
        IntegerBalance.token(values.elementAs(1), token, immutable: true);
    final DateTime updated = values.elementAs(2);
    final String denom = values.elementAs(3);
    return CW20Token._(
        balance: balance, token: token, updated: updated, denom: denom);
  }

  @override
  CW20Token updateToken(Token updateToken) {
    return CW20Token.create(
        balance: streamBalance.value.balance, token: updateToken, denom: denom);
  }

  final String denom;
  void _updateBalance([BigInt? updateBalance]) {
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
          streamBalance.value.balance,
          CborEpochIntValue(_updated),
          denom
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [denom];

  @override
  String? get issuer => denom;

  @override
  late final String? type = "CW20";

  @override
  TokenCoreType get tokenType => TokenCoreType.cw20;

  @override
  String get identifier => denom;
}
