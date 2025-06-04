import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/bitcoin/account/state.dart';
import 'package:on_chain_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class BitcoinMultisigAccountInfoView extends StatelessWidget {
  const BitcoinMultisigAccountInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      accsess: WalletAccsessType.unlock,
      title: "multisig_address_infos".tr,
      onAccsess: (credential, password, network) {
        return NetworkAccountControllerView<BitcoinClient?, IBitcoinAddress,
            BitcoinChain>(
          addressRequired: true,
          clientRequired: false,
          childBulder: (wallet, account, client, address, onAccountChanged) {
            return _BitcoinMultisigAccountInfoView(account);
          },
        );
      },
    );
  }
}

class _BitcoinMultisigAccountInfoView extends StatefulWidget {
  final BitcoinChain account;
  const _BitcoinMultisigAccountInfoView(this.account);

  @override
  State<_BitcoinMultisigAccountInfoView> createState() =>
      __BitcoinMultisigAccountInfoViewState();
}

class __BitcoinMultisigAccountInfoViewState
    extends BitcoinAccountState<_BitcoinMultisigAccountInfoView>
    with ProgressMixin {
  @override
  BitcoinChain get account => widget.account;
  List<_BitcoinMultisigAccountInfo> keyInfos = [];
  late final int threshold;
  late final String script;

  Future<void> _init() async {
    if (!account.haveAddress || !account.address.multiSigAccount) {
      progressKey.errorText("invalid_account".tr);
      return;
    }
    final BitcoinMultiSigBase address = account.address as BitcoinMultiSigBase;
    threshold = address.multiSignatureAddress.threshold;
    keyInfos = address.multiSignatureAddress.signers
        .map((e) => _BitcoinMultisigAccountInfo(
            weight: e.weight,
            address:
                addresses.firstWhereOrNull((i) => i.keyIndex == e.keyIndex),
            publicKey: e.publicKey,
            keyIndex: e.keyIndex))
        .toList();
    script = address.multiSignatureAddress.multiSigScript.script.join(" ");
    progressKey.backToIdle();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    MethodUtils.after(() => _init());
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      initialStatus: PageProgressStatus.progress,
      backToIdle: APPConst.oneSecoundDuration,
      initialWidget:
          ProgressWithTextView(text: "retrieve_account_informations".tr),
      key: progressKey,
      child: (context) {
        return CustomScrollView(slivers: [
          SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverToBoxAdapter(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("address".tr, style: context.textTheme.titleMedium),
                  ContainerWithBorder(
                    child: AddressDetailsView(address: address),
                  ),
                  WidgetConstant.height20,
                  Text("locking_script".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.onPrimaryContainer),
                      child: CopyableTextWidget(
                          text: script,
                          maxLines: 3,
                          color: context.onPrimaryContainer)),
                  WidgetConstant.height20,
                  Text("threshold".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      onRemoveIcon:
                          Icon(Icons.edit, color: context.onPrimaryContainer),
                      child: Text(threshold.toString(),
                          style: context.onPrimaryTextTheme.titleMedium)),
                  WidgetConstant.height20,
                  Text("list_of_public_keys".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ListView.separated(
                      shrinkWrap: true,
                      physics: WidgetConstant.noScrollPhysics,
                      itemBuilder: (context, index) {
                        return _ShowAddressView(account: keyInfos[index]);
                      },
                      separatorBuilder: (context, index) =>
                          WidgetConstant.divider,
                      itemCount: keyInfos.length)
                ],
              )))
        ]);
      },
    );
  }
}

class _BitcoinMultisigAccountInfo {
  final IBitcoinAddress? address;
  final String publicKey;
  final Bip32AddressIndex keyIndex;
  final int weight;
  const _BitcoinMultisigAccountInfo(
      {required this.address,
      required this.publicKey,
      required this.keyIndex,
      required this.weight});
}

class _ShowAddressView extends StatelessWidget {
  final _BitcoinMultisigAccountInfo account;
  const _ShowAddressView({required this.account});
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      iconAlginment: CrossAxisAlignment.start,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (account.address != null) ...[
          Text("account".tr, style: context.onPrimaryTextTheme.labelLarge),
          WidgetConstant.height8,
          ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: AddressDetailsView(
                address: account.address!,
                color: context.colors.primaryContainer),
          ),
          WidgetConstant.height20
        ],
        Text("public_key".tr, style: context.onPrimaryTextTheme.labelLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: CopyableTextWidget(
              text: account.publicKey,
              color: context.primaryContainer,
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddressDrivationInfo(account.keyIndex,
                      color: context.primaryContainer),
                  OneLineTextWidget(account.publicKey,
                      style: context.primaryTextTheme.titleMedium)
                ],
              ),
            )),
        WidgetConstant.height20,
        Text("weight".tr, style: context.onPrimaryTextTheme.labelLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: Text(account.weight.toString(),
                style: context.primaryTextTheme.titleMedium))
      ]),
    );
  }
}
