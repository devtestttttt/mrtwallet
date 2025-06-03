import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/params/models/add_new_chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/params/models/sign_message.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/permission/models/permission.dart';

import '../models/transaction.dart';

abstract class Web3CosmosRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    CosmosBaseAddress,
    CosmosChain,
    ICosmosAddress,
    Web3CosmosChainAccount,
    Web3CosmosChain> {
  @override
  abstract final Web3CosmosRequestMethods method;

  Web3CosmosRequestParam();
  @override
  List<Web3CosmosChainAccount> get requiredAccounts => [];

  factory Web3CosmosRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3CosmosRequestParam param;
    switch (method) {
      case Web3CosmosRequestMethods.signTransactionAmino:
      case Web3CosmosRequestMethods.signTransactionDirect:
        param = Web3CosmosSignTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3CosmosRequestMethods.addNewChain:
        param = Web3CosmosAddNewChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3CosmosRequestMethods.signMessage:
        param = Web3CosmosSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;

      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
    if (param is! Web3CosmosRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3CosmosRequest<RESPONSE,
        PARAMS extends Web3CosmosRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, CosmosBaseAddress, CosmosChain,
        Web3CosmosChainAccount, ICosmosAddress, Web3CosmosChain, PARAMS> {
  Web3CosmosRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain,
      required super.accounts});

  Web3CosmosRequest<R, P> cast<R, P extends Web3CosmosRequestParam<R>>() {
    return this as Web3CosmosRequest<R, P>;
  }
}
