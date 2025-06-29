import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/wc_sym_key.dart';

final class CryptoRequestGenerateWalletConnectSymKeyInfo
    extends CryptoRequest<GeneratedSharedKey, MessageArgsThreeBytes> {
  final List<int> publicKey;
  final List<int> privateKey;
  CryptoRequestGenerateWalletConnectSymKeyInfo._(
      {required List<int> publicKey, required List<int> privateKey})
      : publicKey = publicKey.asImmutableBytes,
        privateKey = privateKey.asImmutableBytes;
  factory CryptoRequestGenerateWalletConnectSymKeyInfo(
      {required String publicKey, required List<int> privateKey}) {
    return CryptoRequestGenerateWalletConnectSymKeyInfo._(
        publicKey: BytesUtils.fromHexString(publicKey), privateKey: privateKey);
  }

  factory CryptoRequestGenerateWalletConnectSymKeyInfo.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.symkey.tag);
    return CryptoRequestGenerateWalletConnectSymKeyInfo._(
        publicKey: values.elementAt(0), privateKey: values.elementAs(1));
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
        CborListValue.fixedLength([publicKey, privateKey]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.symkey;

  @override
  GeneratedSharedKey result() {
    final kp = X25519Keypair.generate(seed: privateKey);
    final sharedKey1 = X25519.scalarMult(kp.privateKey, publicKey);
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

final class CryptoRequestGenerateX25519Key
    extends CryptoRequest<GeneratedX25519Key, MessageArgsTwoBytes> {
  final List<int>? seed;
  const CryptoRequestGenerateX25519Key({this.seed});

  factory CryptoRequestGenerateX25519Key.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.x25519.tag);
    return CryptoRequestGenerateX25519Key(seed: values.elementAt(0));
  }

  @override
  MessageArgsTwoBytes getResult() {
    final data = result();
    return MessageArgsTwoBytes(
      keyOne: data.publicKey,
      keyTwo: data.privateKey,
    );
  }

  @override
  GeneratedX25519Key parsResult(MessageArgsTwoBytes result) {
    return GeneratedX25519Key(
        publicKey: result.keyOne, privateKey: result.keyTwo);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([seed]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.x25519;

  @override
  GeneratedX25519Key result() {
    final kp = X25519Keypair.generate(
        seed: seed == null
            ? QuickCrypto.generateRandom()
            : QuickCrypto.sha256Hash(seed!));
    return GeneratedX25519Key(
        publicKey: kp.publicKey, privateKey: kp.privateKey);
  }
}
