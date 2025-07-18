import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/web3/web3.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/stellar.dart';

class Web3StellarGlobalRequestController<RESPONSE,
        T extends Web3StellarRequestParam<RESPONSE>>
    extends Web3StellarImpl<RESPONSE, T> {
  Web3StellarGlobalRequestController({
    required super.walletProvider,
    required super.request,
  });
  @override
  bool get clientRequired => false;
  void onChangeForm() {
    notify();
  }

  void onCompleteForm(Object? obj) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = obj;
    switch (request.params.method) {
      case Web3StellarRequestMethods.signMessage:
        if (obj != true) {
          progressKey.idle();
          return;
        }
        final signingParams = request.params as Web3StellarSignMessage;
        final signMessage = await MethodUtils.call(() async {
          final signature = await walletProvider.wallet.signTransaction(
              request: WalletSigningRequest(
            addresses: [address],
            network: network,
            sign: (generateSignature) async {
              final signRequest = GlobalSignRequest.stellar(
                  digest: signingParams.chalengBytes(),
                  index: address.keyIndex.cast());
              final response = await generateSignature(signRequest);
              return Web3StellarSignMessageResponse(
                  signature: response.signature);
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
