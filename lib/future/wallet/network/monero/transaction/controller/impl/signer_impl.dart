import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages/messages.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/transaction.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/transaction/controller/impl/transaction.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

mixin MoneroTransactionSignerImpl on MoneroTransactionImpl {
  final Cancelable _cancelable = Cancelable();
  Future<void> signTransaction() async {
    if (!txReady) return;
    _cancelable.dispose();
    progressKey.progressText("create_sign_monero_tx_desc"
        .tr
        .replaceOne(network.coinParam.token.name));
    final tx = await MethodUtils.call(() async {
      final r = await _signTransaction();
      return r;
    }, cancelable: _cancelable);
    if (tx.hasError) {
      progressKey.errorText(tx.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    _cancelable.dispose();
    final result = await MethodUtils.call(() async {
      return await apiProvider.sendTx(tx.result.txBytes);
    }, cancelable: _cancelable);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    final transaction = MoneroWalletTransaction(
        txId: tx.result.txData.txID,
        time: DateTime.now(),
        network: network,
        totalOutput: WalletTransactionIntegerAmount(
            amount: utxos
                .map((e) => e.utxos)
                .expand((e) => e)
                .fold<BigInt>(BigInt.zero, (p, c) => p + c.amount.balance),
            network: network),
        outputs: receivers
            .map((e) => MoneroWalletTransactionOutput(
                amount: WalletTransactionIntegerAmount(
                    amount: e.amount.balance, network: network),
                to: e.address.networkAddress))
            .toList(),
        txKeys: tx.result.txData.txKeys.map((e) => e.key).toList());
    await account.saveTransaction(address: address, transaction: transaction);
    progressKey.success(
        progressWidget: SuccessTransactionTextView(
          network: network,
          txIds: [tx.result.txData.txID],
          additionalWidget: (context) {
            return FixedElevatedButton(
                onPressed: () {
                  context.openSliverDialog(
                      (p0) => TransactionModalView(
                          chain: account, transaction: transaction),
                      "transaction".tr);
                },
                child: Text("show_proofs".tr));
          },
        ),
        backToIdle: false);
    notify();
  }

  Future<MoneroRingOutput> _generateRingOutput(
      List<MoneroLockedPayment> payments) async {
    BigInt maxGlobalIndex = BigInt.zero;
    for (final i in payments) {
      final globalIndex = i.globalIndex;
      if (globalIndex > maxGlobalIndex) {
        maxGlobalIndex = globalIndex;
      }
    }
    final rctBinary = await apiProvider.getBinaryAbsoluteDistribution();
    return await walletProvider.wallet.nonEncryptedRequest(
        NoneEncryptedRequestGenerateRingOutput(
            rctOffsetData: rctBinary,
            payments: payments,
            maxGlobalIndex: maxGlobalIndex,
            fakeOutsLength: MoneroConst.ringSize - 1));
  }

  Future<MoneroSigningTxResponse> _signTransaction() async {
    final destinations = receivers.map((e) => e.toMoneroDestination()).toList();
    final payments = selectedUtxos.values
        .expand((e) => e)
        .map((e) => e.toLockedPayment())
        .toList();
    final MoneroRingOutput ringOutput = await _generateRingOutput(payments);
    final spendablePayment = await apiProvider.generatePaymentOutputs(
        payments: payments,
        outKeysRequestOrder: ringOutput.orderedIndexes,
        outKeysRequests: ringOutput.indexes,
        fakeOutsLength: MoneroConst.ringSize - 1);
    final r = await walletProvider.wallet.signTransaction(
        request: WalletSigningRequest(
          addresses: selectedUtxos.keys.map((e) => e.account!).toList(),
          network: network,
          sign: (generateSignature) async {
            final s = MoneroSigningRequest(
                destinations: destinations,
                fee: fee.balance,
                utxos: spendablePayment,
                change: remindAmount.largerThanZero
                    ? MoneroTxDestination(
                        amount: remindAmount.balance,
                        address: change.networkAddress)
                    : null,
                index: address.keyIndex);
            final r = await generateSignature(s);
            return MoneroSigningTxResponse.deserialize(bytes: r.signature);
          },
        ),
        timeout: MoneroConst.moneroSigningTimeout);
    return r.result;
  }

  @override
  void close() {
    super.close();
    _cancelable.cancel();
  }
}
