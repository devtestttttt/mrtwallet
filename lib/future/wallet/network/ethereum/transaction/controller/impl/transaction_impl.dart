import 'package:on_chain_wallet/future/wallet/transaction/transaction.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

abstract class EthTransactionImpl extends WalletSendTransactionStateImpl<
    IEthAddress, EthereumClient, WalletEthereumNetwork, EthereumChain> {
  EthTransactionImpl(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider});
}
