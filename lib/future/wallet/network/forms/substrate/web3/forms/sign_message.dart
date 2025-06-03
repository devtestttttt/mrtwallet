import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/substrate/client/substrate.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';

class Web3SubstrateSignMessageForm<PARAMS extends Web3SubstrateRequestParam>
    extends SubstrateWeb3Form<SubstrateClient?, ISubstrateAddress, PARAMS> {
  Web3SubstrateSignMessageForm({required this.request});

  @override
  Web3SubstrateRequest<dynamic, PARAMS> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(true);
  }
}
