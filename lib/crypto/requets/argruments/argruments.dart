import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/crypto/requets/messages/crypto/requests/read_master_key.dart';

class _MessageArgsTags {
  static const List<int> twoBytes = [1, 2];
  static const List<int> oneBytes = [1, 1];
  static const List<int> streamId = [1, 4];
  static const List<int> streamArgs = [1, 5];
  static const List<int> threeBytes = [1, 3];
  static const List<int> fourBytes = [1, 6];
  static const List<int> exception = [0, 0];
  static const List<int> message = [0, 1];
  static const List<int> network = [2, 0];
  static const List<int> nonEncrypted = [2, 1];
  static const List<int> wallet = [3, 0];
  static const List<int> stream = [2, 3];
}

enum ArgsResponseType {
  streamId(_MessageArgsTags.streamId),
  message(_MessageArgsTags.message),
  streamArgs(_MessageArgsTags.streamArgs),
  oneArg(_MessageArgsTags.oneBytes),
  twoArgs(_MessageArgsTags.twoBytes),
  threeArgs(_MessageArgsTags.threeBytes),
  fourArgs(_MessageArgsTags.fourBytes),
  exception(_MessageArgsTags.exception);

  static const int tagLength = 2;

  final List<int> tag;
  const ArgsResponseType(this.tag);
  static ArgsResponseType fromTag(List<int>? tag) {
    return values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag?.sublist(0, tagLength)),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "invalid args type tag."));
  }
}

enum CryptoArgsType {
  crypto(_MessageArgsTags.network),
  nonEncrypted(_MessageArgsTags.nonEncrypted),
  wallet(_MessageArgsTags.wallet);

  static const int tagLength = 2;

  bool get isEncrypted => this == wallet || this == crypto;

  final List<int> tag;
  const CryptoArgsType(this.tag);
  static CryptoArgsType fromTag(List<int>? tag) {
    return values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag?.sublist(0, tagLength)),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "invalid args type tag."));
  }
}

enum StreamCryptoArgsType {
  streamArgs(_MessageArgsTags.streamArgs),
  streamRequest(_MessageArgsTags.stream);

  static const int tagLength = 2;

  final List<int> tag;
  const StreamCryptoArgsType(this.tag);
  static StreamCryptoArgsType fromTag(List<int>? tag) {
    return values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag?.sublist(0, tagLength)),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "invalid args type tag."));
  }
}

abstract class CborMessageResponseArgs with CborSerializable {
  const CborMessageResponseArgs();
  abstract final ArgsResponseType type;
  static T deserialize<T extends CborMessageResponseArgs>(List<int> bytes) {
    final CborTagValue cbor = CborSerializable.toTagValue(bytes);
    final type = ArgsResponseType.fromTag(cbor.tags);
    CborMessageResponseArgs args;
    switch (type) {
      case ArgsResponseType.oneArg:
        args = MessageArgsOneBytes.deserialize(object: cbor);
        break;
      case ArgsResponseType.streamId:
        args = MessageArgsStreamId.deserialize(object: cbor);
        break;
      case ArgsResponseType.twoArgs:
        args = MessageArgsTwoBytes.deserialize(object: cbor);
        break;
      case ArgsResponseType.threeArgs:
        args = MessageArgsThreeBytes.deserialize(object: cbor);
        break;
      case ArgsResponseType.fourArgs:
        args = MessageArgsFourBytes.deserialize(object: cbor);
        break;
      case ArgsResponseType.exception:
        args = MessageArgsException.deserialize(object: cbor);
        break;
      case ArgsResponseType.streamArgs:
        args = MessageArgsStreamResponse.deserialize(object: cbor);
        break;
      case ArgsResponseType.message:
        args = MessageArgsMessage.deserialize(object: cbor);
        break;
    }
    if (args is! T) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return args;
  }
}

