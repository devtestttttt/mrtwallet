import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/wc_sym_key.dart';

final class CryptoRequestGenerateWalletConnectSymKeyInfo
    extends CryptoRequest<GeneratedSharedKey, MessageArgsThreeBytes> {
  final String publicKey;
  final bool hashKey;
  const CryptoRequestGenerateWalletConnectSymKeyInfo(
      {required this.publicKey, required this.hashKey});

  factory CryptoRequestGenerateWalletConnectSymKeyInfo.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.symkey.tag);
    return CryptoRequestGenerateWalletConnectSymKeyInfo(
        publicKey: values.elementAt(0), hashKey: values.elementAs(1));
  }

  static (List<int>, List<int>) encrypt(
      {required List<int> key,
      required int nonceLength,
      required List<int> message,
      List<int>? nonce}) {
    final chacha = ChaCha20Poly1305(key);
    nonce ??= QuickCrypto.generateRandom(nonceLength);
    final encrypt = chacha.encrypt(nonce, message);
    return (encrypt, nonce);
  }

  @override
  MessageArgsThreeBytes getResult() {
    final data = result();
    return MessageArgsThreeBytes(
        keyOne: data.symkey, keyTwo: data.publicKey, keyThree: data.topic);
  }

  @override
  GeneratedSharedKey parsResult(MessageArgsThreeBytes result) {
    return GeneratedSharedKey(
        symkey: result.keyOne,
        publicKey: result.keyTwo,
        topic: result.keyThree);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([publicKey, hashKey]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.symkey;

  @override
  GeneratedSharedKey result() {
    List<int> peerKey;
    if (hashKey) {
      peerKey = X25519
          .scalarMultBase(QuickCrypto.sha256Hash(publicKey.codeUnits))
          .publicKey;
    } else {
      peerKey = BytesUtils.fromHexString(publicKey);
    }
    final kp = X25519Keypair.generate(seed: QuickCrypto.generateRandom());
    final sharedKey1 = X25519.scalarMult(kp.privateKey, peerKey);
    final hdkf = HKDF(
        ikm: sharedKey1,
        hash: () => SHA256(),
        length: X25519KeyConst.privateKeyLength);
    final symKey = hdkf.derive().asImmutableBytes;
    return GeneratedSharedKey(
        topic: QuickCrypto.sha256Hash(symKey),
        publicKey: kp.publicKey,
        symkey: symKey);
  }
}
