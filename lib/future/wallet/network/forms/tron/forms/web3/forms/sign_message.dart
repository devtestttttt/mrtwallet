import 'package:on_chain_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/tron/client/tron.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/tron.dart';

class Web3TronSignMessageForm
    extends TronWeb3Form<TronClient?, ITronAddress, Web3TronSignMessageV2> {
  Web3TronSignMessageForm({required this.request});

  @override
  Web3TronRequest<dynamic, Web3TronSignMessageV2> request;
}
