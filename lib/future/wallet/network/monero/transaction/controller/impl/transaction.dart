import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/constant/networks/monero.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

enum MoneroTxPage {
  utxo,
  send;
}

abstract class MoneroTransactionImpl extends WalletSendTransactionStateImpl<
    IMoneroAddress, MoneroClient, WalletMoneroNetwork, MoneroChain> {
  MoneroTransactionImpl({
    required super.walletProvider,
    required super.account,
    required super.apiProvider,
  });
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  DaemonGetEstimateFeeResponse get baseFee;
  late final IntegerBalance fee = IntegerBalance.zero(network.token);
  late final IntegerBalance remindAmount = IntegerBalance.zero(network.token);
  late final IntegerBalance setupAmount = IntegerBalance.zero(network.token);
  Future<void> calculateFee();

  List<MoneroAccountWithUtxo> _utxos = [];
  List<MoneroAccountWithUtxo> get utxos => _utxos;
  ReceiptAddress<MoneroAddress>? _change;
  ReceiptAddress<MoneroAddress> get change => _change!;

  bool _txReady = false;
  bool get txReady => _txReady;

  final Map<MoneroAddress, MoneroOutputWithBalance> _receivers = {};

  List<MoneroOutputWithBalance> get receivers => _receivers.values.toList();
  late final IntegerBalance spendableAmount =
      IntegerBalance.zero(network.token, allowNegative: false);

  MoneroTxPage _page = MoneroTxPage.utxo;
  MoneroTxPage get page => _page;
  bool get canPop =>
      page == MoneroTxPage.utxo ||
      (page == MoneroTxPage.send && progressKey.isSuccess);

  void onPop(bool canPop, Object? result) {
    _page = MoneroTxPage.utxo;
    notify();
  }

  bool _utxosIsReady = false;
  bool get utxosIsReay => _utxosIsReady;
  final Map<ReceiptAddress<MoneroAddress>, List<MoneroOutputDetails>>
      _selectedUtxos = {};

  Map<ReceiptAddress<MoneroAddress>, List<MoneroOutputDetails>>
      get selectedUtxos => _selectedUtxos;

  bool _isReady() {
    final zeroOutput = receivers.any((element) => !element.hasAmount);
    return receivers.isNotEmpty &&
        !zeroOutput &&
        !remindAmount.isNegative &&
        !setupAmount.isZero;
  }

  void addOrRemoveUtxo(
      {required ReceiptAddress<MoneroAddress> address,
      required MoneroOutputDetails utxo,
      required DynamicVoid onError}) {
    try {
      final r = _selectedUtxos[address]!.remove(utxo);
      if (r) return;
      if (utxo.needUpdate) return;
      final total = _selectedUtxos.values.fold(0, (p, c) => p + c.length);
      if (total > MoneroConst.ringSize) {
        onError();
        return;
      }
      _selectedUtxos[address]?.add(utxo);
    } finally {
      _checkUtxos();
      notify();
    }
  }

  bool _canSendToAddress(MoneroAddress address) {
    if (address.isIntegratedAddress) {
      if (receivers.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  void _checkUtxos() {
    final total = _selectedUtxos.values.fold(BigInt.zero,
        (p, c) => p + c.fold<BigInt>(BigInt.zero, (p, c) => p + c.amount));
    final totalUtxos = _selectedUtxos.values.fold(0, (p, c) => p + c.length);
    spendableAmount.updateBalance(total);
    _utxosIsReady = spendableAmount.balance > BigInt.zero &&
        totalUtxos <= MoneroConst.ringSize;
  }

  Future<void> initTransaction() async {
    // await apiProvider.updateAccountUtxos(address: address, account: account);
    _utxos = account.relatedTxAccountsUtxos(address.addrDetails.viewKey);
    int total = 0;
    for (final i in _utxos) {
      List<MoneroOutputDetails> utxos = i.utxos
          .where((e) => !e.output.needUpdate)
          .map((e) => e.output)
          .toList();
      if (total < 16) {
        utxos = utxos.take(16 - total).toList();
      } else {
        break;
      }
      _selectedUtxos.putIfAbsent(i.address, () => utxos);
      total += utxos.length;
    }
    _change = ReceiptAddress(
        view: address.networkAddress.address,
        networkAddress: address.networkAddress,
        account: address,
        type: address.networkAddress.type.name);
    _checkUtxos();
  }

  Future<void> goToSend() async {
    if (utxosIsReay) {
      progressKey.progressText("estimating_fee_please_wait".tr);
      onCalculateAmount();
      await calculateFee();
      onCalculateAmount();
      _page = MoneroTxPage.send;
      notify();
      progressKey.backToIdle();
    }
  }

  void onCalculateAmount() {
    final totalAmounts = receivers.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.amount.balance);
    setupAmount.updateBalance(totalAmounts);
    final remind = spendableAmount.balance - (totalAmounts + fee.balance);
    remindAmount.updateBalance(remind);
    _txReady = _isReady();
  }

  (String, bool)? _onAddRecever(ReceiptAddress<MoneroAddress> addr) {
    if (_receivers.length >= MoneroConst.maxTxOutput) {
      return ("transaction_output_exceeds_16_desc".tr, true);
    }
    if (change.networkAddress == addr.networkAddress ||
        _receivers.containsKey(addr.networkAddress)) {
      return ("some_addresses_exist".tr, false);
    } else {
      if (_canSendToAddress(addr.networkAddress)) {
        _receivers[addr.networkAddress] =
            MoneroOutputWithBalance(address: addr, network: network);
        return null;
      }
      return ("monero_tx_integrated_address_alert".tr, false);
    }
  }

  void onAddRecever(
      List<ReceiptAddress<MoneroAddress>>? addr, StringVoid onError) {
    if (addr == null) return;
    for (final i in addr) {
      final hasError = _onAddRecever(i);
      if (hasError == null) continue;
      onError(hasError.$1);
      if (hasError.$2) break;
    }
    notify();
  }

  void _calculateFee() {
    bool outputIsReady = receivers.isEmpty
        ? false
        : receivers.every((element) => element.hasAmount);
    if (outputIsReady) {
      calculateFee();
    }
  }

  void onRemoveReceiver(ReceiptAddress<MoneroAddress> addr) {
    final r = _receivers.remove(addr.networkAddress);
    if (r != null) {
      onCalculateAmount();
      notify();
      _calculateFee();
    }
  }

  void changeAccount(IMoneroAddress? change, DynamicVoid onAccountExists) {
    if (change != null) {
      if (change.networkAddress == _change?.networkAddress) return;
      if (_receivers.containsKey(change.networkAddress)) {
        onAccountExists();
        return;
      }
      _change = ReceiptAddress(
          view: change.networkAddress.address,
          networkAddress: change.networkAddress,
          type: change.type,
          account: change);
      notify();
    }
  }

  void setupAccountAmount(MoneroAddress address, BigInt? amount) async {
    if (amount == null) return;
    _receivers[address]?.updateBalance(amount);
    notify();
    final isMax = amount == remindAmount.balance;
    onCalculateAmount();
    if (isMax) {
      await calculateFee();
      if (isMax) {
        final fixedAmount = amount + remindAmount.balance;
        _receivers[address]?.updateBalance(fixedAmount);
        onCalculateAmount();
        notify();
      }
    } else {
      if (_utxosIsReady) {
        _calculateFee();
      }
    }
  }
}
