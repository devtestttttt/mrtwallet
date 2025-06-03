import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/permission/models/account.dart';

class Web3TronSignMessageV2 extends Web3TronRequestParam<String> {
  final Web3TronChainAccount accessAccount;
  final String challeng;
  final String? content;

  Web3TronSignMessageV2(
      {required this.accessAccount, required this.challeng, this.content});

  factory Web3TronSignMessageV2.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final List<int> challeng = values.elementAt(2);
    return Web3TronSignMessageV2(
        accessAccount: Web3TronChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3TronRequestMethods get method => Web3TronRequestMethods.signMessageV2;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          accessAccount.toCbor(),
          CborBytesValue(BytesUtils.fromHexString(challeng)),
          content
        ]),
        type.tag);
  }

  List<int> chalengBytes() {
    return BytesUtils.fromHexString(challeng);
  }

  @override
  Web3TronRequest<String, Web3TronSignMessageV2> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3TronRequest<String, Web3TronSignMessageV2>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3TronChainAccount> get requiredAccounts => [accessAccount];
}
