import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain/sui/sui.dart';

class UpdateSuiProvider extends StatelessWidget {
  const UpdateSuiProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SuiClient?, ISuiAddress?, SuiChain>(
        addressRequired: false,
        clientRequired: false,
        childBulder: (wallet, account, client, address, onAccountChanged) =>
            _UpdateSuiProvider(account));
  }
}

class _UpdateSuiProvider extends StatefulWidget {
  const _UpdateSuiProvider(this.account);
  final SuiChain account;

  @override
  State<_UpdateSuiProvider> createState() => _UpdateSuiProviderState();
}

class _UpdateSuiProviderState extends State<_UpdateSuiProvider>
    with
        SafeState<_UpdateSuiProvider>,
        ProgressMixin<_UpdateSuiProvider>,
        UpdateNetworkProviderState<_UpdateSuiProvider, SuiAPIProvider,
            SuiAddress, ISuiAddress, SuiClient, TokenCore, NFTCore, SuiChain> {
  @override
  SuiChain get chain => widget.account;

  @override
  SuiAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return SuiAPIProvider(
        fullNodeUri: url,
        auth: auth,
        identifier: APIUtils.getProviderIdentifier());
  }

  @override
  late final List<ServiceProtocol> supportedProtocol;

  void init() {
    supportedProtocol = [ServiceProtocol.http];
    protocol = supportedProtocol.first;
  }

  @override
  void onInitOnce() {
    MethodUtils.after(() async => init());
    super.onInitOnce();
  }

  @override
  Future<SuiAPIProvider> validate(SuiAPIProvider provider) async {
    final client = APIUtils.buildSuiProvider(
        provider: provider, network: network.toNetwork());
    final init = await client.init();
    if (!init) {
      throw WalletException("network_genesis_hash_validator");
    }
    return provider;
  }
}
