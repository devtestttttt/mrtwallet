import 'package:blockchain_utils/bip/bip/conf/core/coin_conf.dart';
import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/account/state.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/constant/networks/monero.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

enum _SyncOptionsPage {
  walletRPC("wallet_rpc"),
  transactions("transaction_id"),
  block("block"),
  showPayment("");

  final String tr;
  const _SyncOptionsPage(this.tr);
}

class MoneroSyncOptionsView extends StatelessWidget {
  const MoneroSyncOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      title: "sync_options".tr,
      accsess: WalletAccsessType.unlock,
      onAccsess: (credential, password, network) {
        return NetworkAccountControllerView<MoneroClient, IMoneroAddress,
                MoneroChain>(
            addressRequired: true,
            clientRequired: true,
            childBulder: (wallet, account, client, address, onAccountChanged) =>
                _MoneroSyncOptionsView(
                    wallet: wallet, chain: account, client: client));
      },
    );
  }
}

class _MoneroSyncOptionsView extends StatefulWidget {
  final WalletProvider wallet;
  final MoneroChain chain;
  final MoneroClient client;
  const _MoneroSyncOptionsView(
      {required this.wallet, required this.chain, required this.client});

  @override
  State<_MoneroSyncOptionsView> createState() => _MoneroSyncOptionsViewState();
}

