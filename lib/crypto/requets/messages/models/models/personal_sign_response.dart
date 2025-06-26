import 'package:blockchain_utils/blockchain_utils.dart';

final class CryptoPersonalSignResponse {
  final String signatureHex;
  final List<int> signature;
  CryptoPersonalSignResponse({
    required this.signatureHex,
    required List<int> signature,
  }) : signature = signature.asImmutableBytes;
}

final class CryptoBitcoinPersonalSignResponse {
  final List<int> signature;
  final List<int> digest;
  CryptoBitcoinPersonalSignResponse({
    required List<int> signature,
    required List<int> digest,
  })  : digest = digest.asImmutableBytes,
        signature = signature.asImmutableBytes;
}
