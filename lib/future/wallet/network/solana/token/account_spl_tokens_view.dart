import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain/solana/src/instructions/spl_token/constant.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class SolanaImportSPLTokensView extends StatelessWidget {
  const SolanaImportSPLTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SolanaClient, ISolanaAddress,
        SolanaChain>(
      title: "import_spl_tokens".tr,
      addressRequired: true,
      clientRequired: true,
      childBulder: (wallet, account, client, address, onAccountChanged) {
        return _SolanaImportSPLTokensView(
          apiProvider: client,
          account: account,
          wallet: wallet,
        );
      },
    );
  }
}

class _SolanaImportSPLTokensView extends StatefulWidget {
  const _SolanaImportSPLTokensView(
      {required this.apiProvider, required this.account, required this.wallet});
  final SolanaClient apiProvider;
  final SolanaChain account;
  final WalletProvider wallet;
  @override
  State<_SolanaImportSPLTokensView> createState() =>
      __SolanaImportSPLTokensViewState();
}

class __SolanaImportSPLTokensViewState
    extends State<_SolanaImportSPLTokensView> {
  late final address = widget.account.address;
  final List<SolanaSPLToken> tokens = [];
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_SolanaImportSPLTokensView");
  void fetchTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodUtils.call(() async {
      final spltoken =
          await widget.apiProvider.getAccountTokens(address.networkAddress);
      final splTokens2022 = await widget.apiProvider.getAccountTokens(
          address.networkAddress,
          tokenProgram: SPLTokenProgramConst.token2022ProgramId);
      return [...spltoken, ...splTokens2022];
    });
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      tokens.addAll(result.result.map((e) => e.toSplToken).toList());
      if (tokens.isNotEmpty) {
        progressKey.success();
      } else {
        progressKey.success(
            backToIdle: false,
            progressWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetConstant.checkCircleLarge,
                WidgetConstant.height8,
                Text("unable_to_locate_token".tr),
              ],
            ));
      }
    }
  }

  Future<void> add(SolanaSPLToken token) async {
    return await widget.account.addNewToken(token: token, address: address);
  }

  Future<void> removeToken(SolanaSPLToken token) async {
    return await widget.account.removeToken(token: token, address: address);
  }

  Future<void> onTap(SolanaSPLToken token, bool exist) async {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTokens();
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
              itemBuilder: (context) => SliverToBoxAdapter(
                child: ConstraintsBoxView(
                  padding: WidgetConstant.padding20,
                  child: ListView.separated(
                    physics: WidgetConstant.noScrollPhysics,
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemBuilder: (context, index) {
                      final token = tokens.elementAt(index);
                      final bool exist = address.tokens.contains(token);
                      return TokenDetailsView(
                          onSelect: () {
                            context.openSliverDialog(
                                (ctx) => DialogTextView(
                                    buttonWidget: AsyncDialogDoubleButtonView(
                                      firstButtonPressed: () =>
                                          onTap(token, exist),
                                    ),
                                    text: exist
                                        ? "remove_token_from_account".tr
                                        : "add_token_to_your_account".tr),
                                exist ? "remove_token".tr : "add_token".tr);
                          },
                          onSelectIcon: APPCheckBox(
                              value: exist,
                              ignoring: true,
                              onChanged: (value) {}),
                          token: token);
                    },
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemCount: tokens.length,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
