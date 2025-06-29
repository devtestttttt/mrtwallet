import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/cosmos/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class Web3CosmosGlobalRequestController<RESPONSE,
        T extends Web3CosmosRequestParam<RESPONSE>>
    extends Web3CosmosImpl<RESPONSE, T> {
  @override
  bool get clientRequired => false;
  Web3CosmosGlobalRequestController(
      {required super.walletProvider, required super.request});
  void onChangeForm() {
    notify();
  }

  CosmosWeb3Form _init() {
    switch (request.params.method) {
      case Web3CosmosRequestMethods.signMessage:
        return Web3CosmosSignMessageForm(request: request.cast());
      case Web3CosmosRequestMethods.addNewChain:
        return Web3CosmosAddNewChainForm(request: request.cast());
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  LiveTransactionForm<CosmosWeb3Form>? _liveRequest;
  CosmosWeb3Form get form => _liveRequest!.value;

  Future<Web3CosmosSignMessageResponse> _signMessage() async {
    final form = this.form as Web3CosmosSignMessageForm;
    final message = form.challengeBytes();
    final signRequest = WalletSigningRequest(
      addresses: [address],
      network: network,
      sign: (generateSignature) async {
        final signRequest = CosmosSigningRequest(
            digest: form.challengeBytes(),
            index: address.keyIndex,
            alg: address.algorithm);
        final response = await generateSignature(signRequest);
        return response.signature;
      },
    );
    final signatures =
        await walletProvider.wallet.signTransaction(request: signRequest);
    return Web3CosmosSignMessageResponse(
        messageBytes: message, signature: signatures.result);
  }

  Future<void> _importNewChain() async {
    final form = (this.form as Web3CosmosAddNewChainForm).form;
    if (!form.formKey.ready()) return;
    final rpcUrl = form.getRpcUrl();
    if (rpcUrl == null) return;
    progressKey.process(text: "processing_request".tr);
    final r = await MethodUtils.call(() async {
      final networkParams = await form.createNetwork();
      if (networkParams == null) {
        throw WalletException("some_required_field_not_filled");
      }
      await walletProvider.wallet
          .updateImportNetwork(WalletCosmosNetwork(-1, networkParams));
    });
    if (r.hasError) {
      progressKey.error(error: r.exception, showBackButton: true);
      return;
    }
    request.completeResponse(true);
    progressKey.response(text: "request_completed_success".tr);
  }

  void onCompleteForm(Object? obj) async {
    if (request.params.method == Web3CosmosRequestMethods.addNewChain) {
      return _importNewChain();
    }
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3CosmosRequestMethods.signMessage:
        if (obj != true) {
          progressKey.idle();
          return;
        }
        final signMessage = await MethodUtils.call(() => _signMessage());
        if (signMessage.hasError) {
          progressKey.error(error: signMessage.exception, showBackButton: true);
          return;
        }
        result = signMessage.result;
        break;
      default:
        break;
    }
    request.completeResponse(result);
    progressKey.response(text: "request_completed_success".tr);
  }

  @override
  Future<void> initWeb3() async {
    await MethodUtils.after(() async {
      try {
        final form = _init();
        _liveRequest = LiveTransactionForm(validator: form);
        _liveRequest?.addListener(onChangeForm);
        form.onCompleteForm = onCompleteForm;
        await form.initForm(
            account: account,
            address: permissionAccount,
            client: clientOrNull,
            network: network);
        progressKey.idle();
      } catch (e) {
        progressKey.errorResponse(error: e);
        final error = Web3RequestExceptionConst.fromException(e);
        request.error(error);
      }
    });
  }

  @override
  void close() {
    super.close();
    _liveRequest?.removeListener(onChangeForm);
    _liveRequest?.value.onCompleteForm = null;
  }
}
