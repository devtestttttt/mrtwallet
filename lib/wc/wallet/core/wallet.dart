import 'dart:async';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/worker.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wc/core/types/exception.dart';
import 'package:on_chain_wallet/wc/wallet/core/network.dart';
import 'package:on_chain_wallet/wc/wallet/types/types.dart';
import 'package:on_chain_wallet/wc/wc.dart';
import 'package:on_chain_wallet/wc/core/types/types.dart';
import 'session.dart';

typedef SENDWEB3WALLETCONNECTREQUEST = Future<Web3MessageCore> Function(
    Web3RequestWalletConnectpplicationInformation);
typedef LOCALAUTH = Future<Web3APPData> Function();
typedef AUTHREQUEST = Future<Web3DappInfo?> Function(
    Web3ClientInfo onAuthRequest, bool create);

class Web3WalletConnectHandler {
  final SENDWEB3WALLETCONNECTREQUEST sendRequest;
  final AUTHREQUEST authRequest;
  final LOCALAUTH defaultAuth;
  final Map<String, Web3WalletConnectSessionHandler> sessions = {};
  final Map<String, Web3RequestWalletConnectpplicationInformation> __requests =
      {};
  final WalletConnectStorage _storage;
  final SynchronizedLock _lock = SynchronizedLock();

  Web3WalletConnectHandler(
      {required this.sendRequest,
      required this.authRequest,
      required this.defaultAuth,
      required String storageKey})
      : _storage = WalletConnectStorage(storageKey);
  StreamValue<WcRpcSocketStatus> get connectionStatus =>
      walletConnectCore.connectionStatus;
  late final WalletConnect walletConnectCore = () {
    final walletConnect = WalletConnect(
        projectId: "392db477d2a3f837141f08aa2bd40583",
        metadata: WcMetadata(
            name: 'OnChain',
            description: 'The best wallet in world',
            url: 'https://github.com/mrtnetwork',
            icons: []),
        getSessionInternal: _getSession);
    walletConnect.onEvent.listen(_onWcEvent);
    return walletConnect;
  }();

  /// wallet internal methods
  void _successRequest(String requestId) {
    final request = __requests.remove(requestId);
    request?.completeSuccess();
  }

  void _errorRequest(String requestId, {AppException? error}) {
    final request = __requests.remove(requestId);
    request?.completeError(error: error);
  }

  Future<List<int>> getSessionRequiredChainIds(
      {required SessionData session, Web3APPData? auth}) async {
    final localAuth = auth ?? await defaultAuth();
    final defaultNamespaces = await generateDefaultNamespace(auth: localAuth);
    Set<String> chains = {
      ...defaultNamespaces
          .allowedNamespace(session.requiredNamespaces)
          .chainIds,
    };
    if (chains.isEmpty) {
      chains = defaultNamespaces
          .allowedNamespace(session.optionalNamespaces)
          .chainIds
          .take(1)
          .toSet();
    }
    final networks = localAuth.chains.expand((e) => e.networks).toList();
    List<int> networkIds = [];
    for (final i in chains) {
      final network = networks.firstWhereOrNull((e) => e.isChain(i));
      if (network != null) networkIds.add(network.id);
    }
    return networkIds;
  }

