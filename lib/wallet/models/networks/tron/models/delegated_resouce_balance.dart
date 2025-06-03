import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain/on_chain.dart';

class MaxDelegatedResourceAmount {
  MaxDelegatedResourceAmount._(this.amoumt, this.resourceCode);
  factory MaxDelegatedResourceAmount.fromJson(
      Map<String, dynamic> json, int resourceId, WalletTronNetwork network) {
    final resource = ResourceCode.fromValue(resourceId);
    return MaxDelegatedResourceAmount._(
        IntegerBalance.token(
            BigintUtils.tryParse(json["max_size"]) ?? BigInt.zero,
            network.token),
        resource);
  }
  final IntegerBalance amoumt;
  final ResourceCode resourceCode;

  @override
  String toString() {
    return "MaxDelegatedResourceAmount{amount: $amoumt, resource: $resourceCode}";
  }
}
