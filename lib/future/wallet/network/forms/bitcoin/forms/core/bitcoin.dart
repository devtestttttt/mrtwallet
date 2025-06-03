import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

abstract class BitcoinTransactionForm extends TransactionForm<BitcoinClient,
    IBitcoinAddress, WalletBitcoinNetwork, BitcoinChain> {
  BigInt get transferValue;
  DynamicVoid? onStimateChanged;
  @override
  String? validateError();
}

abstract class BitcoinWeb3Form<
        CLIENT extends BitcoinClient?,
        ADDRESS extends IBitcoinAddress?,
        PARAMS extends Web3BitcoinRequestParam>
    extends Web3Form<
        BitcoinBaseAddress,
        CLIENT,
        ADDRESS,
        WalletBitcoinNetwork,
        BitcoinChain,
        IBitcoinAddress,
        Web3BitcoinChainAccount,
        Web3BitcoinChain,
        PARAMS> {
  abstract final Web3BitcoinRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }

  @override
  void close() {
    super.close();
    onCompleteForm = null;
  }
}
