import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/permission/models/account.dart';

class Web3StellarSignMessageResponse with CborSerializable {
  final List<int> signature;
  Web3StellarSignMessageResponse({required List<int> signature})
      : signature = signature.asImmutableBytes;
  factory Web3StellarSignMessageResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3StellarSignMessageResponse(signature: values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([signature]), CborTagsConst.defaultTag);
  }

  Map<String, dynamic> toWalletConnectJson() {
    return {
      "signature": StringUtils.decode(signature, type: StringEncoding.base64)
    };
  }
}

class Web3StellarSignMessage
    extends Web3StellarRequestParam<Web3StellarSignMessageResponse> {
  final Web3StellarChainAccount accessAccount;
  final String challeng;
  final String? content;

  Web3StellarSignMessage(
      {required this.accessAccount, required this.challeng, this.content});

  factory Web3StellarSignMessage.deserialize({
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
    return Web3StellarSignMessage(
        accessAccount: Web3StellarChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3StellarRequestMethods get method => Web3StellarRequestMethods.signMessage;

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
  Web3StellarRequest<Web3StellarSignMessageResponse, Web3StellarSignMessage>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3StellarRequest<Web3StellarSignMessageResponse,
        Web3StellarSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3StellarChainAccount> get requiredAccounts => [accessAccount];

  @override
  Object? toJsWalletResponse(Web3StellarSignMessageResponse response) {
    return response.toCbor().encode();
  }
}
