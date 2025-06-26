import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/error/exception.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/substrate/methods/metadata.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/substrate/models/models/models.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:on_chain_wallet/wallet/constant/networks/substrate.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/services/core/base_service.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/substrate/substrate.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/substrate.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateClient
    extends NetworkClient<SubstrateWalletTransaction, SubstrateAPIProvider>
    implements BaseSwapSubstrateClient {
  SubstrateClient({required this.provider, required this.network});
  final SubstrateProvider provider;
  @override
  final WalletSubstrateNetwork? network;
  SubstrateChainMetadata? _metadata;
  SubstrateChainMetadata? get metadataNullable => _metadata;
  SubstrateChainMetadata get metadata => _metadata!;
  @override
  MetadataApi get api => metadata.metadata;
  String get genesisBlock => metadata.genesis;

  @override
  NetworkServiceProtocol<SubstrateAPIProvider> get service =>
      provider.rpc as NetworkServiceProtocol<SubstrateAPIProvider>;

  Future<BigInt> getAccountBalance(BaseSubstrateAddress address) async {
    final storage =
        await api.getDefaultAccountInfo(address: address, rpc: provider);
    return storage.data.free;
  }

  @override
  Future<int> getAccountNonce(BaseSubstrateAddress address) async {
    final storage = await api.getAccount(address: address, rpc: provider);
    return storage.nonce;
  }

  Future<SubstrateBlockHash> getBlockHash({int? atNumber}) async {
    final blockHash = await provider
        .request(SubstrateRequestChainGetBlockHash(number: atNumber));
    if (blockHash == null) {
      throw UnimplementedError();
    }
    return SubstrateBlockHash.hash(blockHash);
  }

  @override
  Future<SubstrateBlockHash> getFinalizBlock({int? atNumber}) async {
    final blockHash = await provider
        .request(const SubstrateRequestChainChainGetFinalizedHead());
    return SubstrateBlockHash.hash(blockHash);
  }

  @override
  Future<SubstrateHeaderResponse> getBlockHeader({String? atBlockHash}) async {
    final header = await provider
        .request(SubstrateRequestChainChainGetHeader(atBlockHash: atBlockHash));
    return header;
  }

  Future<SubstrateTxIdWithBlock> broadcastTransaction(
      List<int> extrinsic) async {
    final blockHeader =
        await provider.request(SubstrateRequestChainChainGetHeader());
    final txId = await provider.request(SubstrateRequestAuthorSubmitExtrinsic(
        BytesUtils.toHexString(extrinsic, prefix: "0x")));
    return SubstrateTxIdWithBlock(txId: txId, block: blockHeader.number);
  }

  Future<SubstrateBlockWithEra> finalizeBlockWithEra() async {
    final finalizeBlock = (await getFinalizBlock());
    final blockHash = finalizeBlock.toHex();
    final header = await getBlockHeader(atBlockHash: blockHash);
    return SubstrateBlockWithEra(
        block: blockHash,
        era: header.toMortalEra(period: APPSubstrateConst.defaultEraPeriod),
        blockHashBytes: finalizeBlock.bytes);
  }

  Future<SubstrateFeeInfos> estimateFee(
      {required List<int> extrinsic,
      required WalletSubstrateNetwork network}) async {
    final fee = await provider.request(
        SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails
            .fromExtrinsic(exirceBytes: extrinsic));
    return SubstrateFeeInfos.fromFeeDetails(fee: fee, network: network);
  }

  Future<MetadataApi?> getLastestVersionedMetadata() async {
    List<int> versionIds = [];
    try {
      versionIds = await provider
          .request(const SubstrateRequestRuntimeMetadataGetVersions());
    } on RPCError catch (_) {}
    versionIds.sort((a, b) => b.compareTo(a));
    for (final i in versionIds) {
      if (APPSubstrateConst.supportedVersion.contains(i)) {
        try {
          final request = SubstrateGetApiAt(i);
          final metadata = await provider.requestDynamic(request);
          final supported = request.onResonse(metadata);
          if (supported != null) return supported;
        } on ApiProviderException {
          rethrow;
        } catch (_) {}
      }
    }
    final request = const SubstrateGetStateApi();
    final metadata = await provider.request(request);
    return metadata;
  }

  Future<SubstrateChainMetadata?> loadApi() async {
    final api = await getLastestVersionedMetadata();
    if (api == null) return null;
    final genesis = await _loadGenesis();
    return SubstrateChainMetadata(genesis: genesis.toHex(), metadata: api);
  }

  Future<SubstrateBlockHash> _loadGenesis() async {
    final genesis = await provider
        .request(const SubstrateRequestChainGetBlockHash(number: 0));
    if (genesis == null) {
      throw UnimplementedError();
    }
    return SubstrateBlockHash.hash(genesis);
  }

  Future<bool> validateNetworkGenesis() async {
    final genesis = await _loadGenesis();
    return StringUtils.strip0x(genesis.toHex()) == network?.genesisBlock;
  }

  Future<List<String>> queryStorage(
      List<SubstrateStorageQueryParams> requests) async {
    final r = await api.queryStorageAt(
        requestes: List.generate(requests.length, (i) {
          final request = requests[i];
          return QueryStorageRequest(
              palletNameOrIndex: request.pallet,
              methodName: request.storage.name,
              identifier: i,
              input: request.input);
        }),
        rpc: provider,
        fromTemplate: false);
    return List.generate(requests.length, (i) {
      final result = r.getResult(i);
      if (result is Map) {
        return StringUtils.fromJson(result,
            indent: '', toStringEncodable: true);
      }
      return result.toString();
    });
  }

  Future<String> runtimeCall(
      {required String methodName,
      required String apiName,
      List<Object?> inputs = const []}) async {
    final result = await api.runtimeCall(
        rpc: provider,
        fromTemplate: false,
        methodName: methodName,
        apiName: apiName,
        params: inputs);
    if (result is Map) {
      return StringUtils.fromJson(result, indent: '', toStringEncodable: true);
    }
    return result.toString();
  }

  @override
  Future<BigInt> getBalance(BaseSubstrateAddress address) async {
    final storage =
        await api.getDefaultAccountInfo(address: address, rpc: provider);
    return storage.data.free;
  }

  @override
  Future<SubstrateBlockHash> getGenesis() {
    return _loadGenesis();
  }

  @override
  Future<String> sendTransaction(Extrinsic extrinsic) async {
    final txInfo = await broadcastTransaction(extrinsic.serialize());
    return txInfo.txId;
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    return WalletTransactionStatus.unknown;
  }

  @override
  Stream<T> trackMempoolTransaction<T extends SubstrateWalletTransaction>(
      List<T> transactions) {
    Future<WalletTransactionStatus> transactionStatus(
        SubstrateWalletTransaction transaction) async {
      try {
        final result = await _streamBlock(
            txId: transaction.txId,
            extrinsic: transaction.extrinsics,
            blockId: transaction.block,
            maxRetryEachBlock: 10);
        if (result.events.any(
            (e) => e.method == APPSubstrateConst.extrinsicFailedMethodName)) {
          return WalletTransactionStatus.failed;
        }
        return WalletTransactionStatus.block;
      } catch (_) {
        return WalletTransactionStatus.unknown;
      }
    }

    final StreamController<T> controller = StreamController();
    Future<void> run() async {
      final future = transactions.map((e) async {
        final r = await transactionStatus(e);
        e.updateStatus(r);
        controller.add(e);
      });
      await Future.wait(future);
      controller.close();
    }

    run();

    return controller.stream;
  }

  @override
  Future<SubtrateTransactionSubmitionResult> submitExtrinsicAndWatch(
      {required Extrinsic extrinsic, int maxRetryEachBlock = 10}) async {
    final blockHeader =
        await provider.request(SubstrateRequestChainChainGetHeader());
    final ext = extrinsic.toHex(prefix: "0x");
    final txId =
        await provider.request(SubstrateRequestAuthorSubmitExtrinsic(ext));
    final result = await _streamBlock(
        txId: txId,
        extrinsic: ext,
        blockId: blockHeader.number,
        maxRetryEachBlock: maxRetryEachBlock);
    return result;
  }

  Future<SubtrateTransactionSubmitionResult> _streamBlock({
    required String txId,
    required String extrinsic,
    required int blockId,
    int maxRetryEachBlock = 5,
  }) async {
    final completer = Completer<SubtrateTransactionSubmitionResult>();
    StreamSubscription<SubtrateTransactionSubmitionResult>? stream;
    try {
      stream = _findTransactionStream(
              blockId: blockId,
              extrinsic: extrinsic,
              maxRetryEachBlock: maxRetryEachBlock,
              transactionHash: txId)
          .listen(
              (e) async {
                completer.complete(e);
              },
              onDone: () {},
              onError: (e) {
                if (completer.isCompleted) return;
                if (e is WalletException) {
                  completer.completeError(WalletException(e.message));
                } else {
                  completer.completeError(
                      WalletException("transaction_confirmation_failed"));
                }
              });
      return await completer.future;
    } finally {
      stream?.cancel();
      stream = null;
    }
  }

  Future<SubtrateTransactionSubmitionResult?> _lockupBlock(
      {required int blockId,
      required String extrinsic,
      required String transactionHash}) async {
    final blockHash = await provider
        .request(SubstrateRequestChainGetBlockHash<String?>(number: blockId));
    if (blockHash == null) {
      throw TypeError();
    }
    final block = await provider
        .request(SubstrateRequestChainGetBlock(atBlockHash: blockHash));
    try {
      final index = block.block.extrinsics.indexOf(extrinsic);
      if (index < 0) return null;
      final events =
          await api.getSystemEvents(provider, atBlockHash: blockHash);
      return SubtrateTransactionSubmitionResult(
          events: events.where((e) => e.applyExtrinsic == index).toList(),
          block: blockHash,
          extrinsic: extrinsic,
          blockNumber: blockId,
          transactionHash: transactionHash);
    } on RPCError {
      rethrow;
    } catch (e) {
      throw WalletException("transaction_confirmation_failed");
    }
  }

  Stream<SubtrateTransactionSubmitionResult> _findTransactionStream(
      {Duration retryInterval = const Duration(seconds: 4),
      required int blockId,
      required String extrinsic,
      required String transactionHash,
      int maxRetryEachBlock = 5,
      int blockCount = 20}) {
    final controller = StreamController<SubtrateTransactionSubmitionResult>();
    void closeController() {
      if (!controller.isClosed) {
        controller.close();
      }
    }

    void startFetching() async {
      int id = blockId;
      int retry = maxRetryEachBlock;
      int count = blockCount;
      while (!controller.isClosed) {
        try {
          final result = await _lockupBlock(
              blockId: id,
              extrinsic: extrinsic,
              transactionHash: transactionHash);
          id++;
          count--;
          retry = maxRetryEachBlock;
          if (result != null) {
            controller.add(result);
            closeController();
          } else if (count <= 0) {
            controller
                .addError(WalletException("transaction_confirmation_failed"));
            closeController();
          }
        } on WalletException catch (e) {
          controller.addError(e);
          closeController();
          return;
        } catch (_) {
          retry--;
          if (retry <= 0) {
            controller
                .addError(WalletException("transaction_confirmation_failed"));
            closeController();
            return;
          }
        }
        await Future.delayed(retryInterval);
      }
    }

    startFetching();
    return controller.stream.asBroadcastStream(onCancel: (e) {
      controller.close();
    });
  }

  @override
  Future<SubstrateTransactionBlockRequirment>
      transactionBlockRequirment() async {
    final finalizeBlock = (await getFinalizBlock());
    final genesis = await getGenesis();
    final blockHash = finalizeBlock.toHex();

    final header = await getBlockHeader(atBlockHash: blockHash);
    return SubstrateTransactionBlockRequirment(
        blockNumber: header.number,
        era: header.toMortalEra(period: APPSubstrateConst.defaultEraPeriod),
        blockHashBytes: finalizeBlock.bytes,
        genesisBlock: genesis);
  }

  @override
  Future<bool> initSwapClient() async {
    final init = await this.init();
    if (!init) {
      throw WalletException('network_client_initialize_failed');
    }
    return true;
  }

  @override
  Future<SwapPolkadotAccountAssetBalance> getAccountsAssetBalance(
      PolkadotSwapAsset asset, BaseSubstrateAddress account) async {
    if (!asset.type.isNative) {
      throw WalletException("invalid_swap_asset");
    }
    return SwapPolkadotAccountAssetBalance(
        address: account, balance: await getBalance(account), asset: asset);
  }

  @override
  Future<BigInt> getBlockHeight() async {
    final header = await getBlockHeader();
    return BigInt.from(header.number);
  }

  @override
  Future<bool> onInit() async {
    if (_metadata != null) return true;
    final metadata = await loadApi();
    if (metadata?.genesis != network?.genesisBlock) {
      return false;
    }
    _metadata = metadata;
    return true;
  }

  @override
  NetworkType get networkType => NetworkType.substrate;
}
