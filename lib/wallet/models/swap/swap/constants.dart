import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:on_chain_wallet/app/http/models/auth.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/cosmos.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/custom.dart';
import 'package:on_chain_wallet/wallet/constant/chain/const.dart';

class APPSwapConstants {
  static const int cfTestnetNetworkId = ChainConst.cfTestnetNetworkId;
  static const int polkadotMainnetId = ChainConst.polkadotMainnetId;
  static final Map<SwapServiceType, Map<ChainType, List<APIProvider>>>
      _swapProviders = {
    SwapServiceType.chainFlip: {
      ChainType.testnet: [
        const CustomAPIProvider(
            url: 'https://chainflip-swap-perseverance.chainflip.io/',
            identifier: '')
      ],
      ChainType.mainnet: [
        const CustomAPIProvider(
            url: 'https://chainflip-swap.chainflip.io/', identifier: '')
      ]
    },
    SwapServiceType.thor: {
      ChainType.mainnet: [
        CosmosAPIProvider(
            identifier: '', uri: "https://thornode.ninerealms.com/thorchain"),
      ]
    },
    SwapServiceType.maya: {
      ChainType.mainnet: [
        CosmosAPIProvider(
          uri: "https://mayanode.mayachain.info/mayachain",
          identifier: 'identifier',
        ),
      ]
    },
    SwapServiceType.skipGo: {
      ChainType.mainnet: [
        CustomAPIProvider(url: "https://api.skip.build", identifier: ''),
      ]
    },
    SwapServiceType.swapKit: {
      ChainType.mainnet: [
        CustomAPIProvider(
            identifier: '',
            url: "https://api.swapkit.dev",
            auth: BasicProviderAuthenticated(
                type: ProviderAuthType.header,
                key: "x-api-key",
                value: "9e1a8dce-8e2d-4cad-9d09-9430df70743c")),
      ]
    },
  };

  static T? getProvider<T extends APIProvider>(SwapServiceType service,
      {ChainType chainType = ChainType.mainnet}) {
    return _swapProviders[service]?[chainType]?.firstOrNull?.toProvider<T>();
  }
}
