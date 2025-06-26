import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/controller/impl/fee.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/bitcoin/forms/core/bitcoin.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

typedef ONUPDATEUTXOS = Future<List<BitcoinUtxoWithBalance>?> Function(
    List<BitcoinAccountWithUtxos>, List<BitcoinUtxoWithBalance>);

class Web3BitcoinSendTransactionForm extends BitcoinWeb3Form<
    BitcoinClient,
    IBitcoinAddress,
    Web3BitcoinSendTransaction> with BitcoinTransactionFeeController {
  Web3BitcoinSendTransactionForm({required this.request});
  late final List<IBitcoinAddress> spenders = request.accounts.toImutableList;
  late final List<String> spendersAddresses =
      request.accounts.map((e) => e.address.address).toImutableList;
  String? _requiredAccount;
  String? _error;
  String? get error => _error;
  List<BitcoinAccountWithUtxos> _allUtxos = [];
  List<BitcoinAccountWithUtxos> get allUtxos => _allUtxos;
  List<PsbtBitcoinOutputWithBalance> _outputs = [];
  List<PsbtBitcoinOutputWithBalance> get outputs => _outputs;
  late IBitcoinAddress _changeAccount;
  IBitcoinAddress get change => _changeAccount;

  List<BitcoinUtxoWithBalance> _selectedUtxos = [];
  List<BitcoinUtxoWithBalance> get selectedUtxos => _selectedUtxos;
  late final IntegerBalance _totalSelect = IntegerBalance.zero(network.token);
  IntegerBalance get totalSelect => _totalSelect;

  late IntegerBalance _insufficientBalances =
      IntegerBalance.zero(network.token);
  IntegerBalance get insufficientBalances => _insufficientBalances;

  late IntegerBalance _remainderAmount = IntegerBalance.zero(network.token);
  IntegerBalance get remainderAmount => _remainderAmount;

  bool get hasUtxos => _selectedUtxos.isNotEmpty;
  BasedUtxoNetwork get utxoNetwork => network.coinParam.transacationNetwork;
  late final IntegerBalance totalUtxos =
      IntegerBalance.zero(network.token, allowNegative: false);
  BigInt get balance => _totalSelect.balance;
  bool get isReady => _error == null && !_insufficientBalances.isNegative;

  void onChangeRemainderAccount(IBitcoinAddress? remainderAccount) {
    if (remainderAccount == null) return;
    _changeAccount = remainderAccount;
    notify();
  }

  void _updateTx() {
    _insufficientBalances = _checkBalances();
    _remainderAmount = _checkRemainderAmount();
    notify();
  }

  Future<void> updateUtxos(ONUPDATEUTXOS onTap) async {
    final utxos = await onTap(allUtxos, _selectedUtxos);
    if (utxos == null) return;
    _setUtxos(utxos);
    _updateTotalUtxos();
    _updateTx();
    estimateFee();
  }

  void _setUtxos(List<BitcoinUtxoWithBalance> utxos) {
    final cl = utxos.clone();
    cl.sort((a, b) => spendersAddresses
        .indexOf(a.viewAddress)
        .compareTo(spendersAddresses.indexOf(b.viewAddress)));
    _selectedUtxos = cl.toImutableList;
    if (_requiredAccount != null) {
      if (!utxos.any((e) => e.viewAddress == _requiredAccount)) {
        _error =
            'bitcoin_account_must_spend'.tr.replaceOne(_requiredAccount ?? '');
      } else {
        _error = null;
      }
    }
  }

  IntegerBalance _checkRemainderAmount() {
    if (insufficientBalances.largerThanZero) {
      return insufficientBalances.clone(allowNegative: false, immutable: true);
    }
    return IntegerBalance.zero(network.token, immutable: true);
  }

  ReceiptAddress<BitcoinBaseAddress>? _getReceiptAddress(
      BitcoinBaseAddress? address) {
    if (address == null) return null;
    final addressStr = address.toAddress(utxoNetwork);
    return account.getReceiptAddress(addressStr) ??
        ReceiptAddress(view: addressStr, networkAddress: address);
  }

  PsbtBitcoinOutputWithBalance _buildOutput(
      Web3BitcoinSendTransactionOutput output) {
    BitcoinBaseAddress? address;
    if (output.address != null) {
      address = BitcoinNetworkAddress.parse(
              address: output.address!,
              network: network.coinParam.transacationNetwork)
          .baseAddress;
    } else {
      address = account.findAddressFromScript(output.scriptPubKey) ??
          BitcoinScriptUtils.tryGenerateAddressFromScriptPubKey(
              output.scriptPubKey);
    }
    final receipt = _getReceiptAddress(address);
    return PsbtBitcoinOutputWithBalance(
      scriptPubKey: output.scriptPubKey,
      balance: output.value,
      network: network,
      address: receipt,
    );
  }

  @override
  Web3BitcoinRequest<String, Web3BitcoinSendTransaction> request;
  Future<List<BitcoinAccountWithUtxos>> _readUtxos(
      List<IBitcoinAddress> spenders) async {
    List<BitcoinAccountWithUtxos> allUtxos = [];
    for (final i in spenders) {
      final utxos = await client.readUtxos(i.toUtxoRequest(), false);
      allUtxos.add(BitcoinAccountWithUtxos(
          address: i,
          addressDetails: i.toUtxoRequest(),
          utxos: utxos.where((e) => e.utxo.token == null).toList(),
          network: network));
    }
    return allUtxos.immutable;
  }

  void _updateTotalUtxos() {
    final amounts =
        selectedUtxos.fold(BigInt.zero, (p, c) => p + c.balance.balance);
    _totalSelect.updateBalance(amounts);
  }

  IntegerBalance _checkBalances() {
    final insufficientBalances =
        _totalSelect.clone(allowNegative: true, immutable: false);
    insufficientBalances.minusAmount(fee.balance);
    for (final i in outputs) {
      insufficientBalances.minusAmount(i.balance.balance);
    }
    return insufficientBalances;
  }

  Web3BitcoinSendTransaction get params => request.params;

  List<UtxoWithAddress> _buildInputs() {
    return _selectedUtxos.map((e) => e.utxo).toList();
  }

  List<BitcoinBaseOutput> _buildOutputs() {
    final outs = outputs.map((e) => e.toOutput()).toList();
    return [
      ...outs,
      if (_remainderAmount.largerThanZero)
        BitcoinOutput(
            address: _changeAccount.networkAddress,
            value: _remainderAmount.balance)
    ];
  }

  @override
  void estimateFee(
      {List<BitcoinBaseOutput> outPuts = const [],
      List<UtxoWithAddress> inputs = const [],
      BCMR? bcmr}) {
    outPuts = _buildOutputs();
    inputs = _buildInputs();
    super.estimateFee(outPuts: outPuts, inputs: inputs, bcmr: bcmr);
    _updateTx();
  }

  @override
  Future<void> changeFee(ONCHANGEFEE onTap) async {
    await super.changeFee(onTap);
    _updateTx();
  }

  BasedBitcoinTransacationBuilder buildTransaction() {
    final outPuts = _buildOutputs();
    final inputs = _buildInputs();
    if (network.coinParam.isForked) {
      return ForkedTransactionBuilder(
          utxos: inputs,
          outPuts: outPuts,
          fee: fee.balance,
          inputOrdering: BitcoinOrdering.none,
          outputOrdering: BitcoinOrdering.none,
          network: network.coinParam.transacationNetwork);
    } else {
      return BitcoinTransactionBuilder(
          utxos: inputs,
          outPuts: outPuts,
          fee: fee.balance,
          inputOrdering: BitcoinOrdering.none,
          outputOrdering: BitcoinOrdering.none,
          network: network.coinParam.transacationNetwork);
    }
  }

  void sendTransaction() {
    onCompleteForm?.call(null);
  }

  @override
  Future<void> initForm(
      {required BitcoinChain account,
      required IBitcoinAddress address,
      required WalletBitcoinNetwork network,
      required BitcoinClient<IBitcoinAddress> client}) async {
    await super.initForm(
        account: account, address: address, network: network, client: client);
    if (spenders.isEmpty) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    if (spenders.map((e) => e.network).toSet().length != 1) {
      throw Web3BitcoinExceptionConstant.invalidRequestAccounts;
    }
    if (spenders.isEmpty) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    if (params.requiredAccount != null) {
      _requiredAccount = params.requiredAccount?.addressStr;
      if (!spenders.any((e) => e.address.address == _requiredAccount)) {
        throw Web3RequestExceptionConst.missingPermission;
      }
    }

    final rOutputs = request.params.outputs;
    if (rOutputs.isEmpty) {
      throw Web3BitcoinExceptionConstant.emptyOutput;
    }

    _allUtxos = await _readUtxos(spenders);
    _setUtxos(
        _allUtxos.map((e) => e.utxosWithBalance).expand((e) => e).toList());

    _updateTotalUtxos();
    final outputs = rOutputs.map((e) => _buildOutput(e)).toList();
    _outputs = outputs.immutable;
    _changeAccount = this.address;
    _updateTx();
    await initNetworkFee();
    estimateFee();
  }

  @override
  void close() {
    super.close();
    onCompleteForm = null;
  }
}
