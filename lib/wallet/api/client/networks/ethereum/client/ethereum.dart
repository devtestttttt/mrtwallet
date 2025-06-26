import 'dart:async';

import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/ethereum/methods/methods.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/networks/ethereum/etherum.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/crypto/utils/solidity/solidity.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class EthereumClient
    extends NetworkClient<EthWalletTransaction, EthereumAPIProvider>
    implements BaseSwapEthereumClient {
  EthereumClient({required this.provider, required this.network});
  @override
  final EthereumProvider provider;
  @override
  final WalletNetwork? network;
  @override
  NetworkServiceProtocol<EthereumAPIProvider> get service =>
      provider.rpc as NetworkServiceProtocol<EthereumAPIProvider>;

  Future<FeeHistorical> getHistoricalFee() async {
    final historical = await provider.request(EthereumRequestGetFeeHistory(
        blockCount: 10,
        newestBlock: BlockTagOrNumber.latest,
        rewardPercentiles: [30, 60, 99]));
    return historical!.toFee();
  }

  Future<(BigInt, bool)> getNetworkInfo() async {
    final BigInt chainId = await provider.request(EthereumRequestGetChainId());
    try {
      final eip = await provider.request(EthereumRequestGetFeeHistory(
          blockCount: 25,
          newestBlock: BlockTagOrNumber.pending,
          rewardPercentiles: [25, 50, 90]));
      return (chainId, eip != null);
    } on RPCError {
      return (chainId, false);
    }
  }

  Future<BigInt> gasPrice() async {
    final historical = await provider.request(EthereumRequestGetGasPrice());
    return historical;
  }

  Future<BigInt> estimateGasLimit(Map<String, dynamic> estimateDetails) async {
    final estimate = await provider
        .request(EthereumRequestEstimateGas(transaction: estimateDetails));
    return estimate;
  }

  Future<int> getAccountNonce(ETHAddress account) async {
    final nonce = await provider
        .request(EthereumRequestGetTransactionCount(address: account.address));
    return nonce;
  }

  Future<String> sendRawTransaction(String digest) async {
    final txID = await provider
        .request(EthereumRequestSendRawTransaction(transaction: digest));
    return txID;
  }

  Future<bool> isContract(SolidityAddress address) async {
    final code = await provider
        .request(EthereumRequestGetCode(address: address.toHex()));
    return code != null;
  }

  Future<dynamic> dynamicCall({required String method, dynamic params}) async {
    return await provider.requestDynamic(
        EthereumRequestDynamic(methodName: method, params: params));
  }

  Future<Token?> getErc20Details(SolidityAddress contractAddress) async {
    try {
      final decimal = await provider.request(RPCERC20Decimal(contractAddress,
          blockNumber: BlockTagOrNumber.latest));
      if (decimal == null) return null;
      String? name;
      String? symbol;

      final symbolQuery = await MethodUtils.call(() async =>
          await provider.request(RPCERC20Symbol(contractAddress,
              blockNumber: BlockTagOrNumber.latest)));
      if (symbolQuery.hasResult) {
        symbol = symbolQuery.result;
      }
      final nameQuery = await MethodUtils.call(() async =>
          await provider.request(RPCERC20Name(contractAddress,
              blockNumber: BlockTagOrNumber.latest)));
      if (nameQuery.hasResult) {
        name = nameQuery.result;
      }
      name ??= symbol;
      symbol ??= name;
      return Token(
          name: name ?? "Unknown",
          symbol: symbol ?? "Unknown",
          decimal: decimal);
    } on RPCError {
      return null;
    }
  }

  Future<(ContractABI, SolidityContractInterface)?> detectContractAbi({
    required SolidityAddress contractAddress,
    required SolidityAddress from,
  }) async {
    SolidityContractInterface interface = SolidityContractInterface.none;
    for (final i in SolidityContractInterface.values) {
      try {
        final support = await provider.request(RPCDetectContactInterface(
            interface: i, contractAddress: contractAddress, from: from));
        if (support) {
          interface = i;
          break;
        }
      } on RPCError catch (_) {
        break;
      } catch (_) {}
    }
    final assetPath = interface.getContractAssetPath;
    if (assetPath == null) return null;
    final contractJson = await PlatformUtils.loadAssetText(assetPath);
    return (
      ContractABI.fromJson(StringUtils.toJson<List>(contractJson)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()),
      interface
    );
  }

  Future<EthereumTransactionDataInfo>
      _getTransactionContractInfo<NETWORKADDRESS extends SolidityAddress>(
          {required ContractABI? contract,
          required SolidityAddress contractAddress,
          required SolidityAddress account,
          required Chain chain,
          required List<int> data,
          required String dataHex,
          required List<int> selector,
          required SolidityContractInterface? interface}) async {
    if (contract == null || interface == SolidityContractInterface.erc20) {
      final token = await getAccountERC20Token(account, contractAddress);
      if (token != null) {
        if (BytesUtils.bytesEqual(
            selector, SolidityContractUtils.erc20Transfer.selector)) {
          final decodeTransfer = MethodUtils.nullOnException(() {
            final decode = SolidityContractUtils.decodeErc20Transfer(data);
            if (chain.network.type == NetworkType.tron) {
              return (decode.a.toTronAddress(), decode.b);
            }
            return (decode.a.toEthereumAddress(), decode.b);
          });
          if (decodeTransfer != null) {
            final to = chain.getReceiptAddress(decodeTransfer.$1.toString()) ??
                ReceiptAddress<NETWORKADDRESS>(
                    view: decodeTransfer.$1.toString(),
                    networkAddress: decodeTransfer.$1 as NETWORKADDRESS);
            return SolidityERC20TransferMethodInfo<NETWORKADDRESS>(
                selector: selector,
                token: token,
                to: to as ReceiptAddress<NETWORKADDRESS>,
                value: IntegerBalance.token(decodeTransfer.$2, token.token),
                dataHex: dataHex);
          }
        }
        if (contract == null) {
          final contractJson = await PlatformUtils.loadAssetText(
              SolidityContractInterface.erc20.getContractAssetPath!);
          contract = ContractABI.fromJson(StringUtils.toJson<List>(contractJson)
              .map((e) => Map<String, dynamic>.from(e))
              .toList());
        }
      }
    }
    final method = MethodUtils.nullOnException(() {
      final method = contract?.findFunctionFromSelector(selector);
      final decodeInput = method?.decodeInput(data);
      if (decodeInput != null) {
        return SolidityNameAndInputValues(
            selector: selector, inputs: decodeInput, name: method!.name);
      }
      return null;
    });
    return method ??
        SolidityUnknownMethodInfo(selector: selector, dataHex: dataHex);
  }

  Future<EthereumTransactionDataInfo>
      getTransactionContractInfo<NETWORKADDRESS extends SolidityAddress>(
          {required SolidityAddress account,
          required SolidityAddress contractAddress,
          required Chain chain,
          required List<int> data}) async {
    final dataHex = BytesUtils.toHexString(data, prefix: "0x");
    final selector = SolidityContractUtils.getSelector(data);
    if (selector == null) {
      return SolidityUnknownMethodInfo(selector: data, dataHex: dataHex);
    }
    final contract = await detectContractAbi(
        contractAddress: contractAddress, from: account);
    return _getTransactionContractInfo<NETWORKADDRESS>(
        contract: contract?.$1,
        contractAddress: contractAddress,
        account: account,
        chain: chain,
        data: data,
        interface: contract?.$2,
        selector: selector,
        dataHex: dataHex);
  }

  Future<SolidityToken?> getAccountERC20Token(
      SolidityAddress account, SolidityAddress contractAddress) async {
    final token = await getErc20Details(contractAddress);
    if (token == null) return null;
    final balance = await provider
        .request(RPCERC20TokenBalance(contractAddress.toHex(), account));
    if (contractAddress is TronAddress) {
      return TronTRC20Token.create(
          balance: balance, token: token, contractAddress: contractAddress);
    }
    return ETHERC20Token.create(
        balance: balance,
        token: token,
        contractAddress: contractAddress as ETHAddress);
  }

  Future<Web3EthereumTransactionRequestInfos> getWeb3TransactionInfos(
      {required IEthAddress from,
      required Web3EthreumSendTransaction transaction,
      required EthereumChain chain}) async {
    final ReceiptAddress<ETHAddress>? destination = transaction.to != null
        ? chain.getReceiptAddress(transaction.to!.address) ??
            ReceiptAddress<ETHAddress>(
                view: transaction.to!.address, networkAddress: transaction.to!)
        : null;
    EthereumTransactionDataInfo? contractInfos;
    ETHTransactionType? type = transaction.transactionType;
    if (type == null) {
      type = chain.network.coinParam.supportEIP1559
          ? ETHTransactionType.eip1559
          : ETHTransactionType.legacy;
    } else if (type == ETHTransactionType.eip2930 &&
        transaction.gasPrice == null &&
        chain.network.coinParam.supportEIP1559) {
      type = ETHTransactionType.eip1559;
    }
    if (transaction.to != null) {
      final bool isSmartContract = await isContract(transaction.to!);
      if (!isSmartContract) {
        return Web3EthereumTransactionRequestInfos(
            transaction: transaction,
            destination: destination,
            type: type,
            contractInfo: transaction.data.isEmpty
                ? null
                : UnknownTransactionData.fromBytes(transaction.data),
            network: chain.network);
      }
      contractInfos = await getTransactionContractInfo(
          account: from.networkAddress,
          contractAddress: transaction.to!,
          data: transaction.data,
          chain: chain);
    }
    if (transaction.to == null && transaction.data.isNotEmpty) {
      contractInfos ??= SolidityCreationContract();
    } else if (transaction.data.isNotEmpty) {
      contractInfos ??= UnknownTransactionData.fromBytes(transaction.data);
    }

    return Web3EthereumTransactionRequestInfos(
        transaction: transaction,
        destination: destination,
        type: type,
        contractInfo: contractInfos,
        network: chain.network);
  }

  @override
  Future<BigInt> getChainId() async {
    return await provider.request(EthereumRequestGetChainId());
  }

  Future<bool> checkNetworkChainId() async {
    if (network?.type != NetworkType.ethereum) return false;
    final networkChainId =
        network!.toNetwork<WalletEthereumNetwork>().coinParam.chainId;
    final chainId = await getChainId();
    return chainId == networkChainId;
  }

  @override
  Future<BigInt> getAllowance(
      {required ETHAddress contract,
      required ETHAddress owner,
      required ETHAddress spender}) async {
    final function = EthereumAbiCons.getAllowance;
    final result = await provider.request(EthereumRequestCall.fromMethod(
        contractAddress: contract.address,
        function: function,
        params: [owner, spender]));
    return (result as List)[0];
  }

  @override
  Future<BigInt> getBalance(ETHAddress address) async {
    return await provider
        .request(EthereumRequestGetBalance(address: address.address));
  }

  @override
  Future<BigInt> getTokenBalance(
      {required SolidityAddress address,
      required SolidityAddress contract}) async {
    return await provider
        .request(RPCERC20TokenBalance(contract.toHex(), address));
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    final receipt = await provider
        .request(EthereumRequestGetTransactionReceipt(transactionHash: txId));
    if (receipt == null) return WalletTransactionStatus.unknown;
    final status = receipt.status;
    if (status != null && !status) {
      return WalletTransactionStatus.failed;
    }
    return WalletTransactionStatus.block;
  }

  @override
  Future<TransactionReceipt> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 5),
      Duration periodicTimeOut = const Duration(seconds: 3)}) async {
    Timer? timer;
    try {
      final Completer<TransactionReceipt> completer =
          Completer<TransactionReceipt>();
      timer = Timer.periodic(periodicTimeOut, (t) async {
        final receipt = await provider
            .request(EthereumRequestGetTransactionReceipt(
                transactionHash: transactionId))
            .catchError((e, s) {
          return null;
        });
        if (receipt != null && !completer.isCompleted) {
          completer.complete(receipt);
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
  Future<SwapEthereumAccountAssetBalance> getAccountsAssetBalance(
      ETHSwapAsset asset, ETHAddress account) async {
    if (asset.isContract && asset.contractAddress == null) {
      throw WalletException("invalid_swap_asset");
    }

    return SwapEthereumAccountAssetBalance(
        address: account,
        balance: asset.isNative
            ? await getBalance(account)
            : await getTokenBalance(
                address: account, contract: asset.contractAddress!),
        asset: asset);
  }

  @override
  Future<BigInt?> getBlockHeight() async {
    final block = await provider.request(EthereumRequestGetBlockNumber());
    return BigInt.from(block);
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
  Future<bool> onInit() async {
    if (network?.type == NetworkType.ethereum) {
      final result = await MethodUtils.call(() async {
        final BigInt chainId =
            await provider.request(EthereumRequestGetChainId());
        return chainId;
      });
      return result.hasResult &&
          result.result ==
              network?.toNetwork<WalletEthereumNetwork>().coinParam.chainId;
    }
    return false;
  }

  @override
  NetworkType get networkType => NetworkType.ethereum;
}
