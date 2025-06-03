import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/params/models/sign_message.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/params/models/transaction.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/permission/permission.dart';
import 'package:stellar_dart/stellar_dart.dart';

abstract class Web3StellarRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    StellarAddress,
    StellarChain,
    IStellarAddress,
    Web3StellarChainAccount,
    Web3StellarChain> {
  @override
  abstract final Web3StellarRequestMethods method;

  Web3StellarRequestParam();

  factory Web3StellarRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3StellarRequestParam param;
    switch (method) {
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        param = Web3StellarSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
      case Web3StellarRequestMethods.signMessage:
        param = Web3StellarSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3StellarRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3StellarRequest<RESPONSE,
        PARAMS extends Web3StellarRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, StellarAddress, StellarChain,
        Web3StellarChainAccount, IStellarAddress, Web3StellarChain, PARAMS> {
  Web3StellarRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain,
      required super.accounts});

  Web3StellarRequest<R, P> cast<R, P extends Web3StellarRequestParam<R>>() {
    return this as Web3StellarRequest<R, P>;
  }
}
