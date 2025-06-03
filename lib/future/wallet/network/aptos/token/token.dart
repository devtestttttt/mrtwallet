import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/aptos/account/state.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class AptosImportFATTokensView extends StatelessWidget {
  const AptosImportFATTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<AptosClient, IAptosAddress, AptosChain>(
      title: "import_token".tr,
      addressRequired: true,
      clientRequired: true,
      childBulder: (wallet, account, client, address, onAccountChanged) {
        return _AptosImportFATTokensView(
            account: account, wallet: wallet, client: client);
      },
    );
  }
}

class _AptosImportFATTokensView extends StatefulWidget {
  const _AptosImportFATTokensView(
      {required this.account, required this.wallet, required this.client});
  final AptosChain account;
  final WalletProvider wallet;
  final AptosClient client;
  @override
  State<_AptosImportFATTokensView> createState() =>
      __AptosImportFATTokensViewState();
}

class __AptosImportFATTokensViewState
    extends AptosAccountState<_AptosImportFATTokensView> {
  @override
  AptosChain get account => widget.account;
  @override
  AptosClient get client => widget.client;
  List<AptosFATokens> tokens = [];
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_AptosImportFATTokensView");
  Future<void> fetchTokens() async {
    final result = await MethodUtils.call(() async {
      return await client.getAccountFTTokens(address.networkAddress);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      tokens = result.result;
      progressKey.success();
    }
  }

  Future<void> add(AptosFATokens token) async {
    return await widget.account.addNewToken(token: token, address: address);
  }

  Future<void> removeToken(AptosFATokens token) async {
    return await widget.account.removeToken(token: token, address: address);
  }

  Future<void> onTap(AptosFATokens token, bool exist) async {
    try {
      if (exist) {
        await removeToken(token);
      } else {
        await add(token);
      }
    } finally {
      updateState();
    }
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
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
                        final bool exist = addressTokens.contains(token);
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
                      itemCount: tokens.length),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