  Future<WCSessionNamespaces> generateDefaultNamespace(
      {Web3APPData? auth}) async {
    final localAuth = auth ?? await defaultAuth();
    List<WCChainNamespace> wcNamespaces = [];
    for (final i in localAuth.chains) {
      final method = Web3NetworkRequestMethods.getMethods(i.networkType);
      final methodNames =
          method.expand((e) => e.walletConnectMethodNames).toList();
      final eventsNames =
          Web3NetworkEvent.getEvents(i.networkType).map((e) => e.name).toList();
      if (i.networkType.isBitcoin) {
        final bchNetworks =
            i.networks.cast<Web3BitcoinChainIdnetifier>().where((e) => e.isBch);
        final btcNetwork = i.networks
            .cast<Web3BitcoinChainIdnetifier>()
            .where((e) => !e.isBch);
        final bch = WCChainNamespace(
            identifier: NetworkType.bitcoinCash.caip2,
            namespace: WCNamespace(
                chains: bchNetworks.map((e) => e.caip2).toList(),
                accounts: [],
                methods: methodNames,
                events: eventsNames));
        final btc = WCChainNamespace(
            identifier: NetworkType.bitcoinAndForked.caip2,
            namespace: WCNamespace(
                chains: btcNetwork.map((e) => e.caip2).toList(),
                accounts: [],
                methods: methodNames,
                events: eventsNames));
        wcNamespaces.addAll([bch, btc]);
        continue;
      }
      final namespace = WCChainNamespace(
          identifier: i.networkType.caip2,
          namespace: WCNamespace(
              chains: i.networks.map((e) => e.caip2).toList(),
              accounts: [],
              methods:
                  method.expand((e) => e.walletConnectMethodNames).toList(),
              events: eventsNames));
      wcNamespaces.add(namespace);
    }
    final namespaces =
        WCSessionNamespaces(wcNamespaces, allowEmptyAccount: true);
    return namespaces;
  }

  Future<void> _sendMessage(WalletMessageRequest request) async {
    final session = sessions[request.topic];
    assert(session != null, "session not found.");
    // request.
    if (session == null) return;
    final r = Web3RequestWalletConnectpplicationInformation(
        info: session.client,
        request: request.message,
        requestId: request.requestId);
    __requests[request.wcRequestId ?? request.requestId] = r;
    final response = await sendRequest(r);
    session.onWalletResponse(message: response, requestId: request.requestId);
    if (request.wcRequestId == null) {
      _successRequest(request.requestId);
    }
  }

  Future<void> _sendEvent(WalletEventRequest request) async {
    final session = sessions[request.topic];
    if (session == null || !session.session.isActive) return;
    final events = request.event.map((e) => e.generateEvents()).toList();
    final updateSession = request.session;
    if (updateSession != null) {
      await _storage.setSession(updateSession);
      await walletConnectCore.updateSession(updateSession);
    }
    await walletConnectCore.emitSessionEvent(
        topic: session.topic, events: events, session: session.session);
  }

  SessionData? getSession({String? topic, String? peerKey}) {
    return _storage.getSession(topic: topic, peerKey: peerKey);
  }

  Future<Web3WalletConnectSessionHandler?> _getInternalSession(
      String topic) async {
    Web3WalletConnectSessionHandler? handler =
        sessions.values.firstWhereOrNull((e) => e.topic == topic);
    if (handler != null) {
      return handler;
    }
    final session = getSession(topic: topic);
    if (session == null) return null;
    final clientId = session.peerKey;
    final metadata = session.peer.metadata;
    final client = Web3ClientInfo.walletConnect(
        clientId: clientId,
        url: metadata.url,
        name: metadata.name,
        description: metadata.description,
        faviIcon: metadata.icons
            .map((e) => APPImage.network(e))
            .whereType<APPImage>()
            .firstOrNull);
    final auth = await authRequest(client, false);
    if (auth == null) return null;
    handler = Web3WalletConnectSessionHandler(
        sendMessagetowallet: _sendMessage,
        sendEventToClient: _sendEvent,
        client: client,
        session: session);
    sessions[clientId] = handler;
    handler.updateAuthenticated(auth.dappData);
    return handler;
  }

