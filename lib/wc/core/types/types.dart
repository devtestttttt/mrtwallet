import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/exception/exception.dart';
import 'exception.dart';

class WcMetadata with CborSerializable {
  final String name;
  final String description;
  final String url;
  final List<String> icons;
  final String? verifyUrl;
  final WcRedirect? redirect;
  const WcMetadata(
      {required this.name,
      required this.description,
      required this.url,
      required this.icons,
      this.verifyUrl,
      this.redirect});
  factory WcMetadata.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.wcMetadata);
    return WcMetadata(
        name: values.elementAs(0),
        description: values.elementAs(1),
        url: values.elementAs(2),
        icons: values
            .elementAsListOf<CborStringValue>(3)
            .map((e) => e.value)
            .toList(),
        verifyUrl: values.elementAs(4),
        redirect: values.elemetMybeAs<WcRedirect, CborTagValue>(
            5, (c) => WcRedirect.deserialize(obj: c)));
  }
  factory WcMetadata.fromJson(Map<String, dynamic> json) {
    return WcMetadata(
      name: json['name'],
      description: json['description'],
      url: json['url'],
      icons: List<String>.from(json['icons'] ?? []),
      verifyUrl: json['verifyUrl'],
      redirect: json['redirect'] != null
          ? WcRedirect.fromJson(json['redirect'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'url': url,
      'icons': icons,
      'verifyUrl': verifyUrl,
      'redirect': redirect?.toJson(),
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          name,
          description,
          url,
          CborListValue.fixedLength(icons),
          verifyUrl,
          redirect?.toCbor()
        ]),
        CborTagsConst.wcMetadata);
  }
}

class WcRedirect with CborSerializable {
  final String? native;
  final String? universal;
  final bool? linkMode;
  const WcRedirect(
      {required this.native, required this.universal, required this.linkMode});
  factory WcRedirect.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.wcRedirect);
    return WcRedirect(
        native: values.elementAs(0),
        universal: values.elementAs(1),
        linkMode: values.elementAs(2));
  }
  factory WcRedirect.fromJson(Map<String, dynamic> json) {
    return WcRedirect(
      native: json['native'],
      universal: json['universal'],
      linkMode: json['linkMode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'native': native,
      'universal': universal,
      'linkMode': linkMode,
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([native, universal, linkMode]),
        CborTagsConst.wcRedirect);
  }
}

class WCChainNamespace with Equatable, CborSerializable {
  final String identifier;
  final WCNamespace namespace;
  const WCChainNamespace({required this.identifier, required this.namespace});
  factory WCChainNamespace.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.wcChainNamespace);
    return WCChainNamespace(
        identifier: values.elementAs(0),
        namespace:
            WCNamespace.deserialize(obj: values.elementAs<CborTagValue>(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([identifier, namespace.toCbor()]),
        CborTagsConst.wcChainNamespace);
  }

  @override
  List get variabels => [identifier, namespace];

  Map<String, dynamic> toJson() {
    return {identifier: namespace.toJson()};
  }
}

class WCSessionNamespaces with Equatable, CborSerializable {
  final List<WCChainNamespace> namespaces;
  WCSessionNamespaces._(List<WCChainNamespace> namespaces)
      : namespaces = namespaces.immutable;
  factory WCSessionNamespaces(List<WCChainNamespace> namespaces,
      {bool allowEmptyAccount = false}) {
    namespaces = namespaces.clone();
    if (!allowEmptyAccount) {
      // namespaces = namespaces
      //     .map((e) => WCChainNamespace(
      //           identifier: e.identifier,
      //           namespace: WCNamespace(
      //               chains: e.namespace.chains
      //                   .where((i) =>
      //                       e.namespace.accounts.any((e) => e.startsWith(i)))
      //                   .toList(),
      //               methods: e.namespace.methods,
      //               events: e.namespace.events,
      //               accounts: e.namespace.accounts),
      //         ))
      //     .toList();
      namespaces =
          namespaces.where((e) => e.namespace.accounts.isNotEmpty).toList();
    }
    namespaces.sort((a, b) => a.identifier.compareTo(b.identifier));
    return WCSessionNamespaces._(namespaces);
  }
  factory WCSessionNamespaces.fromJson(Map<String, dynamic> json,
      {bool allowEmptyAccount = false}) {
    final keys = json.keys.toList();
    final namespaces = keys
        .map((e) => WCChainNamespace(
            identifier: e, namespace: WCNamespace.fromJson(json[e])))
        .toList();
    return WCSessionNamespaces(namespaces,
        allowEmptyAccount: allowEmptyAccount);
  }
  factory WCSessionNamespaces.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.wcSessionNamespace);
    return WCSessionNamespaces._(values
        .elementAsListOf<CborTagValue>(0)
        .map((e) => WCChainNamespace.deserialize(obj: e))
        .toList());
  }

  Set<String> get chainIds =>
      namespaces.expand<String>((e) => e.namespace.chains).toSet();

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(namespaces.map((e) => e.toCbor()).toList()),
        ]),
        CborTagsConst.wcSessionNamespace);
  }

  Map<String, dynamic> toJson() {
    return {
      for (final i in namespaces) i.identifier: i.namespace.toJson(),
    };
  }

  bool chainApproved(String chainId) {
    return namespaces.any((e) =>
        (e.namespace.chains.contains(chainId)) &&
        e.namespace.accounts.isNotEmpty);
  }

  bool allowNamespace(WCSessionNamespaces other) {
    for (final i in other.namespaces) {
      final namspace =
          namespaces.firstWhereOrNull((e) => e.identifier == i.identifier);
      if (namspace == null) return false;
      if (!i.namespace.methods
          .every((e) => namspace.namespace.methods.contains(e))) {
        return false;
      }
      if (!i.namespace.events
          .every((e) => namspace.namespace.events.contains(e))) {
        return false;
      }
      final otherChains = i.namespace.chains;
      final chains = namspace.namespace.chains;
      if (!otherChains.every((e) => chains.contains(e))) {
        return false;
      }
    }
    return true;
  }

  WCSessionNamespaces allowedNamespace(WCSessionNamespaces other) {
    List<WCChainNamespace> allowedNamespace = [];
    for (final i in other.namespaces) {
      final namspace =
          namespaces.firstWhereOrNull((e) => e.identifier == i.identifier);
      if (namspace == null) continue;
      final methods = i.namespace.methods
          .where((e) => namspace.namespace.methods.contains(e))
          .toList();
      final events = i.namespace.events
          .where((e) => namspace.namespace.events.contains(e))
          .toList();
      final chains = i.namespace.chains
          .where((e) => namspace.namespace.chains.contains(e))
          .toList();
      final namespace = WCChainNamespace(
          identifier: namspace.identifier,
          namespace:
              WCNamespace(chains: chains, methods: methods, events: events));
      allowedNamespace.add(namespace);
    }
    return WCSessionNamespaces(allowedNamespace, allowEmptyAccount: true);
  }

  @override
  List get variabels => [namespaces];
}

