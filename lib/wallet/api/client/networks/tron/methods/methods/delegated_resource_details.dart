import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/tron/models/account_delegated_resource_info.dart';
import 'package:on_chain/tron/tron.dart';

/// In Stake2.0, query the detail of resource share delegated from fromAddress to toAddress
/// [developers.tron.network](https://developers.tron.network/reference/getdelegatedresourcev2).
class TronRequestGetDelegatedResourceV2Details
    extends TronRequest<DelegatedAccountResourceInfo, Map<String, dynamic>> {
  TronRequestGetDelegatedResourceV2Details(
      {required this.fromAddress,
      required this.toAddress,
      required this.network,
      this.visible = true});

  /// resource from address
  final TronAddress fromAddress;

  /// resource to address
  final TronAddress toAddress;

  final WalletTronNetwork network;
  @override
  final bool visible;

  /// wallet/getdelegatedresourcev2
  @override
  TronHTTPMethods get method => TronHTTPMethods.getdelegatedresourcev2;

  @override
  Map<String, dynamic> toJson() {
    return {
      "fromAddress": fromAddress,
      "toAddress": toAddress,
      "visible": visible
    };
  }

  @override
  String toString() {
    return "TronRequestGetDelegatedResourceV2{${toJson()}}";
  }

  @override
  DelegatedAccountResourceInfo onResonse(Map<String, dynamic> result) {
    return DelegatedAccountResourceInfo.fromJson(result, network);
  }
}
