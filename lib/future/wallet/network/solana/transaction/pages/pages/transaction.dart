import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/solana/transaction/controller/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class SolanaTransactionFieldsView extends StatelessWidget {
  const SolanaTransactionFieldsView({super.key, this.field});
  final LiveTransactionForm<SolanaTransactionForm>? field;
  @override
  Widget build(BuildContext context) {
    final LiveTransactionForm<SolanaTransactionForm> validator =
        field ?? context.getArgruments();
    return NetworkAccountControllerView<SolanaClient, ISolanaAddress,
            SolanaChain>(
        addressRequired: true,
        clientRequired: true,
        childBulder: (wallet, account, client, address, onAccountChanged) {
          return StateBuilder<SolanaTransactionStateController>(
            repositoryId: StateConst.solana,
            controller: () => SolanaTransactionStateController(
                walletProvider: wallet,
                account: account,
                validator: validator,
                apiProvider: client),
            builder: (controller) {
              return PageProgress(
                initialStatus: StreamWidgetStatus.progress,
                initialWidget: ProgressWithTextView(
                    text: "retrieving_network_condition".tr),
                backToIdle: APPConst.oneSecoundDuration,
                key: controller.progressKey,
                child: (c) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ConstraintsBoxView(
                            padding: WidgetConstant.padding20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("account".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                  onRemoveIcon: Icon(Icons.edit,
                                      color: context.onPrimaryContainer),
                                  onRemove: controller.form.enableSwitchAccount
                                      ? () {
                                          context
                                              .selectOrSwitchAccount<
                                                      ISolanaAddress>(
                                                  account: controller.account,
                                                  showMultiSig: true)
                                              .then(onAccountChanged);
                                        }
                                      : null,
                                  child: AddressDetailsView(
                                      color: context.onPrimaryContainer,
                                      address: controller.address,
                                      key: ValueKey<ISolanaAddress?>(
                                          controller.address)),
                                ),
                                WidgetConstant.height20,
                                _SolanaTransactionFileds(
                                    validator: controller.validator,
                                    controller: controller),
                                AnimatedSize(
                                  duration: APPConst.animationDuraion,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      WidgetConstant.height20,
                                      Text("transaction_fee".tr,
                                          style: context.textTheme.titleMedium),
                                      WidgetConstant.height8,
                                      ContainerWithBorder(
                                          validateText: controller.feeError?.tr,
                                          validate: controller.hasFee &&
                                              controller.feeError == null,
                                          onRemove: () {},
                                          enableTap: false,
                                          onRemoveIcon: ButtonProgress(
                                            key: controller.feeProgressKey,
                                            initialStatus:
                                                StreamWidgetStatus.idle,
                                            child: (context) => Icon(
                                                Icons.circle,
                                                color:
                                                    context.colors.transparent),
                                          ),
                                          child: CoinAndMarketPriceView(
                                            balance: controller.fee,
                                            style: context
                                                .onPrimaryTextTheme.titleMedium,
                                            symbolColor:
                                                context.onPrimaryContainer,
                                          )),
                                    ],
                                  ),
                                ),
                                WidgetConstant.height20,
                                Text("setup_memo".tr,
                                    style: context.textTheme.titleMedium),
                                WidgetConstant.height8,
                                ContainerWithBorder(
                                    onRemoveIcon:
                                        AddOrEditIconWidget(controller.hasMemo),
                                    onRemove: () {
                                      controller.onTapMemo((s) async {
                                        final result = await context
                                            .openSliverBottomSheet<String>(
                                          "transaction_memo".tr,
                                          child: StringWriterView(
                                            defaultValue: s,
                                            maxLength: SolanaConst.memoLength,
                                            title: PageTitleSubtitle(
                                                title: "setup_memo".tr,
                                                body: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("empty_desc".tr),
                                                  ],
                                                )),
                                            buttonText: "setup_memo".tr,
                                            label: "memo".tr,
                                          ),
                                        );
                                        return result;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: controller.hasMemo
                                              ? Text(controller.memoStr ?? "",
                                                  style: context
                                                      .onPrimaryTextTheme
                                                      .bodyMedium)
                                              : Text("tap_to_add_memo".tr,
                                                  style: context
                                                      .onPrimaryTextTheme
                                                      .bodyMedium),
                                        ),
                                      ],
                                    )),
                                WidgetConstant.height20,
                                InsufficientBalanceErrorView(
                                    verticalMargin:
                                        WidgetConstant.paddingVertical10,
                                    balance: controller.remindAmount),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FixedElevatedButton(
                                      padding: WidgetConstant.paddingVertical40,
                                      onPressed: controller.transactionIsReady
                                          ? controller.sendTransaction
                                          : null,
                                      child: Text("send_transaction".tr),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        title: validator.validator.name.tr);
  }
}

class _SolanaTransactionFileds extends StatelessWidget {
  const _SolanaTransactionFileds(
      {required this.validator, required this.controller});
  final LiveTransactionForm<SolanaTransactionForm> validator;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    switch (validator.validator.mode) {
      case SolanaTransactionType.createAssociatedTokenAccount:
        final field = validator.value as SolanaCreateAssociatedTokenAccountForm;
        return _CreateAssociatedTokenAccountFields(
            field: field, controller: controller);
      case SolanaTransactionType.createAccount:
        final field = validator.value as SolanaCreateAccountForm;
        return _CreateAccountFields(field: field, controller: controller);
      case SolanaTransactionType.initializeMint:
        final field = validator.value as SolanaInitializeMintForm;
        return _InitializeMintFields(field: field, controller: controller);
      case SolanaTransactionType.mintTo:
        final field = validator.value as SolanaMintToForm;
        return _MintToFields(field: field, controller: controller);
      default:
        final field = validator.value as SolanaTransferForm;
        return _SolanaTransferFields(field: field, controller: controller);
    }
  }
}

class _SolanaTransferFields extends StatelessWidget {
  const _SolanaTransferFields({required this.field, required this.controller});
  final SolanaTransferForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.isTokenTransfer)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("token_transfer".tr, style: context.textTheme.titleMedium),
              WidgetConstant.height8,
              TokenDetailsView(
                  token: field.splToken!,
                  onSelectWidget: WidgetConstant.sizedBox),
              WidgetConstant.height20,
            ],
          ),
        Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
        Text("amount_for_each_output".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(field.destination.length, (index) {
            final destination = field.destination.value[index];
            return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              onRemoveWidget: IconButton(
                  onPressed: () {
                    field.removeReceiver(destination);
                  },
                  icon: Icon(Icons.remove_circle,
                      color: context.colors.onPrimaryContainer)),
              validate: destination.isReady,
              validateText: destination.hasAmount ? "invalid_address".tr : null,
              enableTap: false,
              onRemove: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: ReceiptAddressDetailsView(
                          address: destination.address,
                          color: context.primaryContainer)),
                  ContainerWithBorder(
                    onRemove: () {
                      final max =
                          field.max(destination) - controller.fee.balance;
                      context
                          .setupAmount(token: field.token, max: max)
                          .then((amount) {
                        field.setupAccountAmount(destination, amount);
                      });
                    },
                    validate: destination.hasAmount,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.primaryContainer),
                    backgroundColor: context.onPrimaryContainer,
                    child: CoinAndMarketPriceView(
                      balance: destination.balance,
                      style: context.primaryTextTheme.titleMedium,
                      symbolColor: context.primaryContainer,
                    ),
                  ),
                  if (!destination.isPubKey)
                    ErrorTextContainer(
                        error:
                            "solana_destination_address_invalid_public_key".tr,
                        showErrorIcon: false),
                ],
              ),
            );
          }),
        ),
        ContainerWithBorder(
            validate: field.destination.isNotEmpty,
            onRemove: () {
              context
                  .selectAccount<SolAddress>(
                      account: controller.account,
                      multipleSelect: true,
                      onFilterAccount: field.filterAddress)
                  .then(
                (value) {
                  field.onAddRecever(value, (s) {
                    context.showAlert(s);
                  });
                },
              );
            },
            onRemoveIcon: const Icon(Icons.add_box),
            child: Text("tap_to_add_new_receipment".tr)),
      ],
    );
  }
}