class WCNamespace with Equatable, CborSerializable {
  final List<String> chains;
  final List<String> accounts;
  final List<String> methods;
  final List<String> events;
  factory WCNamespace.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.wcNamespace);
    return WCNamespace(
        chains: values
            .elementAsListOf<CborStringValue>(0)
            .map((e) => e.value)
            .toList(),
        accounts: values
            .elementAsListOf<CborStringValue>(1)
            .map((e) => e.value)
            .toList(),
        methods: values
            .elementAsListOf<CborStringValue>(2)
            .map((e) => e.value)
            .toList(),
        events: values
            .elementAsListOf<CborStringValue>(3)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(chains),
          CborListValue.fixedLength(accounts),
          CborListValue.fixedLength(methods),
          CborListValue.fixedLength(events),
        ]),
        CborTagsConst.wcNamespace);
  }

  const WCNamespace._(
      {required this.chains,
      required this.accounts,
      required this.methods,
      required this.events});
  factory WCNamespace(
      {required List<String> chains,
      List<String> accounts = const [],
      required List<String> methods,
      required List<String> events}) {
    accounts = accounts.toSet().toList()..sort();
    chains = chains.toSet().toList()..sort();
    methods = methods.toSet().toList()..sort();
    events = events.toSet().toList()..sort();
    return WCNamespace._(
        accounts: accounts, methods: methods, events: events, chains: chains);
  }

  WCNamespace copyWith({
    List<String>? chains,
    List<String>? accounts,
    List<String>? methods,
    List<String>? events,
  }) {
    return WCNamespace(
      chains: chains ?? this.chains,
      accounts: accounts ?? this.accounts,
      methods: methods ?? this.methods,
      events: events ?? this.events,
    );
  }

  factory WCNamespace.fromJson(Map<String, dynamic> json) {
    return WCNamespace(
      chains: (json['chains'] as List?)?.toList().cast() ?? [],
      accounts: (json['accounts'] as List?)?.toList().cast() ?? [],
      methods: (json['methods'] as List).toList().cast(),
      events: (json['events'] as List).toList().cast(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chains': chains,
      'accounts': accounts,
      'methods': methods,
      'events': events,
    };
  }

  @override
  List get variabels => [chains, accounts, methods, events];
}

class SessionData with CborSerializable {
  final String symkey;
  final String pairTopic;
  String get peerKey => peer.publicKey;
  final String topic;
  final WcProtocolOptions relay;
  final WCSessionNamespaces namespaces;
  final WCSessionNamespaces requiredNamespaces;
  final WCSessionNamespaces optionalNamespaces;
  final WcProposer peer;
  final TransportType transportType;
  final bool isActive;
  final DateTime expireTime;
  final DateTime latestAction;
  bool get isExpired => expireTime.isBefore(DateTime.now());
  factory SessionData.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.wcNamespace);
    return SessionData(
        symkey: values.elementAs(0),
        topic: values.elementAs(1),
        relay: WcProtocolOptions.deserialize(
            obj: values.elementAs<CborTagValue>(2)),
        namespaces: WCSessionNamespaces.deserialize(
            obj: values.elementAs<CborTagValue>(3)),
        peer: WcProposer.deserialize(obj: values.elementAs<CborTagValue>(4)),
        transportType: TransportType.fromTag(values.elementAs(5)),
        isActive: values.elementAs(6),
        expireTime: values.elementAs(7),
        pairTopic: values.elementAs(8),
        latestAction: values.elementAs(9),
        requiredNamespaces: WCSessionNamespaces.deserialize(
            obj: values.elementAs<CborTagValue>(10)),
        optionalNamespaces: WCSessionNamespaces.deserialize(
            obj: values.elementAs<CborTagValue>(11)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          symkey,
          topic,
          relay.toCbor(),
          namespaces.toCbor(),
          peer.toCbor(),
          transportType.value,
          isActive,
          expireTime,
          pairTopic,
          latestAction,
          requiredNamespaces.toCbor(),
          optionalNamespaces.toCbor()
        ]),
        CborTagsConst.wcNamespace);
  }

  SessionData({
    required this.pairTopic,
    required this.topic,
    required this.relay,
    required this.namespaces,
    required this.peer,
    required this.symkey,
    required this.requiredNamespaces,
    required this.optionalNamespaces,
    this.isActive = false,
    required this.expireTime,
    DateTime? latestAction,
    this.transportType = TransportType.relay,
  }) : latestAction = latestAction ?? DateTime.now();

  SessionData copyWith({
    String? topic,
    WcProtocolOptions? relay,
    WCSessionNamespaces? namespaces,
    WcProposer? peer,
    Map<String, String>? sessionProperties,
    TransportType? transportType,
    String? symkey,
    bool? isActive,
    DateTime? expireTime,
    String? pairTopic,
    DateTime? latestAction,
  }) {
    return SessionData(
        topic: topic ?? this.topic,
        relay: relay ?? this.relay,
        namespaces: namespaces ?? this.namespaces,
        peer: peer ?? this.peer,
        transportType: transportType ?? this.transportType,
        symkey: symkey ?? this.symkey,
        isActive: isActive ?? this.isActive,
        expireTime: expireTime ?? this.expireTime,
        pairTopic: pairTopic ?? this.pairTopic,
        latestAction: latestAction ?? this.latestAction,
        requiredNamespaces: requiredNamespaces,
        optionalNamespaces: optionalNamespaces);
  }
}

class SessionRequest {
  final PairMessageRequest pairRequest;
  int get id => pairRequest.message.id;
  String get topic => pairRequest.topic;
  final WcSessionRequest request;
  final DAPPVerifyStatus verifyStatus;
  final TransportType transportType;
  final SessionData session;

  Duration? timout() {
    return request.timeout() ?? pairRequest.timeout();
  }

