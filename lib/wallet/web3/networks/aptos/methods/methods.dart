import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/aptos/constant/constants/constant.dart';

class Web3AptosRequestMethods extends Web3NetworkRequestMethods {
  const Web3AptosRequestMethods._(
      {required super.id, required super.name, super.reloadAuthenticated});

  static const Web3AptosRequestMethods requestAccounts =
      Web3AptosRequestMethods._(
          id: Web3AptosConst.requestAccountTag,
          name: Web3AptosConst.requestAccounts);
  static const Web3AptosRequestMethods getNetwork = Web3AptosRequestMethods._(
      id: Web3AptosConst.getNetworkTag, name: Web3AptosConst.getNetwork);

  static const Web3AptosRequestMethods signMessage = Web3AptosRequestMethods._(
      id: Web3AptosConst.signMessageV2Tag, name: Web3AptosConst.signMessage);
  static const Web3AptosRequestMethods switchNetwork =
      Web3AptosRequestMethods._(
          id: Web3AptosConst.changeNetworkTag,
          name: Web3AptosConst.switchNetwork,
          reloadAuthenticated: true);
  static const Web3AptosRequestMethods signTransaction =
      Web3AptosRequestMethods._(
          id: Web3AptosConst.signTransactionTag,
          name: Web3AptosConst.signTransaction);

  @override
  NetworkType get network => NetworkType.aptos;

  static List<Web3AptosRequestMethods> values = [
    requestAccounts,
    signTransaction,
    signMessage,
    getNetwork,
    switchNetwork
  ];

  static Web3AptosRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3AptosRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
