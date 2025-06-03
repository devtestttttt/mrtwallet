import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/messages.dart';

typedef OnStreamMessage = Function(CborMessageResponseArgs message, int id);

class StreamIsolateMessageController {
  StreamIsolateMessageController(this.onStreamCallBack);
  final OnStreamMessage onStreamCallBack;
  static const MessageArgsException verificationFailed =
      MessageArgsException("data_verification_failed");

  final Map<String, IsolateStreamRequest> streams = {};

  Future<CborMessageResponseArgs> handleMessage(
      {required CryptoStreamMessageArgs args,
      required int id,
      List<int>? encryptedPart}) async {
    CborMessageResponseArgs result;
    try {
      switch (args.type) {
        case StreamCryptoArgsType.streamRequest:
          final streamId = UUID.generateUUIDv4();
          final IsolateStreamRequest msg = args as IsolateStreamRequest;
          StreamSubscription<MessageArgsStreamResponse>? subscription;
          subscription = msg
              .getIsolateResult(
                  streamId: streamId, encryptedPart: encryptedPart)
              .listen(
            (e) {
              onStreamCallBack(e, id);
            },
            onDone: () {
              subscription?.cancel();
              subscription = null;
              final r = streams.remove(streamId);
              assert(r?.closed ?? true, "stream muset be closed!.");
              r?.close();
            },
          );
          streams[streamId] = msg;
          result = MessageArgsStreamId(streamId);
          break;
        case StreamCryptoArgsType.streamArgs:
          final MessageArgsStream msg = args as MessageArgsStream;
          final controller = streams[msg.streamId];
          if (controller == null) {
            result = MessageArgsException("stream_does_not_exists");
            break;
          }
          controller.add(msg);
          result = MessageArgsMessage();
          break;
      }
    } on WalletException catch (e) {
      result = MessageArgsException(e.toString());
    } on ApiProviderException catch (e) {
      result = MessageArgsException(e.toString());
    } on BlockchainUtilsException catch (e) {
      result = MessageArgsException(e.message);
    } catch (e) {
      result = verificationFailed;
    }
    return result;
  }
}