  const SessionRequest(
      {required this.pairRequest,
      required this.request,
      required this.session,
      this.verifyStatus = DAPPVerifyStatus.unknown,
      this.transportType = TransportType.relay});
}

enum SessionProposalResponseType { aprove, reject }

abstract final class SessionProposalResponse {
  final WcSessionProposalRequest request;
  final SessionProposalResponseType type;
  const SessionProposalResponse({required this.request, required this.type});

  T cast<T extends SessionProposalResponse>() {
    if (this is! T) {
      throw WalletConnectExceptionConst.internalError;
    }
    return this as T;
  }
}

final class SessionProposalAprove extends SessionProposalResponse {
  final String publicKey;
  final SessionData session;
  final Map<String, String>? sessionProperties;
  final String? relayProtocol;
  SessionProposalAprove(
      {required super.request,
      required this.publicKey,
      required this.session,
      this.sessionProperties,
      this.relayProtocol})
      : super(type: SessionProposalResponseType.aprove);
}

final class SessionProposalReject extends SessionProposalResponse {
  final Web3RequestException exception;
  const SessionProposalReject({required super.request, required this.exception})
      : super(type: SessionProposalResponseType.reject);
}

enum DAPPVerifyStatus {
  safe,
  unknown,
  scam;
}

class SessionEventRequest {
  final WcSessionEventRequest event;
  final SessionData session;
  const SessionEventRequest({required this.event, required this.session});
}

class SessionEventResponse {
  final WcSessionEventEvnet response;
  final SessionEventRequest request;
  const SessionEventResponse({required this.response, required this.request});
}

enum TransportType {
  relay(0),
  linkMode(1);

  final int value;
  const TransportType(this.value);

  bool get isLinkMode => this == linkMode;
  bool get isRelay => this == relay;
  static TransportType fromTag(int? tag) {
    return values.firstWhere(
      (e) => e.value == tag,
      orElse: () => throw WalletConnectExceptionConst.internalError,
    );
  }
}

enum ProtocolType {
  pair,
  sign,
}

class WcPairingClient {
  final String topic;
  final WcProtocolOptions relay;
  final WcMetadata? peerMetadata;
  final String? symkey;
  final Completer<WcSessionProposalRequest> completer = Completer();
  WcPairingClient(
      {required this.topic,
      required this.relay,
      required this.symkey,
      this.peerMetadata});

  Future<WcSessionProposalRequest> wait() {
    return completer.future;
  }

  void complete(WcSessionProposalRequest request) {
    assert(!completer.isCompleted);
    if (completer.isCompleted) return;
    completer.complete(request);
  }

  void cancel(WalletConnectException exception) {
    assert(!completer.isCompleted);
    if (completer.isCompleted) return;
    completer.completeError(exception);
  }
}

enum RelayClientMessageTypes {
  type0(0),
  type1(1),
  type2(2);

  final int tag;
  const RelayClientMessageTypes(this.tag);
  static RelayClientMessageTypes fromTag(int? tag) {
    return values.firstWhere((e) => e.tag == tag,
        orElse: () => throw WalletConnectExceptionConst.internalError);
  }
}

class RelayClientEncryptedMessage {
  final List<int> sealed;
  final List<int> nonce;
  final List<int>? senderPublicKey;
  final RelayClientMessageTypes type;

  String serialize() {
    List<int> serializeBytes;
    switch (type) {
      case RelayClientMessageTypes.type0:
        serializeBytes = [type.tag, ...nonce, ...sealed];
        break;
      case RelayClientMessageTypes.type1:
        if (senderPublicKey == null) {
          throw WalletConnectException(
              'Missing sender public key for type 1 envlope.');
        }
        serializeBytes = [type.tag, ...senderPublicKey!, ...nonce, ...sealed];
        break;
      case RelayClientMessageTypes.type2:
        serializeBytes = [type.tag, ...sealed];
        break;
    }
    return StringUtils.decode(serializeBytes, type: StringEncoding.base64);
  }

  RelayClientEncryptedMessage(
      {required this.type,
      required List<int> sealed,
      required List<int> nonce,
      List<int>? publickKey})
      : sealed = sealed.asImmutableBytes,
        nonce = nonce.asImmutableBytes,
        senderPublicKey = publickKey?.asImmutableBytes;
  factory RelayClientEncryptedMessage.deserialize(String b64) {
    final decode = StringUtils.encode(b64,
        validateB64Padding: false, type: StringEncoding.base64);
    final type = RelayClientMessageTypes.fromTag(decode.elementAtOrNull(0));
    switch (type) {
      case RelayClientMessageTypes.type0:
        return RelayClientEncryptedMessage(
            sealed: decode.sublist(WalletConnectConst.messageTypeLength +
                WalletConnectConst.nonceLength),
            nonce: decode.sublist(
                WalletConnectConst.messageTypeLength,
                WalletConnectConst.messageTypeLength +
                    WalletConnectConst.nonceLength),
            type: type);
      case RelayClientMessageTypes.type2:
        return RelayClientEncryptedMessage(
            publickKey: null,
            nonce: QuickCrypto.generateRandom(WalletConnectConst.nonceLength),
            sealed: decode.sublist(WalletConnectConst.messageTypeLength),
            type: type);
      case RelayClientMessageTypes.type1:
        final publickKey = decode.sublist(
            WalletConnectConst.messageTypeLength,
            Ed25519KeysConst.pubKeyByteLen +
                WalletConnectConst.messageTypeLength);
        return RelayClientEncryptedMessage(
            publickKey: publickKey,
            nonce: decode.sublist(
                Ed25519KeysConst.pubKeyByteLen +
                    WalletConnectConst.messageTypeLength,
                Ed25519KeysConst.pubKeyByteLen +
                    WalletConnectConst.messageTypeLength +
                    WalletConnectConst.nonceLength),
            sealed: decode.sublist(
              Ed25519KeysConst.pubKeyByteLen +
                  WalletConnectConst.messageTypeLength +
                  WalletConnectConst.nonceLength,
            ),
            type: type);
      // case RelayClientMessageTypes.type2:
      //   final publickKey = decode.sublist(
      //       WalletConnectConst.messageTypeLength,
      //       Ed25519KeysConst.pubKeyByteLen +
      //           WalletConnectConst.messageTypeLength);
      //   return RelayClientEncryptedMessage(
      //       messageBytes: decode.sublist(Ed25519KeysConst.pubKeyByteLen +
      //           WalletConnectConst.messageTypeLength),
      //       nonce: QuickCrypto.generateRandom(WalletConnectConst.nonceLength),
      //       publickKey: publickKey,
      //       type: type);
    }
  }
}

