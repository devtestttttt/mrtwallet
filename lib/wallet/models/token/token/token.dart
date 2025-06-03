import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/euqatable/equatable.dart';
import 'package:on_chain_wallet/app/models/models/image.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/app/utils/string/utils.dart';
import 'package:on_chain_wallet/wallet/models/token/coingecko/coin.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';

abstract class APPToken with CborSerializable, Equatable {
  final String name;
  final String symbol;
  final String nameView;
  final String symbolView;
  final CoingeckoCoin? market;
  final APPImage? assetLogo;
  const APPToken(
      {required this.name,
      required this.symbol,
      required this.nameView,
      required this.symbolView,
      required this.market,
      required this.assetLogo});
}

class Token extends APPToken {
  final int decimal;
  factory Token.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.token);
      final String name = cbor.elementAs(0);
      final String symbol = cbor.elementAs(1);
      final int decimal = cbor.elementAs(2);
      final APPImage? image = cbor.elemetMybeAs<APPImage, CborTagValue>(
          3, (e) => APPImage.deserialize(obj: e));
      final CoingeckoCoin? market =
          cbor.elemetMybeAs<CoingeckoCoin, CborTagValue>(
              4, (e) => CoingeckoCoin.fromCborBytesOrObject(obj: e));
      return Token(
          name: name,
          symbol: symbol,
          decimal: decimal,
          assetLogo: image,
          market: market);
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  const Token._(
      {required super.name,
      required super.symbol,
      required super.nameView,
      required super.symbolView,
      super.assetLogo,
      required this.decimal,
      super.market});
  factory Token(
      {required String name,
      required String symbol,
      APPImage? assetLogo,
      required int decimal,
      CoingeckoCoin? market}) {
    if (decimal < 0 || decimal > 255) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
    final String nameView = StrUtils.substring(name, length: 20);
    final String symbolView = StrUtils.substring(symbol, length: 5);
    return Token._(
        name: name,
        symbol: symbol,
        assetLogo: assetLogo,
        decimal: decimal,
        market: market,
        nameView: nameView,
        symbolView: symbolView);
  }
  Token copyWith({
    String? name,
    String? symbol,
    int? decimal,
    APPImage? assetLogo,
    CoingeckoCoin? market,
  }) {
    return Token(
        name: name ?? this.name,
        symbol: symbol ?? this.symbol,
        decimal: decimal ?? this.decimal,
        assetLogo: assetLogo ?? this.assetLogo,
        market: market ?? this.market);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          name,
          symbol,
          decimal,
          assetLogo?.toCbor() ?? const CborNullValue(),
          market?.toCbor() ?? const CborNullValue()
        ]),
        CborTagsConst.token);
  }

  @override
  List get variabels => [name, symbol, decimal];

  String? get marketUri {
    return market?.marketUri;
  }

  @override
  String toString() {
    return "Token: $name";
  }
}

class NonDecimalToken extends APPToken {
  factory NonDecimalToken.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.decimalToken);
      final String name = cbor.elementAs(0);
      final String symbol = cbor.elementAs(1);
      final APPImage? image = cbor.elemetMybeAs<APPImage, CborTagValue>(
          2, (e) => APPImage.deserialize(obj: e));
      final CoingeckoCoin? market =
          cbor.elemetMybeAs<CoingeckoCoin, CborTagValue>(
              3, (e) => CoingeckoCoin.fromCborBytesOrObject(obj: e));

      return NonDecimalToken(
          name: name, symbol: symbol, assetLogo: image, market: market);
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  const NonDecimalToken._(
      {required super.name,
      required super.symbol,
      required super.nameView,
      required super.symbolView,
      super.assetLogo,
      super.market});
  factory NonDecimalToken(
      {required String name,
      required String symbol,
      APPImage? assetLogo,
      CoingeckoCoin? market}) {
    final String nameView = StrUtils.substring(name, length: 20);
    final String symbolView = StrUtils.substring(symbol, length: 5);
    return NonDecimalToken._(
        name: name,
        symbol: symbol,
        assetLogo: assetLogo,
        market: market,
        nameView: nameView,
        symbolView: symbolView);
  }
  NonDecimalToken copyWith({
    String? name,
    String? symbol,
    APPImage? assetLogo,
    CoingeckoCoin? market,
  }) {
    return NonDecimalToken(
        name: name ?? this.name,
        symbol: symbol ?? this.symbol,
        assetLogo: assetLogo ?? this.assetLogo,
        market: market ?? this.market);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          name,
          symbol,
          assetLogo?.toCbor() ?? const CborNullValue(),
          market?.toCbor() ?? const CborNullValue()
        ]),
        CborTagsConst.decimalToken);
  }

  @override
  List get variabels => [name, symbol];

  String? get marketUri {
    return market?.marketUri;
  }

  @override
  String toString() {
    return "Token: $name";
  }
}
