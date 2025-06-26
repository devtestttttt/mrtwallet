import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/web3/models/models/network.dart';
import 'account.dart';

class Web3BitcoinChain extends Web3Chain<BitcoinBaseAddress, BitcoinChain,
    IBitcoinAddress, Web3BitcoinChainAccount, WalletBitcoinNetwork> {
  Web3BitcoinChain._({
    required super.accounts,
    required super.id,
  }) : super(network: NetworkType.bitcoinAndForked);
  @override
  Web3BitcoinChain clone() {
    return Web3BitcoinChain._(
        accounts: activeAccounts.map((e) => e.clone()).toList(),
        id: currentChain);
  }

  factory Web3BitcoinChain.create({int? id}) {
    return Web3BitcoinChain._(
        accounts: const [],
        id: id ?? NetworkType.bitcoinAndForked.mainNetworkId);
  }

  factory Web3BitcoinChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.bitcoinAndForked.tag);
    return Web3BitcoinChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3BitcoinChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1));
  }

  @override
  Web3BitcoinChain disconnect() {
    return Web3BitcoinChain._(
        accounts: const [], id: NetworkType.bitcoinAndForked.mainNetworkId);
  }

  @override
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletBitcoinNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final web3Networks = networks
        .map((e) => Web3BitcoinChainIdnetifier(
            id: e.network.value,
            wsIdentifier: e.network.wsIdentifier,
            caip2: e.network.caip,
            network: e.network.coinParam.transacationNetwork))
        .toList();

    final currentWeb3Network = Web3BitcoinChainIdnetifier(
        id: currentNetwork.value,
        wsIdentifier: currentNetwork.wsIdentifier,
        caip2: currentNetwork.caip,
        network: currentNetwork.coinParam.transacationNetwork);
    return Web3BitcoinChainAuthenticated(
        accounts: activeAccounts,
        networks: web3Networks,
        currentNetwork: currentWeb3Network);
  }
}
