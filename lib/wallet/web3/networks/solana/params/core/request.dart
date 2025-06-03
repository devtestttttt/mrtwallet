import 'package:on_chain_wallet/wallet/web3/networks/solana/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/params/models/sign_message.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/params/models/transaction.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/permission/models/permission.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain/solana/solana.dart';

abstract class Web3SolanaRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    SolAddress,
    SolanaChain,
    ISolanaAddress,
    Web3SolanaChainAccount,
    Web3SolanaChain> {
  @override
  abstract final Web3SolanaRequestMethods method;

  Web3SolanaRequestParam();

  factory Web3SolanaRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3SolanaRequestParam param;
    switch (method) {
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.signAndSendAllTransactions:
      case Web3SolanaRequestMethods.sendTransaction:
        param = Web3SolanaSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
      case Web3SolanaRequestMethods.signIn:
      case Web3SolanaRequestMethods.signMessage:
        param = Web3SolanaSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3SolanaRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3SolanaRequest<RESPONSE,
        PARAMS extends Web3SolanaRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, SolAddress, SolanaChain,
        Web3SolanaChainAccount, ISolanaAddress, Web3SolanaChain, PARAMS> {
  Web3SolanaRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain,
      required super.accounts});

  Web3SolanaRequest<R, P> cast<R, P extends Web3SolanaRequestParam<R>>() {
    return this as Web3SolanaRequest<R, P>;
  }
}
