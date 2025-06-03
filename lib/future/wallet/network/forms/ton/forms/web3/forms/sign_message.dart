import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/ton/forms/core/ton.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/ton/client/ton.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ton/params/core/request.dart';

class Web3TonSignMessageForm<PARAMS extends Web3TonRequestParam>
    extends TonWeb3Form<TonClient?, ITonAddress, PARAMS> {
  Web3TonSignMessageForm({required this.request});

  @override
  Web3TonRequest<dynamic, PARAMS> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(true);
  }
}
