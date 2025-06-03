import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class NetworkGenericAddressDerivationView extends StatelessWidget {
  const NetworkGenericAddressDerivationView({super.key});

  @override
  Widget build(BuildContext context) {
    final Chain chain = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.unlock,
        onAccsess: (crendential, password, _) {
          return NetworkAccountControllerView<NetworkClient?, ChainAccount?,
              Chain>(
            account: chain,
            initAccount: true,
            childBulder: (wallet, account, client, address, onAccountChanged) {
              switch (chain.network.type) {
                case NetworkType.bitcoinAndForked:
                case NetworkType.bitcoinCash:
                  return SetupBitcoinAddressView(account.cast());
                case NetworkType.cardano:
                  return SetupCardanoAddressView(account.cast());
                default:
                  return _NetworkGenericAddressDerivationView(account);
              }
            },
            addressRequired: false,
            clientRequired: false,
          );
        },
        title: "setup_address".tr,
        subtitle: PageTitleSubtitle(
            title: "unlock_wallet".tr, body: Text("unlock_access_desc".tr)));
  }
}

class _NetworkGenericAddressDerivationView extends StatelessWidget {
  const _NetworkGenericAddressDerivationView(this.chain);
  final Chain chain;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return StateBuilder<AddressDerivationController>(
      controller: () =>
          AddressDerivationController(chain: chain, wallet: wallet),
      repositoryId: StateConst.addressDerivation,
      builder: (controller) => PageProgress(
        key: controller.pageProgressKey,
        backToIdle: APPConst.oneSecoundDuration,
        initialStatus: PageProgressStatus.idle,
        child: (c) => Center(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              WidgetConstant.sliverPaddingVertial20,
              SliverToBoxAdapter(
                  child: ConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                child: Form(
                  key: controller.form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitleSubtitle(
                          title: "setup_network_address".tr.replaceOne(
                              controller.network.coinParam.token.name),
                          body: LargeTextView(
                            [
                              "disable_standard_derivation_desc".tr,
                              "setup_address_derivation_keys_desc".tr,
                              "please_following_steps_to_generate_address".tr,
                              "custom_path_derivation_desc".tr,
                              if (controller.network.type == NetworkType.ton)
                                "ton_mnemonic_feature_desc".tr
                            ],
                          )),
                      SetupGenericAddressView(controller: controller)
                    ],
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
