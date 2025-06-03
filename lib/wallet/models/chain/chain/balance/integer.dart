part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class IntegerBalance implements BalanceCore<BigInt, Token> {
  Token _token;
  @override
  Token get token => _token;
  final bool allowNegative;
  BigInt _balance = BigInt.zero;
  @override
  BigInt get balance => _balance;

  late String _price;
  @override
  String get price => _price;

  int get currencyDecimal => token.decimal;
  late final int showDecimal;

  late String _viewPrice;

  @override
  String get viewPrice => _viewPrice;

  final bool immutable;
  bool _largerThanZero = false;
  @override
  bool get largerThanZero => _largerThanZero;

  factory IntegerBalance.zero(Token token,
      {int? decimalPlaces, bool immutable = false, bool allowNegative = true}) {
    return IntegerBalance.token(BigInt.zero, token,
        immutable: immutable, allowNegative: allowNegative);
  }

  factory IntegerBalance.convertRational(
      {required BigRational basePrice,
      required Token token,
      required String amount,
      required Token newToken,
      int? decimalPlaces,
      bool immutable = false,
      bool allowNegative = true}) {
    final decimals = token.decimal;

    final BigRational aPrice = BigRational.parseDecimal(amount);
    final val = PriceUtils.decodePrice(
        (basePrice * aPrice).toDecimal(), decimals,
        validateDecimal: false);
    final balance = IntegerBalance.token(val, token,
        decimalPlaces: decimalPlaces,
        immutable: immutable,
        allowNegative: allowNegative);
    final newDecimals = newToken.decimal;

    balance._token = newToken;
    balance._balance = PriceUtils.decodePrice(balance._price, newDecimals);
    return balance;
  }

  factory IntegerBalance.token(BigInt balance, Token token,
      {int? decimalPlaces, bool immutable = false, bool allowNegative = true}) {
    final currencyDecimal = token.decimal;
    final showDecimal =
        decimalPlaces ?? (currencyDecimal > 8 ? 8 : currencyDecimal);
    final currency =
        IntegerBalance._(token, showDecimal, immutable, allowNegative);
    currency._updateBalance(balance);

    return currency;
  }

  IntegerBalance._(
      this._token, this.showDecimal, this.immutable, this.allowNegative);

  IntegerBalance clone({bool? immutable, bool? allowNegative}) {
    return IntegerBalance.token(balance, token,
        immutable: immutable ?? this.immutable,
        allowNegative: allowNegative ?? this.allowNegative);
  }

  void _updateBalance(BigInt updateBalance) {
    if (!allowNegative && updateBalance.isNegative) {
      assert(false, "update balance should not be here.");
      return;
    }
    _price = PriceUtils.encodePrice(updateBalance, currencyDecimal,
        amoutDecimal: showDecimal);
    _balance = updateBalance;
    _viewPrice = StrUtils.to3Digits(_price, separator: ",");
    _isZero = _balance == BigInt.zero;
    _isNegative = _balance.isNegative;
    _largerThanZero = _balance > BigInt.zero;
  }

  bool _internalUpdateBalance([BigInt? updateBalance]) {
    if (updateBalance == null) return false;
    if (updateBalance == _balance) return false;
    _updateBalance(updateBalance);
    return true;
  }

  @override
  bool updateBalance([BigInt? updateBalance]) {
    assert(!immutable, "Imutable balance");
    if (updateBalance == null || immutable) return false;
    if (updateBalance == _balance) return false;
    _updateBalance(updateBalance);
    return true;
  }

  bool tryUpdateBalanceStr({String? updateBalance, BigInt? onFailed}) {
    assert(!immutable, "Imutable balance");
    if (updateBalance == null || immutable) return false;
    final toBigit =
        PriceUtils.tryDecodePrice<BigInt?>(updateBalance, token.decimal) ??
            onFailed;
    if (toBigit == null) return false;
    _updateBalance(toBigit);
    return true;
  }

  BigInt _addAmount(BigInt amount) {
    return balance + amount;
  }

  BigInt _minusAmount(BigInt amount) {
    return balance - amount;
  }

  bool addAmount([BigInt? amount]) {
    assert(!immutable, "Imutable balance");
    if (amount == null || immutable) return false;
    final newBalance = _addAmount(amount);
    if (newBalance == _balance) return false;
    _updateBalance(newBalance);
    return true;
  }

  bool minusAmount([BigInt? amount]) {
    assert(!immutable, "Imutable balance");
    if (amount == null || immutable) return false;
    final newBalance = _minusAmount(amount);
    if (newBalance == _balance) return false;
    _updateBalance(newBalance);
    return true;
  }

  void zero() {
    if (immutable) return;
    _updateBalance(BigInt.zero);
  }

  bool _isZero = false;
  @override
  bool get isZero => _isZero;
  bool _isNegative = false;
  @override
  bool get isNegative => _isNegative;

  @override
  String toString() {
    return _price;
  }

  IntegerBalance operator -(IntegerBalance other) {
    return IntegerBalance.token(_balance - other.balance, token);
  }

  IntegerBalance operator +(IntegerBalance other) {
    return IntegerBalance.token(_balance + other.balance, token);
  }

  bool operator <=(BigInt other) {
    return _balance <= other;
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        (other is IntegerBalance &&
            token == other.token &&
            other._balance == _balance);
  }

  @override
  int get hashCode => HashCodeGenerator.generateHashCode([token, _balance]);
}
