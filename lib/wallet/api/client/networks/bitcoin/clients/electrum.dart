import 'dart:async';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/bitcoin/core/core.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/bitcoin/methods/script_hash_balance.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/models/chain/account.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/transaction/transaction.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class BitcoinElectrumClient extends BitcoinClient<IBitcoinAddress> {
  BitcoinElectrumClient({required this.provider, required this.network});
  @override
  final WalletBitcoinNetwork network;

  @override
  NetworkServiceProtocol<ElectrumAPIProvider> get service =>
      provider.rpc as NetworkServiceProtocol<ElectrumAPIProvider>;

  final ElectrumProvider provider;

  @override
  Future<List<UtxoWithAddress>> readUtxos(UtxoAddressDetails address,
      [bool includeTokens = false]) async {
    final utxos = await provider.request(ElectrumRequestScriptHashListUnspent(
        scriptHash: address.address.pubKeyHash(),
        includeTokens: includeTokens));
    return utxos
        .where((element) => (!includeTokens) ? element.token == null : true)
        .map((e) {
      final utxo = UtxoWithAddress(
          utxo: e.toUtxo(address.address.type), ownerDetails: address);
      return utxo;
    }).toList();
  }

  @override
  Future<BitcoinFeeRate?> getFeeRate() async {
    final BigInt? high =
        await provider.request(ElectrumRequestEstimateFee(numberOfBlock: 2));
    if (high == null) {
      return null;
    }
    final BigInt? medium =
        await provider.request(ElectrumRequestEstimateFee(numberOfBlock: 5));
    final BigInt? low =
        await provider.request(ElectrumRequestEstimateFee(numberOfBlock: 10));
    return BitcoinFeeRate(high: high, low: low ?? high, medium: medium ?? high);
  }

  @override
  Future<String> sendTransaction(String digest) async {
    return await provider
        .request(ElectrumRequestBroadCastTransaction(transactionRaw: digest));
  }

  @override
  Future<String> genesisHash() async {
    final header = await provider
        .request(ElectrumRequestBlockHeader(startHeight: 0, cpHeight: 0));
    return BytesUtils.toHexString(
        QuickCrypto.sha256DoubleHash(BytesUtils.fromHexString(header))
            .reversed
            .toList());
  }

  @override
  Future<BtcTransaction> getTx(String txId) async {
    return await provider.request(ElectrumRequestGetRawTransaction(txId));
  }

  @override
  Future<BigRational> estimateFeePerByte(SwapBitcoinNetwork network) async {
    final fee = await getFeeRate();
    if (fee == null) {
      if (!network.chainType.isMainnet) {
        return BigRational.parseDecimal('1.1');
      }
      throw WalletException("Failed to fetch network fee rate.");
    }
    return BigRational(fee.medium) / BigRational.from(1024);
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
      return await provider.request(ElectrumRequestScriptHashListUnspent(
          scriptHash: e.address.baseAddress.pubKeyHash()));
    }));
    final utxoss = List.generate(utxos.length, (i) async {
      final request = addresses[i];
      final accountUtxos = utxos[i];
      final er = await Future.wait(accountUtxos
          .map(
              (e) => provider.request(ElectrumRequestGetRawTransaction(e.txId)))
          .toList());
      return List.generate(
        accountUtxos.length,
        (index) {
          return PsbtUtxo(
              utxo: accountUtxos[index].toUtxo(request.address.type),
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

  Future<ElectrumHeaderSubscribeResponse> getBlock() async {
    return await provider.request(ElectrumRequestHeaderSubscribe());
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    try {
      final r =
          await provider.request(ElectrumRequestGetVerboseTransaction(txId));
      if (r.confirmations == null) {
        return WalletTransactionStatus.pending;
      }
      return WalletTransactionStatus.block;
    } catch (_) {
      return WalletTransactionStatus.unknown;
    }
  }

  @override
  Future<BigInt> getBalance(BitcoinBaseAddress address) async {
    return provider.request(
        ElectrumGetScriptHashSumBalance(scriptHash: address.pubKeyHash()));
  }

  @override
  Future<BigInt?> getBlockHeight() async {
    final block = await getBlock();
    return BigInt.from(block.block);
  }

  @override
  BitcoinClient<IBitcoinAddress> clone() {
    return BitcoinElectrumClient(provider: provider, network: network);
  }

  @override
  Future<BigInt> getAccountBalance(BitcoinBaseAddress address) async {
    return await provider.request(
        ElectrumGetScriptHashSumBalance(scriptHash: address.pubKeyHash()));
  }
}
