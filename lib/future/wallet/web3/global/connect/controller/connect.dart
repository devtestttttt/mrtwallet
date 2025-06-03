import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class Web3GlobalRequestConnectStateController
    extends Web3StateContoller<Web3GlobalRequest>
    with Web3GlobalRequestControllerState {
  NetworkType? _network;
  NetworkType? get network => _network;
  @override
  final Web3GlobalRequest request;
  Web3GlobalRequestConnectStateController(this.request);

  Future<void> onUpdateApplication(List<NetworkType> networks) async {
    progressKey.response(text: "client_permission_have_been_updated".tr);
    request.completeResponse(networks);
  }

  @override
  Future<void> initWeb3() async {
    final param = request.params.cast<Web3ConnectApplication>();
    _network = param.chain;
    progressKey.idle();
  }
}
