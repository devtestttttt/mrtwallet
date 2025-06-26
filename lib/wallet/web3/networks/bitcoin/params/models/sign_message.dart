import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/permission/models/account.dart';

class Web3BitcoinSignMessageResponse with CborSerializable {
  final List<int> signature;
  // final String address;
  final List<int> digest;
  Web3BitcoinSignMessageResponse({
    required List<int> signature,
    required List<int> digest,
  })  : digest = digest.asImmutableBytes,
        signature = signature.asImmutableBytes;

  factory Web3BitcoinSignMessageResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3BitcoinSignMessageResponse(
      signature: values.elementAs(0),
      digest: values.elementAs(1),
    );
  }
  String signatureAsBase64() {
    return StringUtils.decode(signature, type: StringEncoding.base64);
  }

  Map<String, dynamic> toWalletConnectJson() {
    return {
      "signature": BytesUtils.toHexString(signature),
      "digest": BytesUtils.toHexString(digest)
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(signature), CborBytesValue(digest)]),
        CborTagsConst.defaultTag);
  }
}

class Web3BitcoinSignMessage
    extends Web3BitcoinRequestParam<Web3BitcoinSignMessageResponse> {
  final String message;
  final String? messagePrefix;
  final String? content;
  Web3BitcoinSignMessage._(
      {required this.accessAccount,
      required this.message,
      required this.content,
      required this.messagePrefix,
      required this.method});
  factory Web3BitcoinSignMessage(
      {required Web3BitcoinChainAccount account,
      required String message,
      required String? content,
      required String? messagePrefix,
      required Web3NetworkRequestMethods method}) {
    switch (method) {
      case Web3BitcoinRequestMethods.signMessage:
      case Web3BitcoinRequestMethods.signPersonalMessage:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3BitcoinSignMessage._(
        accessAccount: account,
        message: message,
        content: content,
        messagePrefix: messagePrefix,
        method: method.cast());
  }

  factory Web3BitcoinSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAs(0));
    return Web3BitcoinSignMessage(
        method: method,
        account:
            Web3BitcoinChainAccount.deserialize(object: values.getCborTag(1)),
        message: values.elementAs(2),
        content: values.elementAs(3),
        messagePrefix: values.elementAs(4));
  }

  @override
  final Web3BitcoinRequestMethods method;

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
    return response.toCbor().encode();
  }

  @override
  List<Web3BitcoinChainAccount> get requiredAccounts => [accessAccount];
}
