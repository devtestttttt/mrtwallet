import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/global/global.dart';
import 'package:on_chain_wallet/future/wallet/network/bch/token/pages/cash_token_info.dart';
import 'package:on_chain_wallet/future/wallet/network/bch/transaction/cotnroller/bitcoin_operation.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/utils/bitcoin_cash/bitcoin_cash_utils.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class TokenCashOperationView extends StatefulWidget {
  const TokenCashOperationView(
      {super.key,
      required this.token,
      required this.account,
      required this.network,
      required this.remindAmount});
  final BitcoinCashTransactionTokenOperation token;
  final BitcoinChain account;
  final WalletBitcoinCashNetwork network;
  final BigInt remindAmount;

  @override
  State<TokenCashOperationView> createState() => _TokenCashOperationViewState();
}

class _TokenCashOperationViewState extends State<TokenCashOperationView>
    with SafeState {
  final Map<String, BitcoinCashTokenOperation> _receivers = {};
  late final IntegerBalance remindAmount;
  late final IntegerBalance remindTokenAmount;
  late final BCHCashToken token = widget.token.cashToken;
  bool get haveBurnaleOutput =>
      _receivers.containsKey(token.cashToken.category);
  bool get haveAnyOutput =>
      _receivers.values.where((element) => !element.isBurnable).isNotEmpty;
  late final bool isImMutable = token.cashToken.hasNFT &&
      token.cashToken.capability == CashTokenCapability.noCapability;
  late final bool isMutable = token.cashToken.hasNFT &&
      token.cashToken.capability == CashTokenCapability.mutable;

  @override
  void initState() {
    remindAmount =
        IntegerBalance.token(widget.remindAmount, widget.network.token);
    remindTokenAmount =
        IntegerBalance.token(token.cashToken.amount, widget.token.token);
    for (final i in widget.token.operation) {
      if (i.isBurnable) {
        i as BurnableBitcoinCashTokenOperation;
        _receivers.addAll({
          token.cashToken.category:
              BurnableBitcoinCashTokenOperation(receiver: i.receiver.copyWith())
        });
      } else {
        _receivers.addAll({
          i.receiver.viewAddress:
              SpendBitcoinCashTokenOperation(receiver: i.receiver.copyWith())
        });
      }
    }

    calculateRemindAmounts();
    super.initState();
  }

  List<BitcoinCashTokenOperation> get receivers => _receivers.values.toList();
  bool isReady = false;

  void onAddRecever_(ReceiptAddress<BitcoinBaseAddress>? addr) {
    if (addr == null) return;
    final toAddr = addr.networkAddress
        .toAddress(widget.network.coinParam.transacationNetwork);
    if (_receivers.containsKey(toAddr) && !token.cashToken.hasNFT) {
      return;
    } else {
      final SpendBitcoinCashTokenOperation operation =
          SpendBitcoinCashTokenOperation(
              receiver: BitcoinOutputWithBalance(
                  address: addr,
                  network: widget.network,
                  token: token.cashToken));
      _receivers[toAddr] = operation;
      if (isImMutable) {
        operation.receiver.tokenBalance?.updateBalance(token.cashToken.amount);
      }
    }
  }

  void onAddRecever(List<ReceiptAddress<BitcoinBaseAddress>>? addr) {
    if (addr == null) return;
    for (final i in addr) {
      onAddRecever_(i);
    }
    calculateRemindAmounts();
    updateState();
  }

  void onRemoveReceiver(String address) {
    _receivers.remove(address);
    calculateRemindAmounts();
  }

  void calculateRemindAmounts() {
    final spendAmount = _receivers.values.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.networkAmount);
    remindAmount.updateBalance(widget.remindAmount - spendAmount);
    if (token.cashToken.hasAmount) {
      final spendToken = _receivers.values.fold(BigInt.zero,
          (previousValue, element) => previousValue + element.tokenAmount);
      remindTokenAmount.updateBalance(token.cashToken.amount - spendToken);
    }
    final bool receiversIsReady = receivers.isEmpty ||
        _receivers.values.any((element) => !element.isReady);
    isReady = (!remindAmount.isNegative && remindTokenAmount.isZero) &&
        !receiversIsReady;
    updateState(() {});
  }

  void setupAccountAmount(String address, BigInt? amount) {
    if (amount == null) return;
    final BitcoinCashTokenOperation operation = _receivers[address]!;
    operation as SpendBitcoinCashTokenOperation;
    operation.receiver.balance.updateBalance(amount);
    calculateRemindAmounts();
  }

  void setupTokenAmount(String address, BigInt? amount) {
    if (amount == null || isImMutable) return;
    _receivers[address]!.receiver.tokenBalance?.updateBalance(amount);
    calculateRemindAmounts();
  }

  void onSetupOperation() {
    if (!isReady) return;
    final transactionOperation = widget.token.copyWith(
        operation: _receivers.values.map((e) => e.copyWith()).toList());
    context.pop(transactionOperation);
  }

  void onChangeCapability(String? addres, CashTokenCapability? capability) {
    if (capability == null || !_receivers.containsKey(addres) || isImMutable) {
      return;
    }
    if (isMutable && capability == CashTokenCapability.minting) {
      context.showAlert("bch_nft_wrong_capability".tr);
      updateState(() {});
      return;
    }
    final BitcoinCashTokenOperation operation = _receivers[addres]!;
    operation as SpendBitcoinCashTokenOperation;
    BitcoinOutputWithBalance receiver = operation.receiver;
    receiver = receiver.copyWith(
        token: receiver.token?.copyWith(
            bitfield: CashTokenUtils.buildBitfield(
                hasAmount: token.cashToken.hasAmount,
                capability: capability,
                hasNFT: true,
                hasCommitmentLength: receiver.token!.hasCommitment)));
    _receivers[addres!] = SpendBitcoinCashTokenOperation(receiver: receiver);
    calculateRemindAmounts();
  }

  String? commitmentValidate(String? v) {
    if (BCHUtils.commitmentValidate(v)) {
      return null;
    }
    return "commitment_validate_desc".tr;
  }

  void onUpdateCommitment(String? address, String? commitment) {
    if (address == null || !_receivers.containsKey(address) || isImMutable) {
      return;
    }
    final String? correctCommitment =
        (commitment?.isEmpty ?? true) ? null : commitment;
    final BitcoinCashTokenOperation operation = _receivers[address]!;
    operation as SpendBitcoinCashTokenOperation;
    final receiver = operation.receiver.copyWith(
        token: operation.receiver.token?.copyWith(
            commitment: correctCommitment == null
                ? null
                : StringUtils.toBytes(correctCommitment),
            bitfield: CashTokenUtils.buildBitfield(
                hasAmount: token.cashToken.hasAmount,
                capability: token.cashToken.capability,
                hasNFT: true,
                hasCommitmentLength: correctCommitment != null)));
    _receivers[address] = SpendBitcoinCashTokenOperation(receiver: receiver);
    calculateRemindAmounts();
  }

  void onAddBurnOperantion() {
    final BurnableBitcoinCashTokenOperation operation =
        BurnableBitcoinCashTokenOperation(
            receiver: BitcoinBurnableUtxoWithBalance(
                token: token.cashToken, categoryId: token.cashToken.category));
    _receivers[token.cashToken.category] = operation;
    if (isImMutable) {
      operation.receiver.tokenBalance?.updateBalance(token.cashToken.amount);
    }
    calculateRemindAmounts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "token_operation".tr,
            body: Column(
              children: [
                ContainerWithBorder(
                    child: BCHCashTokenDetailsView(
                        token: token, color: context.onPrimaryContainer)),
                ErrorTextContainer(
                    error: "assets_balance_not_supported_desc".tr,
                    enableTap: false),
              ],
            )),
        Text("list_of_operations".tr, style: context.textTheme.titleMedium),
        Text("initiate_operations".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(receivers.length, (index) {
            final address = _receivers.keys.toList()[index];
            final receiver = receivers[index].receiver;
            final operation = receivers[index];
            return ContainerWithBorder(
              validate: receivers[index].isReady,
              iconAlginment: CrossAxisAlignment.start,
              child: APPExpansionListTile(
                tilePadding: EdgeInsets.zero,

                title: Text(operation.isBurnable ? "burn".tr : "recipient".tr,
                    style: context.onPrimaryTextTheme.bodyMedium),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!operation.isBurnable) ...[
                        ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          onRemoveIcon: Icon(Icons.remove_circle,
                              color: context.primaryContainer),
                          onRemove: () {
                            onRemoveReceiver(address);
                          },
                          child: ReceiptAddressDetailsView(
                              address: receiver.address,
                              color: context.primaryContainer),
                        ),
                        ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          onRemoveIcon: AddOrEditIconWidget(receiver.hasAmount,
                              color: context.primaryContainer),
                          validate: receiver.hasAmount,
                          onRemove: () {
                            context
                                .setupAmount(
                                    token: widget.network.coinParam.token,
                                    max: remindAmount.balance +
                                        receiver.balance.balance,
                                    min: BCHUtils.minimumSatoshiTokenOutput)
                                .then((amount) {
                              if (context.mounted) {
                                setupAccountAmount(
                                    receiver.viewAddress, amount);
                              }
                            });
                          },
                          child: CoinAndMarketPriceView(
                            balance: receiver.balance,
                            style: context.primaryTextTheme.titleMedium,
                            symbolColor: context.primaryContainer,
                            showTokenImage: true,
                          ),
                        ),
                      ] else
                        ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            onRemoveIcon: Icon(Icons.remove_circle,
                                color: context.primaryContainer),
                            onRemove: () {
                              onRemoveReceiver(address);
                            },
                            enableTap: false,
                            child: OneLineTextWidget(
                              token.cashToken.category,
                              style: context.primaryTextTheme.bodyMedium,
                            )),
                      if (token.cashToken.hasAmount) ...[
                        ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          onRemoveIcon: AddOrEditIconWidget(
                            receiver.hasTokenAmount,
                            color: context.primaryContainer,
                          ),
                          validate: receiver.hasTokenAmount,
                          onRemove: isImMutable
                              ? null
                              : () {
                                  context
                                      .setupAmount(
                                          token: widget.token.token,
                                          max: remindTokenAmount.balance +
                                              receiver.tokenBalance!.balance,
                                          title: operation.isBurnable
                                              ? "burn_amount".tr
                                              : null)
                                      .then((amount) {
                                    if (context.mounted) {
                                      if (operation.isBurnable) {
                                        setupTokenAmount(
                                            token.cashToken.category, amount);
                                      } else {
                                        setupTokenAmount(
                                            receiver.viewAddress, amount);
                                      }
                                    }
                                  });
                                },
                          child: CoinAndMarketPriceView(
                            balance: receiver.tokenBalance!,
                            style: context.primaryTextTheme.titleMedium,
                            symbolColor: context.primaryContainer,
                            showTokenImage: true,
                          ),
                        ),
                      ],
                      if (token.cashToken.hasNFT) ...[
                        ContainerWithBorder(
                            backgroundColor: context.colors.secondary,
                            child: AppDropDownBottom(
                              border: InputBorder.none,
                              iconEnabledColor: context.colors.onSecondary,
                              items: {
                                for (final i in CashTokenCapability.values)
                                  i: Text(i.name.tr,
                                      style: context.colors.onSecondary
                                          .bodyMedium(context))
                              },
                              selectedItemBuilder: {
                                for (final i in CashTokenCapability.values)
                                  i: Text(i.name.tr)
                              },
                              value: receiver.token!.capability,
                              fillColor: context.colors.transparent,
                              key: UniqueKey(),
                              onChanged: isImMutable || operation.isBurnable
                                  ? null
                                  : (p0) {
                                      onChangeCapability(
                                          address, p0 as CashTokenCapability?);
                                    },
                            )),
                        WidgetConstant.height20,
                        Text("commitment".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                          onRemoveIcon: Icon(Icons.edit,
                              color: context.colors.onSecondary),
                          onRemove: isImMutable || operation.isBurnable
                              ? null
                              : () {
                                  context
                                      .openSliverBottomSheet<String>(
                                    "update_commitment".tr,
                                    child: StringWriterView(
                                      defaultValue:
                                          receiver.token?.commitmentInHex,
                                      maxLength: RippleConst.maxDomainLength,
                                      customForm: commitmentValidate,
                                      title: PageTitleSubtitle(
                                          title: "commitment".tr,
                                          body: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("commitment_desc".tr),
                                              WidgetConstant.height8,
                                              Text("empty_desc".tr)
                                            ],
                                          )),
                                      buttonText: "setup_input".tr,
                                      label: "commitment".tr,
                                    ),
                                  )
                                      .then(
                                    (value) {
                                      onUpdateCommitment(address, value);
                                    },
                                  );
                                },
                          backgroundColor: context.colors.secondary,
                          child: Text(
                              receiver.token!.commitmentInHex ??
                                  (!isImMutable
                                      ? "tap_to_add_commitment".tr
                                      : "without_commitment".tr),
                              style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSecondary)),
                        )
                      ],
                    ],
                  ),
                ],

                // duration: APPConst.animationDuraion,
                // alignment: Alignment.topCenter,
                // children: Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [],
                // ),
              ),
            );
          }),
        ),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: isImMutable && _receivers.isNotEmpty
              ? WidgetConstant.sizedBox
              : Column(
                  children: [
                    if (isMutable && haveAnyOutput)
                      WidgetConstant.sizedBox
                    else
                      ContainerWithBorder(
                        onRemove: () {
                          context
                              .selectAccount<BitcoinBaseAddress>(
                                  account: widget.account, multipleSelect: true)
                              .then(onAddRecever);
                        },
                        onRemoveIcon: Icon(Icons.add_box,
                            color: context.onPrimaryContainer),
                        child: Text("tap_to_add_operation".tr,
                            style: context.onPrimaryTextTheme.bodyMedium),
                      ),
                    if (!haveBurnaleOutput)
                      ContainerWithBorder(
                        onRemove: () {
                          onAddBurnOperantion();
                        },
                        onRemoveIcon: Icon(Icons.add_box,
                            color: context.onPrimaryContainer),
                        child: Text("tap_to_add_burn_operation".tr,
                            style: context.onPrimaryTextTheme.bodyMedium),
                      ),
                  ],
                ),
        ),
        APPAnimatedSize(
            isActive: remindTokenAmount.isZero,
            onActive: (context) => WidgetConstant.sizedBox,
            onDeactive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("remaining_amount".tr,
                        style: context.textTheme.titleMedium),
                    Text("remaining_token_amount_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      child: CoinAndMarketPriceView(
                          balance: remindTokenAmount,
                          style: context.onPrimaryTextTheme.titleMedium,
                          symbolColor: context.onPrimaryContainer),
                    ),
                  ],
                )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical40,
              onPressed: isReady ? onSetupOperation : null,
              child: Text("setup_operation".tr),
            )
          ],
        )
      ],
    );
  }
}
