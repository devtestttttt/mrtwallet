import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/sui.dart';
import 'package:on_chain/sui/sui.dart';

import 'transaction_impl.dart';

mixin SuiSignerImpl on SuiTransactionImpl {
  final Cancelable _cancelable = Cancelable();
  @override
  Future<SuiTransactionDataV1> createEstimateTransaction(
      {required BigInt gasPrice, required BigInt budget}) async {
    final kind = await createTransactionKind();
    return SuiTransactionDataV1(
        expiration: const SuiTransactionExpirationNone(),
        sender: address.networkAddress,
        gasData: SuiGasData(
            payment: [],
            owner: address.networkAddress,
            price: gasPrice,
            budget: budget),
        kind: SuiTransactionKindProgrammableTransaction(kind));
  }

  Future<SuiProgrammableTransaction> createTransactionKind();
  Future<(SuiTransactionDataV1, SuiBaseSignature)> createTransaction(
      {required BigInt gasPrice, required BigInt budget}) async {
    final kind = await createTransactionKind();
    SuiTransactionDataV1 transaction = SuiTransactionDataV1(
        expiration: const SuiTransactionExpirationNone(),
        sender: address.networkAddress,
        gasData: SuiGasData(
            payment: [],
            owner: address.networkAddress,
            price: gasPrice,
            budget: budget),
        kind: SuiTransactionKindProgrammableTransaction(kind));
    transaction = await apiProvider.filledGasPayment(transaction);
    final transactionDigest = SuiCryptoUtils.generateTransactionDigest(
        txBytes: transaction.serializeSign(), hashDigest: true);
    final signatures = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: [address],
      sign: (generateSignature) async {
        if (address.multiSigAccount) {
          final multisigAccount = address as ISuiMultiSigAddress;
          List<SuiGenericSignature> signatures = [];
          int weight = 0;
          for (final i in multisigAccount.multiSignatureAddress.publicKeys) {
            final Bip32AddressIndex signer = i.keyIndex;
            final signRequest =
                GlobalSignRequest.sui(digest: transactionDigest, index: signer);
            final signature = await generateSignature(signRequest);
            signatures.add(SuiGenericSignature(
                signature: signature.signature,
                algorithm: i.keyScheme.suiKeyAlgorithm));
            weight += i.weight;
            if (weight >= multisigAccount.multiSignatureAddress.threshold) {
              break;
            }
          }
          if (weight < multisigAccount.multiSignatureAddress.threshold) {
            throw WalletException("insufficient_signatures");
          }
          return signatures;
        } else {
          final Bip32AddressIndex signer = address.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.sui(digest: transactionDigest, index: signer);
          final signature = await generateSignature(signRequest);
          final suiSignature = SuiGenericSignature(
              signature: signature.signature,
              algorithm: address.keyScheme.suiKeyAlgorithm);
          return [suiSignature];
        }
      },
    ));
    final signature = address.createTransactionAuthenticated(signatures.result);
    return (transaction, signature);
  }

  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final SuiWalletTransaction transaction =
          validator.validator.toWalletTransaction(txId: txId);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save sui transaction failed $txId");
  }

  Future<void> buildAndSignTransaction(
      {required BigInt gasPrice, required BigInt budget}) async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final transaction = await MethodUtils.call(() async {
      return await createTransaction(gasPrice: gasPrice, budget: budget);
    }, cancelable: _cancelable);
    if (transaction.hasError) {
      progressKey.errorText(transaction.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    _cancelable.dispose();
    final result = await MethodUtils.call(() async {
      final txId = await apiProvider.excuteTx(
          tx: transaction.result.$1, signatures: [transaction.result.$2]);
      await _saveTransaction(txId: txId.digest!);
      return txId;
    }, cancelable: _cancelable);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
              network: network,
              txIds: [result.result.digest!],
              error: result.result.error),
          backToIdle: false);
    }
  }
}
