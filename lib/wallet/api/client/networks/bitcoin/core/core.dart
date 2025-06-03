import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/bitcoin.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

abstract class BitcoinClient<T extends IBitcoinAddress>
    extends NetworkClient<BitcoinWalletTransaction, BaseBitcoinAPIProvider>
    with HttpImpl
    implements BaseSwapBitcoinClient {
  @override
  abstract final WalletBitcoinNetwork network;

  Future<BigInt> getAccountBalance(BitcoinBaseAddress address);
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]);
  @override
  Future<String> sendTransaction(String digest);
  Future<BitcoinFeeRate?> getFeeRate();
  @override
  Future<WalletTransactionStatus> transactionStatus({required String txId});
  Future<String> genesis();
  Future<BtcTransaction> getTx(String txId);

  BitcoinClient clone();

  @override
  Future<bool> onInit() async {
    final genesisHash = await genesis();
    return genesisHash == network.genesisBlock;
  }

  @override
  Future<SwapBitcoinAccountAssetBalance> getAccountsAssetBalance(
      BitcoinSwapAsset asset, BitcoinBaseAddress account) async {
    return SwapBitcoinAccountAssetBalance(
        address: account, balance: await getBalance(account), asset: asset);
  }

  @override
  NetworkType get networkType => network.type;

  @override
  Future<bool> initSwapClient() async {
    final init = await this.init();
    if (!init) {
      throw WalletException('network_client_initialize_failed');
    }
    return true;
  }
}