class _MoneroSyncOptionsViewState
    extends MoneroAccountState<_MoneroSyncOptionsView> {
  late MoneroSyncChain syncChain = account.syncChain;
  bool allowCreateBlockRequest = false;
  // bool get syncIsActive => account.syncIsActive;

  Map<_SyncOptionsPage, Widget> options = {};
  Map<ChainType?, Widget> syncChainItems = {};

  List<MoneroViewUnlockedPaymentRequestDetails>? payments;
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<AppTextFieldState> txIdsStateKey = GlobalKey();
  List<MoneroAddress> allRelatedAccountAddresses = [];

  @override
  final List<IMoneroAddress> addresses = [];

  MoneroAPIProvider? walletProvider;
  RPCURL? rpcUrl;
  final GlobalKey<HTTPServiceProviderFieldsState> serviceProviderStateKey =
      GlobalKey(
          debugLabel: "_MoneroSyncOptionsViewState_serviceProviderStateKey");

  WalletProvider get wallet => widget.wallet;
  @override
  MoneroChain get account => widget.chain;

  @override
  MoneroClient get client => widget.client;
  WalletMoneroNetwork get network => account.network;
  bool walletRpcSync = false;
  bool get walletRpcConnected => walletRpcSync && walletProvider != null;

  _SyncOptionsPage? option;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "_MoneroSyncOptionsViewState_progressKey");

  void onChangeWalletRpcSync(bool? _) async {
    final provider = walletProvider;
    if (walletRpcSync && provider != null) {
      final accept = await context.openSliverDialog<bool>(
          (p0) => DialogTextView(
              buttonWidget: DialogDoubleButtonView(),
              widget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("disconnect_from_monero_wallet_rpc_desc".tr),
                ],
              )),
          "disconnect_from_wallet_rpc".tr);
      if (accept != true) {
        return;
      }
      await account.saveWalletRpc(null);
      rpcUrl = RPCURL(url: provider.callUrl, auth: provider.auth);
      walletProvider = null;
    }
    walletRpcSync = !walletRpcSync;
    updateState();
  }

  Future<void> initOptions() async {
    for (final i in _SyncOptionsPage.values) {
      if (i == _SyncOptionsPage.showPayment) continue;
      options[i] = Text(i.tr.tr);
    }
    for (final i in ChainType.values) {
      syncChainItems[i] = Text(i.tr.tr);
    }
    syncChainItems[null] = Text("none".tr);

    allRelatedAccountAddresses =
        account.addresses.map((e) => e.networkAddress).toList();
    walletProvider = await account.getWalletRPC();
    if (walletProvider != null) {
      walletRpcSync = true;
    }
    checkAllowCreateBlockRequest();
    progressKey.backToIdle();
  }

  void onChangeOption(_SyncOptionsPage? option) {
    this.option = option;
    updateState();
  }

  void checkAllowCreateBlockRequest() {
    allowCreateBlockRequest =
        syncChain.chain == account.network.coinParam.chainType;

    if (!allowCreateBlockRequest) {
      blockRequest.clear();
    }
  }

  void onChangeSyncChain(ChainType? option) {
    switch (option) {
      case ChainType.testnet:
        syncChain = MoneroSyncChain.testnet;
        break;
      case ChainType.mainnet:
        syncChain = MoneroSyncChain.mainnet;
        break;
      default:
        syncChain = MoneroSyncChain.none;
        break;
    }
    checkAllowCreateBlockRequest();
    updateState();
  }

  List<MoneroViewUnlockedPaymentRequestDetails>? toViewPayment(
      List<MoneroUnlockedPaymentRequestDetails>? payments) {
    return payments?.map((e) {
      final output = e.output;
      return MoneroViewUnlockedPaymentRequestDetails(
          txID: e.txID,
          status: e.status,
          output: output == null
              ? null
              : MoneroViewOutputDetails(
                  output: output,
                  amount: IntegerBalance.token(output.amount, network.token)));
    }).toList();
  }

  void syncFromRpc() async {
    rpcUrl = serviceProviderStateKey.currentState?.getEndpoint();
    final url = rpcUrl;
    if (url == null) return;
    final provider = MoneroAPIProvider(
        identifier: APIUtils.getProviderIdentifier(),
        httpNodeUri: url.url,
        auth: url.auth);
    final client = MoneroWalletClient(provider, account.network);
    // final r = await client.accountInfos();
    // print("r $r");
    // return;
    progressKey.progressText("monero_fetching_Wallet_addresses".tr);

    final walletAddresses =
        await MethodUtils.call(() => client.readMoneroWalletAdresses());
    if (walletAddresses.hasError) {
      progressKey.errorText(walletAddresses.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    final relatedAccounts = account.addresses
        .where((e) =>
            walletAddresses.result.any((r) => e.networkAddress == r.address))
        .toList();
    if (relatedAccounts.isEmpty) {
      progressKey.errorText("wallet_rpc_different_account_response_desc".tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.progressText("monero_fetching_Wallet_available_transfers".tr);
      final result =
          await MethodUtils.call(() => client.readMoneroWalletTxes(account));
      if (result.hasError) {
        progressKey.errorText(result.error?.tr ?? "");
        return;
      }
      if (walletRpcSync) {
        await account.saveWalletRpc(provider);
        walletProvider = provider;
      }
      if (result.result.isEmpty) {
        progressKey.errorText("monero_wallet_rpc_sync_no_tx_found_desc".tr,
            backToIdle: false, showBackButton: true);
        return;
      }
      progressKey.progressText("retrieving_transaction".tr);
      final unlockedInfo = await wallet.wallet
          .moneroUpdatePendingTxes(account: account, txIds: result.result);
      if (unlockedInfo.hasError) {
        progressKey.errorText(unlockedInfo.error!.tr);
        return;
      }
      payments = toViewPayment(unlockedInfo.result);
      if (payments!.isEmpty) {
        progressKey.successProgress(
            progressWidget: ProgressWithTextView(
              text: "monero_empty_outputs_desc".tr,
              icon: const Icon(Icons.hourglass_empty),
            ),
            backToIdle: true);
        return;
      }
      option = _SyncOptionsPage.showPayment;
      progressKey.success(backToIdle: true);
    }
  }

  void resetToDefault() {
    if (option == null) return;
    option = null;
    progressKey.backToIdle();
    updateState();
  }

  String? validateTransactionIds(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "enter_transaction_ids_validator".tr;
    }
    final txIds = StrUtils.separateBySpace(v).map((e) => e.toLowerCase());
    if (txIds.isEmpty) {
      return "enter_transaction_ids_validator".tr;
    }
    final isValid = txIds.every((e) => APPConst.hex32Bytes.hasMatch(e));
    if (!isValid) return "enter_transaction_ids_validator2".tr;
    if (txIds.toSet().length != txIds.length) {
      return "duplicate_transaction_ids_detected".tr;
    }
    return null;
  }

  List<MoneroSyncAccountRequest> blockRequest = [];
  void onRemoveRequest(MoneroSyncAccountRequest request) {
    blockRequest.remove(request);
    updateState();
  }

  Future<void> addBlockRequest() async {
    if (!allowCreateBlockRequest) {
      context.showAlert("monero_create_block_request_desc".tr);
      return;
    }
    final pendigRequest = account.defaultTracker.getPendingRequestOffsets();
    final List<List<int>> ranges = [
      ...pendigRequest.map((e) => [e.startHeight, e.endHeight]),
      ...blockRequest.map((e) => [e.startHeight, e.endHeight]),
    ];
    final request =
        await context.openMaxExtendSliverBottomSheet<MoneroSyncAccountRequest>(
            'sync_request'.tr,
            child: _CreateSyncHeightRequest(
              account: account,
              curretBlock: client.currentHeight?.block,
              existsRanges: ranges,
            ));
    if (request == null) return;

    blockRequest.add(request);

    updateState();
  }

  Future<void> updateSyncBlockOptions() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("submiting_sync_process".tr);
    final moneroChains = wallet.wallet.getChains<MoneroChain>();
    if (account.syncChain != syncChain) {
      final otherChain = moneroChains.firstWhere((e) => e != account);
      await otherChain.updateSyncChain(syncChain);
    }
    final result = await MethodUtils.call(() async {
      final sync = await account.updateChainSyncOptions(
          requests: blockRequest, chain: syncChain);
      return sync;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    progressKey.success(backToIdle: false);
  }

  void syncTransactionIds() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final txes = txIdsStateKey.currentState?.getValue();
    final txIds = StrUtils.separateBySpace(txes);
    if (txIds.isEmpty) return;
    final relatedTxIds = MoneroAccountPendingTxes.request(
        accountIndex: address.keyIndex.cast(),
        primaryAddress: address.addrDetails.primaryAccount(),
        indexes: account
            .relateAccountIndexes(address.addrDetails.viewKey)
            .map((e) => MoneroAccountIndexTxes(index: e, txes: txIds)));
    progressKey.progressText("retrieving_transaction".tr);
    final unlockedInfo = await wallet.wallet
        .moneroUpdatePendingTxes(account: account, txIds: [relatedTxIds]);
    if (unlockedInfo.hasError) {
      progressKey.errorText(unlockedInfo.error!.tr);
      return;
    }
    payments = toViewPayment(unlockedInfo.result);
    if (payments!.isEmpty) {
      progressKey.successProgress(
          progressWidget: ProgressWithTextView(
            text: "monero_empty_outputs_desc".tr,
            icon: const Icon(Icons.hourglass_empty),
          ),
          backToIdle: true);
      return;
    }
    option = _SyncOptionsPage.showPayment;
    progressKey.success(backToIdle: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async => initOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      canPop: option == null,
      key: formKey,
      onPopInvokedWithResult: (didPop, result) {
        resetToDefault();
      },
      child: PageProgress(
          key: progressKey,
          backToIdle: APPConst.twoSecoundDuration,
          initialStatus: StreamWidgetStatus.progress,
          child: (context) {
            return Center(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  WidgetConstant.sliverPaddingVertial20,
                  SliverConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    sliver: APPSliverAnimatedSwitcher<_SyncOptionsPage>(
                        enable: option,
                        widgets: {
                          null: (c) => _SelectOptions(this),
                          _SyncOptionsPage.walletRPC: (c) =>
                              _WalletRPCSynOption(this),
                          _SyncOptionsPage.transactions: (c) =>
                              _TransactionSyncOption(this),
                          _SyncOptionsPage.block: (c) =>
                              _AtHeightSyncOpetion(this),
                          _SyncOptionsPage.showPayment: (c) =>
                              _ShowPayments(state: this, payments: payments!)
                        }),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class _SelectOptions extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _SelectOptions(this.state);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WidgetConstant.height20,
          Text("sync_options".tr, style: context.textTheme.titleMedium),
          Text("monero_sync_options_desc".tr),
          WidgetConstant.height8,
          AppDropDownBottom(
              hint: "sync_options".tr,
              items: state.options,
              onChanged: state.onChangeOption)
        ],
      ),
    );
  }
}

class _WalletRPCSynOption extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _WalletRPCSynOption(this.state);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "monero_wallet_rpc_sync_desc".tr,
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("monero_wallet_rpc_sync_desc1".tr),
                    Text("monero_wallet_rpc_sync_desc2".tr),
                    WidgetConstant.height8,
                    ErrorTextContainer(
                        error: "monero_wallet_rpc_safty_interacting_desc".tr,
                        enableTap: false),
                  ])),
          AppSwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.walletRpcSync,
            onChanged: state.onChangeWalletRpcSync,
            title: Text("maintain_monero_wallet_rpc_connection".tr,
                style: context.textTheme.titleMedium),
            subtitle: Text("store_wallet_rpc_connection".tr),
          ),
          WidgetConstant.height20,
          APPAnimatedSwitcher(enable: state.walletRpcConnected, widgets: {
            false: (context) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("wallet_rpc_url".tr,
                      style: context.textTheme.titleMedium),
                  Text("wallet_rpc_url_desc".tr),
                  WidgetConstant.height8,
                  HTTPServiceProviderFields(
                    key: state.serviceProviderStateKey,
                    initialUrl: state.rpcUrl,
                    hint: MoneroConst.walletRPCLinkExample,
                    enableAuth: true,
                    protocols: [ServiceProtocol.http],
                  ),
                ]),
            true: (context) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("wallet_rpc".tr, style: context.textTheme.titleMedium),
                  Text("already_connected_to_monero_wallet_rpc".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    child: CopyableTextWidget(
                        text: state.walletProvider!.callUrl,
                        color: context.onPrimaryContainer),
                  ),
                ])
          }),
          APPAnimatedSwitcher(enable: state.walletRpcConnected, widgets: {
            false: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical40,
                        onPressed: state.syncFromRpc,
                        child: Text("sync_now".tr)),
                  ],
                )
          }),
        ],
      ),
    );
  }
}