abstract class CryptoMessageArgs extends RequestableMessage {
  const CryptoMessageArgs();
  abstract final CryptoArgsType type;
  @override
  bool get isEncrypted => type.isEncrypted;
  static T deserialize<T extends CryptoMessageArgs>(List<int> bytes) {
    final CborTagValue cbor = CborSerializable.toTagValue(bytes);
    final type = CryptoArgsType.fromTag(cbor.tags);
    CryptoMessageArgs args;
    switch (type) {
      case CryptoArgsType.crypto:
        args = CryptoRequest.deserialize(object: cbor);
        break;
      case CryptoArgsType.nonEncrypted:
        args = NoneEncryptedCryptoRequest.deserialize(object: cbor);
        break;
      case CryptoArgsType.wallet:
        args = WalletArgs.deserialize(object: cbor);
        break;
    }
    if (args is! T) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return args;
  }
}

abstract class CryptoStreamMessageArgs extends RequestableMessage {
  const CryptoStreamMessageArgs();
  abstract final StreamCryptoArgsType type;
  @override
  bool get isEncrypted => false;
  static T deserialize<T extends CryptoStreamMessageArgs>(List<int> bytes) {
    final CborTagValue cbor = CborSerializable.toTagValue(bytes);
    final type = StreamCryptoArgsType.fromTag(cbor.tags);
    CryptoStreamMessageArgs args;
    switch (type) {
      case StreamCryptoArgsType.streamRequest:
        args = IsolateStreamRequest.deserialize(object: cbor);
        break;
      case StreamCryptoArgsType.streamArgs:
        args = MessageArgsStream.deserialize(object: cbor);
        break;
    }
    if (args is! T) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return args;
  }
}

abstract class RequestableMessage with CborSerializable {
  const RequestableMessage();
  bool get isEncrypted;
}

abstract class StreamArgsRequestable extends CryptoStreamMessageArgs {
  const StreamArgsRequestable();
}

class MessageArgsTwoBytes extends CborMessageResponseArgs {
  final List<int> keyOne;
  final List<int> keyTwo;
  MessageArgsTwoBytes({required List<int> keyOne, required List<int> keyTwo})
      : keyOne = keyOne.asImmutableBytes,
        keyTwo = keyTwo.asImmutableBytes;
  factory MessageArgsTwoBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsResponseType.twoArgs.tag);
    return MessageArgsTwoBytes(
        keyOne: values.elementAt(0), keyTwo: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(keyOne), CborBytesValue(keyTwo)]),
        ArgsResponseType.twoArgs.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.twoArgs;
}

class MessageArgsOneBytes extends CborMessageResponseArgs {
  final List<int> keyOne;
  MessageArgsOneBytes({required List<int> keyOne})
      : keyOne = keyOne.asImmutableBytes;
  factory MessageArgsOneBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsResponseType.oneArg.tag);
    return MessageArgsOneBytes(keyOne: values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([CborBytesValue(keyOne)]),
        ArgsResponseType.oneArg.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.oneArg;
}

class MessageArgsStreamId extends CborMessageResponseArgs {
  final String streamId;
  MessageArgsStreamId(this.streamId);
  factory MessageArgsStreamId.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsResponseType.streamId.tag);
    return MessageArgsStreamId(values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([streamId]), ArgsResponseType.streamId.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.streamId;
}

class MessageArgsThreeBytes extends CborMessageResponseArgs {
  final List<int> keyOne;
  final List<int> keyTwo;
  final List<int> keyThree;
  MessageArgsThreeBytes(
      {required List<int> keyOne,
      required List<int> keyTwo,
      required List<int> keyThree})
      : keyOne = keyOne.asImmutableBytes,
        keyTwo = keyTwo.asImmutableBytes,
        keyThree = keyThree.asImmutableBytes;
  factory MessageArgsThreeBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsResponseType.threeArgs.tag);
    return MessageArgsThreeBytes(
        keyOne: values.elementAs(0),
        keyTwo: values.elementAs(1),
        keyThree: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(keyOne),
          CborBytesValue(keyTwo),
          CborBytesValue(keyThree)
        ]),
        ArgsResponseType.threeArgs.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.threeArgs;
}

