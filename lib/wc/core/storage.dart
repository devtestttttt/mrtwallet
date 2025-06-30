part of 'package:on_chain_wallet/wc/wc.dart';

class WalletConnectStorage with NativeSecureStorageImpl, StreamStateController {
  static const String _sessionKey = "sessions_";
  static const String _messageKey = "msg_";
  @override
  final String storageId;
  final _lock = SynchronizedLock();
  bool _isReady = false;
  Map<String, SessionData> _activeSessions = {};
  Map<int, PublishRequest> _pendingMessage = {};

  WalletConnectStorage(this.storageId);

  String _getAppKey(String topic) {
    return _sessionKey + topic;
  }

  String _getMessagekey(int id) {
    return _messageKey + id.toString();
  }

  SessionData? getSession({String? topic, String? peerKey}) {
    if (topic != null) {
      return _activeSessions[topic];
    } else if (peerKey != null) {
      return _activeSessions.values
          .firstWhereNullable((e) => e.peerKey == peerKey);
    }
    return null;
  }

  Future<void> _deletePendingMessage(int id) async {
    final String key = _getMessagekey(id);
    await delete(key);
    _pendingMessage.remove(id);
  }

  Future<void> _savePendingMessage(PublishRequest message) async {
    final String key = _getMessagekey(message.correlationId);

    _pendingMessage[message.correlationId] = message;
    await write(key: key, value: message.toCbor().toCborHex());
  }

  Future<void> setPendingMessage(WcInternalPublishMessageEvent event) async {
    await _lock.synchronized(() async {
      final id = event.request.correlationId;
      final status = event.status;
      if (!status.isPending) {
        await _deletePendingMessage(id);
        return;
      }
      if (_pendingMessage.containsKey(id)) return;
      await _savePendingMessage(event.request);
    });
  }

  List<PublishRequest> getPendingMessages() {
    return _pendingMessage.values.where((e) => !e.isExpired()).toList();
  }

  Future<void> setSession(SessionData session) async {
    final String key = _getAppKey(session.topic);
    session = session.copyWith(latestAction: DateTime.now());
    await write(key: key, value: session.toCbor().toCborHex());
    _activeSessions[session.topic] = session;
    notify();
  }

  Future<void> deleteSesshins() async {
    await deleteAll(identifier: _sessionKey);
    _activeSessions.clear();
    notify();
  }

  Future<void> deleteSession(String topic) async {
    final String key = _getAppKey(topic);
    await delete(key);
    _activeSessions.remove(topic);
    notify();
  }

  List<SessionData> getActiveSessions() {
    final sessions = _activeSessions.values.where((e) => !e.isExpired).toList();
    sessions.sort((a, b) => b.latestAction.compareTo(a.latestAction));
    return sessions;
  }

  Future<Map<String, SessionData>> _initSessions() async {
    final data = await readAll(identifier: _sessionKey);
    final sessions =
        data.values.map((e) => SessionData.deserialize(hex: e)).toList();
    final expired = sessions.where((e) => e.isExpired).toList();
    final active = sessions.where((e) => !e.isExpired).toList();
    deleteMultiple(expired.map((e) => _getAppKey(e.topic)).toList());
    return {for (final i in active) i.topic: i};
  }

  Future<Map<int, PublishRequest>> _getPendingMessage() async {
    final data = await readAll(identifier: _messageKey);
    final sessions =
        data.values.map((e) => PublishRequest.deserialize(hex: e)).toList();
    final expired = sessions.where((e) => e.isExpired()).toList();
    final active = sessions.where((e) => !e.isExpired()).toList();
    deleteMultiple(
        expired.map((e) => _getMessagekey(e.correlationId)).toList());
    return {for (final i in active) i.correlationId: i};
  }

  Future<void> init() async {
    await _lock.synchronized(() async {
      if (_isReady) return;
      _activeSessions = await _initSessions();
      _pendingMessage = await _getPendingMessage();
      notify();
      _isReady = true;
    });
  }

  Future<void> close() async {
    await _lock.synchronized(() async {
      _activeSessions.clear();
      _pendingMessage.clear();
      _isReady = false;
      dispose();
    });
  }
}
