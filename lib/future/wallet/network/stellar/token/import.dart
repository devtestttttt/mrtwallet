import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
// import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/token_details_view.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:stellar_dart/stellar_dart.dart';

class MonitorStellarTokenView extends StatelessWidget {
  const MonitorStellarTokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<StellarClient, IStellarAddress,
        StellarChain>(
      addressRequired: true,
      clientRequired: true,
      title: "add_token".tr,
      childBulder: (wallet, account, client, address, onAccountChanged) {
        return _MonitorStellarTokenView(
            chain: account, wallet: wallet, client: client);
      },
    );
  }
}

class _MonitorStellarTokenView extends StatefulWidget {
  const _MonitorStellarTokenView(
      {required this.chain, required this.wallet, required this.client});
  final StellarChain chain;
  final WalletProvider wallet;
  final StellarClient client;

  @override
  State<_MonitorStellarTokenView> createState() =>
      __MonitorStellarTokenViewState();
}

class __MonitorStellarTokenViewState extends State<_MonitorStellarTokenView>
    with SafeState {
  late final address = widget.chain.address;
  StellarClient get client => widget.client;
  List<StellarIssueToken> addressTokens = [];
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "__MonitorStellarTokenViewState");
  final Set<StellarIssueToken> tokens = {};
  void fetchingTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodUtils.call(() async {
      final account = await client.getAccount(address.networkAddress);
      if (account == null) return <StellarAssetBalanceResponse>[];
      return account.balances.whereType<StellarAssetBalanceResponse>().toList();
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      final toRippleIssue = result.result.map((e) {
        return addressTokens.firstWhere(
            (i) =>
                i.assetCode == e.assetCode &&
                i.issuer == e.assetIssuer &&
                i.assetType == e.assetType.assetType,
            orElse: () => e.toIssueToken());
      }).toList();
      tokens.addAll(toRippleIssue);
      progressKey.success();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    addressTokens = address.tokens;
    fetchingTokens();
  }

  Future<void> add(StellarIssueToken token) async {
    return await widget.chain.addNewToken(token: token, address: address);
  }

  Future<void> removeToken(StellarIssueToken token) async {
    return await widget.chain.removeToken(token: token, address: address);
  }

  Future<void> onTap(StellarIssueToken token, bool exist) async {
    try {
      if (exist) {
        await removeToken(token);
      } else {
        await add(token);
      }
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialStatus: PageProgressStatus.progress,
      backToIdle: APPConst.oneSecoundDuration,
      initialWidget:
          ProgressWithTextView(text: "fetching_account_token_please_wait".tr),
      child: (c) {
        return CustomScrollView(
          slivers: [
            EmptyItemSliverWidgetView(
              isEmpty: tokens.isEmpty,
              itemBuilder: (context) => SliverConstraintsBoxView(
                padding: WidgetConstant.padding20,
                sliver: SliverList.separated(
                  separatorBuilder: (context, index) => WidgetConstant.divider,
                  itemBuilder: (context, index) {
                    final token = tokens.elementAt(index);
                    final bool exist = address.tokens.contains(token);
                    return TokenDetailsView(
                      token: token,
                      onSelect: () {
                        context.openSliverDialog(
                            (ctx) => DialogTextView(
                                buttonWidget: AsyncDialogDoubleButtonView(
                                  firstButtonPressed: () => onTap(token, exist),
                                ),
                                text: exist
                                    ? "remove_token_from_account".tr
                                    : "add_token_to_your_account".tr),
                            exist ? "remove_token".tr : "add_token".tr);
                      },
                      onSelectWidget: APPCheckBox(
                        ignoring: true,
                        value: exist,
                        onChanged: (e) {},
                      ),
                    );
                  },
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  itemCount: tokens.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
