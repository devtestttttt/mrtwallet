import 'package:blockchain_utils/crypto/crypto/x25519/x25519.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';

class JsCryptoUtils {
  static X25519Keypair generateKey() {
    return X25519Keypair.generate(seed: QuickCrypto.generateRandom());
  }

  static List<int> generateShareKey(
      {required List<int> privateKey, required List<int> peerKey}) {
    return X25519.scalarMult(privateKey, peerKey);
  }
}
