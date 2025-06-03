import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/wallet/constant/networks/substrate.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

import 'metadata_fields.dart';

class SubstrateOutputWithBalance {
  SubstrateOutputWithBalance(
      {required this.address, required WalletSubstrateNetwork network})
      : balance = IntegerBalance.zero(network.token);

  final IntegerBalance balance;
  final ReceiptAddress<BaseSubstrateAddress> address;

  bool get hasAmount => !balance.isZero;

  void updateBalance(BigInt val) {
    balance.updateBalance(val);
  }

  SubstrateDefaultTransfer toMessage() {
    assert(!balance.balance.isNegative, "Invalid transfer amount.");
    return SubstrateDefaultTransfer(
        address: address.networkAddress, value: balance.balance);
  }

  SubstrateWalletTransactionTransferOutput toWalletTransactionOutput(
      WalletSubstrateNetwork network) {
    return SubstrateWalletTransactionTransferOutput(
        to: address.networkAddress,
        amount: WalletTransactionIntegerAmount(
            amount: balance.balance, network: network));
  }
}

enum SubstrateKnownCallMethodsType {
  transfer,
  remark,
  unknown;
}

abstract class SubstrateKnownCallMethods {
  final SubstrateKnownCallMethodsType type;
  const SubstrateKnownCallMethods(this.type);
  BigInt get value => BigInt.zero;
  String get name => type.name;
  static SubstrateKnownCallMethods _parseRemark(Map<String, dynamic> data) {
    try {
      return SubstrateRemarkMethod.fromJson(data);
    } catch (e) {
      final Map<String, dynamic>? methodData =
          StringUtils.tryToJson(data[APPSubstrateConst.systemPalletName]);
      return SubstrateUnknownMethod(
          methodName: methodData?.keys.firstOrNull,
          content:
              StringUtils.fromJson(data, indent: '', toStringEncodable: true));
    }
  }

  static SubstrateKnownCallMethods _parseTransafer(
      {required Map<String, dynamic> data,
      required WalletSubstrateNetwork network}) {
    try {
      return SubstrateTransferMethod.fromJson(data, network);
    } catch (e) {
      final Map<String, dynamic>? methodData =
          StringUtils.tryToJson(data[APPSubstrateConst.balancePalletName]);
      return SubstrateUnknownMethod(
          methodName: methodData?.keys.firstOrNull,
          content:
              StringUtils.fromJson(data, indent: '', toStringEncodable: true));
    }
  }

  static List<SubstrateKnownCallMethods> _parseUtility(
      {required Map<String, dynamic> data,
      required WalletSubstrateNetwork network}) {
    try {
      if (data.containsKey(APPSubstrateConst.utilityPalletName)) {
        final List<Map<String, dynamic>>? r = StringUtils.tryToJson(
            MethodUtils.nullOnException(() =>
                data[APPSubstrateConst.utilityPalletName]
                    ?[APPSubstrateConst.utilityBatchVariantName]));
        if (r != null) {
          return r
              .map((e) => parseTxMethod(data: e, network: network))
              .expand((e) => e)
              .toList();
        }
      }
    } catch (_) {}
    final Map<String, dynamic>? methodData =
        StringUtils.tryToJson(data[APPSubstrateConst.utilityPalletName]);
    return [
      SubstrateUnknownMethod(
          methodName: methodData?.keys.firstOrNull,
          content:
              StringUtils.fromJson(data, indent: '', toStringEncodable: true))
    ];
  }

  static List<SubstrateKnownCallMethods> parseTxMethod(
      {required Map<String, dynamic> data,
      required WalletSubstrateNetwork network}) {
    List<SubstrateKnownCallMethods> knownMethods = [];
    if (data.containsKey(APPSubstrateConst.utilityPalletName)) {
      final method = _parseUtility(data: data, network: network);
      knownMethods.addAll(method);
    } else if (data.containsKey(APPSubstrateConst.systemPalletName)) {
      final method = _parseRemark(data);
      knownMethods.add(method);
    } else if (data.containsKey(APPSubstrateConst.balancePalletName)) {
      final method = _parseTransafer(data: data, network: network);
      knownMethods.add(method);
    } else {
      final Map<String, dynamic>? methodData =
          StringUtils.tryToJson(data.values.first);
      final method = SubstrateUnknownMethod(
          methodName: methodData?.keys.firstOrNull,
          content: StringUtils.fromJson(methodData ?? data,
              indent: '', toStringEncodable: true));
      knownMethods.add(method);
    }
    return knownMethods;
  }
}

class SubstrateRemarkMethod extends SubstrateKnownCallMethods {
  final String? content;
  final String data;
  const SubstrateRemarkMethod({required this.data, required this.content})
      : super(SubstrateKnownCallMethodsType.remark);
  factory SubstrateRemarkMethod.fromJson(Map<String, dynamic> json) {
    if (json.containsKey(APPSubstrateConst.systemPalletName)) {
      json = json[APPSubstrateConst.systemPalletName];
    }
    final String data = json[APPSubstrateConst.systemRemarkVariantName];
    return SubstrateRemarkMethod(
        data: data,
        content: StringUtils.tryDecode(BytesUtils.fromHexString(data)));
  }
}

class SubstrateTransferMethod extends SubstrateKnownCallMethods {
  final ReceiptAddress<BaseSubstrateAddress> receiver;
  final IntegerBalance amount;
  final SubstrateTransferType transferType;
  SubstrateTransferMethod copyWith({
    ReceiptAddress<BaseSubstrateAddress>? receiver,
    IntegerBalance? amount,
    SubstrateTransferType? transferType,
  }) {
    return SubstrateTransferMethod(
        receiver: receiver ?? this.receiver,
        amount: amount ?? this.amount,
        transferType: transferType ?? this.transferType);
  }

  @override
  BigInt get value => amount.balance;
  const SubstrateTransferMethod(
      {required this.receiver,
      required this.amount,
      required this.transferType})
      : super(SubstrateKnownCallMethodsType.transfer);
  factory SubstrateTransferMethod.fromJson(
      Map<String, dynamic> json, WalletSubstrateNetwork network) {
    Map<String, dynamic> data = json;
    if (data.containsKey(APPSubstrateConst.balancePalletName)) {
      data = json[APPSubstrateConst.balancePalletName];
    }
    BaseSubstrateAddress receiver;
    SubstrateTransferType type = SubstrateTransferType.transferAllowDeath;
    if (data.containsKey(SubstrateTransferType.transferAllowDeath.methodName)) {
      data = data[SubstrateTransferType.transferAllowDeath.methodName];
    } else {
      data = data[SubstrateTransferType.transferKeepAlive.methodName];
      type = SubstrateTransferType.transferKeepAlive;
    }
    if (network.coinParam.substrateChainType.isEthereum) {
      receiver = SubstrateEthereumAddress.fromBytes(
          BytesUtils.fromHexString(data["dest"]));
    } else {
      receiver = SubstrateAddress.fromBytes(
          BytesUtils.fromHexString(data["dest"]!["Id"]));
    }
    return SubstrateTransferMethod(
        receiver:
            ReceiptAddress(view: receiver.address, networkAddress: receiver),
        amount: IntegerBalance.token(
            BigintUtils.parse(data["value"]), network.token,
            allowNegative: false, immutable: true),
        transferType: type);
  }
}

class SubstrateUnknownMethod extends SubstrateKnownCallMethods {
  final String content;
  final String? methodName;
  const SubstrateUnknownMethod(
      {required this.content, required this.methodName})
      : super(SubstrateKnownCallMethodsType.unknown);
  @override
  String get name => methodName ?? type.name;
}
