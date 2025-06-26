import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

final class CryptoRequestGenerateJwt
    extends CryptoRequest<String, MessageArgsOneBytes> {
  final String aud;
  const CryptoRequestGenerateJwt(this.aud);

  factory CryptoRequestGenerateJwt.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.jwt.tag);
    return CryptoRequestGenerateJwt(values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([aud]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.jwt;

  @override
  MessageArgsOneBytes getResult() {
    final jwt = result();
    return MessageArgsOneBytes(keyOne: StringUtils.encode(jwt));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return StringUtils.decode(result.keyOne);
  }

  static String _ed25519PublicKeyToIssuer(Ed25519PublicKey key) {
    // Multicodec prefix for Ed25519 public key: 0xED01
    final prefix = [0xED, 0x01];

    // Combine prefix + public key
    final data = [...prefix, ...key.compressed.sublist(1)];

    // Base58btc encode (multibase with prefix "z")
    final base58Encoded = Base58Encoder.encode(data);

    // Return did:key:...
    return 'did:key:z$base58Encoded';
  }

  @override
  String result() {
    final key = Ed25519PrivateKey.fromBytes(QuickCrypto.generateRandom());
    final ait = DateTime.now().subtract(const Duration(minutes: 1));
    final exp = DateTime.now().add(const Duration(days: 1));
    final jwt = Jwt(
      header: JwtHeader(alg: JwtSupportedAlgorithm.eddsa),
      payload: JwtPayload(
          iss: _ed25519PublicKeyToIssuer(key.publicKey),
          aud: [aud],
          sub: BytesUtils.toHexString(QuickCrypto.generateRandom()),
          iat: DateTimeUtils.secondsSinceEpoch(ait),
          exp: DateTimeUtils.secondsSinceEpoch(exp)),
    );
    return jwt.sign(key: key.raw);
  }
}
