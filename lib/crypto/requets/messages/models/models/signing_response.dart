import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/crypto/constant/tags.dart';
import 'package:on_chain_wallet/crypto/keys/keys.dart';

final class GlobalSignResponse with CborSerializable {
  final List<int> signature;
  final AddressDerivationIndex index;
  final CryptoPublicKeyData signerPubKey;
  GlobalSignResponse({
    required List<int> signature,
    required this.index,
    required this.signerPubKey,
  }) : signature = signature.asImmutableBytes;

  factory GlobalSignResponse.deserialize(List<int> bytes) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, tags: CryptoKeyConst.globalSignature);
    final index = AddressDerivationIndex.deserialize(obj: values.getCborTag(0));
    final List<int> signature = values.elementAt(1);
    return GlobalSignResponse(
        signature: signature,
        index: index,
        signerPubKey: CryptoPublicKeyData.fromCborBytesOrObject(
            obj: values.getCborTag(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [index.toCbor(), signature, signerPubKey.toCbor()]),
        CryptoKeyConst.globalSignature);
  }
}
