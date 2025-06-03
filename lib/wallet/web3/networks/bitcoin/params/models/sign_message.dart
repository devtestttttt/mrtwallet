import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/permission/models/account.dart';

class Web3BitcoinSignMessageResponse {
  final String signature;
  final List<int> digest;
  Web3BitcoinSignMessageResponse(
      {required this.signature, required List<int> digest})
      : digest = digest.asImmutableBytes;
  factory Web3BitcoinSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return Web3BitcoinSignMessageResponse(
        digest: (json["digest"] as List).cast(), signature: json["signature"]);
  }
  Map<String, dynamic> toJson() {
    return {"signature": signature, "digest": digest};
  }
}

class Web3BitcoinSignMessage
    extends Web3BitcoinRequestParam<Web3BitcoinSignMessageResponse> {
  final String message;
  final String? messagePrefix;
  final String? content;
  Web3BitcoinSignMessage(
      {required this.accessAccount,
      required this.message,
      required this.content,
      required this.messagePrefix});

  factory Web3BitcoinSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);

    return Web3BitcoinSignMessage(
        accessAccount:
            Web3BitcoinChainAccount.deserialize(object: values.getCborTag(1)),
        message: values.elementAs(2),
        content: values.elementAs(3),
        messagePrefix: values.elementAs(4));
  }

  @override
  Web3BitcoinRequestMethods get method =>
      Web3BitcoinRequestMethods.signPersonalMessage;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          accessAccount.toCbor(),
          message,
          content,
          messagePrefix
        ]),
        type.tag);
  }

  final Web3BitcoinChainAccount accessAccount;

  @override
  Web3BitcoinRequest<Web3BitcoinSignMessageResponse, Web3BitcoinSignMessage>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3BitcoinRequest<Web3BitcoinSignMessageResponse,
        Web3BitcoinSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  Object? toJsWalletResponse(Web3BitcoinSignMessageResponse response) {
    return response.toJson();
  }

  @override
  List<Web3BitcoinChainAccount> get requiredAccounts => [accessAccount];
}
