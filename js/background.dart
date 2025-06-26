import 'dart:async';
import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_bridge/models/events/models/wallet_event.dart';
import 'package:on_chain_bridge/web/web.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'js_wallet/constant/constant.dart';

class _JSBackgroundHandler {
  final lock = SynchronizedLock();
  _JSBackgroundHandler._();
  static Future<_JSBackgroundHandler> init() async {
    await AppNativeMethods.platform.getConfig();
    return _JSBackgroundHandler._();
  }

  Future<String?> _read({required String key}) async {
    return await AppNativeMethods.platform.readSecure(key);
  }

  Future<Map<String, String>> _readAll({String? prefix}) async {
    return await AppNativeMethods.platform.readAllSecure(prefix: prefix);
  }

  Future<void> _write({required String key, required String data}) async {
    await AppNativeMethods.platform.writeSecure(key, data);
  }

  Future<List<Web3ChainNetworkData>> _readNetworks(HDWallet wallet) async {
    final List<Web3ChainNetworkData> web3Chains = [];
    final keys = await _readAll(prefix: wallet.storageKey);
    final data = keys.keys.map((e) => (e, keys[e]!)).toList();
    final keyBytes = data.map((e) => BytesUtils.fromHexString(e.$2)).toList();
    for (final i in keyBytes) {
      try {
        final obj = CborObject.fromCbor(i);
        final CborListValue values = CborSerializable.cborTagValue(
            object: obj, tags: CborTagsConst.iAccount);
        WalletNetwork? network = MethodUtils.nullOnException(() {
          return WalletNetwork.fromCborBytesOrObject(obj: values.getCborTag(1));
        });
        network = MethodUtils.nullOnException(() => ChainConst.updateNetwork(
            networkId: values.elementAs(0), network: network));
        if (network == null || !network.supportWeb3) continue;
        final ProviderIdentifier? serviceIdentifier =
            MethodUtils.nullOnException(() {
          final CborTagValue? identifier = values.elementAs(6);
          if (identifier == null) return null;
          return ProviderIdentifier.deserialize(cbor: identifier);
        });
        final Web3ChainNetworkData n = switch (network.type) {
          NetworkType.ethereum => Web3ChainNetworkData<WalletEthereumNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.tron => Web3ChainNetworkData<WalletTronNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.solana => Web3ChainNetworkData<WalletSolanaNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.stellar => Web3ChainNetworkData<WalletStellarNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.ton => Web3ChainNetworkData<WalletTonNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.substrate => Web3ChainNetworkData<WalletSubstrateNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.aptos => Web3ChainNetworkData<WalletAptosNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.sui => Web3ChainNetworkData<WalletSuiNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.cosmos => Web3ChainNetworkData<WalletCosmosNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.bitcoinAndForked ||
          NetworkType.bitcoinCash =>
            Web3ChainNetworkData<WalletBitcoinNetwork>(
                network: network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
          _ => throw UnimplementedError()
        };
        web3Chains.add(n);
      } catch (_) {}
    }
    return web3Chains;
  }

  Future<HDWallet?> _readWallet() async {
    final wallet = await _read(key: StorageConst.hdWallets);
    if (wallet == null) {
      return null;
    }
    return HDWallets.deserialize(hex: wallet).getInitializeWallet();
  }

  Web3APPAuthenticationKey generateKey() {
    final kp = X25519Keypair.generate(seed: QuickCrypto.generateRandom());

    final sharedKey1 = X25519.scalarMult(kp.privateKey, []);
    final hdkf = HKDF(
        ikm: sharedKey1,
        hash: () => SHA256(),
        length: X25519KeyConst.privateKeyLength);
    final symKey = hdkf.derive().asImmutableBytes;
    return Web3APPAuthenticationKey(
        topic: QuickCrypto.sha256Hash(symKey),
        publicKey: kp.publicKey,
        symkey: symKey);
  }

  Future<Web3APPAuthentication> getPermission(
      {required Web3ClientInfo info, required HDWallet wallet}) async {
    final applicationKey =
        BytesUtils.toHexString(MD4.hash(info.identifier.codeUnits));
    final permission =
        await _read(key: wallet.web3ClientStorageKey(applicationKey));
    Web3APPAuthentication? toPermission = MethodUtils.nullOnException(() {
      if (permission == null) return null;
      return Web3APPAuthentication.deserialize(hex: permission);
    });
    if (toPermission == null) {
      final token = generateKey();
      final permission =
          info.toAuhenticated(token: token, applicationKey: applicationKey);
      await _write(
          key: wallet.web3ClientStorageKey(permission.applicationKey),
          data: permission.toCbor().toCborHex());
      toPermission = permission;
    }
    return toPermission;
  }

  Future<Web3EncryptedMessage> toEncryptedMessage(
      {required List<int> key, required List<int> message}) async {
    final chacha = ChaCha20Poly1305(key);
    final nonce = QuickCrypto.generateRandom(12);
    final encryptedKey = chacha.encrypt(nonce, message);
    return Web3EncryptedMessage(message: encryptedKey, nonce: nonce);
  }

  Future<Web3EncryptedMessage> _getOrCreateAppAuthenticated(
      {required Web3ClientInfo info,
      required HDWallet wallet,
      required String encryptionKey}) async {
    Web3APPAuthentication? toPermission =
        await getPermission(info: info, wallet: wallet);
    final sha256 = SHA256.hash(StringUtils.encode(encryptionKey));
    final networks = await _readNetworks(wallet);
    final auth = toPermission.createAuth(networks);
    final message = Web3ChainMessage(authenticated: auth);
    return toEncryptedMessage(message: message.toCbor().encode(), key: sha256);
  }

  Future<void> send(WalletEvent? event, int? tabId) async {
    if (event == null || tabId == null) return;
    await extension.tabs
        .sendMessage_(tabId: tabId, message: event.toJsEvent())
        .catchError((e) {
      return null;
    });
  }

  Future<void> sendAlive() async {
    final tabs = await extension.tabs.query_();
    for (final i in tabs) {
      send(
          WalletEvent(
              target: WalletEventTarget.background,
              type: WalletEventTypes.ping,
              requestId: 'sendAlive'),
          i.id);
    }
  }

  static Future<WalletEvent> sendWalletMessage(WalletEvent msg,
      {List<WalletEventTarget> allowTargets = const [
        WalletEventTarget.wallet
      ]}) async {
    bool hasListener = false;
    try {
      final Completer<WalletEvent> completer = Completer<WalletEvent>();
      bool onMessage(JSWalletEvent? message, MessageSender? sender,
          JSFunction? sendResponse) {
        final event = message?.toEvent();
        if (event == null) return false;
        if (event.type != WalletEventTypes.ping) return false;
        if (!allowTargets.contains(event.target)) {
          return false;
        }
        final result = extension.runtime.sendMessage_(message: msg);

        result.then((e) {
          completer.complete(e);
        });
        result.catchError((e) {
          completer.completeError(e);
          return null;
        });
        return true;
      }

      try {
        final r = await extension.runtime.sendMessage_(message: msg);
        return r!;
      } catch (e) {
        _onContentListener = onMessage.toJS;
        extension.runtime.onMessage.addListener(_onContentListener);
        hasListener = true;
        return await completer.future;
      }
    } finally {
      if (hasListener) {
        extension.runtime.onMessage.removeListener(_onContentListener);
      }
    }
  }

  Future<HDWallet> getWallet() async {
    final wallet = await _readWallet();
    if (wallet == null) throw Web3RequestExceptionConst.walletNotInitialized;
    return wallet;
  }

  Web3ClientInfo buildClient(ChromeTab tab) {
    APPImage? image = APPImage.network(tab.favIconUrl);
    image ??= APPImage.faviIcon(tab.url!);

    final Web3ClientInfo? client = tab.id == null
        ? null
        : Web3ClientInfo.info(url: tab.url, faviIcon: image, name: tab.title);
    if (client == null) {
      throw Web3RequestExceptionConst.invalidHost;
    }
    return client;
  }

  Future<WalletEvent> openPopup(WalletEvent event) async {
    return await lock.synchronized(() async {
      final WalletEvent? windowIdResponse = await extension.runtime
          .sendMessage_(
              message: event.copyWith(target: WalletEventTarget.background))
          .then((e) => e)
          .catchError((e) => null);
      if (windowIdResponse != null) {
        return windowIdResponse;
      }
      final info = await extension.windows.getCurrent_(populate: true);
      final newLeft = IntUtils.max(0, info.left! + 100);
      final newTop = IntUtils.max(0, info.top! + 100);
      final newWidth = IntUtils.min(info.width!, 400);
      final newHeight = IntUtils.min(info.height!, 600);
      await extension.windows.create_(
          url: "${extension.runtime.getURL("index.html")}?context=popup",
          type: JSWalletConstant.extentionType,
          width: newWidth,
          height: newHeight,
          top: newTop,
          focused: true,
          left: newLeft);
      final result = await sendWalletMessage(JSWalletConstant.openExtension
          .copyWith(target: WalletEventTarget.background));

      return result;
    });
  }

  Future<WalletEvent> onBackgroudMessage(
      WalletEvent event, ChromeTab tab) async {
    try {
      final wallet = await getWallet();
      final Web3ClientInfo client = buildClient(tab);
      final type = NetworkType.fromTag(event.data);
      final appAuthenticated =
          await getPermission(info: client, wallet: wallet);
      appAuthenticated.disconnectChain(type);
      await _write(
          key: wallet.web3ClientStorageKey(appAuthenticated.applicationKey),
          data: appAuthenticated.toCbor().toCborHex());
      final networks = await _readNetworks(wallet);
      final auth = appAuthenticated.createAuth(networks, web3Networks: [type]);
      final response = Web3GlobalResponseMessage(authenticated: auth);
      final message = await toEncryptedMessage(
          key: appAuthenticated.token.symkey,
          message: response.toCbor().encode());
      return WalletEvent(
          clientId: "${tab.id!}",
          data: message.toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.message,
          target: WalletEventTarget.background);
    } on Web3RequestException catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: e.toResponseMessage().toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception,
          target: WalletEventTarget.background);
    } catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: Web3RequestExceptionConst.internalError
              .toResponseMessage()
              .toCbor()
              .encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception,
          target: WalletEventTarget.background);
    }
  }

  Future<WalletEvent> tabInformation(ChromeTab tab, WalletEvent event) async {
    try {
      final wallet = await getWallet();
      final Web3ClientInfo client = buildClient(tab);
      final authenticated = await _getOrCreateAppAuthenticated(
          info: client, wallet: wallet, encryptionKey: tab.id!.toString());
      return WalletEvent(
          clientId: "${tab.id!}",
          data: authenticated.toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.activation,
          target: WalletEventTarget.background);
    } on Web3RequestException catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: e.toResponseMessage().toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception,
          target: WalletEventTarget.background);
    } catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: Web3RequestExceptionConst.internalError
              .toResponseMessage()
              .toCbor()
              .encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception,
          target: WalletEventTarget.background);
    }
  }
}

@JS("OnBackgroundListener_")
external set _onContentListener(JSFunction? f);

@JS("OnBackgroundListener_")
external JSFunction get _onContentListener;

void main() async {
  final handler = await _JSBackgroundHandler.init();
  extension.runtime.onInstalled
      .addListener((OnInstalledDetails details) {}.toJS);
  extension.runtime.onMessage.addListener(
      (JSWalletEvent? message, MessageSender sender, JSFunction sendResponse) {
    final event = message?.toEvent();

    if (event == null || event.target != WalletEventTarget.external) {
      return false;
    }
    switch (event.type) {
      case WalletEventTypes.background:
        handler.onBackgroudMessage(event, sender.tab!).then(
            (e) => sendResponse.callAsFunction(sendResponse, e.toJsEvent()));
        return true;
      case WalletEventTypes.openExtension:
        handler.openPopup(event).then(
            (e) => sendResponse.callAsFunction(sendResponse, e.toJsEvent()));
        return true;

      case WalletEventTypes.tabId:
        handler.tabInformation(sender.tab!, event).then((e) {
          sendResponse.callAsFunction(sendResponse, e.toJsEvent());
        });
        return true;
      default:
        return false;
    }
  }.toJS);
  handler.sendAlive();
}
