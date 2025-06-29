import 'dart:async';
import 'package:blockchain_utils/crypto/crypto/crypto.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/uuid/uuid.dart';
import 'package:on_chain_bridge/models/events/models/wallet_event.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/web3/types/types.dart';
import 'package:on_chain_wallet/wallet/models/others/models/status.dart';
import 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain_wallet/crypto/worker.dart';

typedef ONUPDATEWEB3PERMISSION = void Function(
    Web3UpdatePermissionRequest?, ONWEB3PERMISSIONUPDATED);

enum WalletJSScriptStatus {
  progress,
  active,
  failed,
  block,
  unknownHost;

  bool get inProgress => this == progress;
  static WalletJSScriptStatus? fromJSWalletEvent(WalletEventTypes? event) {
    switch (event) {
      case WalletEventTypes.exception:
        return WalletJSScriptStatus.failed;
      case WalletEventTypes.activation:
        return WalletJSScriptStatus.active;
      default:
        return null;
    }
  }
}

class LastWeb3ActiveClient {
  final String? identifier;
  final String? url;
  final Web3ActiveClient? client;

  const LastWeb3ActiveClient(
      {this.identifier,
      this.web3Status = WalletJSScriptStatus.progress,
      this.client,
      this.url});
  final WalletJSScriptStatus web3Status;

  @override
  String toString() {
    return "latestClient: $identifier $url $client $web3Status ";
  }
}

class Web3PageAuthenticatedResponse {
  final WalletEvent event;
  final Web3ActiveClient? client;
  const Web3PageAuthenticatedResponse(
      {required this.event, required this.client});
}

final class Web3ActiveClient {
  final Web3ClientInfo client;
  final String identifier;
  final String selfPublicKey;
  final ChaCha20Poly1305 crypto;
  final String clientId;
  Web3ActiveClient._(
      {required this.client,
      required this.identifier,
      required this.crypto,
      required this.selfPublicKey,
      required this.clientId});
  factory Web3ActiveClient(
      {required Web3ClientInfo client,
      required String identifier,
      required String selfPublicKey,
      required String clientId,
      required List<int> sharedKey}) {
    return Web3ActiveClient._(
        client: client,
        identifier: identifier,
        selfPublicKey: selfPublicKey,
        crypto: ChaCha20Poly1305(sharedKey),
        clientId: clientId);
  }

  List<int>? decrypt(List<int> message) {
    final encryptMessage = Web3EncryptedMessage.deserialize(bytes: message);
    return crypto.decrypt(encryptMessage.nonce, encryptMessage.message);
  }

  Web3EncryptedMessage encrypt(Web3MessageCore message) {
    final nonce = QuickCrypto.generateRandom(12);
    final encrypt = crypto.encrypt(nonce, message.toCbor().encode());
    return Web3EncryptedMessage(message: encrypt, nonce: nonce);
  }
}

