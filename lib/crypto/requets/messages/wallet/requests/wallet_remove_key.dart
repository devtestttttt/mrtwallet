import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/generate_master_key.dart';

final class WalletRequestRemoveKey extends WalletRequest<
    CryptoGenerateMasterKeyResponse, MessageArgsThreeBytes> {
  final String keyId;
  const WalletRequestRemoveKey._(this.keyId);

  factory WalletRequestRemoveKey(String keyId) {
    return WalletRequestRemoveKey._(keyId);
  }
  factory WalletRequestRemoveKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.removeWalletKeys.tag);
    return WalletRequestRemoveKey(values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([keyId]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.removeWalletKeys;

  @override
  MessageArgsThreeBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final newWallet = wallet.removeKey(keyId);
    final encryptWallet = newWallet.encrypt(key: key);
    return MessageArgsThreeBytes(
        keyOne: encryptWallet.$1.toCbor().encode(),
        keyTwo: encryptWallet.$2,
        keyThree: key);
  }

  @override
  CryptoGenerateMasterKeyResponse parsResult(MessageArgsThreeBytes result) {
    return CryptoGenerateMasterKeyResponse(
        masterKey: EncryptedMasterKey.deserialize(bytes: result.keyOne),
        storageData:
            StringUtils.decode(result.keyTwo, type: StringEncoding.base64),
        walletKey: result.keyThree);
  }

  @override
  CryptoGenerateMasterKeyResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final newWallet = wallet.removeKey(keyId);
    final encryptWallet = newWallet.encrypt(key: key);
    return CryptoGenerateMasterKeyResponse(
        masterKey: encryptWallet.$1,
        storageData:
            StringUtils.decode(encryptWallet.$2, type: StringEncoding.base64),
        walletKey: key);
  }
}
