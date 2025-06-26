import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/bitcoin/constant/constants/constant.dart';

class Web3BitcoinRequestMethods extends Web3NetworkRequestMethods {
  const Web3BitcoinRequestMethods._(
      {required super.id, required super.name, super.methodsName});

  static const Web3BitcoinRequestMethods requestAccounts =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.requestAccountTag,
          name: Web3BitcoinConst.requestAccounts);

  static const Web3BitcoinRequestMethods signPersonalMessage =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.signPersonalMessagTag,
          name: Web3BitcoinConst.signPersonalMessage);

  static const Web3BitcoinRequestMethods signMessage =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.signMessageTag,
          name: Web3BitcoinConst.signMessage);

  static const Web3BitcoinRequestMethods signTransaction =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.signTransactionTag,
          name: Web3BitcoinConst.signTransaction,
          methodsName: [Web3BitcoinConst.signPsbt]);

  static const Web3BitcoinRequestMethods getAccountAddresses =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.getAccountAddressesTag,
          name: Web3BitcoinConst.getAccountAddresses,
          methodsName: [Web3BitcoinConst.bitcoinGetAccountAddresses]);

  static const Web3BitcoinRequestMethods sendTransaction =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.sendTransactionTag,
          name: Web3BitcoinConst.sendTransaction,
          methodsName: [Web3BitcoinConst.sendTransfer]);

  @override
  NetworkType get network => NetworkType.bitcoinAndForked;

  static List<Web3BitcoinRequestMethods> values = [
    requestAccounts,
    signTransaction,
    signPersonalMessage,
    sendTransaction,
    signMessage,
    getAccountAddresses
  ];

  static Web3BitcoinRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3BitcoinRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