class WalletConnectMethodParams {
  final int ttl;
  final int tag;
  final bool prompt;
  static const int defaultTll = 24 * 60 * 60 * 6;
  static const int defaultTag = 24 * 60 * 60 * 6;
  const WalletConnectMethodParams(
      {required this.ttl, required this.tag, required this.prompt});
}

enum WalletConnectKnownMethods {
  pairingPing(
      method: 'wc_pairingPing',
      requestParam:
          WalletConnectMethodParams(ttl: 30, tag: 1002, prompt: false),
      responseParam:
          WalletConnectMethodParams(ttl: 30, tag: 1003, prompt: false)),
  pairingDelete(
      method: 'wc_pairingDelete',
      requestParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1000, prompt: false),
      responseParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1001, prompt: false)),
  unregisteredMethod(
      method: 'unregistered_method',
      requestParam:
          WalletConnectMethodParams(ttl: 24 * 60 * 60, tag: 0, prompt: false),
      responseParam:
          WalletConnectMethodParams(ttl: 24 * 60 * 60, tag: 0, prompt: false)),

  sessionPropose(
      method: 'wc_sessionPropose',
      requestParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1100, prompt: true),
      responseParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1101, prompt: false),
      reject: WalletConnectMethodParams(ttl: 5 * 60, tag: 1120, prompt: false),
      autoReject:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1121, prompt: false)),
  sessionUpdate(
      method: 'wc_sessionUpdate',
      requestParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1104, prompt: false),
      responseParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1105, prompt: false),
      allowReceive: false),
  sessionExtend(
      method: 'wc_sessionExtend',
      requestParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1106, prompt: false),
      responseParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1107, prompt: false),
      allowReceive: false),
  sessionRequest(
      method: 'wc_sessionRequest',
      requestParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1108, prompt: true),
      responseParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1109, prompt: false)),
  sessionEvent(
      method: 'wc_sessionEvent',
      requestParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1110, prompt: true),
      responseParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1111, prompt: false)),
  sessionDelete(
      method: 'wc_sessionDelete',
      requestParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1112, prompt: false),
      responseParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1113, prompt: false)),
  sessionPing(
      method: 'wc_sessionPing',
      requestParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1114, prompt: false),
      responseParam: WalletConnectMethodParams(
          ttl: 24 * 60 * 60, tag: 1115, prompt: false)),
  sessionSettle(
      method: 'wc_sessionSettle',
      requestParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1102, prompt: false),
      responseParam:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1103, prompt: false),
      allowReceive: false),
  sessionAuthenticate(
      method: 'wc_sessionAuthenticate',
      requestParam:
          WalletConnectMethodParams(ttl: 60 * 60, tag: 1116, prompt: true),
      responseParam:
          WalletConnectMethodParams(ttl: 60 * 60, tag: 1117, prompt: false),
      reject: WalletConnectMethodParams(ttl: 5 * 60, tag: 1118, prompt: false),
      autoReject:
          WalletConnectMethodParams(ttl: 5 * 60, tag: 1119, prompt: false),
      allowReceive: false);

  static WalletConnectKnownMethods fromName(String name) {
    return values.firstWhere(
      (e) => e.method == name,
      orElse: () => WalletConnectKnownMethods.unregisteredMethod,
    );
  }

  final String method;
  final WalletConnectMethodParams requestParam;
  final WalletConnectMethodParams responseParam;
  final WalletConnectMethodParams? reject;
  final WalletConnectMethodParams? autoReject;
  final bool allowReceive;
  const WalletConnectKnownMethods(
      {required this.method,
      required this.requestParam,
      required this.responseParam,
      this.allowReceive = true,
      this.reject,
      this.autoReject});
}

class WcUriData {
  final String protocol;
  final String topic;
  final List<String> methods;
  final String symkey;
  final DateTime expire;
  final WcProtocolOptions relay;

  Duration? timeout() {
    final n =
        expire.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    if (n <= 0) return null;
    return Duration(milliseconds: n);
  }

  const WcUriData({
    required this.protocol,
    required this.topic,
    required this.methods,
    required this.symkey,
    required this.expire,
    required this.relay,
  });
}

enum RelayClientResponseType {
  error,
  request,
  subscribe,
  connect,
  disconnect;
}

abstract class RelayClientResponse {
  final RelayClientResponseType type;
  const RelayClientResponse({required this.type});
  factory RelayClientResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("error")) {
      return RelayClientErrorResponse.fromJson(json);
    } else if (json.containsKey("params")) {
      return RelayClientSubscribeResponse.fromJson(json);
    }
    return RelayClientRequestResponse.fromJson(json);
  }
}

class RelayClientConnectResponse extends RelayClientResponse {
  const RelayClientConnectResponse()
      : super(type: RelayClientResponseType.connect);
}

class RelayClientDisconnectResponse extends RelayClientResponse {
  const RelayClientDisconnectResponse()
      : super(type: RelayClientResponseType.disconnect);
}

class RelayClientSubscribeResponse extends RelayClientResponse with Equatable {
  final String topic;
  final String message;
  final int id;
  final String? method;
  final DateTime? publishedAt;
  const RelayClientSubscribeResponse(
      {required this.topic,
      required this.message,
      required this.id,
      required this.method,
      required this.publishedAt})
      : super(type: RelayClientResponseType.subscribe);
  factory RelayClientSubscribeResponse.fromJson(Map<String, dynamic> json) {
    return RelayClientSubscribeResponse(
        topic: json["params"]["data"]["topic"],
        message: json["params"]["data"]["message"],
        id: json["id"],
        method: json["method"],
        publishedAt: json["publishedAt"] == null
            ? null
            : DateTimeUtils.fromSecondsSinceEpoch(
                IntUtils.parse(json["publishedAt"])));
  }

  @override
  List get variabels => [topic, message];
}

class RelayClientRequestResponse extends RelayClientResponse {
  final dynamic result;
  final int id;
  final String? method;
  const RelayClientRequestResponse(
      {required this.result, required this.id, required this.method})
      : super(type: RelayClientResponseType.request);
  factory RelayClientRequestResponse.fromJson(Map<String, dynamic> json) {
    return RelayClientRequestResponse(
        result: json["result"], id: json["id"], method: json["method"]);
  }
}

