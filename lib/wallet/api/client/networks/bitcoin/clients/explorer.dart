import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class BitcoinExplorerApiProvider extends BitcoinClient<IBitcoinAddress> {
  BitcoinExplorerApiProvider({required this.provider, required this.network});
  @override
  final WalletBitcoinNetwork network;

  @override
  NetworkServiceProtocol<BaseBitcoinAPIProvider> get service =>
      provider.service as NetworkServiceProtocol<BaseBitcoinAPIProvider>;

  final ApiProvider provider;

  @override
  Future<BigInt> getAccountBalance(BitcoinBaseAddress address) async {
    final utxos =
        await provider.getAccountUtxo(UtxoAddressDetails.watchOnly(address));
    return utxos.sumOfUtxosValue();
  }

  @override
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]) async {
    assert(
        !includeTokens, "bitcoin explorer api does not support include tokens");
    final utxos = await provider.getAccountUtxo(address);
    return utxos;
  }

  @override
  Future<BitcoinFeeRate> getFeeRate() => provider.getNetworkFeeRate();

  @override
  Future<String> sendTransaction(String digest) async {
    return await provider.sendRawTransaction(digest);
  }

  @override
  Future<BtcTransaction> getTx(String txId) async {
    return await provider.getRawTransaction(txId);
  }

  @override
  Future<BigRational> estimateFeePerByte(SwapBitcoinNetwork network) async {
    final fee = await getFeeRate();
    return BigRational(fee.medium) / BigRational.from(1024);
  }

  @override
  Future<String> genesisHash() async {
    return await provider.genesis();
  }

  @override
  Future<List<PsbtUtxo>> getAccountsUtxos(
      List<BitcoinSpenderAddress> addresses) async {
    final utxos = await _getAccountsUtxo(addresses);
    return utxos.where((e) {
      final height = e.utxo.blockHeight;
      return height != null && height > 0;
    }).toList();
  }

  Future<List<PsbtUtxo>> _getAccountsUtxo(
      List<BitcoinSpenderAddress> addresses) async {
    final utxos = await Future.wait(addresses.map((e) async {
      return await readUtxos(
          UtxoAddressDetails.watchOnly(e.address.baseAddress));
    }));
    final utxoss = List.generate(utxos.length, (i) async {
      final request = addresses[i];
      final accountUtxos = utxos[i];
      final er = await Future.wait(
          accountUtxos.map((e) => getTx(e.utxo.txHash)).toList());
      return List.generate(
        accountUtxos.length,
        (index) {
          return PsbtUtxo(
              utxo: accountUtxos[index].utxo,
              p2shRedeemScript: request.p2shreedemScript,
              p2wshWitnessScript: request.witnessScript,
              tx: er[index],
              scriptPubKey: request.address.baseAddress.toScriptPubKey(),
              xOnlyOrInternalPubKey: request.taprootInternal);
        },
      );
    });
    final e = await Future.wait(utxoss);
    return e.expand((e) => e).toList();
  }

  @override
  Future<BigInt> getBalance(BitcoinBaseAddress address) async {
    final utxos =
        await provider.getAccountUtxo(UtxoAddressDetails.watchOnly(address));
    return utxos.sumOfUtxosValue();
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    if (provider.api.apiType == APIType.mempool) {
      final tx = await provider.getTransaction<MempoolTransaction>(txId);
      if (tx.status.confirmed) {
        return WalletTransactionStatus.block;
      }
      return WalletTransactionStatus.pending;
    }
    final tx = await provider.getTransaction<BlockCypherTransaction>(txId);
    if (tx.doubleSpend) {
      return WalletTransactionStatus.failed;
    }
    if (tx.confirmations > 0) {
      return WalletTransactionStatus.block;
    }
    return WalletTransactionStatus.pending;
  }

  @override
  Future<BigInt?> getBlockHeight() async {
    return provider.getLatestBlockHeight();
  }

  @override
  BitcoinClient<IBitcoinAddress> clone() {
    return BitcoinExplorerApiProvider(provider: provider, network: network);
  }
}
