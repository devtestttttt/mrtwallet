import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/worker.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/ton.dart';

class Web3TonGlobalRequestController<RESPONSE,
    T extends Web3TonRequestParam<RESPONSE>> extends Web3TonImpl<RESPONSE, T> {
  Web3TonGlobalRequestController(
      {required super.walletProvider, required super.request});
  @override
  bool get clientRequired => false;
  void onChangeForm() {
    notify();
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3TonRequestMethods.signMessage:
        if (obj != true) {
          progressKey.idle();
          return;
        }
        final signingParams = request.params as Web3TonSignMessage;
        final signMessage = await MethodUtils.call(() async {
          final signature = await walletProvider.wallet.signTransaction(
              request: WalletSigningRequest(
            addresses: [address],
            network: network,
            sign: (generateSignature) async {
              final signRequest = GlobalSignRequest.ton(
                  digest: signingParams.chalengBytes(),
                  index: address.keyIndex.cast());
              final response = await generateSignature(signRequest);
              return Web3TonSignMessageResponse(signature: response.signature);
            },
          ));
          return signature.result;
        });
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
      liveRequest.addListener(onChangeForm);
      form.onCompleteForm = onCompleteForm;
      progressKey.idle();
    });
  }

  @override
  void close() {
    super.close();
    liveRequest.removeListener(onChangeForm);
    form.onCompleteForm = null;
  }
}
