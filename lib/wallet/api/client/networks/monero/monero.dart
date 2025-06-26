import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/impl/worker_impl.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/monero.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/monero/monero.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/monero.dart';

class MoneroClient
    extends NetworkClient<MoneroWalletTransaction, MoneroAPIProvider>
    with CryptoWokerImpl {
  MoneroClient({required this.provider, required this.network});
  // MoneroWalletClient? _walletClient;
  // MoneroWalletClient? get walletClient => _walletClient;
  final MoneroProvider provider;
  @override
  final WalletMoneroNetwork? network;
  MoneroCachedBlockHeight? _height;
  MoneroCachedBlockHeight? get currentHeight => _height;

  String? _genesis;

  @override
  MoneroHTTPService get service => provider.rpc as MoneroHTTPService;

  Future<MoneroCachedBlockHeight> getHeight({bool refresh = false}) async {
    if (refresh || (_height?.needFetch ?? true)) {
      final h = await provider.request(DaemonRequestGetLastBlockHeader());
      _height = MoneroCachedBlockHeight(h.blockHeader.height);
    }
    return _height!;
  }

  // Future<void> _updateBalance(IMoneroAddress address, MoneroChain chain) async {
  //   final walletTransfers = await MethodUtils.call(
  //       () async => _walletClient?.getAvailableTxes(address));
  //   if (walletTransfers.hasResult) {
  //     final relatedTxes = walletTransfers.result;
  //     if (relatedTxes != null) {
  //       await chain.updatePendingTxes(relatedTxes);
  //     }
  //   }
  // }

  // @override
  // Future<void> updateBalance(IMoneroAddress address,
  //     {MoneroChain? chain}) async {
  //   if (chain == null) return;
  //   // await _updateBalance(address, chain.cast());
  //   // await updateAccountUtxos(address: address, account: chain.cast());
  // }

  Future<DaemonGetBlocksByHeightResponse> getBlockByRange(
      int start, int end) async {
    final List<int> heights = List.generate(end - start, (i) => start + i);
    if (heights.isEmpty) {
      heights.add(start);
    }
    final blocks =
        await provider.request(DaemonRequestGetBlocksByHeightBin(heights));
    if (blocks.blocks.length != heights.length) {
      throw const WalletException("invalid_daemon_repsone");
    }
    return blocks;
  }

  Future<List<int>> getBlocksByRangeBinary(int start) async {
    final genesis = await getGenesisBlockHash();
    final blocks = await provider.requestBinary(
        DaemonRequestGetBlocksBin(
            startHeight: start,
            requestedInfo: DaemonRequestBlocksInfo.blocksOnly,
            blockIds: [genesis]),
        timeout: const Duration(minutes: 2));
    return blocks;
  }

  Future<List<DaemonBlockHeaderResponse>> getBlockHeadersRange(
      {required int start,
      required int end,
      bool validateResponse = true}) async {
    final r = await provider.request(
        DaemonRequestGetBlockHeaderByRange(startHeight: start, endHeight: end));
    if (validateResponse && r.headers.length != (end - start) + 1) {
      throw const WalletException("invalid_daemon_repsone");
    }
    return r.headers;
  }

  Future<DaemonGetEstimateFeeResponse> getFeeEstimate() async {
    final result = await provider.request(const DaemonRequestGetFeeEstimate(
        MoneroNetworkConst.feeEstimateGraceBlocks));
    return result;
  }

  Future<String> getGenesisBlockHash() async {
    _genesis ??= await provider.request(DaemonRequestOnGetBlockHash(0));
    return _genesis!;
  }

  Future<List<TxResponse>> getTxesByTxIds(
      {required List<String> txIds, bool validateResponse = true}) async {
    final rParams = DaemonRequestGetTransactions(txIds,
        prune: false, decodeAsJson: false, split: false);
    final result = await provider.request(rParams);
    if (validateResponse && rParams.txHashes.length != result.length) {
      throw const WalletException("some_transaction_missing");
    }
    return result;
  }

  Future<MoneroTransaction> getTx(String txId) async {
    final rParams = DaemonRequestGetTransactions([txId],
        prune: false, decodeAsJson: false, split: false);
    final result = await provider.request(rParams);
    if (rParams.txHashes.length != result.length) {
      throw const WalletException("transaction_not_found");
    }
    return result[0].toTx();
  }

  Future<List<TxResponse>> getTxes(
      {required List<String> txIds, bool validateResponse = true}) async {
    final rParams = DaemonRequestGetTransactions(txIds,
        prune: false, decodeAsJson: false, split: false);
    final result = await provider.request(rParams);
    if (validateResponse && rParams.txHashes.length != result.length) {
      throw const WalletException("some_transaction_missing");
    }
    return result;
  }

  Future<DaemonIsKeyImageSpentResponse> keyImagesStatus(List<String> keyImages,
      {bool validateResponse = true}) async {
    final result =
        await provider.request(DaemonRequestIsKeyImageSpent(keyImages));
    if (validateResponse && result.spentStatus.length != keyImages.length) {
      throw const DartMoneroPluginException("invalid_daemon_repsone");
    }
    return result;
  }

  Future<List<int>> getBinaryAbsoluteDistribution() async {
    final distributions = await provider.requestBinary(
        DaemonRequestGetOutputDistributionBin(
            amounts: [BigInt.zero], compress: true, cumulative: false));
    return distributions;
  }

  Future<GetOutResponse> getOuts(
      List<DaemonGetOutRequestParams> outputs) async {
    final outs = await provider
        .request(DaemonRequestGetOuts(outputs: outputs, getTxId: false));
    return outs;
  }

  Future<List<SpendablePayment<T>>>
      generatePaymentOutputs<T extends MoneroPayment>(
          {required List<T> payments,
          int fakeOutsLength = 15,
          required List<BigInt> outKeysRequestOrder,
          required List<BigInt> outKeysRequests}) async {
    if (fakeOutsLength <= 0) {
      throw const DartMoneroPluginException(
          "fake outs length should be greather than zero.");
    }
    final List<List<OutsEntery>> outs = [];
    final int baseRequestCount = ((fakeOutsLength + 1) * 1.5 + 1).ceil();
    final List<OutKeyResponse> outKeysResponse = [];
    int offset = 0;
    while (offset < outKeysRequests.length) {
      const int size = 1000;
      final int outChunSize =
          IntUtils.min(outKeysRequests.length - offset, size);
      final List<DaemonGetOutRequestParams> chunkRequest = List.generate(
          outChunSize,
          (i) => DaemonGetOutRequestParams(
              amount: BigInt.zero, index: outKeysRequests[offset + i]));
      offset += size;
      final outs = await getOuts(chunkRequest);
      outKeysResponse.addAll(outs.outs);
    }
    int base = 0;
    for (final payment in payments) {
      const defaultOutCount =
          MoneroNetworkConst.cryptonoteMinedMoneyUnlockWindow -
              MoneroNetworkConst.cryptonoteDefaultTxSpendableAge;
      final int outputsCount = baseRequestCount + defaultOutCount;
      final List<OutsEntery> out = [];
      final mask = RCT.commitVar(
          xmrAmount: payment.output.amount, mask: payment.output.mask);
      bool hasRealOut = false;
      for (int n = 0; n < outputsCount; ++n) {
        final int i = base + n;
        if (outKeysRequests[i] == payment.globalIndex) {
          if (BytesUtils.bytesEqual(
              outKeysResponse[i].key, payment.output.outputPublicKey)) {
            if (BytesUtils.bytesEqual(outKeysResponse[i].mask, mask)) {
              if (outKeysResponse[i].unlocked) {
                hasRealOut = true;
              }
            }
          }
        }
      }
      if (!hasRealOut) {
        throw const DartMoneroPluginException(
            "Daemon response did not include the requested real output");
      }
      out.add(OutsEntery(
          index: payment.globalIndex,
          key: CtKey(dest: payment.output.outputPublicKey, mask: mask)));

      for (int idx = base;
          idx < base + outputsCount && out.length < fakeOutsLength + 1;
          ++idx) {
        final attemptedOutput = outKeysRequestOrder[idx];
        int i;
        for (i = base; i < base + outputsCount; ++i) {
          if (outKeysRequests[i] == attemptedOutput) {
            break;
          }
        }
        if (i == base + outputsCount) {
          throw const DartMoneroPluginException(
              "Could not find index of picked output in requested outputs");
        }
        final fakeOutResponse = outKeysResponse[i];
        final fakeOutRequest = outKeysRequests[i];
        final fakeEntry = OutsEntery(
            index: fakeOutRequest,
            key: CtKey(dest: fakeOutResponse.key, mask: fakeOutResponse.mask));
        if (fakeOutResponse.unlocked &&
            fakeOutRequest != payment.globalIndex &&
            !out.contains(fakeEntry)) {
          out.add(fakeEntry);
        }
      }
      out.sort((a, b) => a.index.compareTo(b.index));
      outs.add(out);
      if (out.length < fakeOutsLength + 1) {
        throw const DartMoneroPluginException("not enough outs to mix.");
      }

      base += outputsCount;
    }
    return List.generate(payments.length, (i) {
      final payment = payments[i];
      final sourceOuts = outs[i];
      final index =
          sourceOuts.indexWhere((e) => e.index == payment.globalIndex);
      if (index.isNegative) {
        throw const DartMoneroPluginException("Index not found.");
      }
      return SpendablePayment<T>(
          payment: payment, outs: sourceOuts, realOutIndex: index);
    });
  }

  Future<void> sendTx(String txHex,
      {bool doNotRelay = false, bool doSanityChecks = true}) async {
    await provider.request(DaemonRequestSendRawTransaction(
        txAsHex: txHex,
        doNotRelay: doNotRelay,
        doSanityChecks: doSanityChecks));
  }

  Future<bool> validateNetworkGenesis() async {
    final gnesis = await getGenesisBlockHash();
    return gnesis == network?.genesisBlock;
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    final r = await provider.request(DaemonRequestGetTransactions([txId]));
    if (r.length != 1) return WalletTransactionStatus.unknown;
    final tx = r[0];
    if (tx.inPool || tx.height == null) return WalletTransactionStatus.pending;
    if (tx.doubleSpend) return WalletTransactionStatus.failed;
    return WalletTransactionStatus.block;
  }

  @override
  Future<bool> onInit() async {
    await getHeight();
    return validateNetworkGenesis();
  }

  @override
  NetworkType get networkType => NetworkType.monero;
}

