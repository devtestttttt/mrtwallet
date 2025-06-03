import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class Web3GlobalRequestSwotchNetworkStateController
    extends Web3StateContoller<Web3GlobalRequest>
    with Web3GlobalRequestControllerState {
  final WalletProvider wallet;
  Chain? _currentChain;
  Chain get chain => _currentChain!;
  Chain? _newChain;
  Chain get newChain => _newChain!;
  @override
  final Web3GlobalRequest request;
  Web3GlobalRequestSwotchNetworkStateController(
      {required this.wallet, required this.request});

  Future<void> confirm() async {
    final param = request.params.cast<Web3SwitchApplicationNetwork>();
    final auth = request.authenticated.getChainFromNetworkType(param.chain);
    auth.setActiveChain(newChain.network);
    progressKey.response();
    request.completeResponse([newChain.network.type]);
  }

  @override
  Future<void> initWeb3() async {
    final param = request.params.cast<Web3SwitchApplicationNetwork>();
    final auth = request.authenticated.getChainFromNetworkType(param.chain);
    final chains =
        wallet.wallet.getChains().where((e) => e.network.type == param.chain);
    _currentChain = chains.firstWhere(
      (e) => e.network.value == auth.currentChain,
      orElse: () => throw Web3RequestExceptionConst.networkDoesNotExists,
    );
    _newChain = chains.firstWhere((e) => e.network.value == param.id,
        orElse: () => throw Web3RequestExceptionConst.networkDoesNotExists);
    progressKey.idle();
  }
}
