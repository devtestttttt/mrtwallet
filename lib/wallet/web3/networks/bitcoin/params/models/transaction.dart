import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/permission/models/account.dart';

class Web3BitcoinSignTransaction extends Web3BitcoinRequestParam<String> {
  final List<Web3BitcoinChainAccount> accounts;
  final Web3BitcoinChainAccount accessAccount;
  final Psbt psbt;

  Web3BitcoinSignTransaction._({
    required this.accounts,
    required this.psbt,
    required this.accessAccount,
  });
  factory Web3BitcoinSignTransaction(
      {required List<Web3BitcoinChainAccount> accounts, required Psbt psbt}) {
    final networks = accounts.map((e) => e.id).toSet();
    if (networks.length != 1) {
      throw Web3RequestExceptionConst.internalError;
    }
    return Web3BitcoinSignTransaction._(
        accounts: accounts, psbt: psbt, accessAccount: accounts[0]);
  }

  factory Web3BitcoinSignTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3BitcoinSignTransaction(
        accounts: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => Web3BitcoinChainAccount.deserialize(object: e))
            .toList(),
        psbt: Psbt.deserialize(values.elementAs(2)));
  }

  @override
  Web3BitcoinRequestMethods get method =>
      Web3BitcoinRequestMethods.signTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          CborBytesValue(psbt.serialize())
        ]),
        type.tag);
  }

  @override
  Web3BitcoinRequest<String, Web3BitcoinSignTransaction> toRequest(
      {required Web3RequestInformation request,
      required Web3RequestAuthentication authenticated,
      required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3BitcoinRequest<String, Web3BitcoinSignTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3BitcoinChainAccount> get requiredAccounts => accounts;
}
