import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/sui/forms/core/sui.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/sui/client/client.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/sui.dart';

class Web3SuiSignMessageForm
    extends SuiWeb3Form<SuiClient?, ISuiAddress, Web3SuiSignMessage> {
  Web3SuiSignMessageForm({required this.request});

  @override
  Web3SuiRequest<Map<String, dynamic>, Web3SuiSignMessage> request;
  List<int> challengeBytes() {
    return BytesUtils.fromHexString(request.params.challeng);
  }

  String get message => request.params.challeng;
  String? get content => request.params.content;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(true);
  }
}
