import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/constant/constant.dart';
import 'package:on_chain_wallet/wallet/web3/networks/tron/constant/constants/constant.dart';

class Web3TronRequestMethods extends Web3NetworkRequestMethods {
  const Web3TronRequestMethods._({
    required super.id,
    required super.name,
    super.methodsName,
    super.reloadAuthenticated,
  });

  static const Web3TronRequestMethods requestAccounts =
      Web3TronRequestMethods._(
          id: Web3TronConst.requestAccountTag,
          name: Web3TronConst.requestAccounts);
  static const Web3TronRequestMethods signMessageV2 = Web3TronRequestMethods._(
      id: Web3TronConst.signMessageV2Tag,
      name: Web3TronConst.signMessageV2,
      methodsName: [Web3TronConst.signMessage]);

  static const Web3TronRequestMethods switchTronChain =
      Web3TronRequestMethods._(
          id: Web3TronConst.switchChainTag,
          name: Web3TronConst.switchChain,
          reloadAuthenticated: true,
          methodsName: [Web3EthereumConst.switchEthereumChain]);

  static const Web3TronRequestMethods signTransaction =
      Web3TronRequestMethods._(
          id: Web3TronConst.signTransactionTag,
          name: Web3TronConst.signTransaction);

  @override
  NetworkType get network => NetworkType.tron;

  static List<Web3TronRequestMethods> values = [
    requestAccounts,
    signTransaction,
    signMessageV2,
    switchTronChain
  ];

  static Web3TronRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3TronRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