  /// wallet connect
  Future<SessionProposalResponse> _onSessionPropose(
      WcSessionProposalRequest request) async {
    final proposer = request.params.proposer;
    final clientId = proposer.publicKey;
    final metadata = proposer.metadata;
    assert(!sessions.containsKey(clientId));

    final defaultNamespaces = await generateDefaultNamespace();
    if (!defaultNamespaces.allowNamespace(request.params.requiredNamespaces)) {
      throw WalletConnectExceptionConst.requiredNamespacesNotSupported;
    }
    Set<String> chains = {
      ...defaultNamespaces
          .allowedNamespace(request.params.requiredNamespaces)
          .chainIds,
    };
    if (chains.isEmpty) {
      chains = defaultNamespaces
          .allowedNamespace(request.params.optionalNamespaces)
          .chainIds
          .take(1)
          .toSet();
    }
    final client = Web3ClientInfo.walletConnect(
        clientId: clientId,
        url: metadata.url,
        name: metadata.name,
        description: metadata.description,
        faviIcon: metadata.icons
            .map((e) => APPImage.network(e))
            .whereType<APPImage>()
            .firstOrNull);
    Duration? timeout = request.timeout();
    if (timeout == null) {
      throw WalletConnectExceptionConst.pairingRequestTimedout;
    }

    final auth = await authRequest(client, true);
    if (auth == null) {
      return SessionProposalReject(
          request: request, exception: Web3RequestExceptionConst.bannedHost);
    }
    final sharedKey = await walletConnectCore.crypto.cryptoIsolateRequest(
        CryptoRequestGenerateWalletConnectSymKeyInfo(
            publicKey: clientId,
            privateKey: auth.authentication.token.privateKey));
    SessionData createSession = SessionData(
        topic: sharedKey.topicAsHex,
        symkey: sharedKey.symkeyAsHex,
        relay: WcProtocolOptions(protocol: WcConstans.relayProtocol),
        namespaces: WCSessionNamespaces([]),
        optionalNamespaces: request.params.optionalNamespaces,
        requiredNamespaces: request.params.requiredNamespaces,
        peer: proposer,
        pairTopic: request.request.topic,
        expireTime: WalletConnectUtils.defaultSessionExpireTime());
    final handler = Web3WalletConnectSessionHandler(
        sendMessagetowallet: _sendMessage,
        sendEventToClient: _sendEvent,
        client: client,
        session: createSession);
    await handler.updateAuthenticated(auth.dappData);
    sessions[clientId] = handler;
    final rId = request.id.toString();
    final connectRequest = WalletConnectNetworkRequest.global(
        method: Web3GlobalRequestMethods.connect.name,
        chains: chains.toList(),
        wcRequestId: rId);
    final active = await handler.activeSession(connectRequest).timeout(
      timeout,
      onTimeout: () {
        _errorRequest(rId,
            error: WalletConnectExceptionConst.pairingRequestTimedout);
        throw WalletConnectExceptionConst.pairingRequestTimedout;
      },
    );
    if (!active) {
      sessions.remove(clientId);
      return SessionProposalReject(
          request: request,
          exception: Web3RequestExceptionConst.rejectedByUser);
    }
    await _storage.setSession(handler.session);
    return SessionProposalAprove(
        request: request,
        publicKey: sharedKey.publicKeyAsHex,
        session: handler.session);
  }

  Future<void> _onSessionRequest(SessionRequest request) async {
    await _lock.synchronized(() async {
      final session = await _getInternalSession(request.session.topic);

      final timeout = request.timout();
      if (timeout == null) return;
      if (session == null) {
        final error = WCSDKErrors.userDisconnected;
        walletConnectCore.sendResponse(
            request: request.pairRequest,
            response: PairResultError(error: error.toRpcError()));
        return;
      }
      try {
        final response = await session
            .onClientRequest(WalletConnectClientRequestParams(request))
            .timeout(timeout);
        final result = switch (response.type) {
          WalletConnectWalletMessageResponseType.success =>
            WcJsonRpcResult(id: request.id, result: response.data),
          WalletConnectWalletMessageResponseType.failed => () {
              final exp = response.data as Web3ExceptionMessage;
              return WcJsonRpcError(
                  id: request.id,
                  error: WcJsonRpcErrorResponse(
                      code: exp.code, message: exp.message));
            }(),
        };
        request.id;
        walletConnectCore.sendResponse(
            request: request.pairRequest, response: result.toPairResult());
      } on TimeoutException {
        final rId = request.pairRequest.message.id.toString();
        _errorRequest(rId,
            error: WalletConnectExceptionConst.sessionRequestExpired);
      }
    });
  }

