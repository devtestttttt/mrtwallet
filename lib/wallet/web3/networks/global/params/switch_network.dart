import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart' show NetworkType;
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/global/methods/methods.dart';

class Web3SwitchApplicationNetwork
    extends Web3GlobalRequestParams<List<NetworkType>> {
  final NetworkType chain;
  final int id;

  Web3SwitchApplicationNetwork({required this.chain, required this.id});

  factory Web3SwitchApplicationNetwork.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletGlobalRequest.tag);
    return Web3SwitchApplicationNetwork(
        chain: NetworkType.fromName(values.elementAs(1)),
        id: values.elementAs(2));
  }

  @override
  Web3GlobalRequestMethods get method => Web3GlobalRequestMethods.switchNetwork;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([method.id, chain.name, id]), type.tag);
  }

  @override
  Object? toJsWalletResponse(response) {
    return null;
  }
}
