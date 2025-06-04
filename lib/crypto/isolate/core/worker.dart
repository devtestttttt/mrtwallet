import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/crypto/isolate/cross/exception.dart';
import 'package:on_chain_wallet/crypto/isolate/types/types.dart';
import 'package:on_chain_wallet/crypto/requets/messages.dart';
import '../cross/cross.dart'
    if (dart.library.js_interop) '../cross/web/web.dart'
    if (dart.library.io) '../cross/io.dart';

abstract class IsolateCryptoWoker {
  static final IsolateCryptoWoker isolate = getCryptoWorker();
  Stream<A> getStream<A extends MessageArgsStreamResponse>(String streamId);

  void init(bool useIsolate);
  bool get hasIsolate;

  Future<T> _call<T>(
      {required Future<T> Function() onIsolate,
      required Future<T> Function() onMain,
      bool useIsolate = true,
      required WorkerMode mode}) async {
    if (!useIsolate || !hasIsolate) {
      return onMain();
    }
    try {
      final result = await onIsolate();
      return result;
    } on FailedIsolateInitialization {
      if (mode != WorkerMode.main) rethrow;
      final result = onMain();

      return result;
    } on TimeoutException {
      if (mode != WorkerMode.main) rethrow;
      final result = onMain();
      return result;
    }
  }

  Future<T> sendRequest<T extends CborMessageResponseArgs>(
      {required RequestableMessage message,
      WorkerMode mode = WorkerMode.main,
      List<int>? encryptPart,
      Duration? timeout});

  Future<void> sendStreamMessage(
      {required MessageArgsStream message,
      required WorkerMode mode,
      List<int>? encryptPart,
      Duration? timeout});

  Future<MessageArgsStreamId> sendStreamRequest(
      {required StreamArgsRequestable message,
      required WorkerMode mode,
      List<int>? encryptPart,
      Duration? timeout});

  ///
  Future<List<int>> generateRandomBytes(
      {int length = 32, List<List<int>> existsKeys = const []}) async {
    List<int> rand = QuickCrypto.generateRandom(length);
    if (existsKeys.isEmpty) return rand;
    while (BytesUtils.isContains(existsKeys, rand)) {
      rand = QuickCrypto.generateRandom(length);
    }
    return rand;
  }

  Future<List<int>> generateHash(
      {required CryptoRequestHashingType type,
      List<int>? dataBytes,
      String? dataHex,
      bool isolate = true}) async {
    return nonEncryptedRequest(
        NoneEncryptedRequestHashing(
            type: type, dataBytes: dataBytes, dataHex: dataHex),
        isolate: isolate,
        mode: WorkerMode.main);
  }

  Future<String> generateHashString(
      {required CryptoRequestHashingType type,
      List<int>? dataBytes,
      String? dataHex,
      bool isolate = true}) async {
    final hashing = await generateHash(
        type: type, dataBytes: dataBytes, dataHex: dataHex, isolate: isolate);
    switch (type) {
      case CryptoRequestHashingType.uuid:
      case CryptoRequestHashingType.generateUuid:
        return StringUtils.decode(hashing);
      default:
        return BytesUtils.toHexString(hashing);
    }
  }

  Future<List<int>> hexToBytes(String hex) async {
    return nonEncryptedRequest(NoneEncryptedRequestHexToBytes(hex: hex),
        mode: WorkerMode.main);
  }

  Future<String> generateRandomHex(
      {int length = 32, List<List<int>> existsKeys = const []}) async {
    return BytesUtils.toHexString(QuickCrypto.generateRandom(length));
  }

  Future<T> cryptoIsolateRequest<T, A extends CborMessageResponseArgs>(
      CryptoArgsCompleter<T, A> message,
      {Duration? timeout}) async {
    return _call(
        onIsolate: () async {
          final A response =
              await sendRequest(message: message, timeout: timeout);
          return message.parsResult(response);
        },
        onMain: () async {
          return message.result();
        },
        useIsolate: true,
        mode: WorkerMode.main);
  }

  Future<T> cryptoMainRequest<T, A extends CborMessageResponseArgs>(
      CryptoArgsCompleter<T, A> message,
      {Duration? timeout}) async {
    return message.result();
  }

  Future<T> nonEncryptedRequest<T, A extends CborMessageResponseArgs>(
      NoneEncryptedArgsCompleter<T, A> message,
      {List<int>? encryptedPart,
      Duration? timeout,
      bool isolate = true,
      WorkerMode mode = WorkerMode.main}) async {
    return _call(
        onIsolate: () async {
          final A response = await sendRequest(
              message: message,
              encryptPart: encryptedPart,
              timeout: timeout,
              mode: mode);
          return message.parsResult(response);
        },
        onMain: () async {
          return message.result(encryptedPart: encryptedPart);
        },
        useIsolate: isolate,
        mode: mode);
  }

  Future<SyncRequestController<T, S>>
      streamRequest<T, A extends MessageArgsStreamResponse, S>(
          IsolateStreamRequest<T, S> message,
          {List<int>? encryptedPart,
          Duration? timeout,
          // bool isolate = true,
          required WorkerMode mode}) async {
    assert(mode != WorkerMode.main);
    return _call(
        onIsolate: () async {
          final response = await sendStreamRequest(
              message: message,
              encryptPart: encryptedPart,
              timeout: timeout,
              mode: mode);
          final streamId = response.streamId;
          final stream = getStream<A>(streamId)
              .transform(StreamTransformer<A, T>.fromHandlers(
            handleData: (data, sink) {
              final r = message.parsResult(data);
              sink.add(r);
            },
          ));
          message.streamController!.stream.listen((event) {
            final msg = message.toRequest(message: event, streamId: streamId);
            sendStreamMessage(message: msg, mode: mode);
          }, onDone: () {
            final msg = MessageArgsStream.close(streamId);
            sendStreamMessage(message: msg, mode: mode).catchError((e) {
              throw e;
            });
            message.close();
          });
          return SyncRequestController(
              controller: message.streamController!, stream: stream);
        },
        onMain: () async {
          final stream = message.result();
          message.streamController!.stream.listen((event) {
            message.streamController!.add(event);
          }, onDone: () {
            message.close();
          });
          return SyncRequestController(
              controller: message.streamController!, stream: stream);
        },
        useIsolate: true,
        mode: mode);
  }

  Future<T> walletArgs<T, A extends CborMessageResponseArgs>({
    required WalletArgsCompleter<T, A> message,
    required List<int> encryptedMasterKey,
    required List<int> key,
    Duration? timeout,
  }) async {
    final args = WalletArgs.fromStorage(
        args: message, encryptedMasterKey: encryptedMasterKey, key: key);
    return _call(
        onIsolate: () async {
          final A response = await sendRequest(message: args, timeout: timeout);
          return message.parsResult(response);
        },
        onMain: () async {
          return await args.result();
        },
        useIsolate: true,
        mode: WorkerMode.main);
  }
}
