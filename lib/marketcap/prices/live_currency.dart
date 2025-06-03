import 'dart:async';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/marketcap/prices/coingecko.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class LiveCurrencies with HttpImpl {
  final _syncRequest = SynchronizedLock();
  final CoingeckoPriceHandler _currenciesPrice = CoingeckoPriceHandler({});
  StreamSubscription? _prices;
  final _lock = SynchronizedLock();
  late final StreamValue<Currency> _currency =
      StreamValue<Currency>(Currency.USD);
  StreamValue<Currency> get currency => _currency;
  Currency get currencyToken => _currency.value;

  Future<void> _getCoinList() async {
    if (_currenciesPrice.hasCoinList) return;
    Future<List<String>> getCoinList() async {
      final json = await httpGet<List<Map<String, dynamic>>>(
          CoinGeckoUtils.coinGeckoCoinListURL,
          responseType: HTTPResponseType.listOfMap);
      return json.result
          .map((e) => CoingeckoCoin.fromJson(e))
          .map((e) => e.apiId)
          .toList();
    }

    final ids = await getCoinList();
    _currenciesPrice.updateSupportIds(ids);
  }

  // WalletCore get wallet;
  Future<CoingeckoPriceHandler> _getCoinPrices(List<String> coins) async {
    final url = CoinGeckoUtils.toCoingeckoPriceUri(
        Currency.toApiCall(), coins.join(","));
    final json = await httpGet<Map<String, dynamic>>(url,
        responseType: HTTPResponseType.map);
    return CoingeckoPriceHandler.fromJson(json.result);
  }

  Future<CoingeckoCoinInfo?> _getCoinPrice(String id) async {
    final url = CoinGeckoUtils.toCoingeckoPriceUri(Currency.toApiCall(), id);
    final json = await httpGet<Map<String, dynamic>>(
      url,
      responseType: HTTPResponseType.map,
    );
    if (json.result.isEmpty) return null;
    return CoingeckoCoinInfo.fromJson(json.result[id]!, id);
  }

  IntegerBalance? amount(String amount, APPToken token) {
    if (token is NonDecimalToken) return null;
    return _currenciesPrice.getPrice(
        baseCurrency: currencyToken, token: token, amount: amount);
  }

  IntegerBalance? getTokenPrice({
    required String amount,
    required APPToken? token,
  }) {
    if (token == null) return null;
    return _currenciesPrice.getPrice(
        baseCurrency: currencyToken, token: token, amount: amount);
  }

  Future<CoingeckoCoinInfo?> getCoinPrice(String id) async {
    CoingeckoCoinInfo? coin = _currenciesPrice.getCoin(id);
    coin ??= await _getCoinPrice(id);
    if (coin != null) {
      _currenciesPrice.addCoin(coin);
    }
    return coin;
  }

  void _onUpdatePrices(CoingeckoPriceHandler result) {
    _currenciesPrice.merge(result);
    _currency.notify();
  }

  Future<void> _onPredioc(dynamic _) async {
    await _syncRequest.synchronized(() async {
      await MethodUtils.call(() async {
        return await _getCoinList();
      });
      if (_currenciesPrice.hasCoinList) {
        final remindIds = _currenciesPrice.getIds();
        if (remindIds.isEmpty) return;
        final r = await MethodUtils.call(() async {
          return await _getCoinPrices(remindIds.take(400).toList());
        });
        if (r.hasResult) {
          _onUpdatePrices(r.result);
        }
      }
      await Future.delayed(const Duration(seconds: 10));
    });
  }

  Future<void> _streamPrices() async {
    await _lock.synchronized(() {
      if (_prices != null) return;
      _prices = Stream.periodic(const Duration(seconds: 15)).listen(_onPredioc);
    });
  }

  Future<void> dispose() async {
    await _lock.synchronized(() {
      _prices?.cancel();
      _prices = null;
    });
  }

  Future<void> streamPrices(List<String> ids) async {
    await _syncRequest.synchronized(() async {
      await _streamPrices();
      _currenciesPrice.addCoinsIds(ids);
    });
  }

  void changeCurrency(Currency? currency) {
    if (currency == null || currency == _currency.value) return;
    _currenciesPrice.clearCache();
    _currency.value = currency;
  }
}
