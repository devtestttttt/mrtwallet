import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

final class WalletRequestReadPrivateKeys
    extends WalletRequest<List<CryptoPrivateKeyData>, MessageArgsOneBytes> {
  final AccessCryptoPrivateKeysRequest request;
  const WalletRequestReadPrivateKeys._(this.request);

  factory WalletRequestReadPrivateKeys(AccessCryptoPrivateKeysRequest request) {
    return WalletRequestReadPrivateKeys._(request);
  }
  factory WalletRequestReadPrivateKeys.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.readPrivateKeys.tag);
    return WalletRequestReadPrivateKeys(
        AccessCryptoPrivateKeysRequest.fromCborBytesOrObject(
            obj: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([request.toCbor()]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.readPrivateKeys;

  @override
  Future<MessageArgsOneBytes> getResult(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    final keys = wallet.readKeys(request.indexes);
    return MessageArgsOneBytes(keyOne: keys.toCbor().encode());
  }

  @override
  Future<List<CryptoPrivateKeyData>> parsResult(
      MessageArgsOneBytes result) async {
    final response =
        CryptoPrivateKeysResponse.fromCborBytesOrObject(bytes: result.keyOne);
    return response.keys;
  }

  @override
  Future<List<CryptoPrivateKeyData>> result(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    final keys = wallet.readKeys(request.indexes);
    return keys.keys;
  }
}
