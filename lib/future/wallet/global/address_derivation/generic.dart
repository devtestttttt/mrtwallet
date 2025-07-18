import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/network/aptos/address/setup.dart';
import 'package:on_chain_wallet/future/wallet/network/cosmos/address/setup_address.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/address/setup_address.dart';
import 'package:on_chain_wallet/future/wallet/network/ripple/address/pages/setup_address.dart';
import 'package:on_chain_wallet/future/wallet/network/stellar/stellar.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/address/setup_address.dart';
import 'package:on_chain_wallet/future/wallet/network/sui/address/setup.dart';
import 'package:on_chain_wallet/future/wallet/network/ton/address/address.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'controller.dart';

class SetupGenericAddressView extends StatelessWidget {
  const SetupGenericAddressView({super.key, required this.controller});
  final AddressDerivationController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.network.type) {
      case NetworkType.xrpl:
        return SetupRippleAddressView(controller: controller);
      case NetworkType.cosmos:
        return SetupCosmosAddressView(controller: controller);
      case NetworkType.stellar:
        return SetupStellarAddressView(controller: controller);
      case NetworkType.ton:
        return SetupTonAddressView(controller: controller);
      case NetworkType.monero:
        return SetupMoneroAddressView(controller: controller);
      case NetworkType.substrate:
        return SetupSubstrateAddressView(controller: controller);
      case NetworkType.aptos:
        return SetupAptosAddressView(controller: controller);
      case NetworkType.sui:
        return SetupSuiAddressView(controller: controller);

      default:
        return _GenericNetworkAddressGenerationView(controller: controller);
    }
  }
}

class _GenericNetworkAddressGenerationView extends StatelessWidget {
  const _GenericNetworkAddressGenerationView({required this.controller});
  final AddressDerivationController controller;
  static NewAccountParams getnerateAccoutParams(
      Bip32AddressIndex keyIndex, WalletNetwork network, CryptoCoins coin) {
    switch (network.type) {
      case NetworkType.ethereum:
        return EthereumNewAddressParams(deriveIndex: keyIndex, coin: coin);
      case NetworkType.solana:
        return SolanaNewAddressParams(deriveIndex: keyIndex, coin: coin);
      case NetworkType.tron:
        return TronNewAddressParams(deriveIndex: keyIndex, coin: coin);
      default:
        throw UnimplementedError();
    }
  }

  static void generateAddress(
      BuildContext context, AddressDerivationController controller) async {
    final keyIndex = await controller.getCoin(
        context: context, seedGeneration: SeedTypes.bip39);
    if (keyIndex == null || !keyIndex.isBip32) return;
    final newAccountParam = getnerateAccoutParams(
        keyIndex.cast(), controller.network, controller.coin);
    controller.generateAddress(newAccountParam);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FixedElevatedButton(
            padding: WidgetConstant.paddingVertical20,
            onPressed: () {
              generateAddress(context, controller);
            },
            child: Text("generate_address".tr)),
      ],
    );
  }
}
