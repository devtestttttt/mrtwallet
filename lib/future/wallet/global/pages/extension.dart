import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/r.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/select_account.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/select_account_or_contact.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/setup_amount.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/others/others.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';

extension QuicWalletPageAccess on BuildContext {
  Future<CHAINACCOUNT?>
      selectOrSwitchAccount<CHAINACCOUNT extends ChainAccount>({
    required APPCHAINACCOUNT<CHAINACCOUNT> account,
    bool isSwitch = false,
    required bool showMultiSig,
    OnSelectAccountFilter<CHAINACCOUNT>? filter,
  }) async {
    return openDialogPage<CHAINACCOUNT>(
      "switch_account".tr,
      child: (context) => SwitchOrSelectAccountView<CHAINACCOUNT>(
          account: account,
          showMultiSig: showMultiSig,
          isSwitch: isSwitch,
          filter: filter),
    );
  }

  Future<List<ReceiptAddress<NETWORKADDRESS>>?> selectAccount<NETWORKADDRESS>({
    required APPCHAINNETWORK<NETWORKADDRESS> account,
    final String? title,
    bool multipleSelect = false,
    final RecipientFilter<NETWORKADDRESS>? onFilterAccount,
  }) {
    return openSliverBottomSheet(
      "",
      initiaalExtend: (account.addresses.length > 2) ? 1 : 0.9,
      bodyBuilder: (c) => SelectRecipientAccountView<NETWORKADDRESS>(
          account: account,
          scrollController: c,
          onFilterAccount: onFilterAccount,
          title: title,
          multipleSelect: multipleSelect),
    );
  }

  Future<BigInt?> setupAmount(
      {required Token token, BigInt? max, BigInt? min, String? title}) {
    assert(min == null || min >= BigInt.zero,
        "negative not allowed for min amount.");
    return openSliverBottomSheet<BigInt>(title ?? 'setup_amount'.tr,
        child:
            SetupNetworkAmount(token: token, max: max, min: min ?? BigInt.zero),
        initiaalExtend: 0.9);
  }
}
