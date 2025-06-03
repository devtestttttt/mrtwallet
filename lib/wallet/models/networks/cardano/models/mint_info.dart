import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain/ada/ada.dart';

class ADAMintInfo {
  final Assets assets;
  final NativeScript script;
  final ADAAddress owner;
  final List<int> pubKeyBytes;
  PolicyID toPolicyId() {
    return PolicyID(script.toHash().data);
  }

  ADAMintInfo(
      {required this.assets,
      required this.script,
      required this.owner,
      required List<int> pubKeyBytes})
      : pubKeyBytes = pubKeyBytes.asImmutableBytes;

  late final UtxoAssets toUtxoAssets = _toUtxoAssets();
  late final UtxoMultiAsset toMultiAsset = _toMultiAsset();
  UtxoAssets _toUtxoAssets() {
    final Map<AssetName, IntegerBalance> multiAssets = {};
    for (final i in assets.assets.entries) {
      multiAssets[i.key] = IntegerBalance.token(
          i.value, Token(name: i.key.name, symbol: i.key.name, decimal: 0));
    }
    return UtxoAssets(multiAssets);
  }

  UtxoMultiAsset _toMultiAsset() {
    return UtxoMultiAsset({toPolicyId(): _toUtxoAssets()});
  }

  ADAMinsBuilder toMintBuilder() {
    return ADAMinsBuilder(
        pubKeyBytes: pubKeyBytes, mintingAssets: assets, owner: owner);
  }
}
