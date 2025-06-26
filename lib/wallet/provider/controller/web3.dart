part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

/// wallet web3 operations
mixin Web3Impl on WalletManager {
  late final Web3WalletConnectHandler walletConnectHandler =
      Web3WalletConnectHandler(
          sendRequest: _web3WalletConnectRequest,
          authRequest: _getWalletConnectAuth,
          defaultAuth: _getDefaultAuth,
          storageKey: _wallet.wcStorageKey);

  Future<Web3APPData?> _getWalletConnectAuth(
      Web3ClientInfo info, bool create) async {
    if (!create) {
      final appAuth = await _getAuthenticated(info.identifier);
      return appAuth?.createAuth(_appChains.getWeb3NetworkData());
    }
    final auth = await _getOrCreateDappAuthenticated(info);
    return auth.createAuth(_appChains.getWeb3NetworkData());
  }

  @override
  Future<List<Web3APPAuthentication>> _getAllWeb3Authenticated() async {
    final keys = await _core._readAll(prefix: _wallet.web3StorageKey);
    final auhts = keys.values
        .map((e) => MethodUtils.nullOnException(
            () => Web3APPAuthentication.deserialize(hex: e)))
        .whereType<Web3APPAuthentication>()
        .toList();
    return auhts;
  }

  Future<List<Web3DappInfo>> _getAllWeb3Applications() async {
    final web3Chains = _appChains.getWeb3NetworkData();
    final auhts = await _getAllWeb3Authenticated();
    return auhts
        .map((e) => Web3DappInfo(
            authentication: e,
            clientInfo: e.toClient(),
            dappData: e.createAuth(web3Chains)))
        .toList();
  }

  Future<Web3DappInfo> _getWeb3Dapp(Web3ClientInfo clientInfo) async {
    final authentication = await _getOrCreateDappAuthenticated(clientInfo);
    final dappData = authentication.createAuth(_appChains.getWeb3NetworkData());
    return Web3DappInfo(
        authentication: authentication,
        dappData: dappData,
        clientInfo: clientInfo);
  }

  //  Future<Web3APPAuthentication?> _getAuthenticated(Web3ClientInfo info) async {
  //   final permission = await _core._readWeb3Permission(
  //       applicationId: info.identifier, wallet: _wallet);

  //   final appAuth = MethodUtils.nullOnException(() {
  //     return Web3APPAuthentication.deserialize(hex: permission);
  //   });
  //   if (appAuth?.protocol != info.protocol) {
  //     return null;
  //   }
  //   return appAuth;
  // }

  Future<Web3APPAuthentication?> _getAuthenticated(String identifier,
      {Web3APPProtocol? protocol}) async {
    final permission = await _core._readWeb3Permission(
        applicationId: identifier, wallet: _wallet);

    final appAuth = MethodUtils.nullOnException(() {
      return Web3APPAuthentication.deserialize(hex: permission);
    });
    if (protocol != null && appAuth?.protocol != protocol) {
      return null;
    }
    return appAuth;
  }

  Future<Web3APPAuthentication> _getOrCreateDappAuthenticated(
      Web3ClientInfo info) async {
    final toPermission = await _getAuthenticated(info.identifier);
    if (toPermission == null) {
      final applicationKey = await crypto.generateHashString(
          type: CryptoRequestHashingType.md4,
          dataBytes: info.identifier.codeUnits,
          isolate: false);
      final token = await crypto.cryptoIsolateRequest(
          CryptoRequestGenerateWalletConnectSymKeyInfo(
              publicKey: info.identifier,
              hashKey: !info.protocol.isWalletConnect));
      final permission = info.toAuhenticated(
          token: Web3APPAuthenticationKey(
              topic: token.topic,
              publicKey: token.publicKey,
              symkey: token.symkey),
          applicationKey: applicationKey);

      await _core._savePermission(permission: permission, wallet: _wallet);
      return permission;
    }

    return toPermission;
  }

  Future<dynamic> _getWalletOwnerResult(Web3Request request) async {
    final push = await _core.onWeb3Request(request);
    if (!(push)) {
      throw Web3RequestExceptionConst.internalError;
    }
    return await request.getResponse();
  }

  Future<Web3MessageCore> _handleGlobalRequest(
      {required Web3GlobalRequestParams requestParams,
      required Web3APPAuthentication authenticated,
      required Web3RequestInformation walletRequest}) async {
    Web3GlobalRequest request = Web3GlobalRequest(
        authenticated: authenticated,
        info: walletRequest,
        params: requestParams);
    List<NetworkType> result;
    switch (requestParams.method) {
      case Web3GlobalRequestMethods.disconnect:
        final disconnect = requestParams.cast<Web3DisconnectApplication>();
        authenticated.disconnectChain(disconnect.chain);
        result = [disconnect.chain];
        break;
      default:
        result = await _getWalletOwnerResult(request);
        break;
    }
    final chains = _appChains.getWeb3NetworkData();
    final auth = authenticated.createAuth(chains, web3Networks: result);
    request.updateActivity();
    return Web3GlobalResponseMessage(authenticated: auth);
  }

  List<Chain> _getRequestChains(NetworkType network) {
    return _appChains.chains(type: network);
  }

  Future<Web3MessageCore> _handleChainRequest(
      {required Web3RequestParams requestParams,
      required Web3APPAuthentication authenticated,
      required Web3RequestInformation walletRequest}) async {
    final request = requestParams.toRequest(
        request: walletRequest,
        chains: _getRequestChains(requestParams.method.network),
        authenticated: authenticated);

    await request.chain.init();

    final Object? result = await _getWalletOwnerResult(request);
    request.updateActivity();
    Object? walletResponse;
    if (authenticated.protocol.isWalletConnect) {
      walletResponse = request.params.toWalletConnectResponse(result);
    } else {
      walletResponse = request.params.toJsWalletResponse(result);
    }
    //
    Web3APPData? auth;
    if (request.params.method.reloadAuthenticated) {
      final chains = _appChains.getWeb3NetworkData();
      auth = authenticated
          .createAuth(chains, web3Networks: [request.chain.network.type]);
    }
    return Web3WalletResponseMessage(
        result: walletResponse,
        authenticated: auth,
        network: request.params.method.network);
  }

  Future<RESPONSE> _localWeb3Request<RESPONSE>(
      WEB3REQUESTPARAMSRESPONSE<RESPONSE> params) async {
    final requestId = await crypto.generateHashString(
        type: CryptoRequestHashingType.generateUuid);

    final request = params.toRequest(
        request: Web3RequestLocalInformation(requestId),
        chains: _getRequestChains(params.method.network),
        authenticated: Web3LocalAuthentication(
            icon: APPConst.logo,
            applicationId: APPConst.name,
            name: APPConst.name));
    await request.chain.init();
    return await _getWalletOwnerResult(request);
  }

  Future<Web3MessageCore> _web3GetResponse(
      {required Web3MessageCore requestParams,
      required Web3APPAuthentication authenticated,
      required Web3RequestInformation walletRequest}) async {
    Web3MessageCore response;
    try {
      if (!authenticated.active) {
        throw Web3RequestExceptionConst.bannedHost;
      }
      switch (requestParams.type) {
        case Web3MessageTypes.walletRequest:
          response = await _handleChainRequest(
              authenticated: authenticated,
              requestParams: requestParams.cast<Web3RequestParams>(),
              walletRequest: walletRequest);

          break;
        case Web3MessageTypes.walletGlobalRequest:
          response = await _handleGlobalRequest(
              requestParams: requestParams.cast<Web3GlobalRequestParams>(),
              authenticated: authenticated,
              walletRequest: walletRequest);
          break;
        default:
          throw Web3RequestExceptionConst.invalidRequest;
      }
    } on Web3RejectException catch (_) {
      rethrow;
    } on Web3RequestException catch (e) {
      Web3APPData? auth;
      switch (e) {
        case Web3RequestExceptionConst.missingPermission:
        case Web3RequestExceptionConst.bannedHost:
        case Web3RequestExceptionConst.invalidNetwork:
        case Web3RequestExceptionConst.internalError:
          auth = authenticated.createAuth(_appChains.getWeb3NetworkData());
          break;
        default:
      }
      response = e.toResponseMessage(
          requestId: walletRequest.requestId, authenticated: auth);
    } catch (e) {
      const exception = Web3RequestExceptionConst.internalError;
      response = exception.toResponseMessage(
          requestId: walletRequest.requestId,
          authenticated:
              authenticated.createAuth(_appChains.getWeb3NetworkData()));
    } finally {
      await _core._savePermission(wallet: _wallet, permission: authenticated);
    }
    return response;
  }

  Future<Web3MessageCore> _web3WalletConnectRequest(
      Web3RequestWalletConnectpplicationInformation walletRequest) async {
    final authenticated =
        await _getAuthenticated(walletRequest.info.identifier);
    if (authenticated == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return _web3GetResponse(
        requestParams: walletRequest.request,
        authenticated: authenticated,
        walletRequest: walletRequest);
  }

  Future<Web3EncryptedMessage> _web3Request(
      Web3RequestApplicationInformation walletRequest) async {
    final authenticated = await _getAuthenticated(walletRequest.applicationId);
    if (authenticated == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    Web3MessageCore requestParams;
    try {
      final Web3EncryptedMessage encryotedMessage =
          Web3EncryptedMessage.deserialize(bytes: walletRequest.data);
      final CryptoDecryptChachaResponse decrypt =
          await crypto.cryptoMainRequest(CryptoRequestDecryptChacha(
              key: authenticated.token.symkey,
              nonce: encryotedMessage.nonce,
              message: encryotedMessage.message));
      requestParams = Web3MessageCore.deserialize(bytes: decrypt.decrypted);
    } catch (_) {
      throw Web3RequestExceptionConst.invalidRequest;
    }
    Web3MessageCore response = await _web3GetResponse(
        requestParams: requestParams,
        authenticated: authenticated,
        walletRequest: walletRequest);
    final CryptoEncryptChachaResponse encryptResponse =
        await crypto.cryptoMainRequest(CryptoRequestEncryptChacha(
            key: authenticated.token.symkey,
            message: response.toCbor().encode()));
    return Web3EncryptedMessage(
        message: encryptResponse.encrypted, nonce: encryptResponse.nonce);
  }

  Future<Web3DappInfo> _updateWeb3Application(Web3APPAuthentication application,
      {List<NetworkType>? web3Networks}) async {
    await _core._savePermission(wallet: _wallet, permission: application);
    final dappData = application.createAuth(_appChains.getWeb3NetworkData(),
        web3Networks: web3Networks);
    return Web3DappInfo(
        authentication: application,
        dappData: dappData,
        clientInfo: application.toClient());
  }

  Future<void> _removeWeb3Authenticated(
      Web3APPAuthentication application) async {
    await _core._removeWeb3Permission(wallet: _wallet, permission: application);
  }

  Future<Web3APPData> _getDefaultAuth() async {
    final application = Web3APPAuthentication.local();
    final permission = application.createAuth(_appChains.getWeb3NetworkData());
    return permission;
  }

  @override
  Future<void> _onInitController() async {
    await super._onInitController();
    await walletConnectHandler.init();
  }

  @override
  void _dispose() {
    super._dispose();
    walletConnectHandler.close();
  }
}
