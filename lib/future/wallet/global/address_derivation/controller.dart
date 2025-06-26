import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

class AddressDerivationController extends StateController {
  AddressDerivationController({required this.wallet, required this.chain});
  final Chain chain;
  final WalletProvider wallet;
  WalletNetwork get network => chain.network;
  final GlobalKey<PageProgressState> pageProgressKey =
      GlobalKey<PageProgressState>(debugLabel: "AddressDerivationController");
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  List<CryptoCoins> get coins => network.coins;
  CryptoCoins get coin => coins.first;

  Future<AddressDerivationIndex?> getCoin({
    required BuildContext context,
    required SeedTypes seedGeneration,
    CryptoCoins? selectedCoins,
  }) async {
    if (!form.ready()) return null;
    if (selectedCoins != null) {
      if (!coins.contains(selectedCoins)) {
        throw WalletExceptionConst.invalidCoin;
      }
    }

    final defaultCoin = selectedCoins ?? coin;
    final customKeys = await wallet.wallet.getCustomKeysForCoin(defaultCoin);
    final activeCoins = selectedCoins != null ? [selectedCoins] : coins;
    return await context.openMaxExtendSliverBottomSheet<AddressDerivationIndex>(
        "setup_derivation".tr,
        child: SetupDerivationModeView(
            coin: defaultCoin,
            chainAccout: chain,
            customKeys: customKeys,
            networkCoins: activeCoins,
            seedGenerationType: seedGeneration));
  }

  Future<void> generateAddress(NewAccountParams newAccount) async {
    if (!form.ready()) return;
    pageProgressKey.progressText("generating_new_addr".tr);
    final result = await wallet.wallet
        .deriveNewAccount(newAccountParams: newAccount, chain: chain);
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.success(
          backToIdle: false,
          progressWidget: SuccessWithButtonView(
              buttonText: "generate_new_address".tr,
              buttonWidget: ContainerWithBorder(
                  margin: WidgetConstant.paddingVertical8,
                  child: AddressDetailsView(address: result.result)),
              onPressed: () {
                pageProgressKey.backToIdle();
              },
              text: "address_added_success".tr));
    }
    notify();
  }
}
