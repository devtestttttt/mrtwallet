import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/types.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class WalletSendTransactionStateImpl<
        CHAINACCOUNT extends ChainAccount,
        CLIENT extends NetworkClient,
        NETWORK extends WalletNetwork,
        C extends APPCHAINACCOUNTCLIENTNETWORK<CHAINACCOUNT, CLIENT, NETWORK>>
    extends StateController {
  WalletSendTransactionStateImpl(
      {required this.walletProvider,
      required this.account,
      required this.apiProvider})
      : network = account.network,
        address = account.address;
  final WalletProvider walletProvider;
  final C account;
  final NETWORK network;
  final CLIENT apiProvider;
  final CHAINACCOUNT address;
}