class _CreateAssociatedTokenAccountFields extends StatelessWidget {
  const _CreateAssociatedTokenAccountFields(
      {required this.field, required this.controller});
  final SolanaCreateAssociatedTokenAccountForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.ownerAddress.value,
          title: "owner_address".tr,
          subtitle: "owner_of_account".tr,
          onTap: () {
            context
                .selectAccount<SolAddress>(
                    account: controller.account, title: "owner".tr)
                .then(
              (value) {
                field.setValue(field.ownerAddress, value?.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mintAddress.value,
          title: "mint_address".tr,
          subtitle: "mint_address_desc".tr,
          onTap: () {
            context
                .selectAccount<SolAddress>(
                    account: controller.account, title: "mint_address".tr)
                .then(
              (value) {
                field.setValue(field.mintAddress, value?.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.tokenProgram.value,
          subtitle: "program_address_desc".tr,
          title: "program_address".tr,
          onTap: () {
            context
                .selectAccount<SolAddress>(
                    account: controller.account, title: "program_address".tr)
                .then(
              (value) {
                field.setValue(field.tokenProgram, value?.firstOrNull);
              },
            );
          },
        ),
        APPAnimatedSwitcher(
          enable: field.assosicatedAddress != null,
          widgets: {
            false: (context) => WidgetConstant.sizedBox,
            true: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("associated_token_address".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      child: CopyableTextWidget(
                        text: field.assosicatedAddress?.address ?? "",
                        color: context.onPrimaryContainer,
                      ),
                    )
                  ],
                )
          },
        )
      ],
    );
  }
}

class _CreateAccountFields extends StatelessWidget {
  const _CreateAccountFields({required this.field, required this.controller});
  final SolanaCreateAccountForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.newAccountAddress.value,
          title: "new_account_address".tr,
          subtitle: "solana_new_account_desc".tr,
          onTap: () {
            context
                .selectOrSwitchAccount<ISolanaAddress>(
                    account: controller.account, showMultiSig: true)
                .then(field.changeAssetOutputAddress);
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.ownerAddress.value,
          title: "owner".tr,
          subtitle: "owner_of_account".tr,
          onTap: () {
            context
                .selectAccount<SolAddress>(
                    account: controller.account, title: "owner".tr)
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.ownerAddress, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("account_size".tr, style: context.textTheme.titleMedium),
        Text("solana_account_size_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: field.space.hasValue,
          onRemoveIcon: AddOrEditIconWidget(field.space.hasValue),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
                  "account_size".tr,
                  child: NumberWriteView(
                    defaultValue: field.space.value,
                    allowDecimal: false,
                    max: SolanaConst.maximumAccountSizeBytes,
                    min: BigRational.zero,
                    allowSign: false,
                    title: PageTitleSubtitle(
                        title: "account_size".tr,
                        body: Text("solana_account_size_desc".tr)),
                    buttonText: "setup_account_size".tr,
                    label: "account_size".tr,
                  ),
                )
                .then(field.setSpace);
          },
          child: Text(
              field.space.value?.toString().to3Digits ??
                  "tap_to_input_value".tr,
              style: context.onPrimaryTextTheme.bodyMedium),
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: field.lamports.value,
          title: "lamports".tr,
          subtitle: "solana_create_account_lamports_desc".tr,
          validate: field.lamports.isCompleted,
          onRemoveIcon: ButtonProgress(
              key: field.rentProgress,
              child: (context) => field.lamports.hasValue
                  ? const Icon(Icons.edit)
                  : const Icon(Icons.add)),
          onTap: () {
            if (field.rentProgress.inProgress) return;
            context
                .setupAmount(
                    token: controller.network.coinParam.token,
                    max: controller.address.address.currencyBalance -
                        controller.fee.balance)
                .then(field.setLamports);
          },
          token: controller.network.coinParam.token,
        ),
      ],
    );
  }
}

