part of 'wallet.dart';

mixin JSWalletStandardHandler {
  abstract final Map<JSClientType, Web3JSStateHandler> _networks;
  void _sendEventToClient(WalletMessageEvent event, JSClientType? client);
  Future<(List<Web3JSStateAddress>, List<String>)> _getWalletChange() async {
    final states =
        await Future.wait(_networks.values.map((e) => e.getState()).toList());
    final accounts = states.map((e) => e.accounts).expand((e) => e).toList();
    final chains = states.map((e) => e.chains).expand((e) => e).toList();
    return (accounts, chains.map((e) => e.wsIdentifier).toList());
  }

  Future<List<Web3ChainIdnetifier>> _getWalletNetwork() async {
    final states =
        await Future.wait(_networks.values.map((e) => e.getState()).toList());
    final chains = states.map((e) => e.chains).expand((e) => e).toList();
    return chains;
  }

  Future<void> _sendGlobalEvent() async {
    final change = await _getWalletChange();
    final event = JSWalletStandardChange.setup(
        accounts: change.$1.map((e) => e.jsAccount).toList(),
        chains: change.$2);
    _sendEventToClient(WalletMessageEvent.build(data: event), null);
  }

  void _onGlobalEvent(PageMessageEvent event) {
    _sendGlobalEvent();
  }

  Future<Web3MessageCore> _onGlobalRequest(
      {required Web3JsClientRequest request,
      required Web3GlobalRequestMethods globalMethod,
      required JSClientType? client}) async {
    switch (globalMethod) {
      case Web3GlobalRequestMethods.disconnect:
        return _networks[client]!.discoonect();
      case Web3GlobalRequestMethods.connect:
        final connectParam = request.requestParams.elementAtOrNull(0);
        List<int> networkIds = [];
        if (connectParam != null) {
          final data = request.paramsAsMap();
          final List<String>? chains =
              Web3ValidatorUtils.parseList<List<String>?, String>(
                  key: "chains", method: globalMethod, json: data);
          if (chains != null && chains.isNotEmpty) {
            final walletChains = await _getWalletNetwork();
            for (final i in chains) {
              if (!Web3ValidatorUtils.isCaip2(i)) {
                throw Web3RequestExceptionConst.invalidCaip2ChainIdStyle;
              }
              final network = walletChains.firstWhere((e) => e.isChain(i),
                  orElse: () =>
                      throw Web3RequestExceptionConst.networkIdDoesNotExists(
                          i));
              networkIds.add(network.id);
            }
          }
        }
        return Web3ConnectApplication.networks(networkIds);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Future<WalletMessageResponse> _finalizeGlobalResponse(
      {required PageMessageRequest message,
      required Web3WalletRequestParams? params,
      required Web3GlobalResponseMessage response}) async {
    final method = Web3GlobalRequestMethods.fromName(message.method);
    switch (method) {
      case Web3GlobalRequestMethods.disconnect:
        return WalletMessageResponse.success(true.toJS);
      case Web3GlobalRequestMethods.connect:
        final error = Web3RequestExceptionConst.rejectedByUser
            .toResponseMessage()
            .toWalletError();
        List<Web3JSStateAddress> accounts = (await _getWalletChange()).$1;
        if (params != null && accounts.isNotEmpty) {
          final connectParams = params.cast<Web3ConnectApplication>();
          final chainIds = connectParams.networks;
          if (chainIds != null) {
            for (final i in chainIds) {
              final chainAccounts =
                  accounts.where((e) => e.networkIdentifier.id == i);
              if (chainAccounts.isEmpty) {
                return WalletMessageResponse.fail(error);
              }
            }
          }
        }
        if (accounts.isNotEmpty) {
          return WalletMessageResponse.success(JSWalletStandardConnect.setup(
              accounts.map((e) => e.jsAccount).toList()));
        }
        return WalletMessageResponse.fail(error);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }
}
