part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class ETHERC20Token extends SolidityToken {
  ETHERC20Token._(
      {required super.balance,
      required super.token,
      required this.contractAddress,
      required super.updated})
      : super._();
  factory ETHERC20Token.create(
      {required BigInt balance,
      required Token token,
      required ETHAddress contractAddress}) {
    return ETHERC20Token._(
        balance: IntegerBalance.token(balance, token, immutable: true),
        token: token,
        contractAddress: contractAddress,
        updated: DateTime.now());
  }
  factory ETHERC20Token.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: TokenCoreType.erc20.tag);
    final Token token = Token.deserialize(obj: cbor.getCborTag(0));
    final ETHAddress contractAddress = ETHAddress(cbor.elementAs(1));
    final IntegerBalance balance =
        IntegerBalance.token(cbor.elementAs(2), token, immutable: true);
    final DateTime updated = cbor.elementAs(3);
    return ETHERC20Token._(
        balance: balance,
        token: token,
        contractAddress: contractAddress,
        updated: updated);
  }

  @override
  ETHERC20Token updateToken(Token updateToken) {
    return ETHERC20Token.create(
        balance: streamBalance.value.balance,
        token: updateToken,
        contractAddress: contractAddress);
  }

  @override
  final ETHAddress contractAddress;
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
          contractAddress.address,
          streamBalance.value.balance,
          CborEpochIntValue(_updated)
        ]),
        tokenType.tag);
  }

  @override
  List get variabels => [contractAddress.address];

  @override
  String? get issuer => contractAddress.address;

  @override
  String toHexAddress() {
    return contractAddress.toHex();
  }

  @override
  late final String? type = "erc20";

  @override
  TokenCoreType get tokenType => TokenCoreType.erc20;

  @override
  String get identifier => contractAddress.address;
}
