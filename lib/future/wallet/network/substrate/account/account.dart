import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/substrate/transfer/extrinsic.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/substrate.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

class SubstrateAccountPageView extends StatelessWidget {
  const SubstrateAccountPageView({required this.chainAccount, super.key});
  final SubstrateChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _SubstrateServices(chainAccount),
      AccountTransactionActivityView(chainAccount)
    ]);
  }
}

class _SubstrateServices extends StatelessWidget {
  const _SubstrateServices(this.account);
  final SubstrateChain account;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      AccountManageProviderIcon(service: account.service),
      SliverToBoxAdapter(
        child: Column(children: [
          AppListTile(
            title: Text("constants".tr),
            subtitle: Text("access_network_constants".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.openMaxExtendSliverBottomSheet(
                'constants'.tr,
                bodyBuilder: (controller) => SubstrateMetadataConstantsView(
                    scrollController: controller, account: account),
              );
            },
          ),
          AppListTile(
            title: Text("storages".tr),
            subtitle: Text("query_network_storages".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.openMaxExtendSliverBottomSheet(
                'storages'.tr,
                bodyBuilder: (controller) => SubstrateMetadataStoragesView(
                    scrollController: controller, account: account),
              );
            },
          ),
          AppListTile(
            title: Text("runtime_apis".tr),
            subtitle: Text("interact_with_substrate_network_run_time_api".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.openMaxExtendSliverBottomSheet(
                'runtime_apis'.tr,
                bodyBuilder: (controller) => SubstrateMetadataRuntimeApiView(
                    scrollController: controller, account: account),
              );
            },
          ),
          AppListTile(
            title: Text("create_extrinsic".tr),
            subtitle: Text("create_and_sign_extrinsic".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PageRouter.substrateTransaction,
                  argruments:
                      LiveTransactionForm(validator: SubstrateExtersincForm()));
            },
          ),
        ]),
      )
    ]);
  }
}
