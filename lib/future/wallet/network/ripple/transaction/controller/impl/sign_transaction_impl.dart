import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/controller/impl/transaction_impl.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

mixin RippleSignTransactionImpl on RippleTransactionImpl {
  LiveTransactionForm<RippleTransactionForm> get validator;
  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final XRPWalletTransaction transaction =
          validator.validator.toWalletTransaction(txId: txId);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save xrp transaction failed $txId");
  }

  Future<void> signAndSendTransaction(
      WalletSigningRequest<XRPTransaction> request,
      XRPTransaction transaction) async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      await XRPHelper.autoFill(apiProvider.provider, transaction,
          calculateFee: false);
      final signature =
          await walletProvider.wallet.signTransaction(request: request);
      if (signature.hasError) {
        throw signature.exception!;
      }
      final trBlob = signature.result.toBlob(forSigning: false);
      final txResult = await apiProvider.provider
          .request(XRPRequestSubmitOnly(txBlob: trBlob));
      if (txResult.isSuccess) {
        _saveTransaction(txId: txResult.txJson.hash);
      }
      return txResult;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      if (!result.result.isSuccess) {
        progressKey.errorText(result.result.engineResultMessage,
            backToIdle: false, showBackButton: true);
      } else {
        progressKey.success(
            progressWidget: SuccessTransactionTextView(
              network: network,
              txIds: [result.result.txJson.hash],
            ),
            backToIdle: false);
      }
    }
  }

  Future<bool?> canSignTransaction() async {
    final info =
        await apiProvider.getAccountInfo(address.networkAddress.toString());
    if (info == null) return null;
    final String? regularKey = info.accountData.regularKey;
    if (info.accountFlags.disableMasterKey) {
      if (!address.multiSigAccount) return false;
      return _checkMultiSigAccsess(regularKey);
    } else {
      if (address.multiSigAccount) return _checkMultiSigAccsess(regularKey);
      return true;
    }
  }

  Future<bool> _checkMultiSigAccsess(String? regularKey) async {
    final multiSignatureAccount =
        (address as IXRPMultisigAddress).multiSignatureAccount;
    if (multiSignatureAccount.isRegular) {
      final multisigRegularAddress = RippleUtils.strPublicKeyToRippleAddress(
          multiSignatureAccount.signers.first.publicKey);
      return multisigRegularAddress.address == regularKey;
    } else {
      final accountSigners = await apiProvider
          .getAccountSignerList(address.networkAddress.address);
      if (accountSigners?.signerEntries.isEmpty ?? true) return false;
      int threshHold = 0;
      final List<String> addressSigners = multiSignatureAccount.signers
          .map((e) =>
              RippleUtils.strPublicKeyToRippleAddress(e.publicKey).address)
          .toList();
      for (final i in addressSigners) {
        final inSignerList = MethodUtils.nullOnException(() => accountSigners!
            .signerEntries
            .firstWhere((element) => element.account == i));
        if (inSignerList == null) continue;
        threshHold += inSignerList.signerWeight;
      }
      return threshHold >= multiSignatureAccount.threshold;
    }
  }
}
