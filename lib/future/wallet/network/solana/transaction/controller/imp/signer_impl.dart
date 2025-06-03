import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/transaction/controller/imp/transaction_impl.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/solana.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

mixin SolanaSignerImpl on SolanaTransactionImpl {
  Future<String> _buildAndSigneTransaction() async {
    final bl = await apiProvider.provider
        .request(const SolanaRequestGetLatestBlockhash());
    final transaction = SolanaTransaction(
        payerKey: address.networkAddress,
        instructions: [
          ...(await validator.validator.instructions()),
          if (memo != null) memo!,
        ],
        recentBlockhash: bl.blockhash);
    final signersAddresses = transaction.message.accountKeys
        .sublist(0, transaction.message.header.numRequiredSignatures)
        .map((e) => e.address)
        .toList();
    final signerAccounts = account.addresses
        .where((element) =>
            signersAddresses.contains(element.networkAddress.address))
        .toList();

    if (signersAddresses.length != signerAccounts.length) {
      throw WalletException("required_signer_account_missing".tr);
    }
    final signedTr = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: signerAccounts,
      sign: (generateSignature) async {
        final digest = List<int>.unmodifiable(transaction.serializeMessage());
        for (int i = 0; i < signerAccounts.length; i++) {
          final addr = signerAccounts.elementAt(i);
          final Bip32AddressIndex signer = addr.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.solana(digest: digest, index: signer);
          final sss = await generateSignature(signRequest);
          transaction.addSignature(addr.networkAddress, sss.signature);
        }
        return transaction;
      },
    ));
    if (signedTr.hasError) {
      throw signedTr.exception!;
    }
    final txId = await apiProvider.sendTransaction(transaction,
        encoding: SolanaRequestEncoding.base58);
    await _saveTransaction(txId: txId);
    return txId;
  }

  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final SolanaWalletTransaction transaction =
          validator.validator.toWalletTransaction(txId: txId);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save solana transaction failed $txId");
  }

  Future<void> buildAndSignTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      return await _buildAndSigneTransaction();
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
              network: network, txIds: [result.result]),
          backToIdle: false);
    }
  }
}
