import 'dart:async';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/text_field/input_formaters.dart';
import 'package:on_chain_wallet/marketcap/prices/live_currency.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

typedef ONSELECTSOURCEACCOUNTS = Future<ChainAccount?> Function(Chain);
mixin SwapSourceController on StreamStateController {
  final _lock = SynchronizedLock();
  StreamValue<IntegerBalance?> inputPrice = StreamValue(null);
  final Cancelable _cancelable = Cancelable();
  List<Chain> get chains;
  LiveCurrencies get liveCurrencies;
  Map<WalletNetwork, Set<APPSwapAssets>> _sourceAssets = {};
  Map<WalletNetwork, Set<APPSwapAssets>> get sourceAssets => _sourceAssets;
  APPSwapAssets? _sourceAsset;
  APPSwapAssets? get sourceAsset => _sourceAsset;
  Chain? _sourceChain;
  Chain? get sourceChain => _sourceChain;
  List<ChainAccount> _sourceAddresses = [];
  List<ChainAccount> get sourceAddresses => _sourceAddresses;
  bool _sourceSupported = false;
  bool get sourceSupported => _sourceSupported;
  BigInt? _balance;
  bool _hasBalance = false;
  bool get hasBalance => _hasBalance;
  void _checkBalance() {
    final hasBalance = this.hasBalance;
    final balance = _balance;
    final amount = _inputAmount;
    _hasBalance =
        (amount == null || balance == null || balance >= amount.amount);
    if (hasBalance != _hasBalance) {
      notify();
    }
  }

  Future<void> _updateBalance() async {
    _lock.synchronized(() async {
      _balance = null;
      _checkBalance();
      final asset = sourceAsset?.asset;
      final addresses = _sourceAddresses;
      await _sourceChain?.init();
      final client = await _sourceChain?.clientOrNull();
      if (asset == null || addresses.isEmpty || client == null) return;
      final initClient = await client.init();
      if (!initClient) return;

      final r = await MethodUtils.call(
          () => Future.wait(_sourceAddresses
              .map((e) async => (client as SwapNetworkClient)
                  .getAccountsAssetBalance(
                      sourceAsset!.asset, e.networkAddress))
              .toList()),
          cancelable: _cancelable);
      if (r.hasError) return;
      _balance = r.result.fold<BigInt>(BigInt.zero, (p, c) => p + c.balance);
      _checkBalance();
    });

    // final balance =;
  }

  bool _allowMultipleAccountSpent = false;
  bool get allowMultipleAccountSpent => _allowMultipleAccountSpent;
  bool _allowAddSource = false;
  bool get allowAddSource => _allowAddSource;
  SwapAmount? _inputAmount;
  SwapAmount? get inputAmount => _inputAmount;

  final CurrencyTextEdittingController amountController =
      CurrencyTextEdittingController(text: '');

  SwapAmount? getInputAmount() {
    final decimals = _sourceAsset?.asset.decimal;
    if (decimals == null) return null;
    return MethodUtils.nullOnException(
        () => SwapAmount.fromString(amountController.getText(), decimals));
  }

  void setSourceAssets(Map<WalletNetwork, Set<APPSwapAssets>> assets) {
    _sourceAssets = assets;
    final coingeckoId = _sourceAssets.values
        .expand((e) => e)
        .map((e) => e.asset.coingeckoId)
        .whereType<String>()
        .toList();
    liveCurrencies.streamPrices(coingeckoId);
  }

  Future<void> onSelectSourceAddress(
      ONSELECTSOURCEACCOUNTS onSelectAddress) async {
    final sChain = _sourceChain;
    if (sChain == null) return;
    final account = await onSelectAddress(sChain);
    if (account == null || account.network != sChain.network.value) return;
    await _lock.synchronized(() async {
      _cancelable.cancel();
      if (_allowMultipleAccountSpent) {
        _sourceAddresses = {..._sourceAddresses, account}.toList();
      } else {
        _sourceAddresses = [account];
      }
      _allowAddSource = _allowMultipleAccountSpent || _sourceAddresses.isEmpty;
      _updateBalance();
      notify();
    });
  }

  IntegerBalance? getTokenPrice(String amount, Token token) {
    return liveCurrencies.getTokenPrice(amount: amount, token: token);
  }

  IntegerBalance? _inputPrice() {
    final asset = sourceAsset;
    final amount = _inputAmount;
    if (asset == null || amount == null) return null;
    final price = getTokenPrice(amount.amountString, asset.token);
    return price;
  }

  Future<void> onSelectUpdateAddress(
      ONSELECTSOURCEACCOUNTS onSelectAddress, ChainAccount account) async {
    if (_allowMultipleAccountSpent) {
      _sourceAddresses.remove(account);
      notify();
      return;
    }
    onSelectSourceAddress(onSelectAddress);
  }

  void onAmountChanged() {
    _inputAmount = getInputAmount();
    inputPrice.value = _inputPrice();
    inputPrice.notify();
    _checkBalance();
  }

  Future<void> updateSourceAsset(APPSwapAssets asset) async {
    await _lock.synchronized(() async {
      _cancelable.cancel();
      _sourceAsset = asset;
      _sourceChain =
          chains.firstWhereOrNull((e) => e.network == sourceAsset?.network);
      _allowMultipleAccountSpent = sourceAsset?.network.type.isBitcoin ?? false;
      amountController.setSymbol(asset.token.symbolView);
      final sourceAddress = _sourceAddresses.firstOrNull;
      if (sourceAddress?.network != _sourceChain?.network.value) {
        _sourceAddresses = [];
        final sourceChain = _sourceChain;
        if (sourceChain != null && sourceChain.haveAddress) {
          _sourceAddresses = [sourceChain.address];
        }
      }
      _sourceSupported = _sourceChain != null;
      _allowAddSource = _allowMultipleAccountSpent || _sourceAddresses.isEmpty;
      onAmountChanged();
      _updateBalance();
    });
  }

  void cleanSourceState() {
    _cancelable.dispose();
    _allowMultipleAccountSpent = false;
    _allowAddSource = false;
    _inputAmount = null;
    _sourceAddresses = [];
    _sourceAssets = {};
    _sourceAsset = null;
    amountController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
    inputPrice.dispose();
    _cancelable.dispose();
    _sourceAddresses = [];
    _sourceAssets = {};
  }
}
