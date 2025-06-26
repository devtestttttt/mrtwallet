import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/global/constant/constant.dart';

class Web3GlobalRequestMethods extends Web3RequestMethods {
  @override
  bool get isGlobalMethod => true;
  const Web3GlobalRequestMethods._(
      {required super.id,
      required super.name,
      super.methodsName = const [],
      super.reloadAuthenticated = true});
  static const Web3GlobalRequestMethods disconnect = Web3GlobalRequestMethods._(
      id: Web3GlobalConst.disconnectTag, name: "disconnect");
  static const Web3GlobalRequestMethods connect = Web3GlobalRequestMethods._(
      id: Web3GlobalConst.connectTag, name: "connect");
  static const Web3GlobalRequestMethods switchNetwork =
      Web3GlobalRequestMethods._(
          id: Web3GlobalConst.switchNetwork, name: "switch_network");
  static const List<Web3GlobalRequestMethods> values = [
    disconnect,
    connect,
    switchNetwork
  ];
  static Web3GlobalRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3GlobalRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
