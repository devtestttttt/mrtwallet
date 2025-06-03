part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

enum TokenCoreType {
  aptos(CborTagsConst.fats),
  cw20(CborTagsConst.cw20),
  erc20(CborTagsConst.erc20Token),
  ripple(CborTagsConst.rippleIssueToken),
  jetton(CborTagsConst.jettonToken),
  spl(CborTagsConst.spltoken),
  stellar(CborTagsConst.stellarIssueToken),
  sui(CborTagsConst.suiToken),
  trc10(CborTagsConst.trc10Token),
  trc20(CborTagsConst.trc20Token);

  final List<int> tag;
  const TokenCoreType(this.tag);
  static TokenCoreType fromTag(List<int>? tag) {
    return values.firstWhere(
      (e) => BytesUtils.bytesEqual(e.tag, tag),
      orElse: () => throw WalletExceptionConst.invalidTokenInformation,
    );
  }
}

abstract class TokenCore<T extends BalanceCore, TOKEN extends APPToken>
    with CborSerializable, Equatable {
  final TOKEN token;
  final StreamValue<T> streamBalance;
  DateTime _updated;
  DateTime get updated => _updated;
  TokenCore._(
      {required this.token, required T balance, required DateTime updated})
      : _updated = updated,
        streamBalance = StreamValue<T>.immutable(balance);
  T get balance => streamBalance.value;
  String? get issuer;
  String? get type;
  TokenCore updateToken(Token updateToken);
  TokenCoreType get tokenType;
  String get identifier;

  static T deserialize<T extends TokenCore>(
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    final type = TokenCoreType.fromTag(tag.tags);
    final TokenCore tokenCore = switch (type) {
      TokenCoreType.aptos => AptosFATokens.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.cw20 => CW20Token.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.erc20 => ETHERC20Token.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.ripple =>
        RippleIssueToken.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.jetton =>
        TonJettonToken.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.spl => SolanaSPLToken.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.stellar =>
        StellarIssueToken.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.sui => SuiToken.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.trc10 => TronTRC10Token.deserialize(bytes: bytes, obj: obj),
      TokenCoreType.trc20 => TronTRC20Token.deserialize(bytes: bytes, obj: obj),
    };
    if (tokenCore is! T) {
      throw WalletException.invalidArgruments(
          ["$T", "${tokenCore.runtimeType}"]);
    }
    return tokenCore;
  }
}

abstract class SolidityToken extends TokenCore<IntegerBalance, Token> {
  SolidityToken._(
      {required super.token, required super.balance, required super.updated})
      : super._();
  SolidityAddress get contractAddress;
  String toHexAddress();
  void _updateBalance([BigInt? updateBalance]);
}

enum TronTokenTypes {
  trc20(CborTagsConst.trc20Token),
  trc10(CborTagsConst.trc10Token);

  final List<int> tag;
  const TronTokenTypes(this.tag);
  static TronTokenTypes fromTag(List<int>? tag) {
    return values.firstWhere(
      (e) => BytesUtils.bytesEqual(e.tag, tag),
      orElse: () => throw WalletExceptionConst.invalidTokenInformation,
    );
  }

  bool get isTrc10 => this == TronTokenTypes.trc10;
}

abstract class TronToken extends TokenCore<IntegerBalance, Token> {
  @override
  TronToken updateToken(Token updateToken);
  void _updateBalance([BigInt? updateBalance]);
  @override
  String get issuer;
  TronTokenTypes get tronTokenType;
  TronToken._(
      {required super.token, required super.balance, required super.updated})
      : super._();
  factory TronToken.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object, hex: hex);
    final type = TronTokenTypes.fromTag(decode.tags);
    return switch (type) {
      TronTokenTypes.trc10 => TronTRC10Token.deserialize(obj: decode),
      TronTokenTypes.trc20 => TronTRC20Token.deserialize(obj: object)
    };
  }
}
