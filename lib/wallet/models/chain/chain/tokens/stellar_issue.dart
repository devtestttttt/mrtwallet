part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class StellarIssueToken extends TokenCore<IntegerBalance, Token> {
  StellarIssueToken._(
      {required super.balance,
      required super.token,
      required this.issuer,
      required super.updated,
      required this.assetType,
      required this.assetCode})
      : super._();
  factory StellarIssueToken.create(
      {required BigInt balance,
      required Token token,
      required String issuer,
      required AssetType assetType,
      required String assetCode}) {
    return StellarIssueToken._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        issuer: issuer,
        updated: DateTime.now(),
        assetType: assetType,
        assetCode: assetCode);
  }
  factory StellarIssueToken.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.stellar.tag);
    final Token token = Token.deserialize(obj: values.getCborTag(0));
    final String issuer = values.elementAs(1);
    final IntegerBalance balance =
        IntegerBalance.token(values.elementAs(2), token, immutable: true);
    final DateTime updated = values.elementAs(3);
    final AssetType assetType = AssetType.fromName(values.elementAs(4));
    final String assetCode = values.elementAs(5);
    return StellarIssueToken._(
        balance: balance,
        token: token,
        issuer: issuer,
        updated: updated,
        assetType: assetType,
        assetCode: assetCode);
  }
  @override
  StellarIssueToken updateToken(Token updateToken) {
    if (updateToken.decimal != token.decimal) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
    return StellarIssueToken._(
        balance: balance,
        token: updateToken,
        issuer: issuer,
        updated: updated,
        assetType: assetType,
        assetCode: assetCode);
  }

  final AssetType assetType;
  @override
  final String issuer;

  final String assetCode;

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
          issuer,
          streamBalance.value.balance,
          CborEpochIntValue(_updated),
          assetType.name,
          assetCode
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [issuer, assetType.name, assetCode];

  @override
  String? get type => assetType.name;

  StellarAsset toStellarAsset() {
    switch (assetType) {
      case AssetType.creditAlphanum4:
        return StellarAssetCreditAlphanum4(
            issuer: StellarPublicKey.fromAddress(
                StellarAddress.fromBase32Addr(issuer)),
            code: assetCode);
      case AssetType.creditAlphanum12:
        return StellarAssetCreditAlphanum12(
            issuer: StellarPublicKey.fromAddress(
                StellarAddress.fromBase32Addr(issuer)),
            code: assetCode);
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
  }

  @override
  TokenCoreType get tokenType => TokenCoreType.stellar;

  @override
  String get identifier => "$issuer-$assetCode-$assetType";
}
