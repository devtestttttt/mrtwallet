import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/crypto/requets/messages/wallet/requests/personal_sign.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/forms.dart';
import 'package:on_chain_wallet/future/wallet/network/tron/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class Web3TronGlobalRequestController<RESPONSE,
        T extends Web3TronRequestParam<RESPONSE>>
    extends Web3TronImpl<RESPONSE, T> {
  Web3TronGlobalRequestController(
      {required super.walletProvider, required super.request});

  @override
  bool get clientRequired => false;
  LiveTransactionForm? _liveRequest;

  TronWeb3Form get form => _liveRequest!.value;

  TronWeb3Form _init() {
    switch (request.params.method) {
      case Web3TronRequestMethods.signMessageV2:
        return Web3TronSignMessageForm(request: request.cast());
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  void onChangeForm() {
    notify();
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3TronRequestMethods.signMessageV2:
        final sign = await walletProvider.wallet.walletRequest(
            WalletRequestSignMessage(
                message:
                    request.params.cast<Web3TronSignMessageV2>().chalengBytes(),
                index: address.keyIndex.cast(),
                network: NetworkType.tron));
        if (sign.hasError) {
          progressKey.error(error: sign.exception, showBackButton: true);
          return;
        }
        result = sign.result.signatureHex;
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
