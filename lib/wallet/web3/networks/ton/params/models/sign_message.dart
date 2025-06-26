import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/permission/models/account.dart';

class Web3TonSignMessageResponse with CborSerializable {
  final List<int> signature;
  Web3TonSignMessageResponse({required List<int> signature})
      : signature = signature.asImmutableBytes;
  factory Web3TonSignMessageResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3TonSignMessageResponse(signature: values.elementAs(0));
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

class Web3TonSignMessage
    extends Web3TonRequestParam<Web3TonSignMessageResponse> {
  final Web3TonChainAccount accessAccount;
  final String challeng;
  final String? content;

  Web3TonSignMessage(
      {required this.accessAccount, required this.challeng, this.content});

  factory Web3TonSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final List<int> challeng = values.elementAt(2);
    return Web3TonSignMessage(
        accessAccount: Web3TonChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3TonRequestMethods get method => Web3TonRequestMethods.signMessage;

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
  Web3TonRequest<Web3TonSignMessageResponse, Web3TonSignMessage> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3TonRequest<Web3TonSignMessageResponse, Web3TonSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3TonChainAccount> get requiredAccounts => [accessAccount];

  @override
  Object? toJsWalletResponse(Web3TonSignMessageResponse response) {
    return response.toCbor().encode();
  }
}