class _TransactionSyncOption extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _TransactionSyncOption(this.state);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "monero_wallet_transaction_sync_desc".tr,
              body: Text("monero_wallet_transaction_sync_desc2".tr)),
          Text("transaction_id".tr, style: context.textTheme.titleMedium),
          Text("enter_transaction_ids_desc".tr),
          WidgetConstant.height8,
          AppTextField(
              label: "transaction_ids".tr,
              pasteIcon: true,
              maxLines: 5,
              minlines: 2,
              validator: state.validateTransactionIds,
              keyboardType: TextInputType.text,
              key: state.txIdsStateKey),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.syncTransactionIds,
                  child: Text("sync_now".tr)),
            ],
          )
        ],
      ),
    );
  }
}

class _ShowPayments extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  final List<MoneroViewUnlockedPaymentRequestDetails> payments;
  const _ShowPayments({required this.state, required this.payments});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("payment_information".tr,
                style: context.textTheme.titleMedium),
            Text("monero_payment_synced_desc".tr),
            WidgetConstant.height8,
          ],
        ),
      ),
      SliverList.separated(
          itemBuilder: (context, index) {
            final payment = payments[index];
            return _ShowPayment(payment: payment, network: state.network);
          },
          itemCount: payments.length,
          separatorBuilder: (context, index) => WidgetConstant.divider),
      SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                child: Text("sync_more".tr),
                onPressed: () {
                  state.resetToDefault();
                }),
          ],
        ),
      ),
    ]);
  }
}

