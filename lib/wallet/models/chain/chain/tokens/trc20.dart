part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class TronTRC20Token extends TronToken implements SolidityToken {
  TronTRC20Token._(
      {required super.balance,
      required super.token,
      required this.contractAddress,
      required super.updated})
      : super._();
  factory TronTRC20Token.create(
      {required BigInt balance,
      required Token token,
      required TronAddress contractAddress}) {
    return TronTRC20Token._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        contractAddress: contractAddress,
        updated: DateTime.now());
  }
  factory TronTRC20Token.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.trc20.tag);

    final Token token = Token.deserialize(obj: cbor.getCborTag(0));
    final TronAddress contractAddress = TronAddress(cbor.elementAs(1));
    final IntegerBalance balance =
        IntegerBalance.token(cbor.elementAs(2), token, immutable: true);
    final DateTime updated = cbor.elementAs(3);
    return TronTRC20Token._(
        balance: balance,
        token: token,
        contractAddress: contractAddress,
        updated: updated);
  }
  @override
  TronTRC20Token updateToken(Token updateToken) {
    return TronTRC20Token.create(
        balance: streamBalance.value.balance,
        token: updateToken,
        contractAddress: contractAddress);
  }

  @override
  final TronAddress contractAddress;
  @override
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
          contractAddress.toAddress(),
          streamBalance.value.balance,
          CborEpochIntValue(_updated)
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [contractAddress.toAddress()];

  @override
  String get issuer => contractAddress.toAddress();

  @override
  String toHexAddress() {
    return contractAddress.toAddress(false);
  }

  @override
  TokenCoreType get tokenType => TokenCoreType.trc20;

  @override
  TronTokenTypes get tronTokenType => TronTokenTypes.trc20;

  @override
  late final String? type = tronTokenType.name;

  @override
  String get identifier => contractAddress.toAddress();
}
