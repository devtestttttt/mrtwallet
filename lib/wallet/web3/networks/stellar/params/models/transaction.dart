import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/permission/models/account.dart';

class Web3StellarSendTransactionResponse with CborSerializable {
  final String envlope;
  final String? txHash;

  const Web3StellarSendTransactionResponse(
      {required this.envlope, this.txHash});
  factory Web3StellarSendTransactionResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3StellarSendTransactionResponse(
        envlope: values.elementAs(0), txHash: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([envlope, txHash]), CborTagsConst.defaultTag);
  }

  Map<String, dynamic> toWalletConnectJson() {
    return {if (txHash != null) "txId": txHash, "envlope": envlope};
  }
  // Map<String, dynamic> toJson() {
  //   return {"envlope": envlope, "tx_hash": txHash};
  // }

  // factory Web3StellarSendTransactionResponse.fromJson(
  //     Map<String, dynamic> json) {
  //   return Web3StellarSendTransactionResponse(
  //       envlope: json["envlope"], txHash: json["tx_hash"]);
  // }
}

class Web3StellarSendTransaction
    extends Web3StellarRequestParam<Web3StellarSendTransactionResponse> {
  final List<int> transaction;
  Web3StellarSendTransaction._({
    required this.accessAccount,
    required List<int> transaction,
    required this.method,
  }) : transaction = transaction.asImmutableBytes;
  factory Web3StellarSendTransaction({
    required Web3StellarChainAccount account,
    required List<int> transaction,
    required Web3StellarRequestMethods method,
  }) {
    switch (method) {
      case Web3StellarRequestMethods.sendTransaction:
      case Web3StellarRequestMethods.signTransaction:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3StellarSendTransaction._(
        accessAccount: account, transaction: transaction, method: method);
  }

  factory Web3StellarSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3StellarSendTransaction(
        account: Web3StellarChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        transaction: values.elementAt(2),
        method: Web3StellarRequestMethods.fromId(
            values.elementAt<List<int>>(0).last));
  }

  @override
  final Web3StellarRequestMethods method;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [method.tag, accessAccount.toCbor(), CborBytesValue(transaction)]),
        type.tag);
  }

  @override
  Web3StellarRequest<Web3StellarSendTransactionResponse,
          Web3StellarSendTransaction>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3StellarRequest<Web3StellarSendTransactionResponse,
        Web3StellarSendTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  Object? toJsWalletResponse(Web3StellarSendTransactionResponse response) {
    return response.toCbor().encode();
  }

  final Web3StellarChainAccount accessAccount;

  @override
  List<Web3StellarChainAccount> get requiredAccounts => [accessAccount];
}
