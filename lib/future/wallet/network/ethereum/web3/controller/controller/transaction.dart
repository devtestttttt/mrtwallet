import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/transaction/controller/impl/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/transaction/controller/impl/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/web3/controller/impl/web3.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/ethereum/models/init_fee.dart';
import 'package:on_chain_wallet/wallet/models/networks/ethereum/models/web3_transaction_infos.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart'
    show WalletTransactionIntegerAmount, WalletWeb3ClientTransaction;
import 'package:on_chain_wallet/wallet/models/transaction/networks/ethereum.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain/on_chain.dart';

typedef ONInsufficientBalance = Future<bool?> Function();

class Web3EthereumTransactionRequestController
    extends Web3EthereumImpl<String, Web3EthreumSendTransaction>
    with ETHTransactionFeeImpl, ETHSignerImpl {
  Web3EthereumTransactionRequestController(
      {required super.walletProvider, required super.request});

  Web3EthereumTransactionRequestInfos? _transactionInfos;
  Web3EthereumTransactionRequestInfos get transactionInfos =>
      _transactionInfos!;
  @override
  EthereumInitFee? get initFee => transactionInfos.initFee;

  IntegerBalance? _remainTokenAmount;
  late final IntegerBalance _remainNativeAmount =
      IntegerBalance.zero(network.token);
  late IntegerBalance _remainAmount = IntegerBalance.zero(network.token);
  IntegerBalance get remindAmount => _remainAmount;

  bool _trReady = false;
  bool get trIsReady => _trReady;
  bool _insufficientBalance = false;

  bool get insufficientBalance => _insufficientBalance;

  bool _checkTransaction() {
    final transactionValue = transactionInfos.value.balance +
        (currentEIP1559Fee?.fee.balance ?? BigInt.zero);
    final erc20Transfer =
        transactionInfos.dataInfo?.safeCast<SolidityERC20TransferMethodInfo>();
    _remainNativeAmount
        .updateBalance(address.address.currencyBalance - transactionValue);
    if (erc20Transfer == null) {
      _remainAmount = _remainNativeAmount;
    } else {
      final remindTokenAmounts =
          erc20Transfer.token.balance.balance - erc20Transfer.value.balance;
      _remainTokenAmount!.updateBalance(remindTokenAmounts);
      if (_remainNativeAmount.isNegative) {
        _remainAmount = _remainNativeAmount;
      } else {
        _remainAmount = _remainTokenAmount!;
      }
    }
    _insufficientBalance = remindAmount.isNegative;

    return gasInited && (feeSpeed == EIP1559FeeSpeed.customFee || !updatingGas);
  }

  @override
  void onFeeChanged() {
    _trReady = _checkTransaction();
    notify();
  }

  void _init() {
    final erc20Transfer =
        transactionInfos.dataInfo?.safeCast<SolidityERC20TransferMethodInfo>();
    if (erc20Transfer != null) {
      _remainTokenAmount = IntegerBalance.token(
          erc20Transfer.value.balance, erc20Transfer.token.token);
    }
    _trReady = _checkTransaction();
  }

  Map<String, dynamic> _toEstimateData() {
    final transaction = ETHTransaction(
        type: transactionInfos.type,
        from: address.networkAddress,
        to: request.params.to,
        nonce: 0,
        gasLimit: BigInt.one,
        data: request.params.data,
        value: BigInt.zero,
        accessList: request.params.accessList
            ?.map((e) => AccessListEntry(
                address: e.address.address,
                storageKeys: e.storageKeys
                    .map((e) => BytesUtils.toHexString(e))
                    .toList()))
            .toList(),
        chainId: network.coinParam.chainId);
    return transaction.toEstimate();
  }

  @override
  Future<void> estimateGasLimit({Map<String, dynamic>? estimateDetails}) async {
    await super.estimateGasLimit(estimateDetails: _toEstimateData());
  }

  Future<void> _saveTransaction(
      {required String txId, required ETHTransaction transaction}) async {
    final s = await MethodUtils.call(() async {
      final EthWalletTransaction walletTx = EthWalletTransaction(
          txId: txId,
          outputs: [],
          totalOutput: WalletTransactionIntegerAmount(
              amount: transaction.value, network: network),
          web3Client: WalletWeb3ClientTransaction(
              name: request.authenticated.name,
              applicationId: request.authenticated.applicationId,
              image: request.authenticated.icon),
          network: network);
      await account.saveTransaction(address: address, transaction: walletTx);
    });
    assert(!s.hasError, "save ethereum transaction failed $txId");
  }

  void sendTransaction(ONInsufficientBalance onInsufficientBalance) async {
    try {
      if (_insufficientBalance) {
        final accept = await onInsufficientBalance();
        if (accept != true) return;
      }
      final fee = currentEIP1559Fee?.clone(network);
      if (fee == null || !trIsReady) return;
      final ETHTransaction transaction = ETHTransaction(
          type: transactionInfos.type,
          from: address.networkAddress,
          chainId: network.coinParam.chainId,
          data: request.params.data,
          nonce: 0,
          accessList: request.params.accessList
              ?.map((e) => AccessListEntry(
                  address: e.address.address,
                  storageKeys: e.storageKeys
                      .map((e) => BytesUtils.toHexString(e))
                      .toList()))
              .toList(),
          gasPrice: fee.gasPrice,
          maxFeePerGas: fee.maxFeePerGas,
          maxPriorityFeePerGas: fee.maxPriorityFeePerGas,
          gasLimit: BigInt.from(fee.gasLimit),
          value: request.params.value,
          to: request.params.to);
      progressKey.process(
          text: "create_send_transaction"
              .tr
              .replaceOne(network.coinParam.token.name));

      final signedTransaction = await MethodUtils.call(() async {
        return await signTransaction(transaction);
      });
      if (signedTransaction.hasError) {
        progressKey.error(
            error: signedTransaction.exception, showBackButton: true);
        return;
      }

      final result = await MethodUtils.call(() async {
        final txId =
            await apiProvider.sendRawTransaction(signedTransaction.result);
        await _saveTransaction(txId: txId, transaction: transaction);
        return txId;
      });
      stopGasEstimate();
      if (result.hasError) {
        progressKey.errorResponse(error: result.exception);
        final error =
            Web3RequestExceptionConst.fromException(result.exception!);
        request.error(error);
      } else {
        progressKey.responseTx(hash: result.result, network: network);
        request.completeResponse(result.result);
      }
    } finally {
      notify();
    }
  }

  @override
  Future<void> initWeb3() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final result = await MethodUtils.call(() async {
      return await apiProvider.getWeb3TransactionInfos(
          from: address, transaction: request.params, chain: account);
    });

    if (result.hasError) {
      progressKey.errorResponse(error: result.exception);
      request.error(result.error!);
    } else {
      _transactionInfos = result.result;
      try {
        await apiProvider.estimateGasLimit(_toEstimateData());
      } catch (e) {
        progressKey.errorResponse(error: e);
        request.error(e);
        return;
      }
      startGasListening();
      _init();
      progressKey.idle();
      estimateGasLimit();
    }
  }
}
