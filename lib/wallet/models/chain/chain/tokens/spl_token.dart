part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class SolanaSPLToken extends TokenCore<IntegerBalance, Token> {
  SolanaSPLToken._(
      {required super.balance,
      required super.token,
      required this.mint,
      required this.tokenAccount,
      required super.updated,
      required this.tokenOwner})
      : super._();
  factory SolanaSPLToken.create({
    required BigInt balance,
    required Token token,
    required SolAddress mint,
    required SolAddress tokenAccount,
    required SolAddress tokenOwner,
  }) {
    return SolanaSPLToken._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        mint: mint,
        tokenAccount: tokenAccount,
        updated: DateTime.now(),
        tokenOwner: tokenOwner);
  }
  factory SolanaSPLToken.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.spl.tag);
    final Token token = Token.deserialize(obj: cbor.getCborTag(0));
    final String mint = cbor.elementAs(1);
    final IntegerBalance balance =
        IntegerBalance.token(cbor.elementAs(2), token, immutable: true);
    final DateTime updated = cbor.elementAs(3);
    final String tokenAccount = cbor.elementAs(4);
    final String tokenOwner = cbor.elementAs(5);
    return SolanaSPLToken._(
        balance: balance,
        token: token,
        mint: SolAddress(mint),
        tokenAccount: SolAddress(tokenAccount),
        updated: updated,
        tokenOwner: SolAddress(tokenOwner));
  }

  @override
  SolanaSPLToken updateToken(Token updateToken) {
    return SolanaSPLToken.create(
        balance: streamBalance.value.balance,
        token: token,
        mint: mint,
        tokenAccount: tokenAccount,
        tokenOwner: tokenOwner);
  }

  final SolAddress mint;
  final SolAddress tokenAccount;
  final SolAddress tokenOwner;

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
          mint.address,
          streamBalance.value.balance,
          CborEpochIntValue(_updated),
          tokenAccount.address,
          tokenOwner.address
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [mint.address, tokenAccount.address];

  @override
  String? get issuer => mint.address;

  @override
  late final String? type = "SPL";
  @override
  TokenCoreType get tokenType => TokenCoreType.spl;

  @override
  String get identifier => mint.address;
}