class _ShowPayment extends StatelessWidget {
  const _ShowPayment({required this.payment, required this.network});
  final MoneroViewUnlockedPaymentRequestDetails payment;
  final WalletMoneroNetwork network;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        onRemove: () {},
        enableTap: false,
        onRemoveWidget: ConditionalWidgets<MoneroUnlockPaymentRequestStatus>(
            enable: payment.status,
            widgets: {
              MoneroUnlockPaymentRequestStatus.error: (context) =>
                  WidgetConstant.errorIcon,
              MoneroUnlockPaymentRequestStatus.success: (context) {
                return ConditionalWidgets(
                    enable: payment.output!.output.status,
                    widgets: {
                      MoneroUnlockPaymentRequestOutputStatus.unspent:
                          (context) => TappedTooltipView(
                                tooltipWidget: ToolTipView(
                                    message: "output_is_ready_to_spent".tr,
                                    child: Icon(Icons.attach_money_rounded,
                                        color: context.colors.green)),
                              ),
                      MoneroUnlockPaymentRequestOutputStatus.spent: (context) =>
                          TappedTooltipView(
                            tooltipWidget: ToolTipView(
                                message: "output_has_already_spent".tr,
                                child: Icon(Icons.money_off_rounded,
                                    color: context.colors.onPrimaryContainer)),
                          ),
                      MoneroUnlockPaymentRequestOutputStatus.pool: (context) =>
                          TappedTooltipView(
                            tooltipWidget: ToolTipView(
                                message: "output_has_already_spent".tr,
                                child: Icon(Icons.money_off_rounded,
                                    color: context.colors.onPrimaryContainer)),
                          ),
                    });
              }
            }),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OneLineTextWidget(payment.txID,
                style: context.colors.onPrimaryContainer.bodyMedium(context)),
            ConditionalWidgets<MoneroUnlockPaymentRequestStatus>(
                enable: payment.status,
                widgets: {
                  MoneroUnlockPaymentRequestStatus.success: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoinAndMarketPriceView(
                            balance: payment.output!.amount,
                            style: context.onPrimaryTextTheme.labelLarge,
                            symbolColor: context.colors.onPrimaryContainer),
                      ],
                    );
                  }
                }),
          ],
        ));
  }
}

