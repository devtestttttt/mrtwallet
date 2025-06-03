import 'package:blockchain_utils/helper/helper.dart';
import 'package:on_chain_wallet/crypto/keys/keys.dart';

final class CryptoGenerateMasterKeyResponse {
  final EncryptedMasterKey masterKey;
  final String storageData;
  final List<int> walletKey;
  CryptoGenerateMasterKeyResponse({
    required this.masterKey,
    required this.storageData,
    required List<int> walletKey,
  }) : walletKey = walletKey.asImmutableBytes;
}

final class CryptoRestoreBackupMasterKeyResponse {
  final EncryptedMasterKey encryptedKey;
  final WalletMasterKeys masterKey;
  final String storageData;
  final bool isValid;
  CryptoRestoreBackupMasterKeyResponse({
    required this.encryptedKey,
    required this.masterKey,
    required this.storageData,
    required this.isValid,
  });
}
