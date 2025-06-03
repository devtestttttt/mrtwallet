import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/nfts/core/core.dart';

class RippleNFToken with Equatable implements NFTCore {
  factory RippleNFToken.deserialize({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: NFTType.ripple.tag);
      final int flags = cbor.elementAs(0);
      final String nftokenId = cbor.elementAs(1);
      final int nftokenTaxon = cbor.elementAs(2);
      final String issuer = cbor.elementAs(3);
      final int serial = cbor.elementAs(4);
      final String? uri = cbor.elementAs(5);

      return RippleNFToken(
          flags: flags,
          issuer: issuer,
          nftokenId: nftokenId,
          nftokenTaxon: nftokenTaxon,
          serial: serial,
          uri: uri);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidNftInformation;
    }
  }
  const RippleNFToken({
    required this.flags,
    required this.nftokenId,
    required this.issuer,
    required this.nftokenTaxon,
    required this.serial,
    required this.uri,
  });
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          flags,
          nftokenId,
          nftokenTaxon,
          issuer,
          serial,
          uri ?? const CborNullValue()
        ]),
        type.tag);
  }

  @override
  final String? uri;
  final String nftokenId;
  final int flags;
  final String issuer;
  final int serial;
  final int nftokenTaxon;

  @override
  List get variabels => [uri, nftokenId, flags, issuer, serial, nftokenTaxon];

  @override
  NFTType get type => NFTType.ripple;

  @override
  String get identifier => nftokenId;
}
