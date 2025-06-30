import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/web3/types/types.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class Web3GlobalRequestConnectStateController
    extends Web3StateContoller<Web3GlobalRequest>
    with Web3GlobalRequestControllerState {
  final WalletProvider wallet;
  late Web3UpdatePermissionRequest _authenticated;
  Web3UpdatePermissionRequest get authenticated => _authenticated;
  @override
  final Web3GlobalRequest request;
  Web3GlobalRequestConnectStateController(
      {required this.request, required this.wallet});

  Future<bool> onUpdateApplication(List<NetworkType> networks) async {
    progressKey.response(text: "client_permission_have_been_updated".tr);
    request.completeResponse(networks);
    return true;
  }

  @override
  Future<void> initWeb3() async {
    final param = request.params.cast<Web3ConnectApplication>();
    List<NetworkType> lockedNetworks = const [];
    List<Chain> locakedChains = const [];
    if (param.chain != null) {
      lockedNetworks = [param.chain!];
    } else if (param.networks != null) {
      final networkIds = param.networks!;
      locakedChains = wallet.wallet
          .getChains()
          .where((e) => networkIds.contains(e.network.value))
          .toList();
      lockedNetworks = locakedChains
          .map((e) => e.network.type.isBitcoin
              ? NetworkType.bitcoinAndForked
              : e.network.type)
          .toSet()
          .toList();
    }
    _authenticated = Web3UpdatePermissionRequest(
        authentication: request.authenticated,
        lockedNetworks: lockedNetworks,
        lockedChains: locakedChains,
        client: request.info.client);
    progressKey.idle();
  }
}
