import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart' show NetworkType;
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/global/methods/methods.dart';

class Web3ConnectApplication
    extends Web3GlobalRequestParams<List<NetworkType>> {
  final NetworkType? chain;
  final List<int>? networks;
  factory Web3ConnectApplication.global() {
    return Web3ConnectApplication._();
  }
  factory Web3ConnectApplication.network(NetworkType network) {
    return Web3ConnectApplication._(chain: network);
  }
  factory Web3ConnectApplication.networks(List<int> networks) {
    return Web3ConnectApplication._(
        networks: networks.isEmpty ? null : networks);
  }

  Web3ConnectApplication._({this.chain, this.networks});

  factory Web3ConnectApplication.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletGlobalRequest.tag);
    return Web3ConnectApplication._(
        chain: values.elemetMybeAs<NetworkType, CborStringValue>(
            1, (e) => NetworkType.fromName(e.value)),
        networks: values.elemetMybeAs<List<int>, CborListValue>(
            2, (e) => e.castValue<int>()));
  }

  @override
  Web3GlobalRequestMethods get method => Web3GlobalRequestMethods.connect;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.id,
          chain?.name,
          networks == null ? null : CborListValue.fixedLength(networks!)
        ]),
        type.tag);
  }

  @override
  Object? toJsWalletResponse(response) {
    return null;
  }
}
