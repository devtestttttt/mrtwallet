import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/page_progress.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

class Web3BitcoinTransactionRequestController
    extends Web3BitcoinImpl<String, Web3BitcoinRequestParam<String>> {
  Web3BitcoinTransactionRequestController(
      {required super.walletProvider, required super.request});
  late final LiveTransactionForm<
          BitcoinWeb3Form<BitcoinClient, IBitcoinAddress,
              Web3BitcoinRequestParam<String>>> liveRequest =
      switch (request.params.method) {
    Web3BitcoinRequestMethods.signTransaction => LiveTransactionForm(
        validator: Web3BitcoinSignTransactionForm(request: request.cast())),
    Web3BitcoinRequestMethods.sendTransaction => LiveTransactionForm(
        validator: Web3BitcoinSendTransactionForm(request: request.cast())),
    _ => throw Web3RequestExceptionConst.invalidRequest
  };
  final Cancelable _cancelable = Cancelable();
  BitcoinWeb3Form<BitcoinClient, IBitcoinAddress,
      Web3BitcoinRequestParam<String>> get form => liveRequest.validator;

  @override
  bool get clientRequired => true;

  Future<void> _signTransaction(Web3BitcoinSignTransactionForm form) async {
    progressKey.process(text: 'signing_transaction_please_wait'.tr);
    final psbt = form.builder.clone();

    final accountInputs = form.accountInputs;
    final signingRequest = WalletSigningRequest(
      addresses: accountInputs.map((e) => e.ownerAddress!).toList(),
      network: network,
      sign: (generateSignature) async {
        for (int i = 0; i < accountInputs.length; i++) {
          final input = accountInputs[i];
          final inputData = psbt.psbtInput(input.index);
          int? sighash = inputData.sigHashType?.sighash;
          if (sighash == null && network.type == NetworkType.bitcoinCash) {
            sighash = BitcoinOpCodeConst.sighashForked |
                BitcoinOpCodeConst.sighashAll;
          } else {
            sighash = null;
          }
          await psbt.signInputAsync(
              index: input.index,
              sighashType: sighash,
              signer: (params) async {
                final account = input.ownerAddress!;
                if (account.multiSigAccount) {
                  final multsigAccount = account as BitcoinMultiSigBase;
                  final signers = multsigAccount.multiSignatureAddress.signers
                      .map((e) => BitcoonPsbtSigner(
                            publicKey: ECPublic.fromHex(e.publicKey),
                            signer: (params) async {
                              final bitcoinSigning = BitcoinSigning(
                                  digest: params.digest,
                                  index: e.keyIndex.cast(),
                                  useBchSchnorr: false,
                                  useTaproot:
                                      account.networkAddress.type.isP2tr,
                                  sighash: params.sighash,
                                  network:
                                      network.type == NetworkType.bitcoinCash
                                          ? SigningRequestNetwork.bitcoinCash
                                          : SigningRequestNetwork.bitcoin);
                              final sig =
                                  await generateSignature(bitcoinSigning);
                              return sig.signature;
                            },
                          ))
                      .toList();
                  return PsbtSignerResponse(signers: signers);
                }
                final signer = BitcoonPsbtSigner(
                  publicKey: ECPublic.fromBytes(account.publicKey),
                  signer: (p) async {
                    final bitcoinSigning = BitcoinSigning(
                        digest: p.digest,
                        index: account.keyIndex.cast(),
                        useBchSchnorr: true,
                        useTaproot: account.networkAddress.type.isP2tr,
                        sighash: p.sighash,
                        network: network.type == NetworkType.bitcoinCash
                            ? SigningRequestNetwork.bitcoinCash
                            : SigningRequestNetwork.bitcoin);
                    final sig = await generateSignature(bitcoinSigning);
                    return sig.signature;
                  },
                );
                return PsbtSignerResponse(signers: [signer]);
              });
          psbt.finalizeInput(i);
        }
        return psbt;
      },
    );
    final signedTransaction =
        await walletProvider.wallet.signTransaction(request: signingRequest);
    try {
      request.completeResponse(signedTransaction.result.toBase64());
      progressKey.response(text: "transaction_signed".tr);
    } on DartBitcoinPluginException catch (e) {
      final error =
          Web3RequestExceptionConst.signingTransactionFailed(e.message);
      progressKey.errorResponse(error: error);
      request.error(error);
    } catch (_) {
      progressKey.error(
          error: signedTransaction.exception, showBackButton: true);
    }
  }

  Future<void> _sendTransaction(Web3BitcoinSendTransactionForm form) async {
    progressKey.process(
        text: 'create_and_send_network_transaction'
            .tr
            .replaceOne(network.networkName));
    final transaction = await MethodUtils.call(() async {
      // final inputs = form.selectedUtxos;
      // final outputs = form.outputs;
      List<IBitcoinAddress> spenders = request.accounts;
      final List<IBitcoinAddress> signers = form.selectedUtxos
          .map((e) => spenders.firstWhere(
              (element) =>
                  element.networkAddress == e.utxo.ownerDetails.address,
              orElse: () => throw Web3RequestExceptionConst.missingPermission))
          .toList();
      final transaction = form.buildTransaction();
      final signingRequest = WalletSigningRequest(
        addresses: signers,
        network: network,
        sign: (generateSignature) async {
          return transaction.buildTransactionAsync(
              (trDigest, utxo, publicKey, sighash) async {
            final account = signers
                .whereType<IBitcoinAddress>()
                .firstWhere((element) => element.signers.contains(publicKey));
            AddressDerivationIndex keyIndex = account.keyIndex;
            if (account.multiSigAccount) {
              final multiSignatureAddress =
                  (account as BitcoinMultiSigBase).multiSignatureAddress;
              final correctSigner = multiSignatureAddress.signers.firstWhere(
                  (element) => element.publicKey == publicKey,
                  orElse: () =>
                      throw Web3RequestExceptionConst.missingPermission);
              keyIndex = correctSigner.keyIndex;
            }
            final bitcoinSigning = BitcoinSigning(
                digest: trDigest,
                index: keyIndex.cast(),
                useTaproot: utxo.utxo.isP2tr,
                useBchSchnorr: false,
                sighash: sighash,
                network: network.coinParam.isBCH
                    ? SigningRequestNetwork.bitcoinCash
                    : SigningRequestNetwork.bitcoin);
            final signature = await generateSignature(bitcoinSigning);
            return BytesUtils.toHexString(signature.signature);
          });
        },
      );
      final signedTx =
          await walletProvider.wallet.signTransaction(request: signingRequest);
      final txId =
          await apiProvider.sendTransaction(signedTx.result.serialize());
      final s = await MethodUtils.call(() async => _saveTransaction(
          signers: signers,
          outputs: form.outputs,
          inputs: form.selectedUtxos,
          txId: txId));

      assert(!s.hasError, 'transaction saving failed. $s');

      return txId;
    }, cancelable: _cancelable);
    try {
      request.authenticated;
      final txId = transaction.result;
      progressKey.responseTx(hash: txId, network: network);
      request.completeResponse(txId);
    } on Web3RequestException catch (e) {
      progressKey.errorResponse(error: e);
      request.error(e);
    } catch (e) {
      progressKey.error(error: e, showBackButton: true);
    }
  }

  Future<void> _onCompleteForm(Object? _) async {
    switch (request.params.method) {
      case Web3BitcoinRequestMethods.signTransaction:
        return _signTransaction(form as Web3BitcoinSignTransactionForm);
      case Web3BitcoinRequestMethods.sendTransaction:
        return _sendTransaction(form as Web3BitcoinSendTransactionForm);
      default:
        break;
    }
  }

  @override
  Future<void> initWeb3() async {
    liveRequest.addListener(_onChangeForm);
    form.onCompleteForm = _onCompleteForm;
    account.updateAccountBalance(addresses: [address]);
    final init = await MethodUtils.call(() => form.initForm(
        account: account,
        address: address,
        client: apiProvider,
        network: network));
    if (init.hasError) {
      progressKey.errorResponse(error: init.exception);
      request.error(Web3RequestExceptionConst.fromException(init.exception!));
      return;
    }
    progressKey.idle();
  }

  Future<void> _saveTransaction(
      {required List<IBitcoinAddress> signers,
      required List<PsbtBitcoinOutputWithBalance> outputs,
      required List<BitcoinUtxoWithBalance> inputs,
      required String txId}) async {
    final s = await MethodUtils.call(() async {
      signers = signers.toSet().toList();
      for (final i in signers) {
        final totalInputs = inputs
            .where((e) => e.utxo.ownerDetails.address == i.networkAddress)
            .map((e) => e.utxo)
            .toList()
            .sumOfUtxosValue();
        if (totalInputs == BigInt.zero) continue;
        final tx = BitcoinWalletTransaction(
            txId: txId,
            time: DateTime.now(),
            scriptHash: address.networkAddress.pubKeyHash(),
            totalOutput: WalletTransactionIntegerAmount(
                amount: totalInputs, network: network),
            web3Client: WalletWeb3ClientTransaction(
                name: request.authenticated.name,
                applicationId: request.authenticated.applicationId,
                image: request.authenticated.icon),
            outputs: [],
            // outputs: outputs
            //     .map((e) {
            //       final address = e.address;
            //       if (address != null) {
            //         return BitcoinWalletTransactionTransferOutput(
            //             amount: WalletTransactionIntegerAmount(
            //                 amount: e.balance.balance, network: network),
            //             to: BitcoinNetworkAddress.fromBaseAddress(
            //                 address: address.networkAddress,
            //                 network: network.coinParam.transacationNetwork));
            //       }
            //       return BitcoinWalletTransactionScriptOutput(
            //           name: 'Script',
            //           content: null,
            //           value: e.balance.balance,
            //           network: network);
            //     })
            //     .whereType<BitcoinWalletTransactionOutput>()
            //     .toList(),
            network: network);
        await account.saveTransaction(address: i, transaction: tx);
      }
    });
    assert(!s.hasError, "saving web bitcoin transaction failed $s");
  }

  void _onChangeForm() {
    notify();
  }

  @override
  void close() {
    super.close();
    _cancelable.cancel();
    liveRequest.removeListener(_onChangeForm);
    form.close();
  }
}