mixin Web3RequestControllerImpl on CryptoWokerImpl {
  WalletCore get walletCore;
  final StreamValue<LastWeb3ActiveClient> latestClient =
      StreamValue(const LastWeb3ActiveClient());
  final _lock = SynchronizedLock();
  List<Web3ActiveClient> get clients => _keys.values.toList();
  final Map<String, Web3ActiveClient> _keys = {};
  final Map<String, List<Web3RequestApplicationInformation>> _clientsRequests =
      {};
  Future<void> sendMessageToClient(
      {required Web3ActiveClient client,
      required Web3EncryptedMessage message});

  Web3ClientInfo? createClientInfos(
      {required String? clientId,
      required String? url,
      required String? title,
      required String? faviIcon}) {
    if (url == null || clientId == null) return null;
    APPImage? image = APPImage.network(faviIcon);
    image ??= APPImage.faviIcon(url);
    return Web3ClientInfo.info(url: url, faviIcon: image, name: title);
  }

  WalletEvent toResponseEvent({
    required String id,
    required WalletEventTypes type,
    List<int> data = const [],
    String? requestId,
    String? additional,
    String? platform,
  }) {
    return WalletEvent(
        clientId: id,
        data: data,
        requestId: requestId ?? UUID.generateUUIDv4(),
        type: type,
        additional: additional,
        platform: platform,
        target: WalletEventTarget.wallet);
  }

  Future<Web3ActiveClient> getEncryptionKey(
      {required String clientId,
      required String identifier,
      required Web3ClientInfo client,
      Web3DappInfo? dappInfo}) async {
    if (_keys.containsKey(clientId)) {
      return _keys[clientId]!;
    }
    Web3APPAuthenticationKey? auth = dappInfo?.authentication.token;
    if (auth == null) {
      final appAuth = await walletCore.getDappAuthenticatedKey(client);
      auth = appAuth.result;
    }
    _keys[clientId] = Web3ActiveClient(
        client: client,
        identifier: identifier,
        clientId: clientId,
        selfPublicKey: BytesUtils.toHexString(auth.publicKey),
        sharedKey: X25519.scalarMult(
            auth.privateKey, BytesUtils.fromHexString(clientId)));
    return _keys[clientId]!;
  }

  Future<Web3PageAuthenticatedResponse> createPageAuthenticated({
    required String peerKey,
    required String identifier,
    Web3ClientInfo? info,
  }) async {
    Web3ExceptionMessage? onException;
    Web3ActiveClient? key;
    try {
      if (info == null) {
        throw Web3RequestExceptionConst.invalidHost;
      }
      final auth = await walletCore.getWeb3Dapp(info);
      final authMessage = Web3ChainMessage(authenticated: auth.result.dappData);
      key = await getEncryptionKey(
          clientId: peerKey,
          client: info,
          identifier: identifier,
          dappInfo: auth.result);
      final encryptMessage = key.encrypt(authMessage);
      final event = toResponseEvent(
          data: encryptMessage.toCbor().encode(),
          id: peerKey,
          type: WalletEventTypes.activation,
          platform: PlatformInterface.appPlatform.name,
          additional: key.selfPublicKey,
          requestId: '');
      return Web3PageAuthenticatedResponse(event: event, client: key);
    } on Web3RequestException catch (e) {
      onException = e.toResponseMessage();
    } catch (e) {
      onException =
          Web3RequestExceptionConst.fromException(e).toResponseMessage();
    }
    final event = toResponseEvent(
        id: peerKey,
        type: WalletEventTypes.exception,
        data: onException.toCbor().encode());
    return Web3PageAuthenticatedResponse(event: event, client: key);
  }

  Future<void> updateApplicationAuthenticated(
      ONUPDATEWEB3PERMISSION onUpdate) async {
    final currentApp = latestClient.value.client;
    if (currentApp == null) return;
    final dapp = await walletCore.getWeb3Dapp(currentApp.client);
    final request = Web3UpdatePermissionRequest(
        lockedChains: [], authentication: dapp.result.authentication);
    onUpdate(
      request,
      (networks) async {
        final message = await walletCore.updateWeb3Application(
            request.authentication,
            web3Networks: networks);
        final msg = Web3ChainMessage(authenticated: message.result.dappData);
        final encrypted = currentApp.encrypt(msg);
        await sendMessageToClient(message: encrypted, client: currentApp);
        return false;
      },
    );
  }

  Future<void> onRequest(
      {required WalletEvent request,
      required String? identifier,
      required String? url,
      required String? title,
      required String? image,
      required Completer<WalletEvent?> completer}) async {
    await _lock.synchronized(() async {
      Web3ActiveClient key;
      Web3MessageCore? message;
      Web3ClientInfo? client;
      try {
        client = createClientInfos(
            clientId: request.clientId,
            url: url,
            faviIcon: image,
            title: title);
        if (client == null) throw Web3RequestExceptionConst.invalidHost;
        if (identifier == null) throw Web3RequestExceptionConst.invalidRequest;
        key = await getEncryptionKey(
            client: client, identifier: identifier, clientId: request.clientId);
        final decryptedMessage = key.decrypt(request.data);
        message = Web3MessageCore.deserialize(bytes: decryptedMessage);
        if (decryptedMessage == null) {
          throw Web3RequestExceptionConst.missingPermission;
        }
      } catch (e) {
        final exception =
            Web3RequestExceptionConst.fromException(e).toResponseMessage();
        completer.complete(toResponseEvent(
            id: request.clientId,
            type: WalletEventTypes.exception,
            data: exception.toCbor().encode(),
            requestId: request.requestId));
        return;
      }
      final walletRequest = Web3RequestApplicationInformation(
          message: message,
          requestId: request.requestId,
          applicationId: client.identifier);
      _clientsRequests[request.clientId] ??= [];
      _clientsRequests[request.clientId]?.add(walletRequest);
      try {
        final result = await walletCore.web3Request(walletRequest);

        WalletEvent event = toResponseEvent(
            id: request.clientId,
            type: WalletEventTypes.message,
            data: key.encrypt(result.result).toCbor().encode(),
            requestId: request.requestId);
        completer.complete(event);
      } on Web3RequestClosed {
        completer.complete(null);
      } catch (e) {
        final exception =
            Web3RequestExceptionConst.fromException(e).toResponseMessage();
        final event = toResponseEvent(
            id: request.clientId,
            type: WalletEventTypes.message,
            data: key.encrypt(exception).toCbor().encode(),
            requestId: request.requestId);
        completer.complete(event);
      }
    });
  }

  void completeRequest({
    required String clientId,
    required String requestId,
    required bool result,
  }) {
    final clientRequests = _clientsRequests[clientId];
    final r =
        clientRequests?.firstWhereNullable((e) => e.requestId == requestId);
    if (r == null) return;
    clientRequests?.remove(r);
    if (result) {
      r.completeSuccess();
    } else {
      r.completeError();
    }
  }

  void onWeb3ClinetDisconnected(Web3ActiveClient? client) {
    if (client == null) return;
    final clientRequests = [
      ..._clientsRequests[client.clientId] ??
          <Web3RequestApplicationInformation>[]
    ];
    for (final i in clientRequests) {
      completeRequest(
          clientId: client.clientId, requestId: i.requestId, result: false);
    }
  }

  void onWeb3ClientRemoved(String? identifier) {
    if (identifier == null) return;
    _keys.removeWhere((k, v) => v.identifier == identifier);
  }

  Future<void> onWalletEvent(WalletActionEvent event) async {
    if (!event.status.isSuccess) return;
    switch (event.action) {
      case WalletActionEventType.eraseWallet:
      case WalletActionEventType.switchWallet:
      case WalletActionEventType.removeAccount:
      case WalletActionEventType.setup:
      case WalletActionEventType.importNetwork:
        final clients = this.clients.clone();
        for (final i in clients) {
          final dapps = await walletCore.getWeb3Dapp(i.client);
          if (dapps.hasError) continue;
          final message =
              Web3ChainMessage(authenticated: dapps.result.dappData);
          sendMessageToClient(client: i, message: i.encrypt(message));
        }
        break;
      default:
    }
  }

  Future<void> updateClientAuthenticated(Web3DappInfo dappData) async {
    final clients = this.clients.clone();
    final relatedClients = clients
        .where((e) => e.client.identifier == dappData.clientInfo.identifier);
    for (final i in relatedClients) {
      final message = Web3ChainMessage(authenticated: dappData.dappData);
      sendMessageToClient(client: i, message: i.encrypt(message));
    }
  }
}
