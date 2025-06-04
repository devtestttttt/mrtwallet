import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/constant.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart'
    show ContactCore, ChainAccount;

class AddressDetailsView extends StatelessWidget {
  const AddressDetailsView(
      {required this.address, super.key, this.showBalance = true, this.color});

  final ChainAccount address;
  final bool showBalance;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final network = wallet.wallet.networkById(address.network);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.accountName != null || address.type != null)
          address.accountName != null
              ? RichText(
                  maxLines: 1,
                  text: TextSpan(children: [
                    TextSpan(
                        text: address.accountName,
                        style: context.textTheme.labelLarge
                            ?.copyWith(color: color)),
                    if (address.type != null)
                      TextSpan(
                          text: " (${address.type!.tr})",
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: color))
                  ]))
              : address.type == null
                  ? WidgetConstant.sizedBox
                  : Text(address.type!.tr,
                      style:
                          context.textTheme.labelLarge?.copyWith(color: color)),
        OneLineTextWidget(address.address.toAddress,
            style: context.textTheme.bodyMedium?.copyWith(color: color)),
        // AddressDrivationInfo(address.keyIndex, color: color),
        if (showBalance && network != null)
          CoinAndMarketLivePriceView(
              liveBalance: address.address.balance,
              style: context.textTheme.titleMedium?.copyWith(color: color),
              symbolColor: color),
      ],
    );
  }
}

class AddressDrivationInfo extends StatelessWidget {
  const AddressDrivationInfo(this.keyIndex, {this.color, super.key});
  final AddressDerivationIndex keyIndex;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final keyStr = keyIndex.toString().tr;
    if (keyIndex.isImportedKey) {
      return OneLineTextWidget("imported_".tr.replaceOne(keyStr),
          style: context.textTheme.bodySmall?.copyWith(color: color));
    }
    return OneLineTextWidget(keyIndex.toString().tr,
        style: context.textTheme.bodySmall?.copyWith(color: color));
  }
}

class ContactAddressView extends StatelessWidget {
  const ContactAddressView({super.key, required this.contact, this.color});
  final ContactCore contact;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OneLineTextWidget(contact.name,
            style: context.textTheme.labelLarge?.copyWith(color: color)),
        if (contact.type != null)
          Text(contact.type!.tr,
              style: context.textTheme.bodySmall?.copyWith(color: color)),
        OneLineTextWidget(contact.address,
            style: context.textTheme.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}
