part of 'package:on_chain_wallet/wc/wc.dart';

typedef ONSESSIONPROPOSEREQUEST = Future<SessionProposalResponse> Function(
    WcSessionProposalRequest proposal);
typedef ONSESSIONREQUEST = Future<WcJsonRpcResponse> Function(
    SessionRequest proposal);
typedef ONSESSIONEVENTREQUEST = Future<SessionEventResponse?> Function(
    SessionEventRequest proposal);
typedef ONGETSESSION = Future<SessionData?> Function(String topic);
typedef ONPIRINGDELETE = void Function(String topic);
typedef ONDELETESESSION = Future<void> Function(SessionData session);

abstract class WalletConnectCore with CryptoWokerImpl {
  final String relayUrl;
  final String projectId;
  WalletConnectCore({required this.relayUrl, required this.projectId});
  Future<SessionData?> getSession(String topic);
}

class WalletConnect extends WalletConnectCore with WalletConnectRelayClient {
  final ONGETSESSION getSessionInternal;

  WalletConnect(
      {super.relayUrl = WcConstans.relayUrl,
      required super.projectId,
      required this.metadata,
      required this.getSessionInternal});

  @override
  Future<SessionData?> getSession(String topic) async {
    return await getSessionInternal(topic);
  }

  final WcMetadata metadata;

  Future<void> pair(
      {required Uri uri,
      required ONSESSIONPROPOSEREQUEST onSessionPropose,
      Cancelable? cancelable}) async {
    final WcUriData parsedUri = WalletConnectUtils.parseUri(uri);
    final String topic = parsedUri.topic;
    final methods = parsedUri.methods.map(WalletConnectKnownMethods.fromName);
    if (methods.any((e) => e == WalletConnectKnownMethods.unregisteredMethod)) {
      throw WalletConnectExceptionConst.unsuportedMethod;
    }
    Duration? timeout = parsedUri.timeout();
    if (timeout == null) {
      throw WalletConnectExceptionConst.pairingRequestTimedout;
    }
    final WcPairingClient pairing = WcPairingClient(
        topic: topic, relay: parsedUri.relay, symkey: parsedUri.symkey);
    cancelable?.setup(() => pairing.completer);
    await _subscribe(topic: topic, keepTopics: false);
    _pendingClients[pairing.topic] = pairing;
    timeout = parsedUri.timeout();
    if (timeout == null) {
      throw WalletConnectExceptionConst.pairingRequestTimedout;
    }
    final proposalRequest = await () async {
      try {
        return await pairing.wait().timeout(timeout!,
            onTimeout: () =>
                throw WalletConnectExceptionConst.pairingRequestTimedout);
      } catch (e) {
        disconnectPair(pairing.topic);
        rethrow;
      }
    }();
    final pairRequest = proposalRequest.request;
    final response = await onSessionPropose(proposalRequest).catchError((e) {
      final error =
          PairResultError(error: WCSDKErrors.userRejected.toRpcError());
      sendResponse(request: pairRequest, response: error);
      throw e;
    });

    switch (response.type) {
      case SessionProposalResponseType.aprove:
        final approve = response.cast<SessionProposalAprove>();
        final protocol = approve.relayProtocol ?? WcConstans.relayProtocol;
        final relay = WcProtocolOptions(protocol: protocol);
        await sendResponse(
            request: pairRequest,
            response: PairResultSuccess(WcSessionProposeResult(
                    relay: relay, responderPublicKey: approve.publicKey)
                .toJson()));
        await _subscribe(topic: approve.session.topic);
        final settleRequest = WcSessionSettleRequest(
            relay: relay,
            namespaces: approve.session.namespaces,
            sessionProperties: approve.sessionProperties,
            expiry: WalletConnectUtils.defaultSessionExpire(),
            controller:
                WcProposer(publicKey: approve.publicKey, metadata: metadata));
        final sendParams = SendSessionRequestParams(
            params: settleRequest,
            topic: approve.session.topic,
            session: approve.session);
        _sendRequest(sendParams).catchError((e) => null);
      case SessionProposalResponseType.reject:
        final error = response.cast<SessionProposalReject>().exception;
        sendResponse(
            request: pairRequest,
            response:
                PairResultError(error: WalletConnectErrors.findError(error)));
        throw error;
    }
  }

  Future<void> updateSession(SessionData session) async {
    final updateRequest =
        WcSessionUpdateRequest(namespaces: session.namespaces);
    final sendParams = SendSessionRequestParams(
        params: updateRequest, topic: session.topic, session: session);
    await _sendRequest(sendParams, waitForResult: false);
  }

  Future<void> deleteSession(SessionData session) async {
    final error = WCSDKErrors.userDisconnected;
    final deleteRequest =
        WcPairingDeleteRequest(code: error.code, message: error.message);
    final sendParams = SendSessionRequestParams(
        params: deleteRequest, topic: session.topic, session: session);
    await _sendRequest(sendParams, waitForResult: false);
  }

  Future<void> emitSessionEvent(
      {required String topic,
      required List<List<WcSessionEventRequest>> events,
      required SessionData session}) async {
    for (final i in events) {
      for (final event in i) {
        if (session.namespaces.chainApproved(event.chainId)) {
          // _sendRequest(
          //     SendSessionRequestParams(
          //         params: event, topic: topic, session: session),
          //     waitForResult: false);
        }
      }
    }
  }
}
