import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/stellar/forms/core/stellar.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/stellar/stellar.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/stellar/stellar.dart';

class Web3StellarSignMessageForm<PARAMS extends Web3StellarRequestParam>
    extends StellarWeb3Form<StellarClient?, IStellarAddress, PARAMS> {
  Web3StellarSignMessageForm({required this.request});

  @override
  Web3StellarRequest<dynamic, PARAMS> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(true);
  }
}