class RelayClientErrorResponse extends RelayClientResponse {
  final int code;
  final String message;
  final int id;
  final String? method;
  const RelayClientErrorResponse(
      {required this.code,
      required this.message,
      required this.id,
      required this.method})
      : super(type: RelayClientResponseType.error);
  factory RelayClientErrorResponse.fromJson(Map<String, dynamic> json) {
    return RelayClientErrorResponse(
        code: json["error"]["code"],
        id: json["id"],
        message: json["error"]["message"],
        method: json["method"]);
  }
}

class LinkModeOptions {
  final int tag;

  LinkModeOptions({required this.tag});

  factory LinkModeOptions.fromJson(Map<String, dynamic> json) {
    return LinkModeOptions(
      tag: json['tag'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
    };
  }
}

class WalletConnectErrors {
  static WcJsonRpcErrorResponse findError(Web3RequestException error) {
    return switch (error) {
      Web3RequestExceptionConst.rejectedByUser =>
        WcJsonRpcErrorResponse(code: 5000, message: 'User Rejected.'),
      _ => WcJsonRpcErrorResponse(code: -1, message: "Unknown error")
    };
  }
}

enum WCSDKErrors {
  invalidMethod("Invalid method.", 1001),
  userDisconnected("User disconnected.", 6000),
  unsuportedWcMethod("Unsuported wc method.", 10001),
  userRejected("User rejected.", 5000),
  unauthorizedMethod("Unauthorized method. ", 3001),
  userRejectedMethods("User rejected methods. ", 5002),
  userRejectedChains("User rejected chains. ", 5001),
  unsuportedMethod("Unsuported method. ", 5101),
  unsuportedChains("Unsuported chains. ", 5100),
  noMatchingKey("No matching key. ", 2);

  final String message;
  final int code;
  const WCSDKErrors(this.message, this.code);

  Map<String, dynamic> toJson() {
    return {"message": message, "code": code};
  }

  WcJsonRpcErrorResponse toRpcError() {
    return WcJsonRpcErrorResponse(code: code, message: message);
  }
}

class WcConstans {
  static const String relayUrl = "wss://relay.walletconnect.org";
  static const String relayProtocol = "irn";
  static const Duration clientPrediocEvent = Duration(seconds: 20);
}

class PublishRequest with CborSerializable {
  // final PairMessageRequest request;
  final int id;
  final String topic;
  final String message;
  final int ttl;
  final int tag;
  final int correlationId;
  final DateTime expired;

  bool isExpired() {
    return expired.isBefore(DateTime.now());
  }

  Duration? timeout() {
    final n =
        expired.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    if (n <= 0) {
      return null;
    }
    return Duration(milliseconds: n);
  }

  Completer? _completer = Completer();
  bool get isComplete => _completer?.isCompleted ?? true;
  PublishRequest({
    required this.tag,
    required this.topic,
    required this.correlationId,
    required this.message,
    required this.ttl,
    required this.id,
  }) : expired = DateTime.now().add(Duration(seconds: ttl));

  factory PublishRequest.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.wcPendigMessage);
    return PublishRequest(
        message: values.elementAs(0),
        ttl: values.elementAs(1),
        topic: values.elementAs(2),
        tag: values.elementAs(3),
        correlationId: values.elementAs(4),
        id: values.elementAs(5));
  }
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'ttl': ttl,
      'topic': topic,
      'tag': tag,
      'correlationId': correlationId
    };
  }

  RelayClientRequest toPublishMessage() {
    return RelayClientRequest(
        method: WalletConnectRelayClientMethods.publish, params: toJson());
  }

  Future<dynamic>? wait() {
    return _completer?.future;
  }

  void success(dynamic data) {
    if (_completer?.isCompleted ?? true) return;
    _completer?.complete(data);
    _completer = null;
  }

  void expire() {
    if (_completer?.isCompleted ?? true) return;
    _completer
        ?.completeError(WalletConnectExceptionConst.publishMessageExpired);
    _completer = null;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [message, ttl, topic, tag, correlationId, id]),
        CborTagsConst.wcPendigMessage);
  }
}

enum WalletConnectRelayClientMethods {
  publish('publish'),
  subscription('subscription'),
  subscribe('subscribe'),
  unsubscribe('unsubscribe');

  final String method;
  const WalletConnectRelayClientMethods(this.method);

  String get withProtocol => "irn_$method";
}

class RelayClientRequest {
  final int id;
  final WalletConnectRelayClientMethods method;
  final dynamic params;
  const RelayClientRequest._(
      {required this.id, required this.method, required this.params});
  factory RelayClientRequest(
      {int? id,
      required WalletConnectRelayClientMethods method,
      required dynamic params}) {
    return RelayClientRequest._(
        id: id ?? DateTime.now().millisecondsSinceEpoch,
        method: method,
        params: params);
  }

  Map<String, dynamic> toJson() {
    return {
      "jsonrpc": "2.0",
      "method": method.withProtocol,
      if (params != null) "params": params,
      "id": id
    };
  }
}

abstract class PairMessage<T extends WcJsonRpcMessage> {
  final String topic;
  final TransportType trasportType;
  final SessionData? session;
  final DateTime? publishedAt;
  final DateTime expire;
  final T message;
  bool get isEpire => expire.isBefore(DateTime.now());

  Duration? timeout() {
    final now = DateTime.now();
    final n = expire.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    if (n <= 0) {
      return null;
    }
    return Duration(milliseconds: n);
  }

  WalletConnectKnownMethods? get method;
  const PairMessage(
      {required this.topic,
      required this.trasportType,
      required this.session,
      required this.publishedAt,
      required this.expire,
      required this.message});
  factory PairMessage.fromMessage(
      {required String topic,
      required WcJsonRpcMessage message,
      TransportType trasportType = TransportType.relay,
      SessionData? session,
      DateTime? publishedAt}) {
    final n = switch (message.messageType) {
      WcJsonRpcMessageType.request => PairMessageRequest(
          topic: topic,
          request: message.cast(),
          trasportType: trasportType,
          session: session,
          publishedAt: publishedAt),
      _ => PairMessageUnknown(
          topic: topic,
          request: message,
          trasportType: trasportType,
          publishedAt: publishedAt,
          session: session),
    };
    return n as PairMessage<T>;
  }
}

