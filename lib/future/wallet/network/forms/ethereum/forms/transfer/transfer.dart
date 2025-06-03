import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/crypto/utils/utils.dart';
import 'package:on_chain/on_chain.dart';

class EthereumTransferForm extends EthereumTransactionForm {
  EthereumTransferForm({required this.token, this.erc20Token});
  @override
  BigInt get callValue => mode != ETHTransactionMode.erc20Transfer
      ? (amount.value?.balance ?? BigInt.zero)
      : BigInt.zero;
  @override
  BigInt get tokenValue => mode == ETHTransactionMode.erc20Transfer
      ? (amount.value?.balance ?? BigInt.zero)
      : BigInt.zero;
  final Token token;
  final ETHERC20Token? erc20Token;
  @override
  bool get enableSwitchAccount => erc20Token == null;
  final TransactionFormField<ReceiptAddress<ETHAddress>> destination =
      TransactionFormField(
          name: "destination",
          optional: false,
          onChangeForm: (p0) {
            return p0;
          });
  final TransactionFormField<IntegerBalance> amount = TransactionFormField(
    name: "amount",
    optional: false,
    onChangeForm: (v) {
      try {
        if (v!.isZero || v.isNegative) return null;
        return v;
      } catch (e) {
        return null;
      }
    },
  );

  List<TransactionFormField> get fields => [destination, amount];

  @override
  String get name => erc20Token != null ? "transfer_erc20" : "transfer";

  void setValue<T>(TransactionFormField<T>? field, T? value) {
    if (field == null) return;
    if (field.setValue(value)) {
      onChanged?.call();
      _checkEstimate();
    }
  }

  void _checkEstimate() {
    if (validateError() == null && erc20Token != null) {
      onStimateChanged?.call();
    }
  }

  @override
  String? validateError() {
    for (final i in fields) {
      if (!i.optional && !i.hasValue) {
        return "field_is_req".tr.replaceOne(i.name.tr);
      }
    }
    return null;
  }

  @override
  Map<String, dynamic> toEstimate({String? memo}) {
    final estimate = ETHTransaction(
            from: address.networkAddress,
            to: erc20Token?.contractAddress ??
                destination.value?.networkAddress ??
                address.networkAddress,
            nonce: 0,
            gasLimit: BigInt.one,
            data: _getData(memo),
            value: BigInt.zero,
            chainId: network.coinParam.chainId)
        .toEstimate();
    return estimate;
  }

  List<int> _getData([String? memo]) {
    List<int> transactionData = [];
    if (erc20Token != null && destination.hasValue && amount.hasValue) {
      transactionData = SolidityContractUtils.erc20Transfer
          .encode([destination.value!.networkAddress, amount.value!.balance]);
    }
    if (memo != null) {
      transactionData = List<int>.from(
          [...transactionData, ...StringUtils.tryToBytes(memo) ?? <int>[]]);
    }
    return transactionData;
  }

  @override
  ETHTransaction toTransaction({required EthereumFee fee, String? memo}) {
    final ETHTransaction tr = ETHTransaction(
      type: fee.isEIP1559
          ? ETHTransactionType.eip1559
          : ETHTransactionType.legacy,
      from: address.networkAddress,
      chainId: network.coinParam.chainId,
      data: _getData(memo),
      nonce: 0,
      gasPrice: fee.gasPrice,
      maxFeePerGas: fee.maxFeePerGas,
      maxPriorityFeePerGas: fee.maxPriorityFeePerGas,
      gasLimit: BigInt.from(fee.gasLimit),
      value: erc20Token != null ? BigInt.zero : amount.value!.balance,
      to: erc20Token?.contractAddress ?? destination.value!.networkAddress,
    );
    return tr;
  }

  @override
  ETHTransactionMode get mode => erc20Token != null
      ? ETHTransactionMode.erc20Transfer
      : ETHTransactionMode.transfer;

  @override
  void close() {
    destination.clear();
    amount.clear();
    super.close();
  }

  @override
  EthWalletTransaction toWalletTransaction({required String txId}) {
    return EthWalletTransaction(
        txId: txId,
        time: DateTime.now(),
        outputs: [
          EthWalletTransactionTransferOutput(
              to: destination.value!.networkAddress,
              amount: WalletTransactionIntegerAmount(
                  amount: amount.value!.balance,
                  network: network,
                  token: erc20Token?.token,
                  tokenIdentifier: erc20Token?.contractAddress.address))
        ],
        totalOutput: WalletTransactionIntegerAmount(
            amount: amount.value!.balance,
            network: network,
            token: erc20Token?.token),
        network: network);
  }
}
