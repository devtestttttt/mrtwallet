import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/params/requests.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/permission/permission.dart';

import 'package:on_chain/ethereum/src/address/evm_address.dart';

abstract class Web3EthereumRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    ETHAddress,
    EthereumChain,
    IEthAddress,
    Web3EthereumChainAccount,
    Web3EthereumChain> {
  @override
  abstract final Web3EthereumRequestMethods method;

  Web3EthereumRequestParam();
  @override
  List<Web3EthereumChainAccount> get requiredAccounts => [];

  factory Web3EthereumRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3EthereumRequestParam param;
    switch (method) {
      case Web3EthereumRequestMethods.addEthereumChain:
        param = Web3EthereumAddNewChain.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.ethSign:
      case Web3EthereumRequestMethods.persoalSign:
        param = Web3EthreumPersonalSign.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.sendTransaction:
        param = Web3EthreumSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3EthereumRequestMethods.typedData:
        param = Web3EthreumTypdedData.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      // case Web3EthereumRequestMethods.switchEthereumChain:
      //   param = Web3EthreumSwitchChain.deserialize(
      //       bytes: bytes, object: object, hex: hex);
      //   break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3EthereumRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3EthereumRequest<RESPONSE,
        PARAMS extends Web3EthereumRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, ETHAddress, EthereumChain,
        Web3EthereumChainAccount, IEthAddress, Web3EthereumChain, PARAMS> {
  Web3EthereumRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain,
      required super.accounts});
  Web3EthereumRequest<R, P> cast<R, P extends Web3EthereumRequestParam<R>>() {
    return this as Web3EthereumRequest<R, P>;
  }
}
