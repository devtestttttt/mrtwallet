import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/cosmos.dart';
import 'package:on_chain_wallet/wallet/constant/networks/cosmos.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';
import 'network_types.dart';

class CosmosFeeToken with CborSerializable {
  final Token token;
  final String denom;
  final IntegerBalance? lowGasPrice;
  final IntegerBalance averageGasPrice;
  final IntegerBalance? highGasPrice;
  IntegerBalance getFee() {
    return averageGasPrice;
  }

  const CosmosFeeToken._(
      {required this.token,
      required this.denom,
      required this.lowGasPrice,
      required this.averageGasPrice,
      required this.highGasPrice});
  factory CosmosFeeToken(
      {required Token token,
      required String denom,
      BigRational? lowGasPrice,
      required BigRational averageGasPrice,
      BigRational? highGasPrice}) {
    final e = token.decimal;
    if (e > CosmosConst.maxTokenExponent) {
      throw WalletException("invalid_token_exponent");
    }
    final networkDecimals = BigRational(BigInt.from(10).pow(e));
    return CosmosFeeToken._(
      token: token,
      denom: denom,
      lowGasPrice: lowGasPrice == null
          ? null
          : IntegerBalance.token(
              (lowGasPrice * networkDecimals).toBigInt(), token),
      averageGasPrice: IntegerBalance.token(
          (averageGasPrice * networkDecimals).toBigInt(), token),
      highGasPrice: highGasPrice == null
          ? null
          : IntegerBalance.token(
              (highGasPrice * networkDecimals).toBigInt(), token),
    );
  }
  factory CosmosFeeToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cosmosNativeToken);
    final token = Token.deserialize(obj: values.getCborTag(0));
    return CosmosFeeToken._(
        token: token,
        denom: values.elementAs(1),
        lowGasPrice: values.elemetMybeAs<IntegerBalance, BigInt>(
            2, (e) => IntegerBalance.token(e, token, immutable: true)),
        averageGasPrice:
            IntegerBalance.token(values.elementAs(3), token, immutable: true),
        highGasPrice: values.elemetMybeAs<IntegerBalance, BigInt>(
            4, (e) => IntegerBalance.token(e, token, immutable: true)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          CborStringValue(denom),
          lowGasPrice?.balance,
          averageGasPrice.balance,
          highGasPrice?.balance,
        ]),
        CborTagsConst.cosmosNativeToken);
  }
}

class CosmosNetworkInfo {
  final String? transactionExplorer;
  final String? addressExplorer;
  final String? networkName;
  final List<CosmosAPIProvider> providers;
  final CosmosFeeToken? nativeToken;
  final int slip44;
  final String? hrp;
  final CosmosNetworkTypes networkType;
  final String? chainId;
  final List<CosmosKeysAlgs> keysAlgs;
  final List<CosmosFeeToken> feeTokens;

  CosmosNetworkInfo({
    this.transactionExplorer,
    this.addressExplorer,
    required this.nativeToken,
    required this.providers,
    this.hrp,
    required this.feeTokens,
    required this.networkType,
    required this.chainId,
    required this.keysAlgs,
    required this.slip44,
    required this.networkName,
  });
}

class CosmosChainAsset {
  final Coin coin;
  final CW20Token? cw20token;
  final Token token;
  final IntegerBalance balance;
  const CosmosChainAsset._(
      {required this.coin,
      required this.token,
      required this.cw20token,
      required this.balance});
  factory CosmosChainAsset.unknown({required Coin coin, BigInt? balance}) {
    final token = Token(
        name: StrUtils.toCamelCase(coin.denom),
        symbol: StrUtils.toCamelCase(coin.denom),
        decimal: 0);
    return CosmosChainAsset._(
        coin: coin,
        token: token,
        cw20token: null,
        balance: IntegerBalance.token(balance ?? BigInt.zero, token));
  }
  factory CosmosChainAsset.ccrAsset(
      {required Coin coin, required CCRAsset asset, BigInt? balance}) {
    final decimal =
        asset.denomUnits.firstWhereOrNull((e) => e.denom == asset.display);
    if (decimal == null) {
      return CosmosChainAsset.unknown(coin: coin, balance: balance);
    }
    final denom = StrUtils.toCamelCase(coin.denom);
    final token = Token(name: denom, symbol: denom, decimal: decimal.exponent);
    return CosmosChainAsset._(
        coin: coin,
        token: token,
        cw20token: CW20Token.create(
            balance: balance ?? BigInt.zero, token: token, denom: coin.denom),
        balance: IntegerBalance.token(balance ?? BigInt.zero, token));
  }
  factory CosmosChainAsset.cw20Token(CW20Token token) {
    return CosmosChainAsset._(
        coin: Coin(denom: token.denom, amount: token.balance.balance),
        token: token.token,
        cw20token: token,
        balance: token.balance);
  }
}

class CosmosIbcChainData {
  final CCRChainData? ccrChainData;
  final List<CCRIbcTransition> ibcConnections;
  final CosmosChain chain;
  CosmosIbcChainData(
      {required this.ccrChainData,
      required this.chain,
      required List<CCRIbcTransition> ibcConnections})
      : token = chain.network.coinParam.nativeToken,
        ibcConnections = ibcConnections.imutable;
  final CW20Token token;
}