class _InitializeMintFields extends StatelessWidget {
  const _InitializeMintFields({required this.field, required this.controller});
  final SolanaInitializeMintForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.programId.value,
          title: "program_id".tr,
          subtitle: "solana_program_id_desc".tr,
          onTap: () {
            context.selectAccount<SolAddress>(account: controller.account).then(
              (value) {
                if (value == null) return;
                field.setValue(field.programId, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mint.value,
          title: "mint".tr,
          subtitle: "mint_address_to_initialize".tr,
          onTap: () {
            context.selectAccount<SolAddress>(account: controller.account).then(
              (value) {
                if (value == null) return;
                field.setValue(field.mint, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mintAuthority.value,
          title: "mint_authority".tr,
          subtitle: "mint_authority_desc".tr,
          onTap: () {
            context.selectAccount<SolAddress>(account: controller.account).then(
              (value) {
                if (value == null) return;
                field.setValue(field.mintAuthority, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.freezAuthority.value,
          validate: true,
          title: "freeze_authority".tr,
          subtitle: "freeze_authority_desc".tr,
          onTap: () {
            context.selectAccount<SolAddress>(account: controller.account).then(
              (value) {
                if (value == null) return;
                field.setValue(field.freezAuthority, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("decimals".tr, style: context.textTheme.titleMedium),
        Text("solana_mint_decimal_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: field.decimals.hasValue,
          onRemoveIcon: AddOrEditIconWidget(field.decimals.hasValue),
          onRemove: () {
            context
                .openSliverBottomSheet<BigRational>(
              "decimals".tr,
              child: NumberWriteView(
                defaultValue: field.decimals.value,
                allowDecimal: false,
                max: SolanaConst.maxSPLTokenDecimalPlaces,
                min: BigRational.zero,
                allowSign: false,
                title: PageTitleSubtitle(
                    title: "decimals".tr,
                    body: Text("solana_mint_decimal_desc".tr)),
                buttonText: "setup_token_decimal".tr,
                label: "decimals".tr,
              ),
            )
                .then(
              (value) {
                field.setValue(field.decimals, value);
              },
            );
          },
          child: Text(
            field.decimals.value?.toString().to3Digits ??
                "tap_to_input_value".tr,
            style: context.onPrimaryTextTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _MintToFields extends StatelessWidget {
  const _MintToFields({required this.field, required this.controller});
  final SolanaMintToForm field;
  final SolanaTransactionStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          address: field.programId.value,
          title: "program_id".tr,
          subtitle: "solana_program_id_desc".tr,
          onTap: () {
            context.selectAccount<SolAddress>(account: controller.account).then(
              (value) {
                if (value == null) return;
                field.setValue(field.programId, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.mint.value,
          title: "mint".tr,
          subtitle: "mint_address_mint_desc".tr,
          onTap: () {
            context
                .selectAccount<SolAddress>(
                    account: controller.account, title: "mint".tr)
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.mint, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.authority.value,
          title: "authority".tr,
          subtitle: "mint_to_authority_desc".tr,
          onTap: () {
            context
                .selectAccount<SolAddress>(
                    account: controller.account, title: "authority".tr)
                .then(
              (value) {
                if (value == null) return;
                field.setValue(field.authority, value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          address: field.destination.value,
          validate: field.destination.hasValue,
          title: "destination".tr,
          subtitle: "use_owner_account_instead_pda_desc".tr,
          onTap: () {
            context
                .selectAccount<SolAddress>(
                    account: controller.account, title: "destination".tr)
                .then(
              (value) {
                if (value == null) return;
                field.setDestination(value.firstOrNull);
              },
            );
          },
        ),
        WidgetConstant.height20,
        Text("destination_info".tr, style: context.textTheme.titleMedium),
        Text("destination_info_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemoveIcon: ButtonProgress(
                child: (context) =>
                    Icon(Icons.circle, color: context.colors.transparent),
                key: field.accountProgressKey),
            onRemove: () {
              if (!field.hasFetchingAccountError) return;
              field.getDestinationAccountInfo();
            },
            child: !field.destination.hasValue
                ? Text("no_account_chosen".tr)
                : field.hasFetchingAccountError
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetConstant.errorIcon,
                          WidgetConstant.width8,
                          Expanded(
                            child: Text(
                              "request_error".tr,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : _DestinationAccountInfoView(
                        accountInfo: field.destinationAccount)),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: field.amount.value,
          title: "amount".tr,
          subtitle: "mint_to_amount_desc".tr,
          validate: field.amount.isCompleted,
          onTap: () {
            context.setupAmount(token: field.token, max: maxU64).then((value) {
              if (value == null) {
                field.setValue(field.amount, null);
              } else {
                field.setValue(
                    field.amount, IntegerBalance.token(value, field.token));
              }
            });
          },
          token: field.token,
        ),
      ],
    );
  }
}

class _DestinationAccountInfoView extends StatelessWidget {
  const _DestinationAccountInfoView({this.accountInfo});
  final SolanaTransferDestinationInfo? accountInfo;
  @override
  Widget build(BuildContext context) {
    if (accountInfo == null) {
      return Text("account_not_found".tr,
          style: context.onPrimaryTextTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("owner".tr, style: context.onPrimaryTextTheme.labelLarge),
        OneLineTextWidget(accountInfo!.ownerTag.tr,
            style: context.onPrimaryTextTheme.bodyMedium),
        Divider(color: context.colors.onPrimaryContainer),
        Text("executable".tr, style: context.onPrimaryTextTheme.labelLarge),
        Text(accountInfo!.executable.tr,
            style: context.onPrimaryTextTheme.bodyMedium),
        if (!accountInfo!.isOnCurve)
          ErrorTextContainer(
              error: "solana_destination_address_invalid_public_key".tr,
              showErrorIcon: false),
      ],
    );
  }
}
