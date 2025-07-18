import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/tron/tron.dart';
import 'package:on_chain_wallet/wallet/models/others/others.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronTransactionRequestController
    extends Web3TronImpl<Transaction, Web3TronSendTransaction> {
  TronFee? _consumedFee;
  TronFee? get consumedFee => _consumedFee;

  Web3TronTransactionRequestController({
    required super.walletProvider,
    required super.request,
  });

  late final IntegerBalance ownerBalance = IntegerBalance.zero(network.token);

  late final Web3TronTransactionInfo info;
  late final ReceiptAddress<TronAddress> owner;
  IntegerBalance? _feeLimit;
  IntegerBalance? get feeLimit => _feeLimit;
  String? _memo;
  String? get memo => _memo;

  late final Transaction transaction;
  TransactionContractType get type => transaction.rawData.type;
  bool _trIsReady = false;
  bool get trIsReady => _trIsReady;

  late IntegerBalance _remainAmount;
  IntegerBalance get remindAmount => _remainAmount;

  bool _checkTransaction() {
    final transactionValue = info.totalTrxAmount?.balance ?? BigInt.zero;
    final remindTrx = ownerBalance.balance -
        (transactionValue + consumedFee!.totalBurn.balance);
    _remainAmount = IntegerBalance.token(remindTrx, network.token);
    if (!_remainAmount.isNegative) {
      if (info.transferAsset != null) {
        final remindTokenAmounts = info.transferAsset!.token.balance.balance -
            info.transferAsset!.amount.balance;
        if (remindTokenAmounts.isNegative) {
          _remainAmount = IntegerBalance.token(
              remindTokenAmounts, info.transferAsset!.token.token);
        }
      }
      if (info.trc20Transfer != null && !_remainAmount.isNegative) {
        final remindTokenAmounts = info.trc20Transfer!.token.balance.balance -
            info.trc20Transfer!.value.balance;
        if (remindTokenAmounts.isNegative) {
          _remainAmount = IntegerBalance.token(
              remindTokenAmounts, info.trc20Transfer!.token.token);
        }
      }
    }

    return !_remainAmount.isNegative;
  }

  Future<TronAccountResourceInfo> _initNetworkCondition() async {
    final result = await MethodUtils.call(() async {
      final account =
          await apiProvider.getAccount(transaction.rawData.ownerAddress);

      if (account == null) {
        return (null, TronAccountResourceInfo.empty());
      }
      final accountResource = await apiProvider
          .getAccountResource(transaction.rawData.ownerAddress);
      return (account, accountResource);
    });
    if (result.hasError) {
      return TronAccountResourceInfo.empty();
    }
    ownerBalance.updateBalance(result.result.$1?.balance);
    return result.result.$2;
  }

  Future<TronFee> _calcuateFee(
      {required Web3TronTransactionInfo transactionInfo,
      required Transaction transaction,
      required TronAccountResourceInfo resource}) async {
    final chainParameters = await apiProvider.getChainParameters();

    int signer = 1;
    int energy = 0;
    // int? permissionId;
    bool isNewAccount = false;
    final dstAccount = transactionInfo.destination;
    if (transactionInfo.isTransferContract && dstAccount != null) {
      final accountInfo =
          await apiProvider.getAccount(dstAccount.networkAddress);
      isNewAccount = accountInfo == null;
    }
    if (address.multiSigAccount) {
      final multiSigAccount = address as ITronMultisigAddress;
      signer = multiSigAccount.keyDetails.length;
    }
    if (transactionInfo.isSmartContract) {
      final contract = transaction.rawData.getContract<TriggerSmartContract>();
      energy = await apiProvider.estimateContractEnergy(
        ownerAddress: contract.ownerAddress,
        contractAddress: contract.contractAddress,
        data: BytesUtils.toHexString(contract.data ?? []),
        callTokenValue: contract.callTokenValue,
        tokenID: contract.tokenId,
        callValue: contract.callValue,
      );
    }
    if (transactionInfo.isCreateContract) {
      final contract = transaction.rawData.getContract<CreateSmartContract>();
      energy = await apiProvider.estimateCreateContractEnergy(
          ownerAddress: contract.ownerAddress,
          byteCode: BytesUtils.toHexString(contract.newContract.bytecode),
          callTokenValue: contract.callTokenValue,
          tokenID: contract.tokenId);
    }
    return TronFee.calculate(
        raw: transaction.rawData,
        chainParameters: chainParameters,
        resource: resource,
        hasMemo: transaction.rawData.data?.isNotEmpty ?? false,
        signature: signer,
        consumedEnergy: energy,
        isNewAccount: isNewAccount,
        network: network);
  }

  @override
  Future<void> initWeb3() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final tx = await MethodUtils.call(() async {
      final transaction = MethodUtils.nullOnException(
          () => Transaction.deserialize(request.params.transaction));
      if (transaction == null) {
        throw Web3RequestExceptionConst.invalidTransaction;
      }
      if (request.params.txId != null &&
          request.params.txId != transaction.rawData.txID) {
        throw Web3RequestExceptionConst.invalidTransaction;
      }
      return transaction;
    });
    if (tx.hasError) {
      progressKey.errorResponse(error: tx.error);
      request.error(Web3RequestExceptionConst.fromException(tx.exception!));
      return;
    }
    transaction = tx.result;
    final resource = await _initNetworkCondition();
    final contractOwner = transaction.rawData.ownerAddress;
    owner = account.getReceiptAddress(contractOwner.toAddress()) ??
        ReceiptAddress<TronAddress>(
            view: contractOwner.toAddress(), networkAddress: contractOwner);
    final transactionInfo = await MethodUtils.call(() async =>
        await apiProvider.getWeb3TransactionInfo(
            transaction: transaction.rawData, chain: account));
    if (address.multiSigAccount) {
      final multiSigAddress = address as ITronMultisigAddress;
      if (transaction.rawData.permissionId() !=
          multiSigAddress.multiSignatureAccount.permissionID) {
        progressKey.errorResponse(
          message: "tron_account_permission_not_access_desc".tr,
        );
        request.error(Web3RequestExceptionConst.missingPermission);
        return;
      }
    }

    if (transactionInfo.hasError) {
      progressKey.errorResponse(error: transactionInfo.exception);
      request.error(Web3RequestExceptionConst.internalError);
    } else {
      final fee = await MethodUtils.call(() => _calcuateFee(
          transactionInfo: transactionInfo.result,
          transaction: transaction,
          resource: resource));
      if (fee.hasError) {
        progressKey.errorResponse(error: fee.exception);
        request.error(Web3RequestExceptionConst.fromException(fee.exception!));
        return;
      }
      info = transactionInfo.result;
      _consumedFee = fee.result;
      if (transaction.rawData.feeLimit != null) {
        _feeLimit =
            IntegerBalance.token(transaction.rawData.feeLimit!, network.token);
      }
      if (transaction.rawData.data?.isNotEmpty ?? false) {
        _memo = StringUtils.tryDecode(transaction.rawData.data) ??
            BytesUtils.toHexString(transaction.rawData.data!);
      }
      _trIsReady = _checkTransaction();
      progressKey.idle();
    }
  }

  Future<void> confirmTransaction() async {
    progressKey.process(text: "create_sign_transaction".tr);
    final result = await MethodUtils.call(() async {
      final WalletSigningRequest<List<List<int>>> request =
          WalletSigningRequest<List<List<int>>>(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final List<int> transactionDigest =
              List<int>.unmodifiable(transaction.rawData.toBuffer());
          if (address.multiSigAccount) {
            final multiSigAddress = address as ITronMultisigAddress;
            final List<List<int>> signerSignatures = [];
            BigInt threshHold = BigInt.zero;
            for (final i in multiSigAddress.multiSignatureAccount.signers) {
              try {
                final signRequest = GlobalSignRequest.tron(
                    digest: transactionDigest, index: i.keyIndex);
                final response = await generateSignature(signRequest);
                signerSignatures.add(response.signature);
                threshHold += i.weight;
                if (threshHold >=
                    multiSigAddress.multiSignatureAccount.threshold) {
                  break;
                }
              } catch (_) {
                continue;
              }
            }
            if (threshHold < multiSigAddress.multiSignatureAccount.threshold) {
              throw WalletExceptionConst.privateKeyIsNotAvailable;
            }
            return signerSignatures;
          }
          final signRequest = GlobalSignRequest.tron(
              digest: transactionDigest, index: address.keyIndex.cast());
          final response = await generateSignature(signRequest);
          return [response.signature];
        },
      );

      final signature =
          await walletProvider.wallet.signTransaction(request: request);
      if (signature.hasError) {
        throw signature.exception!;
      }
      return signature.result.map((e) => e).toList();
    });

    if (result.hasError) {
      progressKey.error(error: result.exception, showBackButton: true);
    } else {
      final signedTx = Transaction(
          rawData: transaction.rawData,
          signature: [...transaction.signature, ...result.result]);
      request.completeResponse(signedTx);
      progressKey.response(text: "transaction_signed".tr);
    }
  }
}
