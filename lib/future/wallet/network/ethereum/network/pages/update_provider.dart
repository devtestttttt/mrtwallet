import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class UpdateEthereumProvider extends StatelessWidget {
  const UpdateEthereumProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<EthereumClient?, IEthAddress?,
            EthereumChain>(
        addressRequired: false,
        clientRequired: false,
        childBulder: (wallet, account, client, address, onAccountChanged) =>
            _UpdateEthereumProvider(account));
  }
}

class _UpdateEthereumProvider extends StatefulWidget {
  const _UpdateEthereumProvider(this.account);
  final EthereumChain account;

  @override
  State<_UpdateEthereumProvider> createState() => _UpdateSolanaProviderState();
}

class _UpdateSolanaProviderState extends State<_UpdateEthereumProvider>
    with
        SafeState<_UpdateEthereumProvider>,
        ProgressMixin<_UpdateEthereumProvider>,
        UpdateNetworkProviderState<
            _UpdateEthereumProvider,
            EthereumAPIProvider,
            ETHAddress,
            IEthAddress,
            EthereumClient,
            TokenCore,
            NFTCore,
            EthereumChain> {
  @override
  EthereumChain get chain => widget.account;

  @override
  EthereumAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return EthereumAPIProvider(
        uri: url, auth: auth, identifier: APIUtils.getProviderIdentifier());
  }

  @override
  late final List<ServiceProtocol> supportedProtocol;

  void init() {
    supportedProtocol = [ServiceProtocol.http, ServiceProtocol.websocket];
    protocol = supportedProtocol.first;
  }

  @override
  void onInitOnce() {
    MethodUtils.after(() async => init());
    super.onInitOnce();
  }

  @override
  Future<EthereumAPIProvider> validate(EthereumAPIProvider provider) async {
    final client = APIUtils.buildEthereumProvider(
        provider: provider, network: network.toNetwork());
    final init = await client.checkNetworkChainId();
    if (!init) {
      throw WalletException("network_incorrect_chain_id");
    }
    return provider;
  }
}
