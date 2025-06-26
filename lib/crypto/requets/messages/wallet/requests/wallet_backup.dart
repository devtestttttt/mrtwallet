import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

final class WalletRequestBackupWallet
    extends WalletRequest<String, MessageArgsOneBytes> {
  final String key;
  final String? passhrase;
  final String? newPassword;

  const WalletRequestBackupWallet._(
      {required this.key, required this.passhrase, required this.newPassword});

  factory WalletRequestBackupWallet(
      {required String key,
      required String? newPassword,
      required String? passhrase}) {
    return WalletRequestBackupWallet._(
        key: key, newPassword: newPassword, passhrase: passhrase);
  }
  factory WalletRequestBackupWallet.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.walletBackup.tag);
    return WalletRequestBackupWallet(
        key: values.elementAt(0),
        newPassword: values.elementAs(1),
        passhrase: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([key, newPassword, passhrase]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.walletBackup;

  @override
  Future<MessageArgsOneBytes> getResult(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    final encrypt = await result(wallet: wallet, key: key);
    return MessageArgsOneBytes(keyOne: BytesUtils.fromHexString(encrypt));
  }

  @override
  Future<String> parsResult(MessageArgsOneBytes result) async {
    return BytesUtils.toHexString(result.keyOne);
  }

  @override
  Future<String> result(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    final masterKey = WalletMasterKeys.generate(
        mnemonic: wallet.mnemonic().mnemonic.toStr(), passphrase: passhrase);
    if (!BytesUtils.bytesEqual(masterKey.checksum, wallet.checksum)) {
      throw WalletExceptionConst.invalidBackupChecksum;
    }

    final web3SD = Web3SecretStorageDefinationV3.encode(
        wallet.toCbor(backup: true).encode(), newPassword ?? this.key);

    return web3SD.encrypt(encoding: SecretWalletEncoding.cbor);
  }
}
