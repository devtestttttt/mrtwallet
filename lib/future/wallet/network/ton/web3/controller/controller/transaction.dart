import 'dart:async';

import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages/messages.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/ton/ton.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/transaction/controller/impl/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/web3/pages/page_progress.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/ton/ton.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/wallet/models/transaction/transaction.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonTransactionRequestController
    extends Web3TonImpl<Web3TonSendTransactionResponse, Web3TonSendTransaction>
    with TonFeeImpl {
  Web3TonTransactionRequestController(
      {required super.walletProvider, required super.request});

  @override
  Web3TonSendTransactionForm get form =>
      liveRequest.validator as Web3TonSendTransactionForm;

  late final IntegerBalance total = IntegerBalance.zero(network.token);
  late final IntegerBalance remindAmount = IntegerBalance.zero(network.token);

  bool get isExcute => request.params.isExcute;

  @override
  Future<void> initWeb3() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final result = await MethodUtils.call(() async {
      final List<TonWeb3TransactionMessageInfo> messages = [];
      for (final i in request.params.messages) {
        final msgInfo = await apiProvider.getWeb3TransactionMessageInfo(
            address: address, account: account, message: i);
        messages.add(msgInfo);
      }
      return messages;
    });
    if (result.hasError) {
      progressKey.errorResponse(error: result.exception);
      request.error(Web3RequestExceptionConst.fromException(result.exception!));
      return;
    }
    await account.updateAddressBalance(address);
    form.init(
        messages: result.result,
        client: apiProvider,
        owner: address,
        validUntil: request.params.validUntil);
    onChange();
    estimateFee();
    progressKey.idle();
  }

  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final TonWalletTransaction transaction = TonWalletTransaction(
          txId: txId,
          outputs: [],
          web3Client: WalletWeb3ClientTransaction(
              name: request.authenticated.name,
              applicationId: request.authenticated.applicationId,
              image: request.authenticated.icon),
          network: network);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save ton transaction failed $txId");
  }

  Future<void> sendTransaction() async {
    // final isExcute = request.params.isExcute;
    if (isExcute) {
      progressKey.process(
          text: "create_send_transaction"
              .tr
              .replaceOne(network.coinParam.token.name));
    } else {
      progressKey.process(text: "signing_transaction_please_wait".tr);
    }
    final externalMessage = await MethodUtils.call(() async {
      final messageBody = await form.createMessageBody();
      final signature = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final signRequest = GlobalSignRequest.ton(
              digest: messageBody.hash(), index: address.keyIndex.cast());
          final response = await generateSignature(signRequest);
          return response.signature;
        },
      ));
      final extMessage = address.context.toExternalMessage(
          message: messageBody,
          signature: signature.result,
          destination: address.networkAddress,
          state: (form.seqno == 0 ? form.wallet.state!.initialState() : null));
      return beginCell().store(extMessage).endCell();
    });

    if (externalMessage.hasError) {
      progressKey.error(error: externalMessage.exception, showBackButton: true);
      return;
    }
    if (!isExcute) {
      final response = Web3TonSendTransactionResponse(
          message: externalMessage.result.toBase64());
      request.completeResponse(response);
      progressKey.response(text: 'transaction_signed'.tr);
      return;
    }
    final result = await MethodUtils.call(() async {
      final txId = await apiProvider.sendMessage(boc: externalMessage.result);
      await _saveTransaction(txId: txId.$1);
      return txId;
    });
    if (result.hasError) {
      progressKey.errorResponse(error: result.exception);
      request.error(Web3RequestExceptionConst.fromException(result.exception!));
      return;
    }
    final String txHash = result.result.$1;
    final response = Web3TonSendTransactionResponse(
        message: externalMessage.result.toBase64(), txHash: txHash);
    request.completeResponse(response);
    progressKey.responseTx(hash: txHash, network: network);
  }

  @override
  Future<Message> buildTransaction({bool fakeSignature = false}) {
    return form.createEstimateMessage();
  }

  @override
  void onChange() {
    total.updateBalance(form.totalTon);
    final remind = address.address.currencyBalance - (form.totalTon + fee);
    remindAmount.updateBalance(remind);
    notify();
  }
}