class MessageArgsFourBytes extends CborMessageResponseArgs {
  final List<int> keyOne;
  final List<int> keyTwo;
  final List<int> keyThree;
  final List<int> keyFour;
  MessageArgsFourBytes(
      {required List<int> keyOne,
      required List<int> keyTwo,
      required List<int> keyThree,
      required List<int> keyFour})
      : keyOne = keyOne.asImmutableBytes,
        keyTwo = keyTwo.asImmutableBytes,
        keyThree = keyThree.asImmutableBytes,
        keyFour = keyFour.asImmutableBytes;
  factory MessageArgsFourBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsResponseType.fourArgs.tag);
    return MessageArgsFourBytes(
        keyOne: values.elementAs(0),
        keyTwo: values.elementAs(1),
        keyThree: values.elementAs(2),
        keyFour: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(keyOne),
          CborBytesValue(keyTwo),
          CborBytesValue(keyThree),
          CborBytesValue(keyFour),
        ]),
        ArgsResponseType.fourArgs.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.fourArgs;
}

enum MessageArgsStreamMethod {
  data(0),
  close(1),
  done(2);

  final int value;
  const MessageArgsStreamMethod(this.value);
  static MessageArgsStreamMethod fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "stream method not found."));
  }
}

class MessageArgsStream extends StreamArgsRequestable {
  final List<int>? data;
  final String streamId;
  final MessageArgsStreamMethod method;
  MessageArgsStream._(
      {List<int>? data, required this.streamId, required this.method})
      : data = data?.asImmutableBytes;
  factory MessageArgsStream.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: StreamCryptoArgsType.streamArgs.tag);
    return MessageArgsStream._(
        data: values.elementAt(0),
        streamId: values.elementAs(1),
        method: MessageArgsStreamMethod.fromValue(values.elementAs(2)));
  }
  factory MessageArgsStream(
      {required List<int> data, required String streamId}) {
    return MessageArgsStream._(
        data: data, method: MessageArgsStreamMethod.data, streamId: streamId);
  }
  factory MessageArgsStream.close(String streamId) {
    return MessageArgsStream._(
        method: MessageArgsStreamMethod.close, streamId: streamId);
  }
  factory MessageArgsStream.done(String streamId) {
    return MessageArgsStream._(
        method: MessageArgsStreamMethod.close, streamId: streamId);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          data == null ? null : CborBytesValue(data!),
          streamId,
          method.value
        ]),
        type.tag);
  }

  @override
  StreamCryptoArgsType get type => StreamCryptoArgsType.streamArgs;
}

class MessageArgsStreamResponse extends CborMessageResponseArgs {
  final List<int>? data;
  final String streamId;
  final MessageArgsStreamMethod method;
  MessageArgsStreamResponse._(
      {List<int>? data, required this.streamId, required this.method})
      : data = data?.asImmutableBytes;
  factory MessageArgsStreamResponse.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: ArgsResponseType.streamArgs.tag);
    return MessageArgsStreamResponse._(
        data: values.elementAt(0),
        streamId: values.elementAs(1),
        method: MessageArgsStreamMethod.fromValue(values.elementAs(2)));
  }
  factory MessageArgsStreamResponse(
      {required List<int> data, required String streamId}) {
    return MessageArgsStreamResponse._(
        data: data, method: MessageArgsStreamMethod.data, streamId: streamId);
  }
  factory MessageArgsStreamResponse.close(String streamId) {
    return MessageArgsStreamResponse._(
        method: MessageArgsStreamMethod.close, streamId: streamId);
  }
  factory MessageArgsStreamResponse.done(String streamId) {
    return MessageArgsStreamResponse._(
        method: MessageArgsStreamMethod.close, streamId: streamId);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          data == null ? null : CborBytesValue(data!),
          streamId,
          method.value
        ]),
        type.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.streamArgs;
}

