import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/impl/worker_impl.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/solana.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/constant/networks/solana.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/solana/models/solana_account_tokens_info.dart';
import 'package:on_chain_wallet/wallet/models/token/token.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/solana.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class SolanaClient
    extends NetworkClient<SolanaWalletTransaction, SolanaAPIProvider>
    with CryptoWokerImpl, HttpImpl
    implements BaseSwapSolanaClient {
  SolanaClient({required this.provider, required this.network});
  final SolanaProvider provider;
  @override
  final WalletSolanaNetwork network;
  @override
  SolanaHTTPService get service => provider.rpc as SolanaHTTPService;
  List<SolanaTokenInfo>? _tokenLists;

  Future<BigInt> getAccountBalance(SolAddress address) async {
    final accountInfo = await getAccountInfo(address);
    return accountInfo?.lamports ?? BigInt.zero;
  }

  @override
  Future<SolanaAccountInfo?> getAccountInfo(SolAddress account) async {
    final info =
        await provider.request(SolanaRequestGetAccountInfo(account: account));
    return info;
  }

  Future<SolanaTokenAccount?> getTokenAccount(SolAddress account) async {
    final info =
        await provider.request(SolanaRPCGetTokenAccount(account: account));
    return info;
  }

  Future<BigInt> getRent(int space) async {
    final lamports = await provider
        .request(SolanaRequestGetMinimumBalanceForRentExemption(size: space));
    return lamports;
  }

  Future<BigInt?> getFee(SolanaTransaction transaction) async {
    return await provider.request(SolanaRequestGetFeeForMessage(
        encodedMessage: StringUtils.decode(transaction.message.serialize(),
            type: StringEncoding.base64),
        commitment: Commitment.processed));
  }

  @override
  Future<SimulateTranasctionResponse> simulate(
      {required SolanaTransaction transaction,
      SolAddress? account,
      bool replaceRecentBlockhash = true,
      bool sigVerify = false,
      Commitment? commitment = Commitment.processed,
      MinContextSlot? minContextSlot}) async {
    return await provider.request(
      SolanaRequestSimulateTransaction(
          encodedTransaction: transaction.serializeString(
              encoding: TransactionSerializeEncoding.base64),
          sigVerify: sigVerify,
          replaceRecentBlockhash: replaceRecentBlockhash,
          encoding: SolanaRequestEncoding.base64,
          commitment: Commitment.processed,
          minContextSlot: minContextSlot,
          accounts: account == null
              ? null
              : RPCAccountConfig(
                  addresses: [account],
                  encoding: SolanaRequestEncoding.base64)),
    );
  }

  Future<List<SolanaTokenInfo>> getTokenList() async {
    if (_tokenLists != null) return _tokenLists!;
    final result = await MethodUtils.call(() async {
      final result = await httpGet<Map<String, dynamic>>(
          SolanaConst.tokenListUri,
          responseType: HTTPResponseType.map);
      final Map<String, dynamic> data = result.result;
      final tokenJson = (data["tokens"] as List).cast<Map<String, dynamic>>();
      final List<SolanaTokenInfo> tokenList = [];
      for (final i in tokenJson) {
        if (i["chainId"] != network.coinParam.chainId) continue;
        tokenList.add(SolanaTokenInfo.fromJson(i));
      }
      return tokenList;
    });
    if (result.hasError) {
      assert(false, "should not be failed.");
      return [];
    }
    _tokenLists = result.result;
    return _tokenLists!;
  }

  @override
  Future<SolAddress> getBlockHash() async {
    final blockHash =
        await provider.request(const SolanaRequestGetLatestBlockhash());
    return blockHash.blockhash;
  }

  Future<String> getGenesisHash() async {
    final gnesisHash = await provider.request(SolanaRequestGetGenesisHash());
    return gnesisHash;
  }

  Future<List<ContactInfo>> clusterNodes() async {
    final gnesisHash = await provider.request(SolanaRequestGetClusterNodes());
    return gnesisHash;
  }

  Future<BigInt> getTokenAddressBalance(SolAddress address) async {
    final account =
        await provider.request(SolanaRPCGetTokenAccount(account: address));
    return account?.amount ?? BigInt.zero;
  }

  Future<List<SolanaAccountSPLTokenInfo>> getAccountTokens(SolAddress account,
      {SolAddress tokenProgram = SPLTokenProgramConst.tokenProgramId}) async {
    final List<SolanaAccountSPLTokenInfo> tokens = [];
    final tokenAccounts = await provider.request(
        SolanaRequestGetTokenAccountsByOwner(
            account: account,
            programId: tokenProgram,
            encoding: SolanaRequestEncoding.base64));
    if (tokenAccounts.isEmpty) return [];
    for (final i in tokenAccounts) {
      final mint = await provider
          .request(SolanaRPCGetMintAccount(account: i.tokenAccount.mint));
      final splToken =
          await _createSplTokenInfo(mintAccount: mint!, tokenAccount: i);
      tokens.add(splToken);
    }
    return tokens;
  }

  Future<SolanaAccountSPLTokenInfo> _createSplTokenInfo(
      {required SolanaMintAccount mintAccount,
      required TokenAccountResponse tokenAccount}) async {
    final mintAddress = tokenAccount.tokenAccount.mint;
    SolanaTokenInfo? tokenInfo;
    final metadatPda =
        MetaplexTokenMetaDataProgramUtils.findMetadataPda(mint: mintAddress);
    final tokenMetadata = await MethodUtils.call(() async => provider
        .request(SolanaRPCGetMetadataAccount(account: metadatPda.address)));
    if (tokenMetadata.hasResult && tokenMetadata.result != null) {
      tokenInfo = SolanaTokenInfo.fromOnChainMetadata(tokenMetadata.result!);
    } else {
      final metadatas = await getTokenList();
      tokenInfo =
          metadatas.firstWhereOrNull((e) => e.address == mintAddress.address);
    }
    APPImage? image = APPImage.network(tokenInfo?.logoURI);
    final token = Token(
        assetLogo: image,
        decimal: mintAccount.decimals,
        name: tokenInfo?.name ?? mintAddress.address,
        symbol: tokenInfo?.symbol ?? mintAddress.address);
    return SolanaAccountSPLTokenInfo(
        amount: tokenAccount.tokenAccount.amount,
        mintAddress: mintAddress,
        token: token,
        pubkey: tokenAccount.pubkey,
        tokenOwner: tokenAccount.account.owner);
  }

  @override
  Future<String> sendTransaction(SolanaTransaction transaction,
      {int? maxRetries,
      bool skipPreflight = false,
      int? minContextSlot,
      Commitment? commitment,
      SolanaRequestEncoding encoding = SolanaRequestEncoding.base64}) async {
    return await provider.request(SolanaRequestSendTransaction(
        encodedTransaction: transaction.serializeString(
          encoding: encoding == SolanaRequestEncoding.base64
              ? TransactionSerializeEncoding.base64
              : TransactionSerializeEncoding.base58,
        ),
        encoding: encoding,
        skipPreflight: skipPreflight,
        maxRetries: maxRetries,
        commitment: skipPreflight ? Commitment.processed : commitment,
        minContextSlot: minContextSlot == null
            ? null
            : MinContextSlot(slot: minContextSlot)));
  }

  Future<bool> validateNetworkGenesis() async {
    final result = await getGenesis();
    return result == network.genesisBlock;
  }

  @override
  Future<BigInt> getBalance(SolAddress address) async {
    final accountInfo = await getAccountInfo(address);
    return accountInfo?.lamports ?? BigInt.zero;
  }

  @override
  Future<String> getGenesis() async {
    return await provider.request(SolanaRequestGetGenesisHash());
  }

  @override
  Future<SignatureStatus?> getSignatureStatuses(String signature) async {
    final statuses = await provider
        .request(SolanaRequestGetSignatureStatuses(signatures: [signature]));
    return statuses.elementAtOrNull(0);
  }

  @override
  Future<SolanaTokenPDAInfo> getTokenAccountAddress(
      {required SolAddress account,
      required SolAddress mint,
      SolAddress? tokenProgramId}) async {
    if (tokenProgramId == null) {
      final mintAccount = await getAccountInfo(mint);
      if (mintAccount == null) {
        throw WalletException("mint_account_not_found");
      }
      tokenProgramId = mintAccount.owner;
      if (tokenProgramId != SPLTokenProgramConst.token2022ProgramId &&
          tokenProgramId != SPLTokenProgramConst.tokenProgramId) {
        throw WalletException("invalid_mint_account_owner");
      }
    }
    final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mint,
        owner: account,
        tokenProgramId: tokenProgramId,
        allowOwnerOffCurve: true);
    return SolanaTokenPDAInfo(
        address: account,
        pdaAddress: pda.address,
        tokenProgramId: tokenProgramId);
  }

  @override
  Future<TransactionConfirmationStatus> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 1),
      Duration periodicTimeOut = const Duration(seconds: 2)}) async {
    Timer? timer;
    try {
      final Completer<TransactionConfirmationStatus> completer =
          Completer<TransactionConfirmationStatus>();
      timer = Timer.periodic(periodicTimeOut, (t) async {
        final receipt = await getSignatureStatuses(transactionId);
        if (receipt != null) {
          if (receipt.err != null) {
            completer.completeError(
                WalletException("transaction_confirmation_failed"));
          } else {
            final status = receipt.confirmationStatus;
            if (status == TransactionConfirmationStatus.finalized) {
              completer.complete(status);
            }
          }
        }
      });
      final receipt = await completer.future.timeout(timeout);
      return receipt;
    } on TimeoutException {
      throw WalletException("transaction_confirmation_failed");
    } finally {
      timer?.cancel();
      timer = null;
    }
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
  Future<SwapSolanaAccountAssetBalance> getAccountsAssetBalance(
      SolanaSwapAsset asset, SolAddress account) async {
    if (asset.isContract && asset.contractAddress == null) {
      throw WalletException("invalid_swap_asset");
    }
    return SwapSolanaAccountAssetBalance(
        address: account,
        balance: asset.isNative
            ? await getBalance(account)
            : await getTokenBalance(
                account: account, mint: asset.contractAddress!),
        asset: asset);
  }

  @override
  Future<BigInt> getTokenBalance(
      {required SolAddress account,
      required SolAddress mint,
      SolAddress? tokenProgramId}) async {
    final address = await getTokenAccountAddress(
        account: account, mint: mint, tokenProgramId: tokenProgramId);
    return await getTokenAddressBalance(address.pdaAddress);
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    final status = await getSignatureStatuses(txId);
    if (status == null) return WalletTransactionStatus.unknown;
    if (status.err != null) return WalletTransactionStatus.failed;
    if (status.confirmationStatus == TransactionConfirmationStatus.finalized) {
      return WalletTransactionStatus.block;
    }
    return WalletTransactionStatus.pending;
  }

  @override
  Future<BigInt> getBlockHeight() async {
    final block = await provider
        .request(SolanaRequestGetBlockHeight(commitment: Commitment.finalized));
    return BigInt.from(block);
  }

  @override
  Future<bool> onInit() async {
    final result =
        await MethodUtils.call(() async => await validateNetworkGenesis());
    return result.hasResult && result.result;
  }

  @override
  void dispose() {
    super.dispose();
    _tokenLists = null;
  }

  @override
  NetworkType get networkType => NetworkType.solana;
}
