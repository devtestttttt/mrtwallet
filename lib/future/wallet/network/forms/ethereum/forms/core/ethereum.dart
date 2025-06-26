import 'package:on_chain_wallet/app/error/exception.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';
import 'package:on_chain/on_chain.dart';

enum ETHTransactionMode { transfer, erc20Transfer, contract, callContract }

abstract class EthereumTransactionForm extends TransactionForm<EthereumClient,
    IEthAddress, WalletEthereumNetwork, EthereumChain> {
  BigInt get callValue;
  BigInt get tokenValue;
  @override
  String? validateError();
  Map<String, dynamic> toEstimate({String? memo});
  ETHTransaction toTransaction({required EthereumFee fee, String? memo});
  EthWalletTransaction toWalletTransaction({required String txId});
  ETHTransactionMode get mode;
  DynamicVoid? onStimateChanged;
}

abstract class EthereumWeb3Form<CLIENT extends EthereumClient?,
        ADDRESS extends IEthAddress?, PARAMS extends Web3EthereumRequestParam>
    extends Web3Form<
        ETHAddress,
        CLIENT,
        ADDRESS,
        WalletEthereumNetwork,
        EthereumChain,
        IEthAddress,
        Web3EthereumChainAccount,
        Web3EthereumChain,
        PARAMS> {
  abstract final Web3EthereumRequest<dynamic, PARAMS> request;
  late final bool isEthSign =
      request.params.method == Web3EthereumRequestMethods.ethSign;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  Future<void> signMessage({FuncFutureNullableBoold? confirm}) async {
    if (isEthSign) {
      final accept = await confirm?.call();
      if (accept != true) return;
    }
    onCompleteForm?.call(null);
  }

  ETHFORM cast<ETHFORM extends EthereumWeb3Form>() {
    if (this is! ETHFORM) {
      throw WalletException.invalidArgruments(["$ETHFORM", "$runtimeType"]);
    }
    return this as ETHFORM;
  }
}
