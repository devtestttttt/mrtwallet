import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/tron/models/delegated_resouce_balance.dart';
import 'package:on_chain/tron/tron.dart';

class TronRequestGetCanDelegatedMaxSizeV2
    extends TronRequest<MaxDelegatedResourceAmount, Map<String, dynamic>> {
  TronRequestGetCanDelegatedMaxSizeV2(
      {required this.ownerAddress,
      required this.type,
      required this.network,
      this.visible = true});
  final TronAddress ownerAddress;
  final WalletTronNetwork network;

  /// resource type, 0 is bandwidth, 1 is energy
  final int type;
  @override
  final bool visible;

  /// wallet/getcandelegatedmaxsize
  @override
  TronHTTPMethods get method => TronHTTPMethods.getcandelegatedmaxsize;

  @override
  Map<String, dynamic> toJson() {
    return {"owner_address": ownerAddress, "type": type, "visible": visible};
  }

  @override
  MaxDelegatedResourceAmount onResonse(Map<String, dynamic> result) {
    return MaxDelegatedResourceAmount.fromJson(result, type, network);
  }

  @override
  String toString() {
    return "TronRequestGetCanDelegatedMaxSize{${toJson()}}";
  }
}
