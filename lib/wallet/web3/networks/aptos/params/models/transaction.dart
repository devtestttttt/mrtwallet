import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/permission/models/account.dart';
import 'package:on_chain/aptos/src/aptos.dart';

class Web3AptosSendTransaction extends Web3AptosRequestParam<List<int>> {
  final AptosRawTransaction transaction;
  final AptosAddress? feePayer;
  final List<AptosAddress>? secondarySignerAddresses;
  final Web3AptosChainAccount accessAccount;

  Web3AptosSendTransaction._(
      {required this.transaction,
      required this.accessAccount,
      required this.method,
      List<AptosAddress>? secondarySignerAddresses,
      this.feePayer})
      : secondarySignerAddresses = secondarySignerAddresses?.imutable;

  factory Web3AptosSendTransaction(
      {required AptosRawTransaction transaction,
      required Web3NetworkRequestMethods method,
      required Web3AptosChainAccount account,
      AptosAddress? feePayer,
      List<AptosAddress>? socondarySignerAddresses}) {
    switch (method) {
      case Web3AptosRequestMethods.signTransaction:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3AptosSendTransaction._(
        transaction: transaction,
        accessAccount: account,
        method: method as Web3AptosRequestMethods,
        feePayer: feePayer,
        secondarySignerAddresses: socondarySignerAddresses);
  }

  factory Web3AptosSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    return Web3AptosSendTransaction(
        account: Web3AptosChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        transaction: AptosRawTransaction.deserialize(values.elementAs(2)),
        feePayer: values.elemetMybeAs<AptosAddress, CborStringValue>(
            3, (e) => AptosAddress(e.value)),
        socondarySignerAddresses:
            values.elemetMybeAs<List<AptosAddress>, CborListValue>(
                4,
                (e) =>
                    e.castValue<String>().map((e) => AptosAddress(e)).toList()),
        method: method);
  }

  @override
  final Web3AptosRequestMethods method;

  // late final bool isSend = method == Web3AptosRequestMethods.sendTransaction;
  // late final bool isBatchRequest =
  //     method == Web3AptosRequestMethods.signAllTransactions;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          accessAccount.toCbor(),
          CborBytesValue(transaction.toBcs()),
          feePayer?.address,
          secondarySignerAddresses == null
              ? null
              : CborListValue.fixedLength(secondarySignerAddresses!
                  .map((e) => CborStringValue(e.address))
                  .toList())
        ]),
        type.tag);
  }

  @override
  Web3AptosRequest<List<int>, Web3AptosSendTransaction> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3AptosRequest<List<int>, Web3AptosSendTransaction>(
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
