import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/permission/models/account.dart'
    show Web3AptosChainAccount;

class Web3AptosSignMessageResponse with CborSerializable {
  final String? message;
  final String? nonce;
  final int? chainId;
  final String? address;
  final String? application;
  final String? prefix;
  final String? fullMessage;
  final List<int> signature;

  factory Web3AptosSignMessageResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3AptosSignMessageResponse._(
        message: values.elementAs(0),
        nonce: values.elementAs(1),
        chainId: values.elementAs(2),
        address: values.elementAs(3),
        application: values.elementAs(4),
        prefix: values.elementAs(5),
        fullMessage: values.elementAs(6),
        signature: values.elementAs(7));
  }

  Web3AptosSignMessageResponse._(
      {this.address,
      this.message,
      this.nonce,
      this.chainId,
      this.application,
      this.prefix,
      this.fullMessage,
      required List<int> signature})
      : signature = signature.asImmutableBytes;
  factory Web3AptosSignMessageResponse.aptos({
    String? address,
    required String message,
    required String nonce,
    required String fullMessage,
    required String prefix,
    int? chainId,
    String? application,
    required List<int> signature,
  }) {
    return Web3AptosSignMessageResponse._(
        address: address,
        message: message,
        nonce: nonce,
        chainId: chainId,
        application: application,
        signature: signature,
        fullMessage: fullMessage,
        prefix: prefix);
  }
  factory Web3AptosSignMessageResponse.wallet({required List<int> signature}) {
    return Web3AptosSignMessageResponse._(signature: signature);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          message,
          nonce,
          chainId,
          address,
          application,
          prefix,
          fullMessage,
          CborBytesValue(signature)
        ]),
        CborTagsConst.defaultTag);
  }

  Map<String, dynamic> toWalletConnectJson() {
    return {
      "message": message,
      "nonce": nonce,
      "chainId": chainId,
      "address": address,
      "application": application,
      "prefix": prefix,
      "fullMessage": fullMessage,
      "signature": BytesUtils.toHexString(signature, prefix: "0x")
    };
  }
}

class Web3AptosSignMessage
    extends Web3AptosRequestParam<Web3AptosSignMessageResponse> {
  final String? message;
  final String? nonce;
  final bool? chainId;
  final bool? address;
  final bool? application;
  final String? messageBytes;
  Web3AptosSignMessage._(
      {required this.accessAccount,
      this.message,
      this.nonce,
      this.chainId,
      this.address,
      this.application,
      this.messageBytes});
  factory Web3AptosSignMessage.aptos(
      {required Web3AptosChainAccount account,
      required String message,
      required String nonce,
      bool? chainId,
      bool? address,
      bool? application}) {
    return Web3AptosSignMessage._(
        accessAccount: account,
        message: message,
        nonce: nonce,
        chainId: chainId,
        address: address,
        application: application);
  }
  factory Web3AptosSignMessage.wallet(
      {required Web3AptosChainAccount account, required String message}) {
    return Web3AptosSignMessage._(
        accessAccount: account, messageBytes: message);
  }

  factory Web3AptosSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    return Web3AptosSignMessage._(
        accessAccount: Web3AptosChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        message: values.elementAs(2),
        address: values.elementAs(3),
        application: values.elementAs(4),
        chainId: values.elementAs(5),
        nonce: values.elementAs(6),
        messageBytes: values.elementAs(7));
  }

  @override
  Web3AptosRequestMethods get method => Web3AptosRequestMethods.signMessage;

  @override
  Object? toJsWalletResponse(Web3AptosSignMessageResponse response) {
    return response.toCbor().encode();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          accessAccount.toCbor(),
          message,
          address,
          application,
          chainId,
          nonce,
          messageBytes
        ]),
        type.tag);
  }

  final Web3AptosChainAccount accessAccount;

  @override
  Web3AptosRequest<Web3AptosSignMessageResponse, Web3AptosSignMessage>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3AptosRequest<Web3AptosSignMessageResponse, Web3AptosSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3AptosChainAccount> get requiredAccounts => [accessAccount];
}
