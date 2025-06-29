import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/utils/utils.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:on_chain_wallet/wallet/web3/state/core/network.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/cosmos.dart';
import 'package:on_chain_wallet/wallet/web3/utils/web3_validator_utils.dart';

mixin CosmosWeb3StateHandler<
        STATEADDRESS,
        STATEACCOUNT extends Web3StateAccount<
            CosmosBaseAddress,
            Web3CosmosChainAccount,
            dynamic,
            Web3CosmoshainIdnetifier,
            Web3StateAddress<CosmosBaseAddress, Web3CosmosChainAccount, dynamic,
                Web3CosmoshainIdnetifier>>,
        RESPONSE,
        REQUEST extends Web3ClientRequest,
        EVENT>
    on Web3StateHandler<CosmosBaseAddress, Web3CosmosChainAccount, STATEADDRESS,
        Web3CosmoshainIdnetifier, STATEACCOUNT, RESPONSE, REQUEST, EVENT> {
  @override
  CosmosBaseAddress toAddress(String v, {Web3CosmoshainIdnetifier? network}) {
    try {
      return CosmosBaseAddress(v, forceHrp: network?.hrp);
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidAddress(
        key: v, network: networkType.name);
  }

  @override
  NetworkType get networkType => NetworkType.cosmos;

  @override
  List<Web3CosmosRequestMethods> get methods => Web3CosmosRequestMethods.values;

  Web3MessageCore toAddNewChainRequest(
      {required REQUEST params,
      required STATEACCOUNT state,
      required Web3CosmosRequestMethods method,
      Web3CosmoshainIdnetifier? network}) {
    return Web3ValidatorUtils.parseParams2(() {
      const List<String> keys = ["chainId", "rpc", "name"];
      final data = params.paramsAsMap(keys: keys, method: method);
      final request = Web3CosmosAddNewChain.fromJson(data);
      final network =
          state.chains.firstWhereOrNull((e) => e.chainId == request.chainId);
      if (network != null) {
        return createResponse(true);
      }
      return request;
    });
  }

  Web3CosmosSignMessage toSignMessageRequest(
      {required REQUEST params,
      required STATEACCOUNT state,
      required Web3CosmosRequestMethods method,
      Web3CosmoshainIdnetifier? network}) {
    return Web3ValidatorUtils.parseParams2(() {
      const List<String> keys = ["message"];
      final data = params.paramsAsMap(keys: keys, method: method);
      final account = Web3ValidatorUtils.parseParams2(() {
        final address = tryParseStateAddress(
            addr: data["account"] ?? data["address"],
            params: params,
            state: state,
            network: network);
        if (address == null) return null;
        return state.findAddressOrDefault(
            address: address.address, network: network ?? address.chain);
      },
          error: Web3RequestExceptionConst.invalidAddressArgrument(
              key: "account", network: networkType.name));

      final message = StringUtils.toBytes(data["message"]);
      return Web3CosmosSignMessage(
          account: account,
          challeng: BytesUtils.toHexString(message),
          content: StringUtils.tryDecode(message));
    });
  }

  Web3CosmosSignTransaction toSignDirectTransactionRequest(
      {required REQUEST params,
      required STATEACCOUNT state,
      required Web3CosmosRequestMethods method,
      Web3CosmoshainIdnetifier? network}) {
    return Web3ValidatorUtils.parseParams2(() {
      const List<String> keys = ['signerAddress', 'signDoc'];
      final param = params.paramsAsMap(method: method, keys: keys);
      if (network == null) {
        final String? chainId = Web3ValidatorUtils.parseString(
            key: "chainId", method: method, json: param);
        if (chainId != null) {
          network = state.chains.firstWhere((e) => e.chainId == chainId,
              orElse: () =>
                  throw Web3RequestExceptionConst.networkDoesNotExists);
        }
      }
      final account = Web3ValidatorUtils.parseAddress(
          onParse: (e) => state.findAddressOrDefault(
              address: CosmosBaseAddress(e), network: network),
          key: "signerAddress",
          method: method,
          json: param,
          network: networkType.name);
      final currentChain = state.getAccountChain(account);
      final tx = Web3CosmosSignTransaction.fromJson(
          account: account,
          json: param,
          method: method,
          chainId: currentChain.chainId);
      if (tx.chainId != currentChain.chainId) {
        throw Web3CosmosExceptionConstant.mismatchChainId;
      }
      return tx;
    }, error: Web3RequestExceptionConst.invalidTransaction);
  }

  // Web3CosmosSignTransaction toSignTransactionRequest(
  //     {required REQUEST params,
  //     required STATEACCOUNT state,
  //     required Web3CosmosRequestMethods method,
  //     Web3CosmoshainIdnetifier? network}) {
  //   return Web3ValidatorUtils.parseParams2(() {
  //     const List<String> keys = ["address", "transaction"];
  //     final param = params.parametersAsMap(keys: keys, method: method);
  //     final account = Web3ValidatorUtils.parseAddress(
  //         onParse: (e) => state.findAddressStrOrDefault(address: e),
  //         key: "address",
  //         method: method,
  //         json: param,
  //         network: networkType.name);
  //     final chain = state.getAccountChain(account);
  //     final toJson = Web3ValidatorUtils.tryObjectAsMap(param["transaction"]);
  //     if (toJson != null) {
  //       final aminoTx = AminoTx.fromJson(toJson);
  //       if (aminoTx.chainId != chain.chainId) {
  //         throw Web3RequestExceptionConst.mismatchAccountAndTransactionChainId;
  //       }
  //       return Web3CosmosSignTransaction(
  //           account: account,
  //           chainId: aminoTx.chainId,
  //           transaction: Web3CosmosSignTransactionAminoParams(aminoTx));
  //     }
  //     final signDoc = SignDoc.deserialize(params.objectAsBytes(
  //         param["transaction"], "transaction",
  //         encoding: StringEncoding.base64));
  //     if (signDoc.chainId != chain.chainId) {
  //       throw Web3RequestExceptionConst.mismatchAccountAndTransactionChainId;
  //     }
  //     return Web3CosmosSignTransaction(
  //         account: account,
  //         chainId: signDoc.chainId,
  //         transaction: Web3CosmosSignTransactionDirectParams(
  //             accountNumber: signDoc.accountNumber,
  //             bodyBytes: signDoc.bodyBytes,
  //             authInfos: signDoc.authInfoBytes));
  //   }, error: Web3CosmosExceptionConstant.invalidSignTransactionParams);
  // }

  @override
  Future<Web3MessageCore> request(REQUEST message,
      {Web3CosmoshainIdnetifier? network}) async {
    final method = Web3CosmosRequestMethods.fromName(message.method);
    final state = await getState();
    if (method == null) {
      throw Web3RequestExceptionConst.methodDoesNotExist;
    }
    switch (method) {
      case Web3CosmosRequestMethods.requestAccounts:
        return onConnect_(message);
      case Web3CosmosRequestMethods.signTransactionAmino:
      case Web3CosmosRequestMethods.signTransactionDirect:
        return toSignDirectTransactionRequest(
            params: message, state: state, method: method, network: network);
      case Web3CosmosRequestMethods.signMessage:
        return toSignMessageRequest(
            params: message, state: state, network: network, method: method);
      case Web3CosmosRequestMethods.addNewChain:
        return toAddNewChainRequest(
            params: message, state: state, network: network, method: method);
      default:
        throw Web3RequestExceptionConst.methodDoesNotSupport;
    }
  }
}
