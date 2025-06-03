import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/messages.dart';

typedef OnStreamMessage = Function(CborMessageResponseArgs message, int id);

class EncryptedIsolateMessageController {
  EncryptedIsolateMessageController(this.onStreamCallBack);
  final OnStreamMessage onStreamCallBack;
  static const MessageArgsException verificationFailed =
      MessageArgsException("data_verification_failed");

  Future<CborMessageResponseArgs> handleMessage(
      {required CryptoMessageArgs args,
      required int id,
      List<int>? encryptedPart}) async {
    CborMessageResponseArgs result;
    try {
      switch (args.type) {
        case CryptoArgsType.nonEncrypted:
          final NoneEncryptedCryptoRequest msg =
              args as NoneEncryptedCryptoRequest;
          result = await msg.getResult(encryptedPart: encryptedPart);
          break;
        case CryptoArgsType.crypto:
          final CryptoRequest msg = args as CryptoRequest;
          result = msg.getResult();
          break;
        case CryptoArgsType.wallet:
          final WalletArgs msg = args as WalletArgs;
          result = msg.getResult();
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