class PairMessageRequest extends PairMessage<WcJsonRpcRequest> {
  const PairMessageRequest._(
      {required super.topic,
      required super.message,
      required super.trasportType,
      required super.session,
      required super.publishedAt,
      required super.expire});
  factory PairMessageRequest({
    required String topic,
    required WcJsonRpcRequest request,
    required TransportType trasportType,
    SessionData? session,
    DateTime? publishedAt,
  }) {
    publishedAt ??= DateTime.now();
    final expire =
        publishedAt.add(Duration(seconds: request.method.requestParam.ttl));
    return PairMessageRequest._(
        topic: topic,
        message: request,
        trasportType: trasportType,
        session: session,
        publishedAt: publishedAt,
        expire: expire);
  }

  @override
  WalletConnectKnownMethods? get method => message.method;
}

class PairMessageUnknown extends PairMessage<WcJsonRpcMessage> {
  const PairMessageUnknown._(
      {required super.topic,
      required super.message,
      required super.trasportType,
      required super.session,
      required super.publishedAt,
      required super.expire,
      this.method});
  factory PairMessageUnknown({
    required String topic,
    required WcJsonRpcMessage request,
    required TransportType trasportType,
    SessionData? session,
    DateTime? publishedAt,
  }) {
    publishedAt ??= DateTime.now();
    WalletConnectKnownMethods? method;
    if (request.messageType == WcJsonRpcMessageType.unsuported) {
      method = request.cast<WcJsonRpcUnsuportedMethod>().method;
    }
    return PairMessageUnknown._(
        topic: topic,
        message: request,
        trasportType: trasportType,
        session: session,
        publishedAt: publishedAt,
        expire: DateTime.now(),
        method: method);
  }

  @override
  final WalletConnectKnownMethods? method;
}

abstract class PairResult {
  const PairResult();
  Map<String, dynamic> toJson(int id);
}

class PairResultSuccess extends PairResult {
  final dynamic result;
  const PairResultSuccess(this.result);
  @override
  Map<String, dynamic> toJson(int id) {
    return {"result": result, "id": id, "jsonrpc": "2.0"};
  }
}

class PairResultError extends PairResult {
  final WcJsonRpcErrorResponse error;
  const PairResultError({required this.error});
  @override
  Map<String, dynamic> toJson(int id) {
    return {'id': id, 'jsonrpc': '2.0', 'error': error.toJson()};
  }
}

class WalletConnectConst {
  static const int nonceLength = 12;
  static const int messageTypeLength = 1;
  static const Duration defaultRequestTimeout = Duration(minutes: 1);
}

class SendSessionRequestParams {
  final WcBaseSessionRequest params;
  final SessionData? session;
  final String topic;
  const SendSessionRequestParams(
      {required this.params, this.session, required this.topic});
  Map<String, dynamic> toJson({int? id}) {
    return {
      "method": params.method.method,
      "id": id ?? DateTime.now().microsecondsSinceEpoch,
      "params": params.toJson(),
      "jsonrpc": "2.0",
    };
  }
}

