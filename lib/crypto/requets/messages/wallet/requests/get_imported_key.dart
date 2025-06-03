import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

final class WalletRequestReadImportedKey
    extends WalletRequest<CryptoPrivateKeyData, MessageArgsOneBytes> {
  final String keyId;
  WalletRequestReadImportedKey._(this.keyId);

  factory WalletRequestReadImportedKey(String keyId) {
    return WalletRequestReadImportedKey._(keyId);
  }

  factory WalletRequestReadImportedKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.readImportKey.tag);
    return WalletRequestReadImportedKey(values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([keyId]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.readImportKey;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final importedKey = wallet.getImportedKey(keyId);
    return MessageArgsOneBytes(keyOne: importedKey.toCbor().encode());
  }

  @override
  PrivateKeyData parsResult(MessageArgsOneBytes result) {
    return PrivateKeyData.deserialize(bytes: result.keyOne);
  }

  @override
  CryptoPrivateKeyData result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    return wallet.getImportedKey(keyId);
  }
}
