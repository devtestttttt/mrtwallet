import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/permission/models/account.dart';

class Web3SuiSignMessageResponse {
  final String messageBytes;
  final String signature;
  const Web3SuiSignMessageResponse(
      {required this.messageBytes, required this.signature});
  factory Web3SuiSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return Web3SuiSignMessageResponse(
        messageBytes: json["messageBytes"], signature: json["signature"]);
  }
  Map<String, dynamic> toJson() {
    return {"messageBytes": messageBytes, "signature": signature};
  }
}

class Web3SuiSignMessage extends Web3SuiRequestParam<Map<String, dynamic>> {
  final String challeng;
  final String? content;
  Web3SuiSignMessage._({
    required this.accessAccount,
    required this.challeng,
    required this.content,
    required this.method,
  });
  factory Web3SuiSignMessage({
    required Web3SuiChainAccount account,
    required String challeng,
    required Web3NetworkRequestMethods method,
    String? content,
  }) {
    switch (method) {
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3SuiSignMessage._(
        accessAccount: account,
        challeng: challeng,
        content: content,
        method: method as Web3SuiRequestMethods);
  }

  factory Web3SuiSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));

    return Web3SuiSignMessage(
        account: Web3SuiChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: values.elementAs(2),
        content: values.elementAs(3),
        method: method);
  }

  @override
  final Web3SuiRequestMethods method;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [method.tag, accessAccount.toCbor(), challeng, content]),
        type.tag);
  }

  final Web3SuiChainAccount accessAccount;
  @override
  Web3SuiRequest<Map<String, dynamic>, Web3SuiSignMessage> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SuiRequest<Map<String, dynamic>, Web3SuiSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3SuiChainAccount> get requiredAccounts => [accessAccount];
}
