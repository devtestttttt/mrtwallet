import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/sui/constant/constants/constant.dart';

class Web3SuiRequestMethods extends Web3NetworkRequestMethods {
  const Web3SuiRequestMethods._({required super.id, required super.name});

  static const Web3SuiRequestMethods requestAccounts = Web3SuiRequestMethods._(
      id: Web3SuiConst.requestAccountTag, name: Web3SuiConst.requestAccounts);

  static const Web3SuiRequestMethods signMessage = Web3SuiRequestMethods._(
      id: Web3SuiConst.signMessagTag, name: Web3SuiConst.signMessage);
  static const Web3SuiRequestMethods signPersonalMessage =
      Web3SuiRequestMethods._(
          id: Web3SuiConst.signPersonalMessagTag,
          name: Web3SuiConst.signPersonalMessage);

  static const Web3SuiRequestMethods signTransaction = Web3SuiRequestMethods._(
      id: Web3SuiConst.signTransactionTag, name: Web3SuiConst.signTransaction);

  static const Web3SuiRequestMethods signRawTransaction =
      Web3SuiRequestMethods._(
          id: Web3SuiConst.signTransactionTag,
          name: Web3SuiConst.signTransaction);
  static const Web3SuiRequestMethods signAndExecuteTransaction =
      Web3SuiRequestMethods._(
          id: Web3SuiConst.signAndExecuteTransactionTag,
          name: Web3SuiConst.signAndExecuteTransaction);

  static const Web3SuiRequestMethods signTransactionBlock =
      Web3SuiRequestMethods._(
          id: Web3SuiConst.signTransactionBlockTag,
          name: Web3SuiConst.signTransactionBlock);
  static const Web3SuiRequestMethods signAndExecuteTransactionBlock =
      Web3SuiRequestMethods._(
          id: Web3SuiConst.signAndExecuteTransactionBlockTag,
          name: Web3SuiConst.signAndExecuteTransactionBlock);

  @override
  NetworkType get network => NetworkType.sui;

  static List<Web3SuiRequestMethods> values = [
    requestAccounts,
    signTransaction,
    signAndExecuteTransaction,
    signMessage,
    signTransactionBlock,
    signAndExecuteTransactionBlock,
    signPersonalMessage
  ];

  static Web3SuiRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3SuiRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
