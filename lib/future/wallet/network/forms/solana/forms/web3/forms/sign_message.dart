import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/solana/solana.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

class Web3SolanaSignMessageForm extends SolanaWeb3Form<SolanaClient?,
    ISolanaAddress, Web3SolanaSignMessage> {
  Web3SolanaSignMessageForm({required this.request});

  @override
  Web3SolanaRequest<List<Web3SolanaSignMessageResponse>, Web3SolanaSignMessage>
      request;
  List<Web3SolanaSignMessageItemView> _messages = [];
  List<Web3SolanaSignMessageItemView> get messages => _messages;
  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(request.params.messages);
  }

  @override
  Future<void> initForm(
      {required SolanaChain account,
      required ISolanaAddress address,
      required WalletSolanaNetwork network,
      required SolanaClient? client}) async {
    await super.initForm(
        account: account, address: address, network: network, client: client);
    List<Web3SolanaSignMessageItemView> messages = [];
    final List<ISolanaAddress> signers = request.accounts;
    for (final i in request.params.messages) {
      final msg = Web3SolanaSignMessageItemView(
          address: signers.firstWhere(
              (e) => e.networkAddress == i.account.address,
              orElse: () => throw Web3RequestExceptionConst.missingPermission),
          method: request.params.method,
          params: i);
      messages.add(msg);
    }
    _messages = messages.imutable;
  }
}

class Web3SolanaSignMessageItemView {
  final ISolanaAddress address;
  final Web3SolanaSignParams params;
  const Web3SolanaSignMessageItemView(
      {required this.address, required this.params, required this.method});
  final Web3SolanaRequestMethods method;
  bool get isSignIn => method == Web3SolanaRequestMethods.signIn;
}
