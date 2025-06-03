import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/account/state.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/monero/monero.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class MoneroVerifyTxProofView extends StatelessWidget {
  const MoneroVerifyTxProofView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      title: "verify_transaction_proof".tr,
      accsess: WalletAccsessType.unlock,
      onAccsess: (credential, password, network) {
        return NetworkAccountControllerView<MoneroClient, IMoneroAddress,
                MoneroChain>(
            addressRequired: true,
            clientRequired: true,
            childBulder: (wallet, account, client, address, onAccountChanged) =>
                _MoneroVerifyTxProofView(account: account, client: client));
      },
    );
  }
}

class _MoneroVerifyTxProofView extends StatefulWidget {
  const _MoneroVerifyTxProofView({required this.account, required this.client});
  final MoneroChain account;
  final MoneroClient client;

  @override
  State<_MoneroVerifyTxProofView> createState() =>
      _MoneroVerifyTxProofViewState();
}

class _MoneroVerifyTxProofViewState
    extends MoneroAccountState<_MoneroVerifyTxProofView> with ProgressMixin {
  final GlobalKey<FormState> formKey = GlobalKey();
  @override
  MoneroChain get account => widget.account;
  @override
  MoneroClient get client => widget.client;
  ReceiptAddress<MoneroAddress>? selectedAccount;
  String? message;

  String txId = '';
  String signature = '';

  void onChangeTxId(String v) {
    txId = v;
  }

  void onChangeSignature(String v) {
    signature = v;
  }

  String? validateSignature(String? v) {
    final version =
        MethodUtils.nullOnException(() => MoneroTxVersion.fromBase58(v!));
    if (version == null) return "monero_proof_validator".tr;
    return null;
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

  void onChangeAddress(ReceiptAddress<MoneroAddress>? address) {
    if (address == null) return;
    selectedAccount = address;
    updateState();
  }

  IntegerBalance? proofBalace;

  Future<void> generateProof() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("generating_proof_please_wait".tr);
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final result = await MethodUtils.call(() => wallet.wallet
        .nonEncryptedRequest(NoneEncryptedRequestMoneroVerifyTxProof(
            txId: txId,
            provider: client.service.provider,
            message: message,
            address: selectedAccount!.networkAddress,
            signature: signature)));
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    if (result.result == null) {
      progressKey.errorText("verification_failed_no_amount_received".tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    proofBalace = IntegerBalance.token(result.result!, account.network.token);
    progressKey.success();
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
                        body: Text("monero_verify_proof_desc".tr)),
                    APPAnimatedSwitcher(enable: proofBalace == null, widgets: {
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
                                  initialValue: txId,
                                  keyboardType: TextInputType.text,
                                  onChanged: onChangeTxId),
                              WidgetConstant.height20,
                              Text("signature".tr,
                                  style: context.textTheme.titleMedium),
                              WidgetConstant.height8,
                              AppTextField(
                                label: "signature".tr,
                                pasteIcon: true,
                                validator: validateSignature,
                                initialValue: signature,
                                keyboardType: TextInputType.text,
                                onChanged: onChangeSignature,
                                minlines: 3,
                                maxLines: 5,
                              ),
                              WidgetConstant.height20,
                              FormField(validator: (value) {
                                if (selectedAccount == null) return "";
                                return null;
                              }, builder: (f) {
                                return ReceiptAddressView(
                                  address: selectedAccount,
                                  subtitle:
                                      "choose_account_received_payment".tr,
                                  validate: f.isValid,
                                  onTap: () {
                                    context
                                        .selectAccount<MoneroAddress>(
                                            account: account)
                                        .then((value) => onChangeAddress(
                                            value?.firstOrNull));
                                  },
                                );
                              }),
                              WidgetConstant.height20,
                              Text("message".tr,
                                  style: context.textTheme.titleMedium),
                              Text("message_of_the_proof".tr),
                              WidgetConstant.height8,
                              ContainerWithBorder(
                                  onRemoveIcon: Icon(Icons.add_box,
                                      color: context.onPrimaryContainer),
                                  onRemove: () {
                                    context
                                        .openSliverBottomSheet<String>(
                                          "verify_transaction_proof".tr,
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
                                      child: Text("verify".tr)),
                                ],
                              )
                            ],
                          ),
                      false: (context) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReceiptAddressView(
                                  address: selectedAccount,
                                  title: "account".tr,
                                  validate: selectedAccount != null),
                              WidgetConstant.height20,
                              Text("amount".tr,
                                  style: context.textTheme.titleMedium),
                              ContainerWithBorder(
                                child: CoinAndMarketPriceView(
                                  balance: proofBalace!,
                                  style: context.onPrimaryTextTheme.titleMedium,
                                  symbolColor: context.onPrimaryContainer,
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
