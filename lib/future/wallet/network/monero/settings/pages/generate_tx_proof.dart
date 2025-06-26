import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/account/state.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/monero/monero.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class MoneroGenerateTxProofView extends StatelessWidget {
  const MoneroGenerateTxProofView({super.key});

  @override
  Widget build(BuildContext context) {
    final MoneroWalletTransactionProof? requestProof =
        context.getNullArgruments();
    return PasswordCheckerView(
      title: "generate_transaction_proof".tr,
      accsess: WalletAccsessType.unlock,
      onAccsess: (credential, password, network) {
        return NetworkAccountControllerView<MoneroClient, IMoneroAddress,
                MoneroChain>(
            addressRequired: true,
            clientRequired: true,
            childBulder: (wallet, account, client, address, onAccountChanged) =>
                _MoneroGenerateTxProofView(
                    account: account, client: client, txOutput: requestProof));
      },
    );
  }
}

class _MoneroGenerateTxProofView extends StatefulWidget {
  const _MoneroGenerateTxProofView(
      {required this.account, required this.client, required this.txOutput});
  final MoneroChain account;
  final MoneroClient client;
  final MoneroWalletTransactionProof? txOutput;

  @override
  State<_MoneroGenerateTxProofView> createState() =>
      _MoneroGenerateTxProofViewState();
}

class _MoneroGenerateTxProofViewState
    extends MoneroAccountState<_MoneroGenerateTxProofView> with ProgressMixin {
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<AppTextFieldState> txIdStateKey = GlobalKey();

  ReceiptAddress<MoneroAddress>? receiver;
  @override
  MoneroChain get account => widget.account;
  @override
  MoneroClient get client => widget.client;
  late IMoneroAddress selectedAccount = address;
  bool isOutputRequest = false;
  String? message;

  String txId = '';

  void onChangeTxId(String v) {
    txId = v;
  }

  String? validateTransactionIds(String? v) {
    final isValid = APPConst.hex32Bytes.hasMatch(v ?? '');
    if (!isValid) return "invalid_transaction_id".tr;
    return null;
  }

  void onChangeMessage(String? message) {
    this.message = message;
    updateState();
  }

  void onChangeAddress(IMoneroAddress? address) {
    if (address == null) return;
    selectedAccount = address;
    updateState();
  }

  String? proof;

  Future<void> generateProof() async {
    if (!formKey.ready()) return;
    progressKey.progressText("generating_proof_please_wait".tr);
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final result = await MethodUtils.call(() => wallet.wallet
        .nonEncryptedRequest(
            NoneEncryptedRequestMoneroGenerateTxProof(
                txId: txId,
                provider: client.service.provider,
                message: message,
                receiverAddress:
                    isOutputRequest ? widget.txOutput!.output.to : null,
                txKeys: isOutputRequest ? widget.txOutput!.txKeys : null),
            encryptedPart: selectedAccount.addrDetails.toCbor().encode()));
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    proof = result.result;
    progressKey.success();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    final request = widget.txOutput;
    if (request != null) {
      isOutputRequest = true;
      txId = request.txId;
      receiver = account.getReceiptAddress(request.output.address) ??
          ReceiptAddress<MoneroAddress>(
              view: request.output.to.address,
              networkAddress: request.output.to);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (context) {
        return CustomScrollView(slivers: [
          SliverConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            sliver: SliverToBoxAdapter(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageTitleSubtitle(
                        title: "transaction_proof".tr,
                        body: Text("monero_tx_proof_desc3".tr)),
                    APPAnimatedSwitcher(enable: proof == null, widgets: {
                      true: (context) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("transaction_id".tr,
                                  style: context.textTheme.titleMedium),
                              Text("payment_transaction_id".tr),
                              WidgetConstant.height8,
                              AppTextField(
                                  label: "transaction_id".tr,
                                  pasteIcon: true,
                                  validator: validateTransactionIds,
                                  readOnly: isOutputRequest,
                                  initialValue: txId,
                                  keyboardType: TextInputType.text,
                                  key: txIdStateKey,
                                  onChanged: onChangeTxId),
                              WidgetConstant.height20,
                              ConditionalWidget(
                                  enable: !isOutputRequest,
                                  onDeactive: (context) =>
                                      ReceiptAddressView(address: receiver!),
                                  onActive: (context) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("account".tr,
                                              style: context
                                                  .textTheme.titleMedium),
                                          Text("choose_account_received_payment"
                                              .tr),
                                          WidgetConstant.height8,
                                          ContainerWithBorder(
                                            onRemoveIcon: Icon(Icons.edit,
                                                color:
                                                    context.onPrimaryContainer),
                                            child: AddressDetailsView(
                                                address: selectedAccount,
                                                color:
                                                    context.onPrimaryContainer,
                                                key: ValueKey<IMoneroAddress?>(
                                                    selectedAccount)),
                                            onRemove: () {
                                              context
                                                  .selectOrSwitchAccount<
                                                          IMoneroAddress>(
                                                      account: account,
                                                      showMultiSig: true)
                                                  .then(onChangeAddress);
                                            },
                                          )
                                        ],
                                      )),
                              WidgetConstant.height20,
                              Text("message".tr,
                                  style: context.textTheme.titleMedium),
                              Text("monero_tx_proof_message_desc".tr),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                  onRemoveIcon: Icon(Icons.add_box,
                                      color: context.onPrimaryContainer),
                                  onRemove: () {
                                    context
                                        .openSliverBottomSheet<String>(
                                          "generate_transaction_proof".tr,
                                          child: StringWriterView(
                                            title: PageTitleSubtitle(
                                                title: "message".tr,
                                                body: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "monero_tx_proof_message_desc"
                                                            .tr),
                                                  ],
                                                )),
                                            buttonText: "setup_message".tr,
                                            label: "message".tr,
                                          ),
                                        )
                                        .then(onChangeMessage);
                                  },
                                  child: OneLineTextWidget(
                                    message ?? "tap_to_input_value".tr,
                                    style:
                                        context.onPrimaryTextTheme.bodyMedium,
                                    maxLine: 3,
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FixedElevatedButton(
                                      padding: WidgetConstant.paddingVertical40,
                                      onPressed: generateProof,
                                      child: Text("generate".tr)),
                                ],
                              )
                            ],
                          ),
                      false: (context) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConditionalWidget(
                                enable: !isOutputRequest,
                                onActive: (context) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("account".tr,
                                          style: context.textTheme.titleMedium),
                                      Text(
                                          "choose_account_received_payment".tr),
                                      WidgetConstant.height8,
                                      ContainerWithBorder(
                                        onRemoveIcon: Icon(Icons.edit,
                                            color: context.onPrimaryContainer),
                                        child: AddressDetailsView(
                                            address: selectedAccount,
                                            color: context.onPrimaryContainer,
                                            key: ValueKey<IMoneroAddress?>(
                                                selectedAccount)),
                                      ),
                                    ]),
                                onDeactive: (context) =>
                                    ReceiptAddressView(address: receiver!),
                              ),
                              WidgetConstant.height20,
                              Text("proof".tr,
                                  style: context.textTheme.titleMedium),
                              ContainerWithBorder(
                                child: CopyableTextWidget(
                                  text: proof!,
                                  color: context.colors.onPrimaryContainer,
                                  maxLines: 4,
                                ),
                              ),
                            ],
                          ),
                    }),
                  ],
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}
