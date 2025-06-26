import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/permission/models/account.dart';

class Web3CosmosSignMessageResponse with CborSerializable {
  final List<int> messageBytes;
  final List<int> signature;
  Web3CosmosSignMessageResponse(
      {required List<int> messageBytes, required List<int> signature})
      : messageBytes = messageBytes.asImmutableBytes,
        signature = signature.asImmutableBytes;
  factory Web3CosmosSignMessageResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);

    return Web3CosmosSignMessageResponse(
        messageBytes: values.elementAs(0), signature: values.elementAs(1));
  }

  Map<String, dynamic> toWalletConnectJson() {
    return {
      "messageBytes":
          StringUtils.decode(messageBytes, type: StringEncoding.base64),
      "signature": StringUtils.decode(signature, type: StringEncoding.base64)
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(messageBytes), CborBytesValue(signature)]),
        CborTagsConst.defaultTag);
  }
}

class Web3CosmosSignMessage
    extends Web3CosmosRequestParam<Web3CosmosSignMessageResponse> {
  final String challeng;
  final String? content;
  Web3CosmosSignMessage._({
    required this.accessAccount,
    required this.challeng,
    required this.content,
  });
  factory Web3CosmosSignMessage({
    required Web3CosmosChainAccount account,
    required String challeng,
    String? content,
  }) {
    return Web3CosmosSignMessage._(
        accessAccount: account, challeng: challeng, content: content);
  }

  factory Web3CosmosSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);

    return Web3CosmosSignMessage(
        account: Web3CosmosChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: values.elementAs(2),
        content: values.elementAs(3));
  }

  @override
  Web3CosmosRequestMethods get method => Web3CosmosRequestMethods.signMessage;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [method.tag, accessAccount.toCbor(), challeng, content]),
        type.tag);
  }

  final Web3CosmosChainAccount accessAccount;
  @override
  Web3CosmosRequest<Web3CosmosSignMessageResponse, Web3CosmosSignMessage>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3CosmosRequest<Web3CosmosSignMessageResponse,
        Web3CosmosSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  Object? toJsWalletResponse(Web3CosmosSignMessageResponse response) {
    return response.toCbor().encode();
  }

  @override
  List<Web3CosmosChainAccount> get requiredAccounts => [accessAccount];
}