class MoneroWalletClient
    extends NetworkClient<MoneroWalletTransaction, MoneroAPIProvider>
    with CryptoWokerImpl {
  final MoneroProvider provider;
  List<MoneroWalletRPCAddress>? _addresses;
  MoneroWalletClient(MoneroAPIProvider provider, this.network)
      : provider = MoneroProvider(MoneroHTTPService(provider));

  @override
  WalletMoneroNetwork? network;

  @override
  MoneroHTTPService get service => provider.rpc as MoneroHTTPService;

  Future<WalletRPCGetAccountsResponse> readMoneroWalletAccounts() async {
    return provider.request(WalletRequestGetAccounts());
  }

  Future<List<MoneroWalletRPCAddress>> readMoneroWalletAdresses() async {
    final accounts = await readMoneroWalletAccounts();
    final List<MoneroWalletRPCAddress> existsAccounts = [];
    for (final i in accounts.subaddressAccounts) {
      final addresses = await provider
          .request(WalletRequestGetAddress(accountIndex: i.accountIndex));
      existsAccounts.addAll(addresses.addresses
          .map((e) => MoneroWalletRPCAddress(
                address: e.address,
                index: MoneroAccountIndex(
                    major: i.accountIndex, minor: e.addressIndex),
              ))
          .toList());
    }
    return existsAccounts;
  }

  Future<List<MoneroAccountPendingTxes>> readMoneroWalletTxes(
      MoneroChain account) async {
    final addresses = _addresses ?? await readMoneroWalletAdresses();
    final accounts = account.addresses
        .where((e) => addresses.any((r) => e.networkAddress == r.address))
        .toList();
    if (accounts.isEmpty) return [];
    final Map<MoneroViewPrimaryAccountDetails, MoneroAccountPendingTxes>
        availableTransfers = {};
    for (final i in accounts) {
      if (availableTransfers.containsKey(i.addrDetails.viewKey)) continue;
      final allIndexes = account.relateAccountIndexes(i.addrDetails.viewKey);
      final r = await provider.request(WalletRequestIncommingTransfers(
          transferType: IncommingTransferType.available,
          accountIndex: i.addrDetails.index.major,
          subaddrIndices: allIndexes.map((e) => e.minor).toList()));
      List<MoneroAccountIndexTxes> indexes = [];
      for (final i in allIndexes) {
        final txes = r.where((e) =>
            e.subAddrIndex?.minor == i.minor &&
            e.subAddrIndex?.major == i.major);
        indexes.add(MoneroAccountIndexTxes(
            index: i, txes: txes.map((e) => e.txHash).toList()));
      }
      if (indexes.isEmpty) continue;
      availableTransfers[i.addrDetails.viewKey] =
          MoneroAccountPendingTxes.request(
              primaryAddress: i.addrDetails.viewKey,
              indexes: indexes,
              accountIndex: i.keyIndex.cast());
    }

    return availableTransfers.values.toList();
  }

  @override
  Future<bool> onInit() async {
    _addresses = await readMoneroWalletAdresses();
    return true;
  }

  @override
  NetworkType get networkType => NetworkType.monero;

  @override
  Future<WalletTransactionStatus> transactionStatus({required String txId}) {
    throw UnimplementedError();
  }
}
