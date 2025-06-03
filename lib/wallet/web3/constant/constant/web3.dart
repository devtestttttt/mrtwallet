import 'package:on_chain_wallet/crypto/models/networks.dart';

class Web3Const {
  static const List<NetworkType> supportedWeb3 = [
    NetworkType.ethereum,
    NetworkType.tron,
    NetworkType.solana,
    NetworkType.ton,
    NetworkType.stellar,
    NetworkType.substrate,
    NetworkType.aptos,
    NetworkType.sui,
    NetworkType.cosmos,
    NetworkType.bitcoinAndForked
  ];
}
