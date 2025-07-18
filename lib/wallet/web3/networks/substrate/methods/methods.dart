import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/constant/constant.dart';

class Web3SubstrateRequestMethods extends Web3NetworkRequestMethods {
  const Web3SubstrateRequestMethods._(
      {required super.id, required super.name, super.reloadAuthenticated});

  static const Web3SubstrateRequestMethods requestAccounts =
      Web3SubstrateRequestMethods._(
          id: Web3SubstrateConst.requestAccountTag,
          name: Web3SubstrateConst.polkadotRequestAccounts);
  static const Web3SubstrateRequestMethods addSubstrateChain =
      Web3SubstrateRequestMethods._(
          id: Web3SubstrateConst.addChainTag,
          name: Web3SubstrateConst.addChain,
          reloadAuthenticated: true);
  static const Web3SubstrateRequestMethods signMessage =
      Web3SubstrateRequestMethods._(
          id: Web3SubstrateConst.signMessageTag,
          name: Web3SubstrateConst.signMessage);
  static const Web3SubstrateRequestMethods knownMetadata =
      Web3SubstrateRequestMethods._(
          id: Web3SubstrateConst.knownMetadataTag,
          name: Web3SubstrateConst.knownMetadata);

  static const Web3SubstrateRequestMethods signTransaction =
      Web3SubstrateRequestMethods._(
          id: Web3SubstrateConst.signTransactionTag,
          name: Web3SubstrateConst.polkadotSignTransaction);

  @override
  NetworkType get network => NetworkType.substrate;

  static List<Web3SubstrateRequestMethods> values = [
    requestAccounts,
    signMessage,
    signTransaction,
    addSubstrateChain,
    knownMetadata
  ];

  static Web3SubstrateRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3SubstrateRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
