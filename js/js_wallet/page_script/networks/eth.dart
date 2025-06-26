part of '../scripts.dart';

class EthereumPageController extends WalletStandardPageController {
  EIP1193? _ethereum;
  EthereumPageController(super.postMessage);

  final Map<JSEventType, List<JSFunction>> _eipListeners = {
    JSEventType.accountsChanged: [],
    JSEventType.chainChanged: [],
    JSEventType.connect: [],
    JSEventType.message: [],
    JSEventType.disconnect: [],
  };

  EIP1193 _createEIP1193() {
    return EIP1193.setup(
        enable: _connectEip.toJS,
        request: _onRequest.toJS,
        on: _addEIPListener.toJS,
        removeListener: _removeEIPListener.toJS,
        disconnect: _disconnectChain.toJS);
  }

  JSPromise<JSAny?> _onRequest(EthereumRequestParams params) {
    return waitForSuccessResponsePromise<JSAny?>(
        method: params.method,
        params: JsUtils.asJSArray(params.params),
        provider: PageRequestType.eip1993);
  }

  void _initController() {
    _ethereum ??= _createEIP1193();
    final proxy = _ethereum?.toProxy();
    try {
      ethereum = proxy;
    } catch (_) {
      jsConsole.error("failed to set ethereum ");
    }
    EIP6963.setup(proxy);
  }

  JSPromise<JSArray<JSString>> _connectEip() {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: JSEthereumConst.requestAccounts,
        provider: PageRequestType.eip1993);
  }

  JSPromise<JSEthereumWalletStandardConnect> _connect([JSString? chainId]) {
    final network = JsUtils.asJSString(chainId);
    final params = network == null ? null : [network].toJS;
    return waitForSuccessResponsePromise<JSEthereumWalletStandardConnect>(
        method: JSEthereumConst.requestAccounts, params: params);
  }

  JSPromise<JSString> _addNewChain(JSEthereumAddNewChainParams params) {
    return waitForSuccessResponsePromise<JSString>(
      method: JSEthereumConst.addChain,
      params: JsUtils.asJSArray(params),
    );
  }

  JSPromise<JSString> _signTypesData(JSEthereumSignTypedDataParams params) {
    return waitForSuccessResponsePromise<JSString>(
      method: JSEthereumConst.typedData,
      params: JsUtils.asJSArray(params),
    );
  }

  JSPromise<JSString> _signTypesDataV3(JSEthereumSignTypedDataParams params) {
    return waitForSuccessResponsePromise<JSString>(
      method: JSEthereumConst.typedDataV3,
      params: JsUtils.asJSArray(params),
    );
  }

  JSPromise<JSString> _signTypesDataV4(JSEthereumSignTypedDataParams params) {
    return waitForSuccessResponsePromise<JSString>(
      method: JSEthereumConst.typedDataV4,
      params: JsUtils.asJSArray(params),
    );
  }

  JSPromise<JSString> _personalSign(JSEthereumSignMessageParams params) {
    return waitForSuccessResponsePromise<JSString>(
        method: JSEthereumConst.personalSign,
        params: JsUtils.asJSArray(params));
  }

  JSPromise<JSString> _ethSign(JSEthereumSignMessageParams params) {
    return waitForSuccessResponsePromise<JSString>(
        method: JSEthereumConst.ethSign, params: JsUtils.asJSArray(params));
  }

  JSPromise<JSString> _sendTransaction(
      JSEthereumWalletStandardTransactionParams params) {
    return waitForSuccessResponsePromise<JSString>(
        method: JSEthereumConst.sendTransaction,
        params: JsUtils.asJSArray(params));
  }

  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    _initController();
    feature.ethereumConnect =
        EthereumWalletAdapterConnectFeature.setup(connect: _connect.toJS);
    feature.ethereumAddNewChain = EthereumWalletAdapterAddNewChainFeature.setup(
        addNewChain: _addNewChain.toJS);
    feature.ethereumsignTypedData =
        EthereumWalletAdapterSignTypedDataFeature.setup(
            signTypedData: _signTypesData.toJS);
    feature.ethereumsignTypedDataV3 =
        EthereumWalletAdapterSignTypedDataV3Feature.setup(
            signTypedDataV3: _signTypesDataV3.toJS);
    feature.ethereumsignTypedDataV4 =
        EthereumWalletAdapterSignTypedDataV4Feature.setup(
            signTypedDataV4: _signTypesDataV4.toJS);
    feature.ethereumPersonalSign =
        EthereumWalletAdapterPersonalSignFeature.setup(
            personalSign: _personalSign.toJS);
    feature.ethereumEthSign =
        EthereumWalletAdapterEthSignFeature.setup(ethSign: _ethSign.toJS);
    feature.ethereumSendTransaction =
        EthereumWalletAdapterSendTransactionFeature.setup(
            sendTransaction: _sendTransaction.toJS);
    feature.ethereumRequest =
        EthereumWalletAdapteRequestFeature.setup(request: _onRequest.toJS);
    feature.ethereumEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);

    feature.ethereumDisconnect = JSWalletStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
  }

  @override
  void onWalletEvent(WalletMessageEvent message) {
    super.onWalletEvent(message);
    final data = message.data as JSWalletNetworkEvent;
    final events = data.eventTypes;
    for (final event in events) {
      switch (event) {
        case JSNetworkEventType.defaultAccountChanged:
          _ethereum?.selectedAddress = data.account?.address;
          break;
        case JSNetworkEventType.message:
          _eventEIPListeners(JSEventType.message, jsObject: data.message);
          _eventListeners(JSEventType.message, data.message);
          break;
        case JSNetworkEventType.networkAccountsChanged:
          _eventEIPListeners(JSEventType.accountsChanged,
              jsObject: data.networkAccounts?.jsAddresses);
          break;
        case JSNetworkEventType.defaultChainChanged:
          final chainChanged = data.chainChanged as JSEthereumEIPChainChanged?;
          _ethereum?.chainId = chainChanged?.chainId;
          _ethereum?.networkVersion = chainChanged?.netVersion;
          if (data.disconnect != null) {
            _eventEIPListeners(JSEventType.disconnect,
                jsObject: data.disconnect);
          }
          if (chainChanged != null) {
            if (data.disconnect == null) {
              _eventEIPListeners(JSEventType.connect, jsObject: chainChanged);
            }
            _eventEIPListeners(JSEventType.chainChanged,
                jsObject: chainChanged.chainId.toJS);
          }

          break;
        default:
      }
    }
  }

  void _eventEIPListeners(JSEventType type, {JSAny? jsObject}) {
    if (jsObject == null || !_eipListeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._eipListeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(null, jsObject);
    }
  }

  void _addEIPListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    if (event == null) return;
    _eipListeners[event]?.add(listener);
    _emitEvent(PageMessageEvent.build(event: event));
  }

  void _removeEIPListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _eipListeners[event]?.remove(listener);
  }

  @override
  JSClientType get _client => JSClientType.ethereum;
}
