part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class TonJettonToken extends TokenCore<IntegerBalance, Token> {
  TonJettonToken._(
      {required super.balance,
      required super.token,
      required this.minterAddress,
      required this.walletAddress,
      required super.updated,
      required this.description,
      required this.uri,
      required this.verified})
      : super._();

  factory TonJettonToken.create({
    required BigInt balance,
    required Token token,
    required TonAddress minterAddress,
    required TonAddress walletAddress,
    required bool verified,
    String? description,
    String? uri,
  }) {
    return TonJettonToken._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        minterAddress: minterAddress,
        walletAddress: walletAddress,
        updated: DateTime.now(),
        description: description,
        uri: uri,
        verified: verified);
  }
  factory TonJettonToken.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.jetton.tag);
    final Token token = Token.deserialize(obj: cbor.getCborTag(0));
    final String minterAddress = cbor.elementAs(1);
    final String walletAddress = cbor.elementAs(2);
    final DateTime updated = cbor.elementAs(4);
    return TonJettonToken._(
        balance:
            IntegerBalance.token(cbor.elementAs(3), token, immutable: true),
        token: token,
        minterAddress: TonAddress(minterAddress),
        walletAddress: TonAddress(walletAddress),
        updated: updated,
        description: cbor.elementAs(5),
        uri: cbor.elementAs(6),
        verified: cbor.elementAs(7));
  }

  final TonAddress minterAddress;
  final TonAddress walletAddress;

  final String? description;
  final String? uri;
  final bool verified;

  void _updateBalance([BigInt? updateBalance]) {
    if (streamBalance.value._internalUpdateBalance(updateBalance)) {
      _updated = DateTime.now().toLocal();
      streamBalance.notify();
    }
  }

  @override
  TonJettonToken updateToken(Token updateToken) {
    return TonJettonToken.create(
      balance: streamBalance.value.balance,
      token: updateToken,
      minterAddress: minterAddress,
      walletAddress: walletAddress,
      description: description,
      uri: uri,
      verified: verified,
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          minterAddress.toFriendlyAddress(),
          walletAddress.toFriendlyAddress(),
          streamBalance.value.balance,
          CborEpochIntValue(_updated),
          description ?? const CborNullValue(),
          uri ?? const CborNullValue(),
          verified
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [minterAddress, walletAddress];

  @override
  String? get issuer => minterAddress.toFriendlyAddress();

  @override
  late final String? type = "Jetton";
  @override
  TokenCoreType get tokenType => TokenCoreType.jetton;

  @override
  String get identifier => minterAddress.toFriendlyAddress();
}
