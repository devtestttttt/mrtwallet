import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

final class WalletRequestBackupWallet
    extends WalletRequest<String, MessageArgsOneBytes> {
  final String key;

  const WalletRequestBackupWallet._(this.key);

  factory WalletRequestBackupWallet(String key) {
    return WalletRequestBackupWallet._(key);
  }
  factory WalletRequestBackupWallet.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.walletBackup.tag);
    return WalletRequestBackupWallet(values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([key]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.walletBackup;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final encrypt = result(wallet: wallet, key: key);
    return MessageArgsOneBytes(keyOne: BytesUtils.fromHexString(encrypt));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return BytesUtils.toHexString(result.keyOne);
  }

  @override
  String result({required WalletMasterKeys wallet, required List<int> key}) {
    final web3SD = Web3SecretStorageDefinationV3.encode(
        wallet.toCbor(backup: true).encode(), this.key);
    return web3SD.encrypt(encoding: SecretWalletEncoding.cbor);
  }
}
