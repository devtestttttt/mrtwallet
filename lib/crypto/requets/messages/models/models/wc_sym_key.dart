import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';

class GeneratedSharedKey {
  final List<int> topic;
  final List<int> publicKey;
  final List<int> symkey;
  GeneratedSharedKey(
      {required List<int> topic,
      required List<int> publicKey,
      required List<int> symkey})
      : topic = topic.asImmutableBytes,
        publicKey = publicKey.asImmutableBytes,
        symkey = symkey.asImmutableBytes;
  late final String topicAsHex = BytesUtils.toHexString(topic);
  late final String publicKeyAsHex = BytesUtils.toHexString(publicKey);
  late final String symkeyAsHex = BytesUtils.toHexString(symkey);
}

class GeneratedX25519Key {
  final List<int> publicKey;
  final List<int> privateKey;
  GeneratedX25519Key(
      {required List<int> privateKey, required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes,
        privateKey = privateKey.asImmutableBytes;
  late final String publicKeyAsHex = BytesUtils.toHexString(publicKey);
}
