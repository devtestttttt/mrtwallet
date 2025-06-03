import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/account/state.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/monero/monero.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/networks/monero/monero.dart';
import 'package:on_chain_wallet/wallet/models/others/models/receipt_address.dart';

class MoneroAccountSyncView extends StatelessWidget {
  const MoneroAccountSyncView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<MoneroClient, IMoneroAddress,
        MoneroChain>(
      title: "sync_information".tr,
      addressRequired: true,
      clientRequired: true,
      childBulder: (wallet, account, client, address, onAccountChanged) =>
          _MoneroAccountSyncView(
              wallet: wallet, chain: account, client: client),
    );
  }
}

class _MoneroAccountSyncView extends StatefulWidget {
  const _MoneroAccountSyncView(
      {required this.wallet, required this.chain, required this.client});
  final WalletProvider wallet;
  final MoneroChain chain;
  final MoneroClient client;

  @override
  State<_MoneroAccountSyncView> createState() => _MoneroAccountSyncViewState();
}

class _MoneroAccountSyncViewState
    extends MoneroAccountState<_MoneroAccountSyncView> {
  @override
  MoneroChain get account => widget.chain;
  @override
  MoneroClient get client => widget.client;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();
  late _SyncRequest defaultTracker;

  List<_SyncRequest> requests = [];
  Map<_SyncRequest, Widget> syncRequests = {};
  int? currentHeight;

  void onChangeTracker(_SyncRequest? tracker) {
    if (tracker == null) return;
    defaultTracker = tracker;
    updateState();
  }

  Future<void> removeRequest(_SyncRequest status) async {
    final requestId = status.requestId;
    if (requestId == null) return;
    final accept = await context.openSliverDialog<bool>(
        (context) => DialogTextView(
            buttonWidget: DialogDoubleButtonView(),
            text: "remove_sync_block_request_from_account".tr),
        'sync_request'.tr);
    if (accept != true) return;
    progressKey.progressText("removing_request_please_wait".tr);
    final r = await MethodUtils.call(() async {
      return await account.removeSyncRequest(requestId);
    }, delay: APPConst.oneSecoundDuration);
    if (r.hasError) {
      progressKey.errorText(r.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    requests.removeWhere((e) => e.requestId == requestId);
    buildRequestsItems();
    defaultTracker = requests.first;
    progressKey.backToIdle();
  }

  _SyncRequest createViewRequest(
      {required List<MoneroBlockTrackingFailed> failedOffsets,
      required int startHeight,
      required int endHeight,
      required int currentHeight,
      required Iterable<MoneroSyncAccountsInfos> addresses,
      required String status,
      DateTime? created,
      int? requestId}) {
    final syncAddresses =
        addresses.map((e) => e.getAddresses()).expand((e) => e).map((e) {
      final address = account.getReceiptAddress(e.address.address) ??
          ReceiptAddress<MoneroAddress>(
              networkAddress: e.address, view: e.address.address);
      return _SyncedAddressWithHeight(height: e.startHeight, address: address);
    }).toList();
    return _SyncRequest(
        startHeight: startHeight.toDouble(),
        endHeight: endHeight.toDouble(),
        addresses: syncAddresses,
        requestId: requestId,
        created: created,
        failedOffsets: failedOffsets
            .map((e) => _FailedOffets(
                startHeight: e.startHeight.toDouble(),
                endHeight: e.endHeight.toDouble()))
            .toList(),
        currentHeight: currentHeight.toDouble(),
        status: status);
  }

  void buildRequestsItems() {
    syncRequests = {};
    for (final i in requests) {
      if (i.requestId == null) {
        syncRequests[i] = Text("default_chain_sync".tr);
      } else {
        syncRequests[i] = Text("requested_synchronizations"
            .tr
            .replaceOne(i.created!.toDateAndTime()));
      }
    }
  }

  void buildRequests({bool init = false}) {
    List<_SyncRequest> requests = [];
    final tracker = account.defaultTracker;
    requests.add(createViewRequest(
        startHeight: tracker.startHeight,
        endHeight: currentHeight ?? tracker.endHeight,
        addresses: tracker.accounts,
        failedOffsets: tracker.failedOffsets,
        currentHeight: tracker.currentHeight,
        status: tracker.status.name.tr));
    for (final i in tracker.requestOffsets) {
      requests.add(createViewRequest(
          startHeight: i.startHeight,
          endHeight: i.endHeight,
          addresses: i.accounts,
          failedOffsets: i.failedOffsets,
          currentHeight: i.currentHeight,
          status: i.status.name.tr,
          created: i.created,
          requestId: i.requestId));
    }
    this.requests = requests;
    buildRequestsItems();
    if (init) {
      defaultTracker = requests.first;
    } else {
      defaultTracker =
          requests.firstWhere((e) => e.requestId == defaultTracker.requestId);
      updateState();
    }
  }

  Future<void> init() async {
    final blockId = await MethodUtils.call(() async {
      final height = await client.getHeight();
      return height.block;
    });
    if (blockId.hasResult) {
      currentHeight = blockId.result;
    }
    buildRequests(init: true);
    progressKey.backToIdle();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    MethodUtils.after(() async => init(),
        duration: APPConst.oneSecoundDuration);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        buildRequests();
      },
      child: PageProgress(
        key: progressKey,
        initialStatus: StreamWidgetStatus.progress,
        backToIdle: APPConst.oneSecoundDuration,
        initialWidget:
            ProgressWithTextView(text: "fetching_current_block_data".tr),
        child: (context) => CustomScrollView(
          slivers: [
            SliverConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                sliver: MultiSliver(
                  children: [
                    SliverToBoxAdapter(
                      child: APPAnimated(
                        isActive: true,
                        onDeactive: (context) => WidgetConstant.sizedBox,
                        onActive: (context) => Column(
                          key: ValueKey(defaultTracker),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConditionalWidget(
                              onActive: (context) => Column(
                                children: [
                                  ErrorTextContainer(
                                      enableTap: false,
                                      error:
                                          "chain_synchronization_disabled_desc"
                                              .tr),
                                ],
                              ),
                              enable: !account.syncIsActive,
                            ),
                            WidgetConstant.height20,
                            Text("available_synchronizations".tr,
                                style: context.textTheme.titleMedium),
                            WidgetConstant.height8,
                            AppDropDownBottom(
                                items: syncRequests,
                                value: defaultTracker,
                                onChanged: onChangeTracker,
                                isExpanded: true),
                            if (defaultTracker.requestId != null) ...[
                              WidgetConstant.height20,
                              Text("status".tr,
                                  style: context.textTheme.titleMedium),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                enableTap: false,
                                onRemoveWidget: IconButton(
                                    onPressed: () =>
                                        removeRequest(defaultTracker),
                                    icon: Icon(Icons.remove_circle,
                                        color: context.onPrimaryContainer)),
                                onRemove: () => removeRequest(defaultTracker),
                                child: Text(defaultTracker.status,
                                    style:
                                        context.onPrimaryTextTheme.bodyMedium),
                              ),
                            ],
                            WidgetConstant.height20,
                            Text("fetched_blocks".tr,
                                style: context.textTheme.titleMedium),
                            WidgetConstant.height8,
                            ContainerWithBorder(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(defaultTracker.rangeStr,
                                      style: context
                                          .onPrimaryTextTheme.bodyMedium),
                                  Slider(
                                      value: defaultTracker.currentHeight,
                                      label: defaultTracker.currentHeight
                                          .toString(),
                                      onChanged: (e) {},
                                      divisions: defaultTracker.divisions,
                                      min: defaultTracker.startHeight,
                                      max: defaultTracker.endHeight,
                                      activeColor: context.colors.primary,
                                      inactiveColor:
                                          context.onPrimaryContainer),
                                ],
                              ),
                            ),
                            ConditionalWidget(
                                enable: currentHeight != null,
                                onActive: (context) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        WidgetConstant.height20,
                                        Text("current_block_height".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        ContainerWithBorder(
                                          child: Text(currentHeight.toString(),
                                              style: context.onPrimaryTextTheme
                                                  .bodyMedium),
                                        ),
                                      ],
                                    )),
                            WidgetConstant.height20,
                            Text("addresses".tr,
                                style: context.textTheme.titleMedium),
                            Text("addresses_and_initial_sync_block".tr,
                                style: context.textTheme.bodyMedium),
                            WidgetConstant.height8,
                            APPExpansionListTile(
                              title: Text("addresses".tr,
                                  style: context.onPrimaryTextTheme.bodyMedium),
                              children: [_Addresses(defaultTracker.addresses)],
                            ),
                            ConditionalWidget(
                                enable: defaultTracker.failedOffsets.isNotEmpty,
                                onActive: (context) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        WidgetConstant.height20,
                                        Text("faliled_blocks".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        APPExpansionListTile(
                                          title: Text("faliled_blocks".tr,
                                              style: context.onPrimaryTextTheme
                                                  .bodyMedium),
                                          children: [
                                            _FailedBlocks(
                                                defaultTracker.failedOffsets)
                                          ],
                                        ),
                                      ],
                                    ))
                          ],
                        ),
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class _FailedBlocks extends StatelessWidget {
  const _FailedBlocks(this.failedBlocks);
  final List<_FailedOffets> failedBlocks;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: WidgetConstant.noScrollPhysics,
        itemBuilder: (context, index) {
          final failedBlock = failedBlocks[index];
          return ContainerWithBorder(
            child: Text(failedBlock.rangeStr,
                style: context.onPrimaryTextTheme.bodyMedium),
          );
        },
        itemCount: failedBlocks.length,
        separatorBuilder: (context, index) =>
            Divider(color: context.onPrimaryContainer));
  }
}

class _Addresses extends StatelessWidget {
  const _Addresses(this.syncAddresses);
  final List<_SyncedAddressWithHeight> syncAddresses;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: WidgetConstant.noScrollPhysics,
        itemBuilder: (context, index) {
          final address = syncAddresses[index];
          return ContainerWithBorder(
            child: Column(
              children: [
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: ReceiptAddressDetailsView(
                    address: address.address,
                    color: context.primaryContainer,
                  ),
                ),
                Divider(color: context.onPrimaryContainer),
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: Text(address.height.toString(),
                      style: context.primaryTextTheme.bodyMedium),
                )
              ],
            ),
          );
        },
        itemCount: syncAddresses.length,
        separatorBuilder: (context, index) =>
            Divider(color: context.onPrimaryContainer));
  }
}

class _SyncedAddressWithHeight {
  final int height;
  final ReceiptAddress<MoneroAddress> address;
  const _SyncedAddressWithHeight({required this.height, required this.address});
}

class _FailedOffets {
  final double startHeight;
  final double endHeight;
  _FailedOffets({required this.startHeight, required this.endHeight})
      : rangeStr = "$startHeight/$endHeight";
  final String rangeStr;
}

class _SyncRequest {
  final double startHeight;
  final double endHeight;
  double currentHeight;
  final List<_SyncedAddressWithHeight> addresses;
  final List<_FailedOffets> failedOffsets;
  final String status;
  final int? requestId;
  final DateTime? created;
  late final int divisions = (endHeight - startHeight).toInt();
  String rangeStr;
  _SyncRequest(
      {required this.startHeight,
      required this.endHeight,
      required this.addresses,
      required this.failedOffsets,
      required this.currentHeight,
      required this.status,
      required this.requestId,
      required this.created})
      : rangeStr = "${startHeight.toInt()}/${endHeight.toInt()}";
}
