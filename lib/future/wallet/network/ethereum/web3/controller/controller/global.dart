import 'package:blockchain_utils/signer/types/eth_signature.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/ethereum/web3/controller/impl/web3.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/ethereum/ethereum.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/models/signing/signing.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain_wallet/crypto/worker.dart';

class Web3EthereumGlobalRequestController<RESPONSE,
        T extends Web3EthereumRequestParam<RESPONSE>>
    extends Web3EthereumImpl<RESPONSE, T> {
  Web3EthereumGlobalRequestController(
      {required super.walletProvider, required super.request});

  @override
  bool get clientRequired => false;
  void onChangeForm() {
    notify();
  }

  LiveTransactionForm? _liveRequest;

  EthereumWeb3Form get form => _liveRequest!.value;

  EthereumWeb3Form _init() {
    /// Web3EthereumAddNewChainForm
    switch (request.params.method) {
      case Web3EthereumRequestMethods.addEthereumChain:
        return Web3EthereumAddNewChainForm(request: request.cast());
      case Web3EthereumRequestMethods.persoalSign:
      case Web3EthereumRequestMethods.ethSign:
        return Web3EthereumPersonalSignForm(request: request.cast());
      case Web3EthereumRequestMethods.typedData:
        return Web3EthereumSignTypedDataForm(request: request.cast());
      default:
        throw UnimplementedError();
    }
  }

  void onCompleteForm(Object? response) async {
    progressKey.process(text: "processing_request".tr);
    Object? result = response;
    switch (request.params.method) {
      case Web3EthereumRequestMethods.ethSign:
        final bytes =
            request.params.cast<Web3EthreumPersonalSign>().chalengBytes();
        final WalletSigningRequest<ETHSignature> signingRequest =
            WalletSigningRequest<ETHSignature>(
          addresses: [address],
          network: network,
          sign: (generateSignature) async {
            final signRequest = GlobalSignRequest.eth(
                digest: bytes, index: address.keyIndex.cast());
            final ethSignature = await generateSignature(signRequest);
            return ETHSignature.fromBytes(ethSignature.signature);
          },
        );
        final signature = await walletProvider.wallet
            .signTransaction(request: signingRequest);
        if (signature.hasError) {
          progressKey.error(error: signature.exception, showBackButton: true);
          return;
        }
        result = signature.result.toHex();
        break;
      case Web3EthereumRequestMethods.persoalSign:
        final sign = await walletProvider.wallet.walletRequest(
            WalletRequestSignMessage(
                message: request.params
                    .cast<Web3EthreumPersonalSign>()
                    .chalengBytes(),
                index: address.keyIndex.cast()));
        if (sign.hasError) {
          progressKey.error(error: sign.exception, showBackButton: true);
          return;
        }
        result = sign.result.signatureHex;
        break;
      case Web3EthereumRequestMethods.typedData:
        final sign = await walletProvider.wallet
            .walletRequest(WalletRequestEthereumTypedDataSign(
          message: request.params.cast<Web3EthreumTypdedData>().typedData,
          index: address.keyIndex.cast(),
        ));
        if (sign.hasError) {
          progressKey.error(error: sign.exception, showBackButton: true);
          return;
        }
        result = sign.result;
        break;
      default:
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