class WcProposer with CborSerializable {
  final String publicKey;
  final WcMetadata metadata;
  factory WcProposer.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: obj, tags: CborTagsConst.wcRelay);
    return WcProposer(
        publicKey: values.elementAs(0),
        metadata: WcMetadata.deserialize(obj: values.getCborTag(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([publicKey, metadata.toCbor()]),
        CborTagsConst.wcRelay);
  }

  const WcProposer({
    required this.publicKey,
    required this.metadata,
  });

  factory WcProposer.fromJson(Map<String, dynamic> json) {
    return WcProposer(
      publicKey: json['publicKey'],
      metadata: WcMetadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() => {
        'publicKey': publicKey,
        'metadata': metadata.toJson(),
      };
}

class WcProtocolOptions with CborSerializable {
  final String protocol;
  final String? data;

  const WcProtocolOptions({
    required this.protocol,
    this.data,
  });
  factory WcProtocolOptions.deserialize(
      {List<int>? bytes, String? hex, CborTagValue? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: obj, tags: CborTagsConst.wcRelay);
    return WcProtocolOptions(
        data: values.elementAs(0), protocol: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([data, protocol]), CborTagsConst.wcRelay);
  }

  factory WcProtocolOptions.fromJson(Map<String, dynamic> json) {
    return WcProtocolOptions(
      protocol: json['protocol'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'protocol': protocol,
        'data': data,
      }.withOutNullValue;
}

class WcProposalStruct {
  final DateTime? expiry;
  // final int? expiryTimestamp;
  final WcProposer proposer;
  final WCSessionNamespaces requiredNamespaces;
  final List<WcProtocolOptions> relays;
  final WCSessionNamespaces optionalNamespaces;
  final Map<String, String> sessionProperties;
  final Map<String, dynamic> scopedProperties;
  final String? pairingTopic;

  const WcProposalStruct({
    this.expiry,
    required this.proposer,
    required this.requiredNamespaces,
    required this.optionalNamespaces,
    required this.sessionProperties,
    required this.scopedProperties,
    required this.pairingTopic,
    required this.relays,
  });

  factory WcProposalStruct.fromJson(Map<String, dynamic> json) {
    final expire = IntUtils.tryParse(json['expiryTimestamp'] ?? json['expiry']);
    return WcProposalStruct(
      expiry: expire == null ? null : DateTimeUtils.detectEpochUnit(expire),
      proposer: WcProposer.fromJson(json['proposer']),
      relays: (json["relays"] as List?)
              ?.map((e) => WcProtocolOptions.fromJson(e))
              .toList() ??
          [],
      requiredNamespaces: WCSessionNamespaces.fromJson(
          json['requiredNamespaces'] ?? {},
          allowEmptyAccount: true),
      optionalNamespaces: WCSessionNamespaces.fromJson(
          json['optionalNamespaces'] ?? {},
          allowEmptyAccount: true),
      sessionProperties:
          Map<String, String>.from(json['sessionProperties'] ?? {}),
      scopedProperties:
          Map<String, dynamic>.from(json['scopedProperties'] ?? {}),
      pairingTopic: json['pairingTopic'],
    );
  }

  // Map<String, dynamic> toJson() => {
  //       if (expiry != null) 'expiry': expiry,
  //       'expiryTimestamp': expiryTimestamp,
  //       'proposer': proposer.toJson(),
  //       'requiredNamespaces': requiredNamespaces.toJson(),
  //       'optionalNamespaces': optionalNamespaces.toJson(),
  //       'sessionProperties': sessionProperties,
  //       'scopedProperties': scopedProperties,
  //       'pairingTopic': pairingTopic,
  //       "relays": relays.map((e) => e.toJson()).toList()
  //     };
}

/// request
class WcSessionProposalRequest {
  final int id;
  final WcProposalStruct params;
  final PairMessageRequest request;

  Duration? timeout() {
    final expiry = params.expiry ?? request.expire;
    final n =
        expiry.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    if (n.isNegative) return null;
    return Duration(milliseconds: n);
  }

  const WcSessionProposalRequest(
      {required this.request, required this.id, required this.params});
}

class WcPairingDeleteRequest extends WcBaseSessionRequest {
  final int code;
  final String message;

  const WcPairingDeleteRequest({
    required this.code,
    required this.message,
  }) : super(method: WalletConnectKnownMethods.sessionDelete);

  factory WcPairingDeleteRequest.fromJson(Map<String, dynamic> json) {
    return WcPairingDeleteRequest(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };
}

class WcSessionConfig {
  final bool? disableDeepLink;
  const WcSessionConfig({this.disableDeepLink});
  Map<String, dynamic> toJson() {
    return {"disableDeepLink": disableDeepLink};
  }
}

abstract class WcBaseSessionRequest {
  final WalletConnectKnownMethods method;
  const WcBaseSessionRequest({required this.method});
  Map<String, dynamic> toJson();
}

class WcSessionSettleRequest extends WcBaseSessionRequest {
  final WcProtocolOptions relay;
  final WCSessionNamespaces namespaces;
  final Map<String, String>? sessionProperties;
  final Map<String, dynamic>? scopedProperties;
  final WcSessionConfig? sessionConfig;
  final int expiry;
  final WcProposer controller;

  const WcSessionSettleRequest({
    required this.relay,
    required this.namespaces,
    this.sessionProperties,
    this.scopedProperties,
    this.sessionConfig,
    required this.expiry,
    required this.controller,
  }) : super(method: WalletConnectKnownMethods.sessionSettle);

  @override
  Map<String, dynamic> toJson() => {
        'relay': relay.toJson(),
        'namespaces': namespaces.toJson(),
        'sessionProperties': sessionProperties,
        'scopedProperties': scopedProperties,
        'sessionConfig': sessionConfig?.toJson(),
        'expiry': expiry,
        'controller': controller.toJson(),
      }.withOutNullValue;
}

class WcSessionUpdateRequest extends WcBaseSessionRequest {
  final WCSessionNamespaces namespaces;

  const WcSessionUpdateRequest({required this.namespaces})
      : super(method: WalletConnectKnownMethods.sessionUpdate);

  @override
  Map<String, dynamic> toJson() => {'namespaces': namespaces.toJson()};
}

class WcSessionRequestRequest {
  final String method;
  final dynamic params;
  final int? expiryTimestamp;

  const WcSessionRequestRequest({
    required this.method,
    required this.params,
    this.expiryTimestamp,
  });

  factory WcSessionRequestRequest.fromJson(Map<String, dynamic> json) {
    return WcSessionRequestRequest(
      method: json['method'],
      params: json['params'],
      expiryTimestamp: json['expiryTimestamp'],
    );
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'params': params,
        'expiryTimestamp': expiryTimestamp,
      }.withOutNullValue;
}

class WcSessionRequest {
  final WcSessionRequestRequest request;
  final String chainId;
  final DateTime? expire;

  const WcSessionRequest._(
      {required this.request, required this.chainId, this.expire});
  factory WcSessionRequest(
      {required WcSessionRequestRequest request, required String chainId}) {
    final expire = request.expiryTimestamp;
    return WcSessionRequest._(
        request: request,
        chainId: chainId,
        expire: expire == null ? null : DateTimeUtils.detectEpochUnit(expire));
  }

  factory WcSessionRequest.fromJson(Map<String, dynamic> json) {
    return WcSessionRequest(
      request: WcSessionRequestRequest.fromJson(json['request']),
      chainId: json['chainId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'request': request.toJson(),
        'chainId': chainId,
      };

  Duration? timeout() {
    final expire = this.expire;
    if (expire == null) return null;
    final now = DateTime.now();
    final n = expire.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    if (n <= 0) return null;
    return Duration(milliseconds: n);
  }
}

class WcSessionEventEvnet {
  final String name;
  final dynamic data;

  const WcSessionEventEvnet({
    required this.name,
    required this.data,
  });

  factory WcSessionEventEvnet.fromJson(Map<String, dynamic> json) {
    return WcSessionEventEvnet(
      name: json['name'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'data': data,
      };
}

class WcSessionEventRequest extends WcBaseSessionRequest {
  final WcSessionEventEvnet event;
  final String chainId;

  const WcSessionEventRequest({
    required this.event,
    required this.chainId,
  }) : super(method: WalletConnectKnownMethods.sessionEvent);

  factory WcSessionEventRequest.fromJson(Map<String, dynamic> json) {
    return WcSessionEventRequest(
      event: WcSessionEventEvnet.fromJson(json['event']),
      chainId: json['chainId'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'event': event.toJson(),
        'chainId': chainId,
      };
}

/// results
class WcSessionProposeResult {
  final WcProtocolOptions relay;
  final String responderPublicKey;

  const WcSessionProposeResult(
      {required this.relay, required this.responderPublicKey});

  factory WcSessionProposeResult.fromJson(Map<String, dynamic> json) {
    return WcSessionProposeResult(
      relay: WcProtocolOptions.fromJson(json['relay']),
      responderPublicKey: json['responderPublicKey'],
    );
  }

  Map<String, dynamic> toJson() => {
        'relay': relay.toJson(),
        'responderPublicKey': responderPublicKey,
      };
}

class WcJsonRpcErrorResponse {
  final int? code;
  final String? message;
  final dynamic data;

  const WcJsonRpcErrorResponse({
    required this.code,
    required this.message,
    this.data,
  });
  factory WcJsonRpcErrorResponse.invalidRequest(String message) {
    return WcJsonRpcErrorResponse(code: -32600, message: message);
  }
  factory WcJsonRpcErrorResponse.methodNotFound(String message) {
    return WcJsonRpcErrorResponse(code: -32601, message: message);
  }

  factory WcJsonRpcErrorResponse.fromJson(Map<String, dynamic> json) {
    return WcJsonRpcErrorResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'data': data,
      }.withOutNullValue;
}

enum WcJsonRpcMessageType { request, response, unsuported, unknwon }

abstract class WcJsonRpcMessage {
  final int id;
  final WcJsonRpcMessageType messageType;
  const WcJsonRpcMessage({required this.messageType, required this.id});
  T cast<T extends WcJsonRpcMessage>() {
    if (this is! T) throw WalletConnectExceptionConst.internalError;
    return this as T;
  }

  factory WcJsonRpcMessage.fromJson(Map<String, dynamic> json) {
    final int? id = IntUtils.tryParse(json["id"]);
    final bool hasMethod = json["method"] != null;
    final bool hasParams = json["params"] != null;
    final bool hasError = json["error"] != null;
    final bool hasResult = json["result"] != null;
    if (id == null) {
      return WcJsonRpcUnknown(id: DateTime.now().millisecondsSinceEpoch);
    }
    if (hasMethod && hasParams) {
      final request = WcJsonRpcRequest.fromJson(json);
      if (request.method == WalletConnectKnownMethods.unregisteredMethod ||
          !request.method.allowReceive) {
        return WcJsonRpcUnsuportedMethod(id: id, method: request.method);
      }
      return request;
    }
    if (hasError || hasResult) {
      return WcJsonRpcResponse.fromJson(json);
    }
    return WcJsonRpcUnknown(id: id);
  }
}

class WcJsonRpcUnknown extends WcJsonRpcMessage {
  const WcJsonRpcUnknown({required super.id})
      : super(messageType: WcJsonRpcMessageType.unknwon);
}

class WcJsonRpcUnsuportedMethod extends WcJsonRpcMessage {
  final WalletConnectKnownMethods method;
  const WcJsonRpcUnsuportedMethod({required super.id, required this.method})
      : super(messageType: WcJsonRpcMessageType.unsuported);
}

class WcJsonRpcRequest extends WcJsonRpcMessage {
  final dynamic params;
  final WalletConnectKnownMethods method;
  final String jsonrpc;
  const WcJsonRpcRequest(
      {required super.id,
      required this.params,
      required this.method,
      required this.jsonrpc})
      : super(messageType: WcJsonRpcMessageType.request);
  factory WcJsonRpcRequest.fromJson(Map<String, dynamic> json) {
    return WcJsonRpcRequest(
        id: json["id"],
        params: json["params"],
        method: WalletConnectKnownMethods.fromName(json['method']),
        jsonrpc: json["jsonrpc"] ?? "2.0");
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "params": params,
      "method": method.method,
      "jsonrpc": jsonrpc
    };
  }
}

class WcJsonRpcResult extends WcJsonRpcResponse {
  final dynamic result;
  const WcJsonRpcResult({
    required super.id,
    super.jsonrpc = "2.0",
    required this.result,
  }) : super(type: WcJsonRpcResponseType.result);

  factory WcJsonRpcResult.fromJson(Map<String, dynamic> json) {
    return WcJsonRpcResult(
      id: json['id'],
      jsonrpc: json['jsonrpc'],
      result: json['result'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'jsonrpc': jsonrpc,
        'result': result,
      };

  @override
  PairResult toPairResult() {
    return PairResultSuccess(result);
  }
}

class WcJsonRpcError extends WcJsonRpcResponse {
  final WcJsonRpcErrorResponse error;
  const WcJsonRpcError({
    required super.id,
    super.jsonrpc = "2.0",
    required this.error,
  }) : super(type: WcJsonRpcResponseType.error);

  factory WcJsonRpcError.fromJson(Map<String, dynamic> json) {
    return WcJsonRpcError(
      id: json['id'],
      jsonrpc: json['jsonrpc'],
      error: WcJsonRpcErrorResponse.fromJson(json["error"]),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'jsonrpc': jsonrpc,
        'error': error.toJson(),
      };

  @override
  PairResult toPairResult() {
    return PairResultError(error: error);
  }
}

enum WcJsonRpcResponseType { error, result }

abstract class WcJsonRpcResponse extends WcJsonRpcMessage {
  final String jsonrpc;
  final WcJsonRpcResponseType type;
  const WcJsonRpcResponse(
      {required super.id, required this.jsonrpc, required this.type})
      : super(messageType: WcJsonRpcMessageType.response);
  factory WcJsonRpcResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("error")) {
      return WcJsonRpcError.fromJson(json);
    }
    return WcJsonRpcResult.fromJson(json);
  }
  Map<String, dynamic> toJson();

  PairResult toPairResult();
}

enum WcInternalEventType {
  connect,
  disconnect,
  pairDelete,
  sessionDelete,
  request,
  event,
  publishMessage
}

abstract class WcInternalEvent {
  final WcInternalEventType type;
  const WcInternalEvent({required this.type});
  T cast<T extends WcInternalEvent>() {
    if (this is T) return this as T;
    throw WalletConnectExceptionConst.internalError;
  }
}

class WcInternalConnectEvent extends WcInternalEvent {
  const WcInternalConnectEvent() : super(type: WcInternalEventType.connect);
}

class WcInternalDisconnectEvent extends WcInternalEvent {
  const WcInternalDisconnectEvent()
      : super(type: WcInternalEventType.disconnect);
}

class WcInternalPairDeleteEvent extends WcInternalEvent {
  final String topic;
  const WcInternalPairDeleteEvent(this.topic)
      : super(type: WcInternalEventType.pairDelete);
}

class WcInternalSessionDeleteEvent extends WcInternalEvent {
  final SessionData session;
  const WcInternalSessionDeleteEvent(this.session)
      : super(type: WcInternalEventType.sessionDelete);
}

class WcInternalSessionRequestEvent extends WcInternalEvent {
  final SessionRequest request;
  const WcInternalSessionRequestEvent(this.request)
      : super(type: WcInternalEventType.request);
}

class WcInternalSessionEventEvent extends WcInternalEvent {
  final SessionEventRequest request;
  const WcInternalSessionEventEvent(this.request)
      : super(type: WcInternalEventType.event);
}

enum WcInternalPublishMessageStatus {
  pending,
  success,
  failed;

  bool get isSuccess => this == success;
  bool get isFailed => this == failed;
  bool get isPending => this == pending;
}

class WcInternalPublishMessageEvent extends WcInternalEvent {
  final PublishRequest request;
  final WcInternalPublishMessageStatus status;
  const WcInternalPublishMessageEvent(
      {required this.request, required this.status})
      : super(type: WcInternalEventType.publishMessage);
}
