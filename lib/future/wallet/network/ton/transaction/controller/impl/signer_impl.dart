import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/transaction/controller/impl/transaction_impl.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/ton.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

mixin TonSignerImpl on TonTransactionImpl {
  int? _seqno;

  @override
  Future<Message> buildTransaction({bool fakeSignature = false}) async {
    final wallet = address.toWalletContract();
    if (_seqno == null) {
      final state = await wallet.getState(rpc: apiProvider.provider);
      if (state.state.isFrozen) {
        throw WalletException("ton_address_is_freez_desc");
      } else if (state.state.isActive) {
        final stateData = VersionedWalletUtils.readState(
            stateData: state.data, type: wallet.type, chain: wallet.chain);
        _seqno = stateData.seqno;
      } else {
        _seqno = 0;
      }
    }
    final actions = validator.validator
        .toMessages()
        .map((e) => OutActionSendMsg(outMessage: e))
        .toList();
    if (wallet.type.version == 1 && actions.length > 1) {
      throw WalletException("ton_wallet_validator_desc");
    }
    final transfer = address.context.buildTransaction(
        actions: actions,
        state: wallet.state!,
        seqno: _seqno!,
        chain: network.coinParam.chain);
    List<int> sig = List<int>.unmodifiable(List<int>.filled(64, 0));

    if (!fakeSignature) {
      final signature = await walletProvider.wallet.signTransaction(
          request: WalletSigningRequest(
        addresses: [address],
        network: network,
        sign: (generateSignature) async {
          final signRequest = GlobalSignRequest.ton(
              digest: transfer.hash(), index: address.keyIndex.cast());
          final response = await generateSignature(signRequest);
          return response.signature;
        },
      ));
      sig = signature.result;
    }
    return address.context.toExternalMessage(
        message: transfer,
        signature: sig,
        destination: address.networkAddress,
        state: (_seqno == 0 ? wallet.state!.initialState() : null));
  }

  Future<void> _saveTransaction({required String txId}) async {
    final s = await MethodUtils.call(() async {
      final TonWalletTransaction transaction =
          validator.validator.toWalletTransaction(txId: txId);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save solana transaction failed $txId");
  }

  Future<void> signAndSendTransaction() async {
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      final exMessage = await buildTransaction();
      final txId = await apiProvider.sendMessage(
          boc: beginCell().store(exMessage).endCell());
      await _saveTransaction(txId: txId.$1);
      return txId;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
            network: network,
            txIds: [result.result.$1],
            error:
                result.result.$2 ? null : "tx_submit_response_failed_desc".tr,
          ),
          backToIdle: false);
    }
  }
}
