import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/params/models/add_chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/params/models/sign_message.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/params/models/transaction.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/permission/permission.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class Web3SubstrateRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    BaseSubstrateAddress,
    SubstrateChain,
    ISubstrateAddress,
    Web3SubstrateChainAccount,
    Web3SubstrateChain> {
  @override
  abstract final Web3SubstrateRequestMethods method;
  @override
  List<Web3SubstrateChainAccount> get requiredAccounts => [];
  Web3SubstrateRequestParam();

  factory Web3SubstrateRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3SubstrateRequestParam param;
    switch (method) {
      case Web3SubstrateRequestMethods.signTransaction:
        param = Web3SubstrateSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);

      case Web3SubstrateRequestMethods.signMessage:
        param = Web3SubstrateSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
      case Web3SubstrateRequestMethods.addSubstrateChain:
        param = Web3SubstrateAddNewChain.deserialize(
            bytes: bytes, object: object, hex: hex);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3SubstrateRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3SubstrateRequest<RESPONSE,
        PARAMS extends Web3SubstrateRequestParam<RESPONSE>>
    extends Web3NetworkRequest<
        RESPONSE,
        BaseSubstrateAddress,
        SubstrateChain,
        Web3SubstrateChainAccount,
        ISubstrateAddress,
        Web3SubstrateChain,
        PARAMS> {
  Web3SubstrateRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain,
      required super.accounts});

  Web3SubstrateRequest<R, P> cast<R, P extends Web3SubstrateRequestParam<R>>() {
    return this as Web3SubstrateRequest<R, P>;
  }
}
