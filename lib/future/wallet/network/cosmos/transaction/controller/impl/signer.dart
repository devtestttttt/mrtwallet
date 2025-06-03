import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'transaction.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

mixin CosmosSignerImpl on CosmosTransactiomImpl {
  Future<String> _buildTransaction() async {
    final messages = validator.validator.messages();
    final txbody = TXBody(messages: messages, memo: memo);
    final authInfo = AuthInfo(signerInfos: [
      address.signerInfo.copyWith(sequence: ownerAccount.sequence)
    ], fee: fee!.toFee().copyWith(amount: isThorChain ? [] : null));
    final SignDoc signDoc = SignDoc(
        bodyBytes: txbody.toBuffer(),
        authInfoBytes: authInfo.toBuffer(),
        chainId: network.coinParam.chainId,
        accountNumber: ownerAccount.accountNumber);
    final List<String> signersAddr = messages
        .map((e) => e.signers)
        .expand((element) => element)
        .where((element) => element != null)
        .toList()
        .cast();

    final signers = account.addresses
        .where((element) => signersAddr.contains(element.address.toAddress))
        .toList();
    final List<AddressDerivationIndex> signerKeyIndexes =
        signers.map((e) => e.keyIndex).toList();
    final digest = List<int>.unmodifiable(signDoc.toBuffer());
    final signRequest = WalletSigningRequest(
      addresses: signers,
      network: network,
      sign: (generateSignature) async {
        final List<List<int>> signatures = [];
        for (int i = 0; i < signerKeyIndexes.length; i++) {
          final signRequest = CosmosSigningRequest(
              digest: digest,
              index: signerKeyIndexes.elementAt(i).cast(),
              alg: signers[i].algorithm);
          final sss = await generateSignature(signRequest);
          signatures.add(sss.signature);
        }
        return signatures;
      },
    );
    final signatures =
        await walletProvider.wallet.signTransaction(request: signRequest);
    if (signatures.hasError) {
      throw signatures.exception!;
    }

    final txRaw = TxRaw(
        bodyBytes: txbody.toBuffer(),
        authInfoBytes: authInfo.toBuffer(),
        signatures: signatures.result);
    // final txId = txRaw.txId();
    final txId = await apiProvider.broadcastTransaction(txRaw.toBuffer());
    await _saveTransaction(txId: txId);
    return txId;
  }

  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final CosmosWalletTransaction transaction =
          validator.validator.toWalletTransaction(txId);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save cosmos transaction failed $txId");
  }

  Future<void> buildTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      return await _buildTransaction();
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txIds: [result.result],
          ),
          backToIdle: false);
    }
  }
}
