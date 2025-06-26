import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:on_chain_wallet/wallet/web3/state/state.dart';
import 'package:stellar_dart/stellar_dart.dart';
import '../../models/models/networks/stellar.dart';
import '../../models/models/networks/wallet_standard.dart';
import '../../models/models/requests.dart';
import '../core/network_handler.dart';

class StellarWeb3JSStateAddress extends Web3JSStateAddress<
    StellarAddress,
    Web3StellarChainAccount,
    JSStellarWalletAccount,
    Web3ChainDefaultIdnetifier> {
  const StellarWeb3JSStateAddress(
      {required super.chainaccount,
      required super.jsAccount,
      required super.networkIdentifier});
}

class StellarWeb3JSStateAccount extends Web3JSStateAccount<
    StellarAddress,
    Web3StellarChainAccount,
    JSStellarWalletAccount,
    Web3ChainDefaultIdnetifier,
    StellarWeb3JSStateAddress> {
  StellarWeb3JSStateAccount._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory StellarWeb3JSStateAccount.init(
      {Web3NetworkState state = Web3NetworkState.disconnect}) {
    return StellarWeb3JSStateAccount._(
        accounts: const [], state: state, chains: []);
  }
  factory StellarWeb3JSStateAccount(
      Web3StellarChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return StellarWeb3JSStateAccount.init(state: Web3NetworkState.block);
    }
    final networks = {for (final i in authenticated.networks) i.id: i};
    final accounts = authenticated.accounts.map((e) {
      final network = networks[e.id];
      if (network == null) return null;
      return StellarWeb3JSStateAddress(
          chainaccount: e,
          jsAccount: JSStellarWalletAccount.setup(
              address: e.addressStr,
              publicKey: e.publicKey,
              chain: network.wsIdentifier),
          networkIdentifier: network);
    }).toList();

    final defaultAddress = authenticated.accounts.firstWhereOrNull((e) =>
        e.defaultAddress &&
        networks.containsKey(e.id) &&
        e.id == authenticated.currentNetwork.id);
    return StellarWeb3JSStateAccount._(
        accounts: accounts.whereType<StellarWeb3JSStateAddress>().toList(),
        state: Web3NetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : StellarWeb3JSStateAddress(
                chainaccount: defaultAddress,
                networkIdentifier: networks[defaultAddress.id]!,
                jsAccount: JSStellarWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.publicKey,
                    chain: networks[defaultAddress.id]!.wsIdentifier),
              ));
  }
}

class StellarWeb3JSStateHandler extends Web3JSStateHandler<
        StellarAddress,
        Web3StellarChainAccount,
        JSStellarWalletAccount,
        Web3ChainDefaultIdnetifier,
        StellarWeb3JSStateAccount>
    with
        StellarWeb3StateHandler<
            JSStellarWalletAccount,
            StellarWeb3JSStateAccount,
            WalletMessageResponse,
            Web3JsClientRequest,
            JSWalletNetworkEvent> {
  StellarWeb3JSStateHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});
  // @override
  // Web3StellarSignMessage toSignMessageRequest(
  //     {required Web3JsClientRequest params,
  //     required StellarWeb3JSStateAccount state,
  //     required Web3StellarRequestMethods method,
  //     Web3ChainDefaultIdnetifier? network}) {
  //   return Web3ValidatorUtils.parseParams2(() {
  //     final param = params.elementAsJsObject<JSStellarSignMessageParams>(0,
  //         keys: JSStellarSignMessageParams.properties);
  //     List<int> message = params.objectAsBytes(param.message, "message",
  //         encoding: [
  //           StringEncoding.hex,
  //           StringEncoding.base64,
  //           StringEncoding.utf8
  //         ]);
  //     Web3StellarChainAccount account =
  //         state.getJsAddressChainAccountOrThrow(param.account);
  //     return Web3StellarSignMessage(
  //         accessAccount: account,
  //         challeng: BytesUtils.toHexString(message),
  //         content: StringUtils.tryDecode(message));
  //   });
  // }

  // @override
  // Web3StellarSendTransaction toSignTransactionRequest(
  //     {required Web3JsClientRequest params,
  //     required StellarWeb3JSStateAccount state,
  //     required Web3StellarRequestMethods method,
  //     Web3ChainDefaultIdnetifier? network}) {
  //   return Web3ValidatorUtils.parseParams2(() {
  //     final param =
  //         params.elementAsJsObject<JSStellarSendOrSignTransactionParams>(0,
  //             keys: JSStellarSendOrSignTransactionParams.properties);
  //     final account = state.getJsAddressChainAccountOrThrow(param.account);
  //     List<int> txBytes =
  //         params.objectAsBytes(param.transaction, "transaction", encoding: [
  //       StringEncoding.hex,
  //       StringEncoding.base64,
  //     ]);
  //     return Web3StellarSendTransaction(
  //         account: account, transaction: txBytes, method: method);
  //   }, error: Web3RequestExceptionConst.invalidTransaction);
  // }

  @override
  Future<Web3MessageCore> request(Web3JsClientRequest params,
      {Web3ChainDefaultIdnetifier? network}) async {
    final state = await getState();
    final method = Web3StellarRequestMethods.fromName(params.request.method);
    switch (method) {
      case Web3StellarRequestMethods.requestAccounts:
        return onConnect_(params);
      case Web3StellarRequestMethods.signMessage:
        return toSignMessageRequest(
            params: params, state: state, method: method!);
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        return toSignTransactionRequest(
            params: params, state: state, method: method!);
      default:
        throw Web3RequestExceptionConst.methodDoesNotSupport;
    }
  }

  @override
  void onRequestDone(Web3JsClientRequest message) {}

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required Web3JsClientRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final method = Web3StellarRequestMethods.fromName(message.request.method);
    switch (method) {
      case Web3StellarRequestMethods.signMessage:
        return WalletMessageResponse.success(
            JSStellarSignMessageResponse.setup(response.resultAsList()));
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        final signedResponse = Web3StellarSendTransactionResponse.deserialize(
            bytes: response.resultAsList<int>());
        if (signedResponse.txHash != null) {
          return WalletMessageResponse.success(
              JSStellarSendTransactionResponse.setup(
                  envlope: signedResponse.envlope,
                  txId: signedResponse.txHash!));
        }
        return WalletMessageResponse.success(
            JSStellarSignTransactionResponse.setup(signedResponse.envlope));
      case Web3StellarRequestMethods.requestAccounts:
        return onConnectResponse(message);
      default:
        break;
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  StellarWeb3JSStateAccount createState(Web3APPData? authenticated) {
    if (authenticated == null) return StellarWeb3JSStateAccount.init();
    return StellarWeb3JSStateAccount(authenticated.getAuth(networkType));
  }
}
