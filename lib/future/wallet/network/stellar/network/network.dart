import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';

class UpdateStellarProvider extends StatelessWidget {
  const UpdateStellarProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<StellarClient?, IStellarAddress?,
            StellarChain>(
        addressRequired: false,
        clientRequired: false,
        childBulder: (wallet, account, client, address, onAccountChanged) =>
            _UpdateStellarProvider(account));
  }
}

class _UpdateStellarProvider extends StatefulWidget {
  const _UpdateStellarProvider(this.account);
  final StellarChain account;

  @override
  State<_UpdateStellarProvider> createState() => _UpdateSolanaProviderState();
}

class _UpdateSolanaProviderState extends State<_UpdateStellarProvider>
    with
        SafeState<_UpdateStellarProvider>,
        ProgressMixin<_UpdateStellarProvider>,
        UpdateNetworkProviderState<
            _UpdateStellarProvider,
            StellarAPIProvider,
            StellarAddress,
            IStellarAddress,
            StellarClient,
            TokenCore,
            NFTCore,
            StellarChain> {
  @override
  StellarChain get chain => widget.account;

  @override
  StellarAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return StellarAPIProvider(
        // httpNodeUri: url,
        horizonUrl: url,
        sorobanUrl: '',
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
  Future<StellarAPIProvider> validate(StellarAPIProvider provider) async {
    throw UnimplementedError();
    // final client = APIUtils.buildSoalanaProvider(provider, network.toNetwork());
    // final init = await client.validateNetworkGenesis();
    // if (!init) {
    //   throw WalletException("network_genesis_hash_validator");
    // }
    // return provider;
  }
}
