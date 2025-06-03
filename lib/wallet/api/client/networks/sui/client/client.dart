import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/sui/models/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/sui.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/constant/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/models/network/params/sui.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/sui.dart';
import 'package:on_chain/sui/src/src.dart';
import 'package:on_chain_wallet/wallet/models/token/token.dart';

class SuiClient extends NetworkClient<SuiWalletTransaction, SuiAPIProvider> {
  final SuiProvider provider;
  final Map<SuiAddress, SuiCachedAccountCoins> _cachedAccountCoins = {};
  @override
  final WalletSuiNetwork? network;
  SuiClient({required this.provider, this.network});
  @override
  SuiHTTPService get service => provider.rpc as SuiHTTPService;

  Future<List<SuiApiBalanceResponse>> getAcountBalances(
      SuiAddress address) async {
    return await provider.request(SuiRequestGetAllBalances(owner: address));
  }

  Future<BigInt> getGasPrice() async {
    return await provider.request(const SuiRequestGetReferenceGasPrice());
  }

  Future<SuiApiGasCostSummary> simulateGasUsed(
      SuiTransactionDataV1 transaction) async {
    final r = await provider.request(SuiRequestDryRunTransactionBlock(
        txBytes: transaction.toVariantBcsBase64()));
    if (r.effects.status.status != SuiApiExecutionStatusType.success) {
      throw WalletException(
          r.effects.status.error ?? "transaction_simulation_failed");
    }
    return r.effects.gasUsed;
  }

  Future<SuiApiDryRunTransactionBlockResponse> simulateTransaction(
      SuiTransactionDataV1 transaction) async {
    final r = await provider.request(SuiRequestDryRunTransactionBlock(
        txBytes: transaction.toVariantBcsBase64()));
    return r;
  }

  Future<SuiExcuteTransactionData> excuteTx(
      {required SuiTransactionDataV1 tx,
      required List<SuiBaseSignature> signatures}) async {
    final excute = await provider.requestDynamic(
        SuiRequestExecuteTransactionBlock(
            txBytes: tx.toVariantBcsBase64(),
            signatures: signatures.map((e) => e.toVariantBcsBase64()).toList(),
            options: const SuiApiTransactionBlockResponseOptions(
                showEffects: true)));
    final response = MethodUtils.nullOnException(
        () => SuiApiTransactionBlockResponse.fromJson(excute));
    if (response != null) {
      return SuiExcuteTransactionData(
          digest: response.digest,
          rawTransactionData: response.rawTransaction,
          error: response.effects?.status.status !=
                  SuiApiExecutionStatusType.success
              ? response.effects?.status.error
              : null,
          effects: response.toJson());
    }
    return SuiExcuteTransactionData(
        digest: excute["digest"] ?? tx.txHash(),
        rawTransactionData: excute["rawTransaction"],
        error: excute["effects"]?["status"]?["error"],
        effects: excute);
  }

  Future<SuiExcuteTransactionData> executeWeb3Transaction({
    required String transactionBcs,
    required List<String> signatures,
    final SuiApiTransactionBlockResponseOptions? options,
    final SuiApiExecuteTransactionRequestType? type,
  }) async {
    final excute = await provider.requestDynamic(
        SuiRequestExecuteTransactionBlock(
            txBytes: transactionBcs,
            signatures: signatures,
            type: type,
            options: options ??
                const SuiApiTransactionBlockResponseOptions(
                    showEffects: true)));
    final response = MethodUtils.nullOnException(
        () => SuiApiTransactionBlockResponse.fromJson(excute));
    if (response != null) {
      return SuiExcuteTransactionData(
          digest: response.digest,
          rawTransactionData: response.rawTransaction,
          error: response.effects?.status.status !=
                  SuiApiExecutionStatusType.success
              ? response.effects?.status.error
              : null,
          effects: response.toJson());
    }
    return SuiExcuteTransactionData(
        digest: excute["digest"],
        rawTransactionData: excute["rawTransaction"],
        error: excute["effects"]?["status"]?["error"],
        effects: excute);
  }

  Future<SuiApiMoveNormalizedFunction> normalizeFunction(
      {required String package,
      required String moduleName,
      required String functionName}) async {
    final normalizedFunction = await provider.request(
        SuiRequestGetNormalizedMoveFunction(
            functionName: functionName,
            moduleName: moduleName,
            package: package));
    return normalizedFunction;
  }

