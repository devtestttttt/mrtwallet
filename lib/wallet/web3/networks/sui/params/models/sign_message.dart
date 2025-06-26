import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/permission/models/account.dart';

class Web3SuiSignMessageResponse with CborSerializable {
  final List<int> messageBytes;
  final List<int> signature;
  Web3SuiSignMessageResponse(
      {required List<int> messageBytes, required List<int> signature})
      : messageBytes = messageBytes.asImmutableBytes,
        signature = signature.asImmutableBytes;

  factory Web3SuiSignMessageResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3SuiSignMessageResponse(
        messageBytes: values.elementAs(0), signature: values.elementAs(1));
  }
  String get messageAsBase64 =>
      StringUtils.decode(messageBytes, type: StringEncoding.base64);
  String get signatureAsBase64 =>
      StringUtils.decode(signature, type: StringEncoding.base64);
  Map<String, dynamic> toWalletConnectJson() {
    return {"messageBytes": messageAsBase64, "signature": signatureAsBase64};
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(messageBytes),
          CborBytesValue(signature),
        ]),
        CborTagsConst.defaultTag);
  }
}

class Web3SuiSignMessage
    extends Web3SuiRequestParam<Web3SuiSignMessageResponse> {
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
  Web3SuiRequest<Web3SuiSignMessageResponse, Web3SuiSignMessage> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SuiRequest<Web3SuiSignMessageResponse, Web3SuiSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  Object? toJsWalletResponse(Web3SuiSignMessageResponse response) {
    return response.toCbor().encode();
  }

  @override
  List<Web3SuiChainAccount> get requiredAccounts => [accessAccount];
}
