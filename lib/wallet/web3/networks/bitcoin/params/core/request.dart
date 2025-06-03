import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/params/models/send_transaction.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/params/models/sign_message.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/params/models/transaction.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/permission/models/permission.dart';

abstract class Web3BitcoinRequestParam<RESPONSE> extends Web3RequestParams<
    RESPONSE,
    BitcoinBaseAddress,
    BitcoinChain,
    IBitcoinAddress,
    Web3BitcoinChainAccount,
    Web3BitcoinChain> {
  @override
  abstract final Web3BitcoinRequestMethods method;

  Web3BitcoinRequestParam();

  factory Web3BitcoinRequestParam.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    final Web3BitcoinRequestParam param;
    switch (method) {
      case Web3BitcoinRequestMethods.signTransaction:
        param = Web3BitcoinSignTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3BitcoinRequestMethods.signPersonalMessage:
        param = Web3BitcoinSignMessage.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;
      case Web3BitcoinRequestMethods.sendTransaction:
        param = Web3BitcoinSendTransaction.deserialize(
            bytes: bytes, object: object, hex: hex);
        break;

      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (param is! Web3BitcoinRequestParam<RESPONSE>) {
      throw Web3RequestExceptionConst.internalError;
    }
    return param;
  }
}

class Web3BitcoinRequest<RESPONSE,
        PARAMS extends Web3BitcoinRequestParam<RESPONSE>>
    extends Web3NetworkRequest<RESPONSE, BitcoinBaseAddress, BitcoinChain,
        Web3BitcoinChainAccount, IBitcoinAddress, Web3BitcoinChain, PARAMS> {
  Web3BitcoinRequest(
      {required super.params,
      required super.info,
      required super.authenticated,
      required super.chain,
      required super.accounts});

  Web3BitcoinRequest<R, P> cast<R, P extends Web3BitcoinRequestParam<R>>() {
    return this as Web3BitcoinRequest<R, P>;
  }
}
