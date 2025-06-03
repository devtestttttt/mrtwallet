import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/params/params.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/permission/models/permission.dart';
import 'package:ton_dart/ton_dart.dart';

abstract class Web3TonRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    TonAddress,
    TheOpenNetworkChain,
    ITonAddress,
    Web3TonChainAccount,
    Web3TonChain> {
  @override
  abstract final Web3TonRequestMethods method;

  Web3TonRequestParam();

  factory Web3TonRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3TonRequestParam param;
    switch (method) {
      case Web3TonRequestMethods.sendTransaction:
      case Web3TonRequestMethods.signTransaction:
        param = Web3TonSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
      case Web3TonRequestMethods.signMessage:
        param = Web3TonSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3TonRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3TonRequest<RESPONSE, PARAMS extends Web3TonRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, TonAddress, TheOpenNetworkChain,
        Web3TonChainAccount, ITonAddress, Web3TonChain, PARAMS> {
  Web3TonRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain,
      required super.accounts});

  Web3TonRequest<R, P> cast<R, P extends Web3TonRequestParam<R>>() {
    return this as Web3TonRequest<R, P>;
  }
}