  Future<List<SuiToken>> getAccountTokens(SuiAddress address,
      {bool allowSuiCoin = false}) async {
    final all =
        await provider.request(SuiRequestGetAllBalances(owner: address));
    List<SuiToken> tokens = [];
    for (final i in all) {
      if (!allowSuiCoin && i.coinType == SuiTransactionConst.suiTypeArgs) {
        continue;
      }
      final metadata = await provider
          .request(SuiRequestGetCoinMetadata(coinType: i.coinType));
      final token = SuiToken.create(
          balance: i.totalBalance,
          token: Token(
              name: metadata.name,
              symbol: metadata.symbol,
              decimal: metadata.decimals,
              assetLogo: APPImage.network(metadata.iconUrl)),
          assetType: i.coinType);
      tokens.add(token);
    }
    return tokens;
  }

  Future<List<SuiApiCoinResponse>> getAccountSuiCoins(
      SuiAddress address) async {
    List<SuiApiCoinResponse> coins = [];
    String? cursor;
    while (true) {
      final r = await provider.request(SuiRequestGetCoins(
          coinType: SuiTransactionConst.suiTypeArgs,
          owner: address,
          pagination: SuiApiRequestPagination(cursor: cursor)));
      coins.addAll(r.data);
      cursor = r.nextCursor;
      if (!r.hasNextPage) {
        break;
      }
    }
    return coins;
  }

  Future<List<SuiApiCoinResponse>> getAccountCoins(SuiAddress address) async {
    List<SuiApiCoinResponse> coins = [];
    String? cursor;
    while (true) {
      final r = await provider.request(SuiRequestGetAllCoins(
          owner: address, pagination: SuiApiRequestPagination(cursor: cursor)));
      coins.addAll(r.data);
      cursor = r.nextCursor;
      if (!r.hasNextPage) {
        break;
      }
    }
    return coins;
  }

  Future<Map<SuiAddress, SuiApiGetDynamicFieldObjectResponse>> getObjects(
      List<SuiAddress> objectIds) async {
    final lists = ListUtils.splitList(objectIds);
    Map<SuiAddress, SuiApiGetDynamicFieldObjectResponse> response = {};
    for (final i in lists) {
      final r = await provider.request(SuiRequestMultiGetObjects(
          objectIds: i.map((e) => e.address).toList(),
          options: SuiApiObjectDataOptions(showOwner: true)));
      response.addAll({for (int j = 0; j < i.length; j++) i[j]: r[j]});
    }
    return response;
  }

  Future<List<SuiApiCoinResponse>> getCachedAccountCoins(
      SuiAddress address) async {
    // final coin = _cachedAccountCoins[address];
    // if (coin?.isValue ?? false) return coin!.coinData;
    final r = await getAccountCoins(address);
    _cachedAccountCoins[address] = SuiCachedAccountCoins(r);
    return _cachedAccountCoins[address]!.coinData;
  }

  Future<SuiTransactionDataV1> filledGasPayment(
      SuiTransactionDataV1 transaction) async {
    List<SuiApiCoinResponse> coins =
        await getCachedAccountCoins(transaction.gasData.owner);
    coins = coins
        .where((e) => e.coinType == SuiTransactionConst.suiTypeArgs)
        .toList();

    final kind =
        transaction.kind.cast<SuiTransactionKindProgrammableTransaction>();
    final ownedObjectAddresses = kind.transaction.inputs
        .whereType<SuiCallArgObject>()
        .map((e) => e.object)
        .whereType<SuiObjectArgImmOrOwnedObject>()
        .map((e) => e.immOrOwnedObject.address);

    final filterCoins = coins
        .where((e) => !ownedObjectAddresses.contains(e.coinObjectId))
        .map((e) => e.toObjectRef())
        .toList();
    if (filterCoins.isEmpty) {
      throw WalletException("leak_of_gas_token_desc");
    }
    return transaction.copyWith(
        gasData: transaction.gasData.copyWith(payment: filterCoins));
  }

  @override
  NetworkType get networkType => NetworkType.sui;

  Future<bool> validateNetworkIdentifier() async {
    final identifier = await provider.request(SuiRequestGetChainIdentifier());
    if (network == null) return false;
    if (network!.coinParam.suiChain != SuiChainType.devnet) {
      return identifier == network!.coinParam.identifier;
    }
    return identifier != SUIConst.mainnetIdentifier &&
        identifier != SUIConst.testnetIdentifier;
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    try {
      final identifier = await provider.requestDynamic(
          SuiRequestGetTransactionBlock(
              transactionDigest: txId,
              options:
                  SuiApiTransactionBlockResponseOptions(showEffects: true)));
      final tx = MethodUtils.nullOnException(
          () => SuiApiTransactionBlockResponse.fromJson(identifier));
      assert(tx != null, 'parsing sui tx failed');
      if (tx != null &&
          tx.effects?.status.status == SuiApiExecutionStatusType.failure) {
        return WalletTransactionStatus.failed;
      }
      return WalletTransactionStatus.block;
    } catch (_) {
      return WalletTransactionStatus.unknown;
    }
  }

  @override
  Future<bool> onInit() {
    return validateNetworkIdentifier();
  }
}
