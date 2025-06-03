import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/crypto/utils/ton/ton.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/ton.dart';
import 'package:ton_dart/ton_dart.dart';

class TonOutputWithBalance {
  TonOutputWithBalance({
    required this.address,
    required WalletTonNetwork network,
  })  : balance = IntegerBalance.zero(network.token),
        networkToken = network.token;
  final Token networkToken;
  final IntegerBalance balance;
  final ReceiptAddress<TonAddress> address;
  bool get hasSetting => _bounce || _typeOfBoy.hasBody;
  TonOutputJettonWithBalance? _token;
  bool get hasToken => _token != null;
  IntegerBalance get tokenBalance => _token!.balance;
  TonJettonToken? get jetton => _token?.token;
  BigInt get queryId => _token!.queryId;

  IntegerBalance get forwardBalance => _token!.forwardBalance;

  bool _bounce = false;
  bool get bounce => _bounce;

  TonMessageBodyType _typeOfBoy = TonMessageBodyType.none;
  TonMessageBodyType get bodyType => _typeOfBoy;

  String? _body;
  String? get body => _body;

  bool get hasAmount => !balance.isZero;

  bool get isReady => hasAmount && (_token == null || hasTokenAmount);

  bool get hasTokenAmount => !_token!.balance.isZero;

  bool get hasForwardBalance => !_token!.forwardBalance.isZero;

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  void updateForwardBalance(BigInt val) {
    _token?.updateForwardAmount(val);
  }

  void updateJettonBalance(BigInt val) {
    _token?.updateBalance(val);
  }

  void toggleBounce(bool useBounce) {
    _bounce = useBounce;
  }

  void setToken(TonJettonToken? jetton) {
    _token = jetton == null
        ? null
        : TonOutputJettonWithBalance(jetton, networkToken);
  }

  void updateQueryId(BigInt? val) {
    if (val == null) return;
    _token?.updateQueryId(val);
  }

  bool setBody(TonMessageBodyType type, String? messageBody) {
    if (type == TonMessageBodyType.none) {
      _body = null;
      _typeOfBoy = type;
      return true;
    }
    if (type.isValid(messageBody)) {
      _typeOfBoy = type;
      _body = messageBody;
      return true;
    }
    return false;
  }

  MessageRelaxed toMessage(WalletTonNetwork network, TonAddress account) {
    final Cell? payload = _typeOfBoy.hasBody ? _typeOfBoy.toValue(body!) : null;
    if (hasToken) {
      return TonUtils.createJettonTransaferBody(
          walletAddress: jetton!.walletAddress,
          amount: balance.balance,
          jettonAmount: tokenBalance.balance,
          forwardTonAmount: forwardBalance.balance,
          responseAddress: account,
          destination: address.networkAddress,
          payload: payload,
          queryId: queryId);
    }
    return TonHelper.internal(
        destination: address.networkAddress,
        amount: balance.balance,
        bounce: bounce,
        body: payload);
  }

  TonWalletTransactionTransferOutput toWalletTransactionOutput(
      WalletTonNetwork network) {
    return TonWalletTransactionTransferOutput(
      to: address.networkAddress,
      amount: WalletTransactionIntegerAmount(
          amount: hasToken ? tokenBalance.balance : balance.balance,
          network: network,
          token: _token?.token.token,
          tokenIdentifier: jetton?.minterAddress.toFriendlyAddress()),
    );
  }
}

class TonOutputJettonWithBalance {
  final TonJettonToken token;
  final IntegerBalance balance;
  final IntegerBalance forwardBalance;
  BigInt _queryId = BigInt.zero;
  BigInt get queryId => _queryId;
  TonOutputJettonWithBalance._(this.token, this.balance, this.forwardBalance);
  factory TonOutputJettonWithBalance(TonJettonToken token, Token native) {
    return TonOutputJettonWithBalance._(
        token, IntegerBalance.zero(token.token), IntegerBalance.zero(native));
  }

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  void updateForwardAmount(BigInt val) {
    forwardBalance.updateBalance(val);
  }

  void updateQueryId(BigInt val) {
    _queryId = val;
  }
}
