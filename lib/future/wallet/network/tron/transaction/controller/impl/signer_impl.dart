import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/transaction/controller/impl/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/crypto/utils/tron/tron.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

mixin TronSignerImpl on TronTransactionImpl {
  LiveTransactionForm<TronTransactionForm> get validator;
  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final TronWalletTransaction transaction =
          validator.validator.toWalletTransaction(txId: txId);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save tron transaction failed $txId");
  }

  Future<void> signAndSendTransaction(TronBaseContract transaction) async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      int? permissionId;
      if (address.multiSigAccount) {
        final multiSigAccount = address as ITronMultisigAddress;
        permissionId = multiSigAccount.multiSignatureAccount.permissionID;
      }

      final block = await apiProvider.getNowBlock();
      final BigInt expiration = BigInt.from(DateTime.now()
          .add(TronUtils.defaultTronTrasactionExpiration)
          .millisecondsSinceEpoch);

      final raw = TransactionRaw(
          refBlockBytes: block.blockHeader.rawData.refBlockBytes,
          refBlockHash: block.blockHeader.rawData.refBlockHash,
          expiration: expiration,
          feeLimit: field.type == TransactionContractType.triggerSmartContract
              ? consumedFee!.feeLimit.balance
              : null,
          data: StringUtils.tryToBytes(memo),
          contract: [
            TransactionContract(
                type: transaction.contractType,
                permissionId: permissionId,
                parameter:
                    Any(typeUrl: transaction.typeURL, value: transaction))
          ],
          timestamp: block.blockHeader.rawData.timestamp);

      final WalletSigningRequest<List<List<int>>> request =
          WalletSigningRequest<List<List<int>>>(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final List<int> transactionDigest =
              List<int>.unmodifiable(raw.toBuffer());
          if (address.multiSigAccount) {
            final multiSigAddress = address as ITronMultisigAddress;
            final List<List<int>> signerSignatures = [];
            BigInt threshHold = BigInt.zero;
            for (final i in multiSigAddress.multiSignatureAccount.signers) {
              try {
                final signRequest = GlobalSignRequest.tron(
                    digest: transactionDigest, index: i.keyIndex);
                final sss = await generateSignature(signRequest);
                signerSignatures.add(sss.signature);
                threshHold += i.weight;
                if (threshHold >=
                    multiSigAddress.multiSignatureAccount.threshold) {
                  break;
                }
              } catch (e) {
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
          final sss = await generateSignature(signRequest);
          return [sss.signature];
        },
      );
      final signature =
          await walletProvider.wallet.signTransaction(request: request);
      if (signature.hasError) {
        throw signature.exception!;
      }
      final tr = Transaction(rawData: raw, signature: signature.result);

      final result = await apiProvider.sendTransaction(tr.toHex);
      return (result.txid, result);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    final txId = result.result.$1;
    final txInfo = result.result.$2;
    if (!txInfo.result) {
      progressKey.errorText(txInfo.message ?? "submit_transaction_failed".tr,
          backToIdle: false, showBackButton: true);
    } else {
      _saveTransaction(txId: txId);
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txIds: [txId],
          ),
          backToIdle: false);
    }
  }
}
