part of '../scripts.dart';

class BitcoinPageController extends WalletStandardPageController {
  BitcoinPageController(super.postMessage);
  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    feature.bitcoinConnect =
        JSWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.bitcoinSignPersonalMessage =
        JSWalletStandardSignPersonalMessageFeature.setup(
            signPersonalMessage: _bitcoinSignPersonalMessage.toJS);
    feature.bitcoinSignTransaction =
        JSWalletStandardSignTransactionFeature.setup(
            signTransaction: _bitcoinSignTransaction);

    feature.bitcoingetAccountAddresses =
        JSWalletStandardGetAccountAddressesFeature.setup(
            getAccountAddresses: _getAccountAddress.toJS);
    feature.bitcoinSendTransaction =
        JSWalletStandardSendTransactionFeature.setup(
            sendTransaction: _bitcoinSendTransaction.toJS);
    feature.bitcoinDisconnect = JSWalletStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
    feature.bitcoinEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }

  JSPromise<JSWalletStandardConnect> _connect([JSString? chainId]) {
    final network = JsUtils.asJSString(chainId);
    final params = network == null ? null : [network].toJS;
    return waitForSuccessResponsePromise<JSWalletStandardConnect>(
        method: BitcoinJSConstant.requestAccountRequestName, params: params);
  }

  JSPromise<JSBitcoinSignMessageResponse> _bitcoinSignPersonalMessage(
      JSBitcoinSignMessageParams params) {
    return waitForSuccessResponsePromise<JSBitcoinSignMessageResponse>(
        method: BitcoinJSConstant.signPersonalMessageRequestName,
        params: [params].toJS);
  }

  JSPromise<JSBitcoinSignTransactionResponse> _bitcoinSignTransaction(
      JSBitcoinSignTransactionResponse params) {
    return waitForSuccessResponsePromise<JSBitcoinSignTransactionResponse>(
        method: BitcoinJSConstant.signTransactionRequestName,
        params: [params].toJS);
  }

  JSPromise<JSArray<JSBitcoinGetAccountAddressResponse>> _getAccountAddress(
      JSBitcoinGetAccountAddressParams params) {
    return waitForSuccessResponsePromise<
            JSArray<JSBitcoinGetAccountAddressResponse>>(
        method: BitcoinJSConstant.getAccountAddresses, params: [params].toJS);
  }

  JSPromise<JSBitcoinSendTransactionResponse> _bitcoinSendTransaction(
      JSArray<JSBitcoinSendTransactionParams> params) {
    return waitForSuccessResponsePromise<JSBitcoinSendTransactionResponse>(
        method: BitcoinJSConstant.sendTransactionRequestName,
        params: JsUtils.asJSArray(params));
  }

  @override
  JSClientType get _client => JSClientType.bitcoin;
}
