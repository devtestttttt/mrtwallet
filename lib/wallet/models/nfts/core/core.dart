import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/nfts/networks/ripple.dart';

enum NFTType {
  ripple(CborTagsConst.rippleNfts);

  final List<int> tag;
  const NFTType(this.tag);

  static NFTType fromTag(List<int>? tag) {
    return values.firstWhere(
      (e) => BytesUtils.bytesEqual(e.tag, tag),
      orElse: () => throw WalletExceptionConst.invalidNftInformation,
    );
  }
}

abstract class NFTCore with CborSerializable {
  abstract final String? uri;
  NFTType get type;
  String get identifier;

  static T deserialize<T extends NFTCore>({List<int>? bytes, CborObject? obj}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    final type = NFTType.fromTag(tag.tags);
    final NFTCore nft = switch (type) {
      NFTType.ripple => RippleNFToken.deserialize(bytes: bytes, obj: obj),
    };
    if (nft is! T) {
      throw WalletException.invalidArgruments(["$T", "${nft.runtimeType}"]);
    }
    return nft;
  }
}
