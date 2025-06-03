import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/generate_master_key.dart';

class CryptoRequestRestoreBackupMasterKey extends CryptoRequest<
    CryptoRestoreBackupMasterKeyResponse, MessageArgsFourBytes> {
  final String? passphrase;
  final List<int> backup;
  final List<int> key;
  const CryptoRequestRestoreBackupMasterKey._(
      {required this.passphrase, required this.backup, required this.key});

  // Public factory constructor
  factory CryptoRequestRestoreBackupMasterKey(
      {String? passphrase, required List<int> backup, required List<int> key}) {
    return CryptoRequestRestoreBackupMasterKey._(
        passphrase: passphrase, backup: backup, key: key);
  }
  factory CryptoRequestRestoreBackupMasterKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.createMasterKey.tag);
    return CryptoRequestRestoreBackupMasterKey(
        passphrase: values.elementAs(0),
        backup: values.elementAs(1),
        key: values.elementAs(2));
  }

  @override
  MessageArgsFourBytes getResult() {
    final masterKey = WalletMasterKeys.generateFromBackup(
        passphrase: passphrase, bytes: backup);
    final encrypt = masterKey.$1.encrypt(key: key);
    return MessageArgsFourBytes(
        keyOne: masterKey.$1.toCbor().encode(),
        keyTwo: encrypt.$1.toCbor().encode(),
        keyThree: encrypt.$2,
        keyFour: [masterKey.$2 ? 1 : 0]);
  }

  @override
  CryptoRestoreBackupMasterKeyResponse parsResult(MessageArgsFourBytes result) {
    return CryptoRestoreBackupMasterKeyResponse(
      masterKey: WalletMasterKeys.deserialize(bytes: result.keyOne),
      encryptedKey: EncryptedMasterKey.deserialize(bytes: result.keyTwo),
      storageData:
          StringUtils.decode(result.keyThree, type: StringEncoding.base64),
      isValid: result.keyFour[0] == 0 ? false : true,
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [passphrase, CborBytesValue(backup), CborBytesValue(key)]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.createMasterKey;

  @override
  CryptoRestoreBackupMasterKeyResponse result() {
    final masterKey = WalletMasterKeys.generateFromBackup(
        passphrase: passphrase, bytes: backup);
    final encrypt = masterKey.$1.encrypt(key: key);
    return CryptoRestoreBackupMasterKeyResponse(
        encryptedKey: encrypt.$1,
        masterKey: masterKey.$1,
        storageData:
            StringUtils.decode(encrypt.$2, type: StringEncoding.base64),
        isValid: masterKey.$2);
  }
}