class _AtHeightSyncOpetion extends StatelessWidget {
  final _MoneroSyncOptionsViewState state;
  const _AtHeightSyncOpetion(this.state);
  @override
  Widget build(BuildContext context) {
    return SliverConstraintsBoxView(
      padding: WidgetConstant.paddingHorizontal20,
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleSubtitle(
                title: 'sync_account_with_blockchain_data'.tr,
                body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("monero_sync_block_desc3".tr),
                      Text("monero_sync_block_desc4".tr),
                      AlertTextContainer(
                        message: "monero_sync_block_desc5".tr,
                        enableTap: false,
                      ),
                    ])),
            Text("sync_network".tr, style: context.textTheme.titleMedium),
            Text("monero_sync_block_desc".tr),
            WidgetConstant.height8,
            AppDropDownBottom<ChainType?>(
                hint: "sync_network".tr,
                items: state.syncChainItems,
                value: state.syncChain.chain,
                onChanged: state.onChangeSyncChain),
            ConditionalWidget(
                enable: state.syncChain.chain != null,
                onActive: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetConstant.height20,
                          Text("monero_block_height_sync_desc".tr,
                              style: context.textTheme.titleMedium),
                          Text("monero_block_height_sync_desc2".tr),
                          WidgetConstant.height8,
                          ...List.generate(state.blockRequest.length, (i) {
                            final request = state.blockRequest[i];
                            return ContainerWithBorder(
                                onRemoveIcon: Icon(Icons.remove_circle,
                                    color: context.onPrimaryContainer),
                                onRemove: () => state.onRemoveRequest(request),
                                child: Text(
                                  request.heightsStr,
                                  style: context.onPrimaryTextTheme.bodyMedium,
                                ));
                          }),
                          ContainerWithBorder(
                              onRemove: state.addBlockRequest,
                              validate: state.allowCreateBlockRequest,
                              validateText:
                                  "monero_create_block_request_desc".tr,
                              onRemoveIcon: Icon(Icons.add_box,
                                  color: context.onPrimaryContainer),
                              child: Text(
                                "tap_to_create_new_request".tr,
                                style: context.onPrimaryTextTheme.bodyMedium,
                              )),
                        ])),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                    padding: WidgetConstant.paddingVertical40,
                    onPressed: state.updateSyncBlockOptions,
                    child: Text("submit".tr)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CreateSyncHeightRequest extends StatefulWidget {
  final MoneroChain account;
  final int? curretBlock;
  final List<List<int>> existsRanges;
  const _CreateSyncHeightRequest(
      {required this.account,
      required this.curretBlock,
      required this.existsRanges});

  @override
  State<_CreateSyncHeightRequest> createState() =>
      __CreateSyncHeightRequestState();
}

