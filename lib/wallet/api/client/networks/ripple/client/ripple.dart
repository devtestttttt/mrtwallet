import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/ripple/methods/methods.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/ripple/ripple.dart';
import 'package:on_chain_wallet/wallet/models/token/token.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/xrp.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

class _RippleApiProviderConst {
  static const int accountNotFound = 19;
}

class RippleClient
    extends NetworkClient<XRPWalletTransaction, RippleAPIProvider> {
  RippleClient({required this.provider, required this.network});
  final XRPProvider provider;
  @override
  final WalletXRPNetwork network;

  @override
  BaseServiceProtocol<RippleAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<RippleAPIProvider>;

  Future<BigInt> getAccountBalance(XRPAddress address) async {
    final accountInfo = await getAccountInfo(address.address);
    if (accountInfo == null) return BigInt.zero;
    return BigintUtils.parse(accountInfo.accountData.balance);
  }

  Future<List<XRPIssueToken>> getAccountTokens(XRPAddress address) async {
    return await provider.request(XRPRPCFetchTokens(account: address.address));
  }

  Future<XRPAccountObjectEntry?> getAccountSignerList(String address) async {
    try {
      return await provider
          .request(XRPRPCSignerAccountObject(account: address));
    } on RPCError catch (e) {
      if (e.errorCode == _RippleApiProviderConst.accountNotFound) {
        return null;
      }
      rethrow;
    }
  }

  Future<AccountInfo?> getAccountInfo(String address) async {
    try {
      return await provider.request(XRPRequestAccountInfo(account: address));
    } on RPCError catch (e) {
      if (e.errorCode == _RippleApiProviderConst.accountNotFound) {
        return null;
      }
      rethrow;
    }
  }

  Future<(String?, XRPAccountObjectEntry?)?> getAccountRegularAndSignerList(
      String address) async {
    final account = await getAccountInfo(address);
    if (account == null) return null;
    final signers = await getAccountSignerList(address);
    if (signers == null && account.accountData.regularKey == null) {
      return null;
    }
    final signerObject =
        (signers?.signerEntries.isEmpty ?? true) ? null : signers!;
    return (account.accountData.regularKey, signerObject);
  }

  Future<List<RippleIssueToken>> accountTokens(IXRPAddress address) async {
    final tokens = await provider
        .request(XRPRPCFetchTokens(account: address.address.toAddress));
    return tokens
        .map((e) => RippleIssueToken.create(
            balance: e.balance,
            token: NonDecimalToken(name: e.symbol, symbol: e.symbol),
            issuer: e.issuer.address,
            assetCode: e.symbol))
        .toList();
  }

  Future<ServerInfo> getServerInfo() async {
    return await provider.request(XRPRequestServerInfo());
  }

  Future<XRPLTransactionResult> sendTransaction(String blob) async {
    return await provider.request(XRPRequestSubmitOnly(txBlob: blob));
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    try {
      return await provider
          .request(XRPRequestTransactionStatus(transaction: txId));
    } catch (_) {
      return WalletTransactionStatus.unknown;
    }
  }

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call(() async {
      return getServerInfo();
    });
    return result.hasResult &&
        result.result.info.networkId == network.coinParam.networkId;
  }

  @override
  NetworkType get networkType => NetworkType.xrpl;
}
