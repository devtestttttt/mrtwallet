import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';

final class CryptoDeriveAddressResponse {
  final NewAccountParams accountParams;
  final CryptoPublicKeyData publicKey;

  CryptoDeriveAddressResponse(
      {required this.accountParams, required this.publicKey});
}