  Future<void> _onWcEvent(WcInternalEvent event) async {
    switch (event.type) {
      case WcInternalEventType.sessionDelete:
        final session = event.cast<WcInternalSessionDeleteEvent>().session;
        await _storage.deleteSession(session.topic);
        final handler = sessions.remove(session.peerKey);
        assert(handler != null, "session does not exists");
        break;
      case WcInternalEventType.request:
        final sessions = event.cast<WcInternalSessionRequestEvent>();
        _onSessionRequest(sessions.request);
        break;
      case WcInternalEventType.publishMessage:
        final message = event.cast<WcInternalPublishMessageEvent>();
        await _storage.setPendingMessage(message);
        if (message.status.isPending) return;
        final rId = message.request.correlationId.toString();
        if (message.status.isSuccess) {
          _successRequest(rId);
        } else {
          _errorRequest(rId);
        }

      default:
    }
  }

  Future<SessionData?> _getSession(String topic) async {
    final handler = await _getInternalSession(topic);
    return handler?.session;
  }

  /// extenal methods
  Future<void> pair(Uri uri, {Cancelable? cancelable}) async {
    await walletConnectCore.pair(
        uri: uri, onSessionPropose: _onSessionPropose, cancelable: cancelable);
  }

  Future<void> onDeleteSession(SessionData topic) async {
    final session = sessions.remove(topic.peerKey);
    assert(session != null, "session does not exists");
    if (session == null) return;
    await _storage.deleteSession(session.topic);
  }

  Future<List<Web3ClientInfo>> getActiveSessions() async {
    final sessions = _storage.getActiveSessions();
    return sessions
        .map((e) => Web3ClientInfo.walletConnect(
            clientId: e.peerKey,
            url: e.peer.metadata.url,
            name: e.peer.metadata.name,
            description: e.peer.metadata.description,
            faviIcon: e.peer.metadata.icons
                .map((e) => APPImage.network(e))
                .whereType<APPImage>()
                .firstOrNull))
        .toList();
  }

  Future<void> removeSession(Web3ClientInfo client) async {
    SessionData? session = sessions.remove(client.identifier)?.session;
    if (session == null) {
      session = getSession(peerKey: client.identifier);
      if (session == null) return;
    }
    await Future.delayed(const Duration(seconds: 5));
    await _storage.deleteSession(session.topic);
    walletConnectCore.deleteSession(session);
  }

  Future<void> updateAuthenticated(Web3DappInfo app) async {
    final auth = app.dappData;
    Web3WalletConnectSessionHandler? handler = sessions[auth.applicationId];
    if (handler != null) {
      await handler.updateAuthenticated(auth);
      return;
    }
    final session = getSession(peerKey: auth.applicationId);
    if (session == null) return;
    handler = Web3WalletConnectSessionHandler(
        sendMessagetowallet: (message) {},
        sendEventToClient: (message) async {},
        client: app.clientInfo,
        session: session);
    await handler.updateAuthenticated(auth);
    await _storage.setSession(handler.session);
    walletConnectCore.updateSession(handler.session);
  }

  Future<void> connect() async {
    await _lock.synchronized(() async {
      await _storage.init();
      final sessions = _storage.getActiveSessions();
      final messages = _storage.getPendingMessages();
      await walletConnectCore.init(sessions: sessions, messages: messages);
    }, lockId: LockId.three);
  }

  Future<void> dispose() async {
    await _lock.synchronized(() async {
      await walletConnectCore.dispose();
    }, lockId: LockId.three);
  }

  Future<void> init() async {
    await _lock.synchronized(() async {
      await _storage.init();
    }, lockId: LockId.three);
  }

  Future<void> close() async {
    await _lock.synchronized(() async {
      await walletConnectCore.close();
      await _storage.close();
    }, lockId: LockId.three);
  }
}
