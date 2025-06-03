part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class TronTRC10Token extends TronToken {
  TronTRC10Token._(
      {required super.balance,
      required super.token,
      required this.tokenID,
      required super.updated})
      : super._();
  factory TronTRC10Token.create(
      {required BigInt balance,
      required Token token,
      required String tokenID}) {
    return TronTRC10Token._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        tokenID: tokenID,
        updated: DateTime.now());
  }
  factory TronTRC10Token.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.trc10.tag);
    final Token token = Token.deserialize(obj: cbor.getCborTag(0));
    final String tokenID = cbor.elementAs(1);
    final DateTime updated = cbor.elementAs(3);
    return TronTRC10Token._(
        balance:
            IntegerBalance.token(cbor.elementAs(2), token, immutable: true),
        token: token,
        tokenID: tokenID,
        updated: updated);
  }
  @override
  TronTRC10Token updateToken(Token updateToken) {
    return TronTRC10Token.create(
        balance: streamBalance.value.balance,
        token: updateToken,
        tokenID: tokenID);
  }

  final String tokenID;
  @override
  void _updateBalance([BigInt? updateBalance]) {
    if (streamBalance.value._internalUpdateBalance(updateBalance)) {
      _updated = DateTime.now().toLocal();
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          tokenID,
          streamBalance.value.balance,
          CborEpochIntValue(_updated)
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [tokenID];

  @override
  String get issuer => tokenID;

  @override
  late final String? type = tronTokenType.name;

  @override
  TronTokenTypes get tronTokenType => TronTokenTypes.trc10;

  @override
  TokenCoreType get tokenType => TokenCoreType.trc10;

  @override
  String get identifier => tokenID;
}
