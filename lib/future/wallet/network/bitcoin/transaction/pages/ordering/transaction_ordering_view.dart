import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/network/bch/token/pages/cash_token_info.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/utils/bitcoin/bitcoin.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TransactionOrderingView extends StatefulWidget {
  const TransactionOrderingView(
      {super.key,
      required this.inputs,
      required this.outputs,
      required this.network,
      required this.controller});
  final List<UtxoWithAddress> inputs;
  final List<BitcoinBaseOutput> outputs;
  final WalletBitcoinNetwork network;
  final ScrollController controller;

  @override
  State<TransactionOrderingView> createState() =>
      _TransactionOrderingViewState();
}

class _TransactionOrderingViewState extends State<TransactionOrderingView> {
  late final List<_OutputWithKey> outputs = widget.outputs
      .where((element) => element is! BitcoinBurnableOutput)
      .map((e) => _OutputWithKey._(e, widget.network))
      .toList();
  late final List<_InputsWithKey> inputs = widget.inputs
      .map((e) => _InputsWithKey(item: e, network: widget.network))
      .toList();

  void ordering() {
    final orderedInputs = inputs.map((e) => e.item).toList();
    final List<BitcoinBaseOutput> orderedOutputs = [
      ...outputs.map((e) => e.output),
      ...widget.outputs.whereType<BitcoinBurnableOutput>()
    ];
    context.pop((orderedInputs, orderedOutputs));
  }

  void onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: ordering,
          child: Icon(Icons.save),
        ),
        appBar: AppBar(
          title: Text("transaction_ordering".tr),
          bottom: TabBar(tabs: [
            Tab(text: "inputs".tr),
            Tab(text: "outputs".tr),
          ]),
        ),
        body: NestedScrollView(
            controller: widget.controller,
            headerSliverBuilder: (c, e) => [],
            body: TabBarView(children: [
              _InputOrdering(
                inputs: inputs,
                network: widget.network,
                onUpdate: onUpdate,
                controller: widget.controller,
              ),
              _OutputOrdering(
                outputs: outputs,
                network: widget.network,
                onUpdate: onUpdate,
                controller: widget.controller,
              )
            ])),
      ),
    );
  }
}

class _InputOrdering extends StatelessWidget {
  const _InputOrdering(
      {required this.inputs,
      required this.network,
      required this.onUpdate,
      required this.controller});
  final List<_InputsWithKey> inputs;
  final WalletBitcoinNetwork network;
  final DynamicVoid onUpdate;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      scrollController: controller,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final item = inputs.removeAt(oldIndex);
        inputs.insert(newIndex, item);
        onUpdate();
      },
      children: List.generate(inputs.length, (index) {
        final input = inputs[index];
        return Padding(
          padding: WidgetConstant.paddingHorizontal20,
          key: input.key,
          child: ConstraintsBoxView(
            child: ContainerWithBorder(
              onRemove: () {},
              enableTap: false,
              onRemoveIcon: ReorderableDragStartListener(
                  index: index,
                  child:
                      Icon(Icons.touch_app, color: context.onPrimaryContainer)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(input.item.ownerDetails.address.type.value.tr,
                      style: context.onPrimaryTextTheme.labelLarge),
                  OneLineTextWidget(
                      input.item.ownerDetails.address
                          .toAddress(network.coinParam.transacationNetwork),
                      style: context.onPrimaryTextTheme.bodyMedium),
                  Divider(color: context.onPrimaryContainer),
                  OneLineTextWidget(input.item.utxo.txHash,
                      style: context.onPrimaryTextTheme.bodyMedium),
                  CoinAndMarketPriceView(
                      balance: input.inputValue,
                      style: context.onPrimaryTextTheme.titleMedium,
                      symbolColor: context.onPrimaryContainer)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OutputOrdering extends StatelessWidget {
  const _OutputOrdering(
      {required this.outputs,
      required this.network,
      required this.onUpdate,
      required this.controller});
  final List<_OutputWithKey> outputs;
  final WalletBitcoinNetwork network;
  final DynamicVoid onUpdate;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      scrollController: controller,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final item = outputs.removeAt(oldIndex);
        outputs.insert(newIndex, item);
        onUpdate();
      },
      buildDefaultDragHandles: false,
      children: List.generate(outputs.length, (index) {
        final output = outputs[index];
        return Padding(
          padding: WidgetConstant.paddingHorizontal20,
          key: output.key,
          child: ContainerWithBorder(
            onRemove: () {},
            enableTap: false,
            onRemoveIcon: ReorderableDragStartListener(
                index: index,
                child:
                    Icon(Icons.touch_app, color: context.onPrimaryContainer)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: output.output is BitcoinSpendableBaseOutput
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OneLineTextWidget(output.addressView!,
                                      style: context
                                          .onPrimaryTextTheme.bodyMedium),
                                  CoinAndMarketPriceView(
                                      balance: output.value,
                                      style: context
                                          .onPrimaryTextTheme.titleMedium,
                                      symbolColor: context.onPrimaryContainer),
                                ],
                              )
                            : Text(
                                output.script ?? "",
                                style: context.onPrimaryTextTheme.bodyMedium,
                              )),
                  ],
                ),
                if (output.token != null) ...[
                  Divider(color: context.colors.onPrimaryContainer),
                  BCHCashTokenDetailsView(
                      token: output.token!,
                      color: context.colors.onPrimaryContainer),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _OutputWithKey<T> {
  _OutputWithKey(
      {this.addressView,
      required this.output,
      required this.value,
      this.script,
      this.token})
      : key = GlobalKey();
  factory _OutputWithKey._(
      BitcoinBaseOutput output, WalletBitcoinNetwork network) {
    if (output is BitcoinScriptOutput) {
      return _OutputWithKey(
          output: output,
          value: IntegerBalance.zero(network.token),
          addressView: null,
          script: BTCUtils.opReturnToView(output.script));
    }
    if (output is BitcoinTokenOutput) {
      return _OutputWithKey(
          output: output,
          addressView:
              output.address.toAddress(network.coinParam.transacationNetwork),
          token: BCHCashToken(cashToken: output.token),
          value: IntegerBalance.token(output.value, network.token));
    }
    output as BitcoinOutput;
    return _OutputWithKey(
        output: output,
        addressView:
            output.address.toAddress(network.coinParam.transacationNetwork),
        value: IntegerBalance.token(output.value, network.token));
  }
  final GlobalKey key;
  final String? addressView;
  final BitcoinBaseOutput output;
  final IntegerBalance value;
  final String? script;
  final BCHCashToken? token;
}

class _InputsWithKey {
  _InputsWithKey({required this.item, required WalletBitcoinNetwork network})
      : key = GlobalKey(),
        inputValue = IntegerBalance.token(item.utxo.value, network.token);
  final GlobalKey key;
  final UtxoWithAddress item;
  final IntegerBalance inputValue;
}
