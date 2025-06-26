import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/solana/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/page_progress.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/progress_widgets.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain/solana/src/rpc/models/models/commitment.dart';
import 'package:on_chain/solana/src/transaction/transaction/transaction.dart';

class Web3SolanaTransactionRequestController extends Web3SolanaImpl<
    List<Web3SolanaTransactionResponse>, Web3SolanaSendTransaction> {
  Web3SolanaTransactionRequestController(
      {required super.walletProvider, required super.request});

  @override
  bool get clientRequired => true;
  @override
  Web3SolanaSendTransactionForm get form =>
      liveRequest.validator as Web3SolanaSendTransactionForm;
  bool get isMultipleTransaction => request.params.isBatchRequest;
  bool get isSend => request.params.isSend;
  bool _hasSimulateError = false;
  bool _isReady = false;
  bool get isReady => _isReady;
  bool _canReplaceBlockHash = false;
  bool get canReplaceBlockHash => _canReplaceBlockHash;
  bool _replaceBlockHash = false;
  bool get replaceBlockHash => _replaceBlockHash;
  late final IntegerBalance total = IntegerBalance.zero(network.token);
  bool _isMultipleWithSameOwner = false;
  bool get isMultipleWithSameOwner => _isMultipleWithSameOwner;
  SolanaSignAndSendAllTransactionMode get mode =>
      request.params.mode ?? SolanaSignAndSendAllTransactionMode.serial;

  void toggleReplaceBlockHash(bool? _) {
    if (!isSend) return;
    _replaceBlockHash = !_replaceBlockHash;
    notify();
  }

  @override
  Future<void> initWeb3() async {
    form.onChanged = onChange;
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final r = await MethodUtils.call(() async {
      final params = request.params.messages;
      final List<SolanaWeb3TransactionInfo> messagess = [];
      List<ISolanaAddress> addresses = [];
      final List<ISolanaAddress> signers = request.accounts;
      for (final i in params) {
        final permission = signers.firstWhere(
            (e) => e.networkAddress == i.account.address,
            orElse: () => throw Web3RequestExceptionConst.missingPermission);
        addresses.add(permission);
        final message = SolanaTransaction.deserialize(i.messageBytes);
        final simulate = SolanaWeb3TransactionInfo(
            transaction: message,
            signer: permission,
            network: network,
            sendTransactionOptions: i.sendConfig);
        messagess.add(simulate);
        account.updateAccountBalance(
            addresses: [permission]).then((e) => _checkTransaction());
      }
      await form.initForm(
          transactions: messagess,
          client: apiProvider,
          account: account,
          address: address,
          network: network);
      final hasSameOwner =
          form.transaction.map((e) => e.signer.networkAddress).toSet().length !=
              form.transaction.length;
      _isMultipleWithSameOwner = isMultipleTransaction && hasSameOwner;
      _canReplaceBlockHash =
          isSend && form.transaction.any((e) => e.canUpdateBlockHash);

      await account.updateAccountBalance(addresses: addresses);
    });
    if (r.hasError) {
      progressKey.errorResponse(error: r.exception);
      request.error(Web3RequestExceptionConst.fromException(r.exception!));
      return;
    }
    progressKey.idle();
  }

  void _checkTransaction() {
    _hasSimulateError = form.transaction.any((e) => e.status.hasSimulateError);
    _isReady = !form.transaction.any((e) => !e.status.isSuccess);
    final totalAccountsBalances = form.transaction
        .fold(BigInt.zero, (p, c) => p + c.signer.address.currencyBalance);
    final totalSol = form.transaction
        .fold(BigInt.zero, (p, c) => p + c.accountChange.balance);
    total.updateBalance(totalAccountsBalances - totalSol);
    notify();
  }

  Future<void> _saveTransaction(
      {required String txId, required ISolanaAddress address}) async {
    final s = await MethodUtils.call(() async {
      final SolanaWalletTransaction transaction = SolanaWalletTransaction(
          txId: txId,
          network: network,
          web3Client: WalletWeb3ClientTransaction(
              name: request.authenticated.name,
              applicationId: request.authenticated.applicationId,
              image: request.authenticated.icon));
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save cosmos transaction failed $txId");
  }

  Future<void> confirm(
      Future<bool?> Function(String error) onFailedInstruction) async {
    if (!_isReady) {
      final accept = await onFailedInstruction(_hasSimulateError
          ? "simulation_failed_continue_desc".tr
          : "simulation_process_continue_desc".tr);
      if (accept != true) return;
    }
    progressKey.process(text: "signing_transaction_please_wait".tr);
    if (_canReplaceBlockHash) {
      await form.replateBlockHash();
    }
    final signerAccounts = form.transaction.map((e) => e.signer).toList();

    final signedTr = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
      network: network,
      addresses: signerAccounts,
      sign: (generateSignature) async {
        final List<SolanaWeb3SignedTransactionInfo> signatures = [];
        for (final i in form.transaction) {
          final digest =
              List<int>.unmodifiable(i.transaction.serializeMessage());
          final Bip32AddressIndex signer = i.signer.keyIndex.cast();
          final signRequest =
              GlobalSignRequest.solana(digest: digest, index: signer);
          final signingResponse = await generateSignature(signRequest);
          i.transaction
              .addSignature(i.signer.networkAddress, signingResponse.signature);
          final signignInfo = SolanaWeb3SignedTransactionInfo(
              info: i, signature: signingResponse.signature);
          signatures.add(signignInfo);
        }
        return signatures;
      },
    ));
    if (signedTr.hasError) {
      progressKey.error(error: signedTr.exception, showBackButton: true);
      return;
    }
    final List<SolanaWeb3SignedTransactionInfo> result = signedTr.result;
    if (!isSend) {
      final signedTransactions = result.map((e) {
        return Web3SolanaTransactionResponse(
            signature: e.signature, signedTx: e.info.transaction.serialize());
      }).toList();
      request.completeResponse(signedTransactions);
      progressKey.response(text: "transaction_signed".tr);
      return;
    }
    final signatures = result.map((e) {
      return Web3SolanaTransactionResponse(
          signature: e.info.transaction.signatures.elementAt(0),
          signedTx: e.info.transaction.serialize());
    }).toList();

    progressKey.process(
        text: "create_send_transaction".tr.replaceOne(network.token.name));
    final List<MethodResult<String>> sendTransactioResults = [];
    bool isSerial = mode == SolanaSignAndSendAllTransactionMode.serial;
    for (final e in result) {
      final config = e.info.sendTransactionOptions;
      final r = await MethodUtils.call(() async => apiProvider.sendTransaction(
            e.info.transaction,
            skipPreflight: config?.skipPreflight ?? false,
            maxRetries: config?.maxRetries ?? 5,
            minContextSlot: config?.minContextSlot,
            commitment: Commitment.fromName(config?.commitment ?? "",
                defaultValue: Commitment.processed),
          ));
      if (r.hasResult) {
        await _saveTransaction(txId: r.result, address: e.info.signer);
      }
      sendTransactioResults.add(r);
      if (r.hasError && isSerial) break;
    }

    progressKey.response(
        widget: ProgressMultipleTextView(
            texts: sendTransactioResults.map((e) {
              if (e.hasError) {
                return ProgressMultipleTextViewObject.error(
                    message: e.error!.tr);
              }
              return ProgressMultipleTextViewObject.success(
                  message: e.result,
                  openUrl: network.getTransactionExplorer(e.result));
            }).toList(),
            logo: network.token.assetLogo,
            title: network.networkName));
    final error = sendTransactioResults.firstWhereOrNull((e) => e.hasError);
    if (error == null || !isSerial) {
      request.completeResponse(signatures);
    } else {
      request.error(Web3RequestExceptionConst.fromException(error.error!));
    }
  }

  void onChange([bool? changed]) {
    _checkTransaction();
  }
}
