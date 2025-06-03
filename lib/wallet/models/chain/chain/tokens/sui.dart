part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class SuiToken extends TokenCore<IntegerBalance, Token> {
  SuiToken._(
      {required super.balance,
      required super.token,
      required super.updated,
      required this.assetType,
      required bool isFreeze})
      : _isFreeze = isFreeze,
        super._();
  factory SuiToken.create(
      {required BigInt balance,
      required Token token,
      required String assetType,
      bool isFreeze = false}) {
    return SuiToken._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        updated: DateTime.now(),
        assetType: assetType,
        isFreeze: isFreeze);
  }
  factory SuiToken.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.sui.tag);
    final Token token = Token.deserialize(obj: values.getCborTag(0));
    final IntegerBalance balance =
        IntegerBalance.token(values.elementAs(1), token, immutable: true);
    final DateTime updated = values.elementAs(2);
    final String assetType = values.elementAs(3);
    final bool isFreez = values.elementAs<bool>(4);
    return SuiToken._(
        balance: balance,
        token: token,
        updated: updated,
        assetType: assetType,
        isFreeze: isFreez);
  }

  @override
  SuiToken updateToken(Token updateToken) {
    return SuiToken.create(
        balance: streamBalance.value.balance,
        token: updateToken,
        assetType: assetType);
  }

  final String assetType;
  bool _isFreeze;
  bool get isFreeze => _isFreeze;
  void setFreeze(bool freeze) {
    _isFreeze = freeze;
  }

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
          assetType,
          _isFreeze
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [assetType];

  @override
  String? get issuer => assetType;

  @override
  late final String? type = "FATs";

  @override
  TokenCoreType get tokenType => TokenCoreType.sui;

  @override
  String get identifier => assetType;
}
