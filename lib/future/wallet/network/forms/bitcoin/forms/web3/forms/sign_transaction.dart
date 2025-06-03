import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/bitcoin/forms/core/bitcoin.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

class Web3BitcoinSignTransactionForm extends BitcoinWeb3Form<BitcoinClient,
    IBitcoinAddress, Web3BitcoinSignTransaction> {
  Web3BitcoinSignTransactionForm({required this.request});
  @override
  Web3BitcoinRequest<String, Web3BitcoinSignTransaction> request;

  List<BitcoinPsbtInputWithAccount> _inputs = [];
  List<BitcoinPsbtInputWithAccount> get inputs => _inputs;
  List<BitcoinPsbtInputWithAccount> _accountInputs = [];
  List<BitcoinPsbtInputWithAccount> get accountInputs => _accountInputs;
  BasedUtxoNetwork get utxoNetwork => network.coinParam.transacationNetwork;
  List<PsbtBitcoinOutputWithBalance> _outputs = [];
  List<PsbtBitcoinOutputWithBalance> get outputs => _outputs;
  Psbt get psbt => request.params.psbt;
  late IntegerBalance _totalOutput = IntegerBalance.zero(network.token);
  IntegerBalance get totalOutput => _totalOutput;
  late IntegerBalance _totalInput = IntegerBalance.zero(network.token);
  IntegerBalance get totalInput => _totalInput;
  late IntegerBalance _totalAccountInput = IntegerBalance.zero(network.token);
  IntegerBalance get totalAccountInput => _totalAccountInput;

  late IntegerBalance _fee = IntegerBalance.zero(network.token);
  IntegerBalance get fee => _fee;
  late PsbtBuilder _builder;
  PsbtBuilder get builder => _builder;

  ReceiptAddress<BitcoinBaseAddress>? _getReceiptAddress(
      BitcoinBaseAddress? address) {
    if (address == null) return null;
    final addressStr = address.toAddress(utxoNetwork);
    return account.getReceiptAddress(addressStr) ??
        ReceiptAddress(view: addressStr, networkAddress: address);
  }

  int _getInputSigHash(int? sighash, BitcoinBaseAddress address) {
    if (sighash != null) return sighash;
    switch (utxoNetwork) {
      case BitcoinSVNetwork.mainnet:
      case BitcoinSVNetwork.testnet:
      case BitcoinCashNetwork.testnet:
      case BitcoinCashNetwork.mainnet:
        return BitcoinOpCodeConst.sighashAll | BitcoinOpCodeConst.sighashForked;
      default:
        if (address.type.isP2tr) return BitcoinOpCodeConst.sighashDefault;
        return BitcoinOpCodeConst.sighashAll;
    }
  }

  Future<List<BitcoinPsbtInputWithAccount>> _readUtxos(
      List<BitcoinPsbtInputWithAccount> inputs) async {
    List<BitcoinPsbtInputWithAccount> checkedInputs = [];
    Map<String, List<UtxoWithAddress>> utxos0 = {};
    Map<String, BtcTransaction> txs = {};
    for (final i in inputs) {
      if (i.owner != null) {
        if (!utxos0.containsKey(i.address.view)) {
          final utxos = await client.readUtxos(i.owner!);
          utxos0[i.address.view] = utxos;
        }
        final utxo = utxos0[i.address.view]!.firstWhere(
            (e) =>
                e.utxo.txHash == i.input.txId && e.utxo.vout == i.input.txIndex,
            orElse: () => throw Web3BitcoinExceptionConstant.txInputNotFound(
                i.input.txId, i.input.txIndex));
        checkedInputs.add(i.copyWith(value: utxo.utxo.value, network: network));
        continue;
      }
      txs[i.input.txId] ??= await client.getTx(i.input.txId);
      final transaction = txs[i.input.txId]!;

      if (i.input.txIndex >= transaction.outputs.length) {
        throw Web3BitcoinExceptionConstant.txInputNotFound(
            i.input.txId, i.input.txIndex);
      }
      final output = transaction.outputs[i.input.txIndex];
      checkedInputs.add(i.copyWith(value: output.amount, network: network));
    }
    return checkedInputs;
  }

  @override
  Future<void> initForm(
      {required BitcoinChain account,
      required IBitcoinAddress address,
      required WalletBitcoinNetwork network,
      required BitcoinClient<IBitcoinAddress> client}) async {
    await super.initForm(
        account: account, address: address, network: network, client: client);
    final builder = PsbtBuilder.fromPsbt(psbt);
    final List<IBitcoinAddress> activeAccount = request.accounts;
    final inputLength = psbt.input.length;
    List<BitcoinPsbtInputWithAccount> inputs = [];
    List<PsbtBitcoinOutputWithBalance> outputs = [];
    final sighashes =
        PsbtUtils.getAllExistsSighashType(psbt.input, builder.txType());
    for (int i = 0; i < inputLength; i++) {
      final signash = sighashes.firstWhereNullable((e) => e.inputIndex == i);

      final psbtInput = builder.psbtInput(i);
      final psbtAddress = psbtInput.address;
      IBitcoinAddress? address;
      final accountAddress =
          this.account.findAddressFromScript(psbtAddress.toScriptPubKey());
      if (accountAddress != null) {
        address =
            this.account.getAddress(accountAddress.toAddress(utxoNetwork));
      }
      final inputSighash = _getInputSigHash(signash?.sighashType, psbtAddress);
      final account = activeAccount.firstWhereOrNull(
          (e) => e.networkAddress.toScriptPubKey() == psbtInput.scriptPubKey);
      if (account != null) {
        if (address == null) {
          throw Web3RequestExceptionConst.missingPermission;
        }
      }
      final inputWithAccount = BitcoinPsbtInputWithAccount(
          owner: address?.toUtxoRequest(),
          input: psbtInput.txInput,
          index: i,
          address: _getReceiptAddress(accountAddress ?? psbtAddress)!,
          sighash: inputSighash,
          ownerAddress: address,
          network: network);
      inputs.add(inputWithAccount);
    }
    if (inputs.isEmpty || inputs.every((e) => e.owner == null)) {
      throw Web3BitcoinExceptionConstant.noRelatedInput;
    }
    inputs = await _readUtxos(inputs);
    final outputLength = psbt.output.length;
    for (int i = 0; i < outputLength; i++) {
      final psbtOutput = builder.psbtOutput(i);
      final currentAddress =
          this.account.findAddressFromScript(psbtOutput.scriptPubKey);
      final output = PsbtBitcoinOutputWithBalance(
        address: _getReceiptAddress(currentAddress ?? psbtOutput.address),
        network: network,
        scriptPubKey: psbtOutput.scriptPubKey,
        balance: psbtOutput.amount,
      );
      outputs.add(output);
    }

    final totalAccountInput = inputs.fold<BigInt>(BigInt.zero, (p, c) {
      if (c.owner == null) return p;
      return p + c.balance.balance;
    });
    final totalInput =
        inputs.fold<BigInt>(BigInt.zero, (p, c) => p + c.balance.balance);
    final totalOutput =
        outputs.fold<BigInt>(BigInt.zero, (p, c) => p + c.balance.balance);
    _inputs = inputs.immutable;
    _outputs = outputs.immutable;
    _accountInputs = inputs.where((e) => e.owner != null).toImutableList;
    _totalAccountInput = IntegerBalance.token(totalAccountInput, network.token,
        allowNegative: false, immutable: true);
    _totalInput = IntegerBalance.token(totalInput, network.token,
        allowNegative: false, immutable: true);
    _totalOutput = IntegerBalance.token(totalOutput, network.token,
        allowNegative: false, immutable: true);
    final fee = totalInput - totalOutput;
    _fee = IntegerBalance.token(fee, network.token,
        allowNegative: true, immutable: true);
    _builder = builder;
  }

  void signTransaction() {
    onCompleteForm?.call(null);
  }

  @override
  void close() {
    super.close();
    _inputs = [];
    _outputs = [];
    _accountInputs = [];
    onCompleteForm = null;
  }
}
