part of 'package:on_chain_wallet/wc/wc.dart';

mixin WalletConnectRelayClient on WalletConnectCore {
  final Map<String, List<int>> _pendingMessages = {};
  final Set<String> _topics = {};
  final Set<String> _subscribeTopics = {};
  final Map<String, WcPairingClient> _pendingClients = {};
  final Map<int, PublishRequest> _publishedMessage = {};
  StreamSubscription<dynamic>? _predioc;
  final SynchronizedLock _lock = SynchronizedLock();
  final StreamController<WcInternalEvent> _internalEmitter =
      StreamController<WcInternalEvent>.broadcast(sync: true);
  Stream<WcInternalEvent> get onEvent => _internalEmitter.stream;
  StreamValue<WcRpcSocketStatus> get connectionStatus => _rpc.status;
  StreamSubscription<RelayClientResponse>? _onSub;
  final Map<int, Completer> _pendingRequests = {};

  late final JsonRpcWebSocketService _rpc = JsonRpcWebSocketService(
    () async {
      final jwt =
          await crypto.cryptoIsolateRequest(CryptoRequestGenerateJwt(relayUrl));
      return WalletConnectUtils.generateRelayUrl(
          relayUrl: relayUrl, auth: jwt, projectId: projectId);
    },
  );
  Future<bool> _messageExists(RelayClientSubscribeResponse message) async {
    return _lock.synchronized(() async {
      _pendingMessages[message.topic] ??= [];
      final hashCode = message.hashCode;
      if (_pendingMessages[message.topic]!.contains(hashCode)) {
        return true;
      }
      _pendingMessages[message.topic]!.add(hashCode);
      return false;
    });
  }

  void _onPeriodic(dynamic _) {
    _publishedMessage.values.map((e) => _publish(e));
  }

  Future<void> _publish(PublishRequest request) async {
    await _lock.synchronized(() async {
      if (request.isComplete) return;
      final timeout = request.timeout();
      try {
        if (timeout == null) {
          throw WalletConnectExceptionConst.publishMessageExpired;
        }
        if (!_publishedMessage.containsKey(request.correlationId)) {
          _publishedMessage[request.correlationId] = request;
          _internalEmitter.add(WcInternalPublishMessageEvent(
              request: request,
              status: WcInternalPublishMessageStatus.pending));
        }

        final result = await _rpc.send(request.toPublishMessage()).timeout(
            timeout,
            onTimeout: () =>
                throw WalletConnectExceptionConst.publishMessageExpired);
        final message = _publishedMessage.remove(request.correlationId);
        if (message != null) {
          message.success(result);
          _internalEmitter.add(WcInternalPublishMessageEvent(
              request: request,
              status: WcInternalPublishMessageStatus.success));
        }
      } catch (e) {
        if (e == WalletConnectExceptionConst.publishMessageExpired) {
          _publishedMessage.remove(request.correlationId);
          request.expire();
          _internalEmitter.add(WcInternalPublishMessageEvent(
              request: request, status: WcInternalPublishMessageStatus.failed));
        }
      }
    }, lockId: LockId.two);
  }

  Future<void> _onConnect() async {
    await Future.wait(_topics.map((e) => _subscribe(topic: e)));
    await Future.wait(_publishedMessage.values.map((e) => _publish(e)));
  }

  Future<dynamic> _subscribe(
      {required String topic, bool keepTopics = true}) async {
    return await _lock.synchronized(() async {
      if (_subscribeTopics.contains(topic)) return;
      if (keepTopics) _topics.add(topic);
      try {
        final result = await _rpc.send(RelayClientRequest(
            method: WalletConnectRelayClientMethods.subscribe,
            params: {'topic': topic}));
        _subscribeTopics.add(topic);

        return result;
      } catch (e) {
        _subscribeTopics.remove(topic);
        rethrow;
      }
    }, lockId: LockId.three);
  }

  Future<void> _onRPCEvent(RelayClientResponse message) async {
    switch (message.type) {
      case RelayClientResponseType.connect:
        await _onConnect();
        _internalEmitter.add(WcInternalConnectEvent());
        break;
      case RelayClientResponseType.disconnect:
        _subscribeTopics.clear();
        _internalEmitter.add(WcInternalDisconnectEvent());
        break;
      case RelayClientResponseType.subscribe:
        final subMessage = message as RelayClientSubscribeResponse;
        _onRelayEvent(subMessage);
        break;
      default:
        assert(false, "Invalid rpc event type: ${message.type}");
        break;
    }
  }

  String? _getRequestEncryptionKey(
      {required WalletConnectKnownMethods? method,
      required String topic,
      required SessionData? session}) {
    switch (method) {
      case WalletConnectKnownMethods.pairingDelete:
      case WalletConnectKnownMethods.pairingPing:
      case WalletConnectKnownMethods.sessionPropose:
        return _pendingClients[topic]?.symkey;
      default:
        return session?.symkey;
    }
  }

  Future<String?> _serializeMessage(
      {required String topic,
      String? symkey,
      required Map<String, dynamic> payload}) async {
    if (symkey == null) return null;
    final List<int> message = StringUtils.encodeJson(payload);
    final msg = RelayClientEncryptedMessage(
        type: RelayClientMessageTypes.type0,
        sealed: message,
        nonce: QuickCrypto.generateRandom(12));
    final String result = await _encryptMessage(msg, symkey);
    return result;
  }

  Future<String> _encryptMessage(
      RelayClientEncryptedMessage message, String symKey) async {
    final encrypt = await crypto.cryptoMainRequest(CryptoRequestEncryptChacha(
        message: message.sealed,
        key: BytesUtils.fromHexString(symKey),
        nonce: message.nonce));
    final encryptedMessage = RelayClientEncryptedMessage(
        type: message.type, sealed: encrypt.encrypted, nonce: message.nonce);
    return encryptedMessage.serialize();
  }

  Future<Map<String, dynamic>?> _decryptMessage(
      {required String? symKey,
      required RelayClientEncryptedMessage message}) async {
    if (symKey == null) return null;
    final decode = await crypto.cryptoMainRequest(CryptoRequestDecryptChacha(
        message: message.sealed,
        key: BytesUtils.fromHexString(symKey),
        nonce: message.nonce));
    return StringUtils.decodeJson<Map<String, dynamic>>(decode.decrypted);
  }

  Future<void> _onRelayEvent(RelayClientSubscribeResponse messagEvent) async {
    final exists = await _messageExists(messagEvent);
    if (exists) return;
    final session = await getSession(messagEvent.topic);
    final symkey =
        _pendingClients[messagEvent.topic]?.symkey ?? session?.symkey;
    final relayMessage =
        RelayClientEncryptedMessage.deserialize(messagEvent.message);

    assert(
        relayMessage.type != RelayClientMessageTypes.type1 &&
            relayMessage.type != RelayClientMessageTypes.type2,
        'should not be here');
    Map<String, dynamic>? data = switch (relayMessage.type) {
      RelayClientMessageTypes.type0 =>
        await _decryptMessage(symKey: symkey, message: relayMessage),
      _ => null
    };
    if (data == null) return;
    final message = PairMessage.fromMessage(
        topic: messagEvent.topic,
        message: WcJsonRpcMessage.fromJson(data),
        session: session,
        publishedAt: messagEvent.publishedAt);
    switch (message.message.messageType) {
      case WcJsonRpcMessageType.unknwon:
        final error = WCSDKErrors.invalidMethod.toRpcError();
        sendResponse(request: message, response: PairResultError(error: error));
        break;
      case WcJsonRpcMessageType.unsuported:
        final error = WCSDKErrors.unsuportedWcMethod.toRpcError();
        sendResponse(request: message, response: PairResultError(error: error));
        break;
      case WcJsonRpcMessageType.response:
        final response = message.message.cast<WcJsonRpcResponse>();
        final pendingRequest = _pendingRequests.remove(response.id);
        if (pendingRequest == null) break;
        switch (response.type) {
          case WcJsonRpcResponseType.error:
            pendingRequest.completeError((response as WcJsonRpcError).error);
            break;
          case WcJsonRpcResponseType.result:
            pendingRequest.complete((response as WcJsonRpcResult).result);
            break;
        }
        break;
      case WcJsonRpcMessageType.request:
        final request = message as PairMessageRequest;
        final response = switch (request.message.method) {
          WalletConnectKnownMethods.sessionDelete =>
            await _onSessionDeleteRequest(request),
          WalletConnectKnownMethods.sessionEvent =>
            await _onSessionEventRequest(request),
          WalletConnectKnownMethods.sessionPing =>
            await _onSessionPingRequest(request),
          WalletConnectKnownMethods.sessionPropose =>
            await _onSessionProposeRequest(request),
          WalletConnectKnownMethods.sessionRequest =>
            await _onSessionRequest(request),
          WalletConnectKnownMethods.pairingPing =>
            await _onPairingPingRequest(request),
          WalletConnectKnownMethods.pairingDelete =>
            await _onPairingDeleteRequest(request),
          _ => null
        };
        sendResponse(request: request, response: response);
        break;
    }
  }

  Future<PairResult> _onPairingPingRequest(PairMessageRequest request) async {
    final client = _pendingClients[request.topic];
    if (client == null) {
      final error = WCSDKErrors.noMatchingKey.toRpcError();
      return PairResultError(error: error);
    }
    return PairResultSuccess(true);
  }

  Future<PairResult?> _onPairingDeleteRequest(
      PairMessageRequest request) async {
    final client = _pendingClients.remove(request.topic);
    if (client == null) {
      final error = WCSDKErrors.noMatchingKey.toRpcError();
      return PairResultError(error: error);
    }
    client.cancel(WalletConnectExceptionConst.pairingCanceledByDapp);
    _internalEmitter.add(WcInternalPairDeleteEvent(request.topic));
    return null;
  }

  Future<PairResult> _onSessionDeleteRequest(
      PairMessageRequest pairRequest) async {
    final session = pairRequest.session;
    if (session == null) {
      final error = WCSDKErrors.noMatchingKey.toRpcError();
      return PairResultError(error: error);
    }
    _topics.remove(pairRequest.topic);
    _internalEmitter.add(WcInternalSessionDeleteEvent(session));
    return PairResultSuccess(true);
  }

  Future<PairResult> _onSessionPingRequest(
      PairMessageRequest pairRequest) async {
    final session = pairRequest.session;
    if (session == null) {
      final error = WCSDKErrors.noMatchingKey.toRpcError();
      return PairResultError(error: error);
    }
    return PairResultSuccess(true);
  }

  Future<PairResult?> _onSessionRequest(PairMessageRequest pairRequest) async {
    final session = pairRequest.session;
    if (session == null) {
      final error = WCSDKErrors.noMatchingKey.toRpcError();
      return PairResultError(error: error);
    }
    final request = WcSessionRequest.fromJson(pairRequest.message.params);
    final sessionRequest = SessionRequest(
        pairRequest: pairRequest, request: request, session: session);
    _internalEmitter.add(WcInternalSessionRequestEvent(sessionRequest));
    return null;
  }

  Future<PairResult?> _onSessionEventRequest(
      PairMessageRequest pairRequest) async {
    final session = pairRequest.session;
    if (session == null) {
      final error = WCSDKErrors.noMatchingKey.toRpcError();
      return PairResultError(error: error);
    }
    final event = WcSessionEventRequest.fromJson(pairRequest.message.params);
    final request = SessionEventRequest(event: event, session: session);
    _internalEmitter.add(WcInternalSessionEventEvent(request));
    return null;
  }

  Future<PairResult?> _onSessionProposeRequest(
      PairMessageRequest pairRequest) async {
    final client = _pendingClients[pairRequest.topic];
    if (client == null) {
      final error = WCSDKErrors.noMatchingKey.toRpcError();
      return PairResultError(error: error);
    }
    final proposeRequest =
        WcProposalStruct.fromJson(pairRequest.message.params);
    final proposalRequest = WcSessionProposalRequest(
        id: pairRequest.message.id,
        params: proposeRequest,
        request: pairRequest);
    _pendingClients[pairRequest.topic]?.complete(proposalRequest);
    return null;
  }

  Future<dynamic> _sendRequest(SendSessionRequestParams request,
      {String? symkey, bool waitForResult = true}) async {
    final int requestId = DateTime.now().microsecondsSinceEpoch;
    final payload = request.toJson(id: requestId);
    final sessionKey = symkey ??
        _getRequestEncryptionKey(
            method: request.params.method,
            topic: request.topic,
            session: request.session);
    final message = await _serializeMessage(
        topic: request.topic, payload: payload, symkey: sessionKey);
    if (message == null) {
      return;
    }
    Completer? completer;
    if (waitForResult) {
      completer = Completer();
      _pendingRequests[requestId] = completer;
    }

    WalletConnectMethodParams opts = request.params.method.requestParam;
    final publishMessage = PublishRequest(
        topic: request.topic,
        message: message,
        ttl: opts.ttl,
        tag: opts.tag,
        correlationId: requestId,
        id: requestId);
    _publish(publishMessage);
    await publishMessage.wait();
    return completer?.future.timeout(WalletConnectConst.defaultRequestTimeout);
  }

  Future<void> sendResponse(
      {PairResult? response,
      required PairMessage request,
      String? symkey}) async {
    if (response == null) return;
    final payload = response.toJson(request.message.id);
    symkey ??= _getRequestEncryptionKey(
        method: request.method, topic: request.topic, session: request.session);
    final String? message = await _serializeMessage(
        topic: request.topic, payload: payload, symkey: symkey);
    if (message == null) {
      return;
    }
    final fallbackOpts =
        request.method?.reject ?? request.method?.responseParam;
    final ttl = fallbackOpts?.ttl ?? WalletConnectMethodParams.defaultTll;
    final tag = fallbackOpts?.tag ?? WalletConnectMethodParams.defaultTag;
    final publicRequest = PublishRequest(
        topic: request.topic,
        message: message,
        ttl: ttl,
        tag: tag,
        correlationId: request.message.id,
        id: request.message.id);
    _publish(publicRequest);
    await publicRequest.wait();
  }

  Future<void> disconnectPair(String topic) async {
    final client = _pendingClients.remove(topic);
    if (client == null) return;
    _internalEmitter.add(WcInternalPairDeleteEvent(topic));
    try {
      final error = WCSDKErrors.userDisconnected;
      await _sendRequest(
          SendSessionRequestParams(
              params: WcPairingDeleteRequest(
                  code: error.code, message: error.message),
              topic: topic),
          symkey: client.symkey);
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _rpc.dispose();
    _predioc?.cancel();
    _predioc = null;
  }

  Future<void> init({
    List<SessionData> sessions = const [],
    List<PublishRequest> messages = const [],
  }) async {
    for (final i in messages) {
      _publishedMessage[i.correlationId] = i;
    }
    _topics.addAll(sessions.map((e) => e.topic));
    _onSub?.cancel();
    _onSub = null;
    _predioc?.cancel();
    _predioc = null;
    _onSub = _rpc.stream.listen(_onRPCEvent);
    await _rpc.init();
    _predioc =
        Stream.periodic(WcConstans.clientPrediocEvent).listen(_onPeriodic);
  }

  Future<void> close() async {
    await _rpc.dispose();
    _predioc?.cancel();
    _predioc = null;
    _onSub?.cancel();
    _onSub = null;
    _internalEmitter.close();
    _pendingMessages.clear();
    _topics.clear();
    _subscribeTopics.clear();
    _pendingClients.clear();
    _pendingRequests.clear();
  }
}