class MessageArgsException extends CborMessageResponseArgs {
  final String message;
  const MessageArgsException(this.message);
  factory MessageArgsException.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsResponseType.exception.tag);
    return MessageArgsException(StringUtils.decode(values.elementAt(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(StringUtils.encode(message))]),
        ArgsResponseType.exception.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.exception;

  @override
  String toString() {
    return "MessageArgsException:$message";
  }
}

class MessageArgsMessage extends CborMessageResponseArgs {
  final String? message;
  const MessageArgsMessage({this.message});
  factory MessageArgsMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsResponseType.message.tag);
    return MessageArgsMessage(message: values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([message]), ArgsResponseType.message.tag);
  }

  @override
  ArgsResponseType get type => ArgsResponseType.message;

  @override
  String toString() {
    return "MessageArgsMessage:$message";
  }
}

abstract class StreamArgsCompleter<T, A extends CborMessageResponseArgs, S>
    extends StreamArgsRequestable {
  const StreamArgsCompleter();
  Stream<A> getIsolateResult(
      {required String streamId, List<int>? encryptedPart});
  T parsResult(A result);
  MessageArgsStream toRequest({required S message, required String streamId});
  void add(MessageArgsStream args);
  Stream<T> result({List<int>? encryptedPart});
}

abstract class CryptoArgsCompleter<T, A extends CborMessageResponseArgs>
    extends CryptoMessageArgs {
  const CryptoArgsCompleter() : super();
  A getResult();
  T parsResult(A result);
  T result();
}

abstract class NoneEncryptedArgsCompleter<T, A extends CborMessageResponseArgs>
    extends CryptoMessageArgs {
  const NoneEncryptedArgsCompleter() : super();
  Future<A> getResult({List<int>? encryptedPart});
  T parsResult(A result);
  Future<T> result({List<int>? encryptedPart});
}

abstract class WalletArgsCompleter<T, A extends CborMessageResponseArgs>
    with CborSerializable {
  const WalletArgsCompleter() : super();
  Future<A> getResult(
      {required WalletMasterKeys wallet, required List<int> key});
  Future<T> parsResult(A result);
  Future<T> result({required WalletMasterKeys wallet, required List<int> key});
}

class WalletArgs<T, A extends CborMessageResponseArgs,
    R extends WalletArgsCompleter<T, A>> extends CryptoMessageArgs {
  final R args;
  final int version;
  final List<int> nonce;
  final List<int> walletData;
  final List<int> key;
  WalletArgs({
    required this.args,
    required this.version,
    required List<int> walletData,
    required List<int> key,
    required List<int> nonce,
  })  : walletData = walletData.asImmutableBytes,
        key = key.asImmutableBytes,
        nonce = nonce.asImmutableBytes;

  factory WalletArgs.fromStorage(
      {required R args,
      required List<int> encryptedMasterKey,
      required List<int> key}) {
    try {
      final CborListValue values =
          CborSerializable.decode(cborBytes: encryptedMasterKey);
      return WalletArgs(
          args: args,
          version: values.elementAt(0),
          nonce: values.elementAt(1),
          walletData: values.elementAt(2),
          key: key);
    } catch (e) {
      throw WalletExceptionConst.incorrectWalletData;
    }
  }
  factory WalletArgs.deserialize({List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: CryptoArgsType.wallet.tag);
    final WalletArgsCompleter args =
        WalletRequest.deserialize(object: values.getCborTag(0));
    if (args is! R) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return WalletArgs(
        args: args,
        version: values.elementAt(1),
        walletData: values.elementAt(2),
        nonce: values.elementAt(3),
        key: values.elementAt(4));
  }

  Future<A> getResult() {
    final masterKey = CryptoRequestReadMasterKey.getWalletMasterKeys(
        nonce: nonce, walletData: walletData, key: key);
    return args.getResult(wallet: masterKey, key: key);
  }

  Future<T> parseResult(A result) {
    return args.parsResult(result);
  }

  Future<T> result() async {
    final result = await getResult();
    return parseResult(result);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [args.toCbor(), version, walletData, nonce, key]),
        CryptoArgsType.wallet.tag);
  }

  @override
  CryptoArgsType get type => CryptoArgsType.wallet;
}
