import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/worker.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class Web3BitcoinGlobalRequestController<RESPONSE,
        T extends Web3BitcoinRequestParam<RESPONSE>>
    extends Web3BitcoinImpl<RESPONSE, T> {
  @override
  bool get clientRequired => false;
  Web3BitcoinGlobalRequestController(
      {required super.walletProvider, required super.request});
  void onChangeForm() {
    notify();
  }

  BitcoinWeb3Form _init() {
    switch (request.params.method) {
      case Web3BitcoinRequestMethods.signPersonalMessage:
      case Web3BitcoinRequestMethods.signMessage:
        return Web3BitcoinSignMessageForm(
            request: request as Web3BitcoinRequest<
                Web3BitcoinSignMessageResponse, Web3BitcoinSignMessage>);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  LiveTransactionForm? _liveRequest;
  BitcoinWeb3Form get form => _liveRequest!.value;

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3BitcoinRequestMethods.signPersonalMessage:
      case Web3BitcoinRequestMethods.signMessage:
        final param = form as Web3BitcoinSignMessageForm;
        MethodResult<CryptoBitcoinPersonalSignResponse> sign =
            await walletProvider.wallet.walletRequest(
                WalletRequestBitcoinSignMessage(
                    message: param.challengeBytes(),
                    index: address.keyIndex.cast(),
                    useTaproot: address.addressType.isP2tr,
                    mode: obj as BIP137Mode,
                    messagePrefix: param.messagePrefix));

        if (sign.hasError) {
          progressKey.error(error: sign.exception, showBackButton: true);
          return;
        }
        result = Web3BitcoinSignMessageResponse(
            signature: sign.result.signature, digest: sign.result.digest);
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
    form.onCompleteForm = null;
  }
}