class __CreateSyncHeightRequestState extends State<_CreateSyncHeightRequest>
    with SafeState<_CreateSyncHeightRequest> {
  final List<IMoneroAddress> addresses = [];
  late final int rctHeight = widget.account.network.coinParam.rctHeight;
  late final int? max = widget.curretBlock;

  bool enable = false;
  void onBlockEnd(int block) {
    endBlock = block;
  }

  void onBlockStart(int block) {
    startBlock = block;
  }

  String? validateOnBlockStart(String? v) {
    final block = int.tryParse(v ?? '');
    return validateBlockFilds(block);
  }

  int startBlock = 0;
  int endBlock = 0;

  void addAddress(IMoneroAddress? address) {
    if (address == null) return;
    if (addresses.contains(address)) {
      context.showAlert("address_already_exist".tr);
      return;
    }
    addresses.add(address);
    enable = addresses.isNotEmpty;
    updateState();
  }

  void removeAddress(IMoneroAddress address) {
    addresses.remove(address);
    enable = addresses.isNotEmpty;
    updateState();
  }

  String? validateBlockFilds(int? block) {
    if (block == null) {
      return "enter_valid_number".tr;
    }
    if (block < rctHeight) {
      return "monero_rct_block_validator".tr.replaceOne(rctHeight.toString());
    }
    for (final i in widget.existsRanges) {
      if ((block >= i[0] && block <= i[1])) {
        return "block_height_already_exists".tr;
      }
    }
    return null;
  }

  String? validateOnBlockEnd(String? v) {
    final block = int.tryParse(v ?? '');
    final err = validateBlockFilds(block);
    if (err != null) return err;
    if (block! <= startBlock) {
      return "monero_sync_block_validator".tr;
    }
    return null;
  }

  void submit() {
    final request = MoneroSyncAccountRequest(
        addresses: addresses, endHeight: endBlock, startHeight: startBlock);
    context.pop(request);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageTitleSubtitle(
          title: "monero_block_height_sync_desc".tr,
          body: LargeTextView([
            "monero_block_height_sync_desc2".tr,
            "monero_block_height_sync_desc3".tr,
            "monero_rct_block_validator".tr.replaceOne(
                widget.account.network.coinParam.rctHeight.toString()),
            "monero_sync_block_desc6".tr
          ])),
      Text("start_at_block".tr, style: context.textTheme.titleMedium),
      WidgetConstant.height8,
      NumberTextField(
          hintText: "start_at_block".tr,
          onChange: onBlockStart,
          min: rctHeight,
          max: max,
          defaultValue: startBlock,
          maxWidth: double.infinity,
          validator: validateOnBlockStart),
      WidgetConstant.height20,
      Text("end_at_block".tr, style: context.textTheme.titleMedium),
      WidgetConstant.height8,
      NumberTextField(
          hintText: "end_at_block".tr,
          onChange: onBlockEnd,
          min: rctHeight,
          validator: validateOnBlockEnd,
          defaultValue: endBlock,
          maxWidth: double.infinity,
          max: max),
      WidgetConstant.height20,
      Text("select_account".tr, style: context.textTheme.titleMedium),
      Text("select_accounts_for_syncing".tr),
      WidgetConstant.height8,
      Column(
        children: List.generate(addresses.length, (index) {
          final address = addresses[index];
          return ContainerWithBorder(
            onRemoveIcon: Icon(Icons.remove_circle,
                color: context.colors.onPrimaryContainer),
            onRemove: () {
              removeAddress(address);
            },
            child: AddressDetailsView(
                address: address,
                showBalance: false,
                color: context.onPrimaryContainer),
          );
        }),
      ),
      ContainerWithBorder(
          validate: addresses.isNotEmpty,
          onRemove: () {
            context
                .selectOrSwitchAccount<IMoneroAddress>(
                    account: widget.account, showMultiSig: true)
                .then(addAddress);
          },
          onRemoveIcon: Icon(Icons.add_box, color: context.onPrimaryContainer),
          child: Text("tap_to_add_account".tr,
              style: context.onPrimaryTextTheme.bodyMedium)),
      WidgetConstant.height20,
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FixedElevatedButton(
              activePress: enable,
              padding: WidgetConstant.paddingVertical40,
              onPressed: submit,
              child: Text("submit".tr)),
        ],
      )
    ]);
  }
}
