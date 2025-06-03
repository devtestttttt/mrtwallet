import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';

import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:on_chain/solana/src/transaction/transaction/transaction.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SwapTransactionStateController extends StateController {
  SwapTransactionStateController({required this.route, required this.wallet});
  final WalletProvider wallet;
  final APPSwapRoute route;
  List<ChainAccount> get sources => route.sources;
  ReceiptAddress get destAddress => route.destAddress;
  final _lock = SynchronizedLock();
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  TransactionOperationStep? _step;
  TransactionOperationStep? get step => _step;

  void reset() {
    progressKey.backToIdle();
    _step = null;
    notify();
  }

  bool get inProgress => _step != null;
  SwapNetwork get network => route.route.route.quote.sourceAsset.network;
  Future<bool> onPop(FuncFutureNullableBoold callback) async {
    if (allowPop) return true;
    final pop = await callback();
    if (pop == true) {
      allowPop = true;
      notify();
      return MethodUtils.after(() async => true);
    }
    return false;
  }

  String? _latestError;
  String? get latestError => _latestError;
  bool allowPop = false;
  void _onUpdateState(TransactionOperationStep step,
      {String? transactionHash}) {
    _step = step;

    if (step == TransactionOperationStep.txHash) {
      allowPop = true;
      progressKey.success(
          backToIdle: false,
          progressWidget: SuccessTransactionTextView(
              txIds: [transactionHash ?? ''],
              network: route.sourceChain.network));
    }
    notify();
  }

  Future<void> _signTransaction(
      StreamController<(TransactionOperationStep, String?)>
          onUpdateState) async {
    final transaction = route.transaction;
    final source = route.sourceChain;
    final client = await source.client();
    final accounts = route.sources;
    void statusChanged(TransactionOperationStep step,
        {String? transactionHash}) {
      assert(!onUpdateState.isClosed);
      onUpdateState.add((step, transactionHash));
    }

    switch (transaction.runtimeType) {
      case const (SwapRouteEthereumTransactionBuilder):
        return await (transaction as SwapRouteEthereumTransactionBuilder)
            .buildTransactions(
                stepsCallBack: statusChanged,
                client: (network) async {
                  return client as BaseSwapEthereumClient;
                },
                signer: (e) async {
                  final ethChain = route.sourceChain.cast<EthereumChain>();
                  return SwapWeb3SignerEthereum(
                      onSign: (e) async {
                        final r = Web3EthreumSendTransaction(
                            account: Web3EthereumChainAccount.fromChainAccount(
                                address: accounts.first.cast<IEthAddress>(),
                                id: ethChain.network.value,
                                defaultAddress: true),
                            to: e.to,
                            value: e.value,
                            gas: e.gasLimit?.toInt(),
                            data: BytesUtils.fromHexString(e.data),
                            chainId: e.chainId,
                            gasPrice: e.gasPrice,
                            maxPriorityFeePerGas: e.maxPriorityFeePerGas,
                            maxFeePerGas: e.maxFeePerGas);
                        return wallet.wallet.localWeb3Request(r);
                      },
                      onSigner: () async => accounts
                          .map((e) => e.networkAddress)
                          .cast<ETHAddress>()
                          .toList());
                });
      case const (SwapRouteCosmosTransactionBuilder):
        return await (transaction as SwapRouteCosmosTransactionBuilder)
            .buildTransactions(
                stepsCallBack: statusChanged,
                client: (network) async => client as BaseSwapCosmosClient,
                signer: (e) async {
                  return SwapWeb3SignerCosmos(onSigner: () async {
                    final cosmosAccounts = accounts.cast<ICosmosAddress>();
                    return cosmosAccounts
                        .map((e) => CosmosSpenderAddress(
                            address: e.networkAddress,
                            publicKey: e.toCosmosPublicKey()))
                        .toList();
                  }, onSign: (e) async {
                    final cosmosChain = route.sourceChain.cast<CosmosChain>();
                    final transaction = Web3CosmosSignTransactionDirectParams(
                        bodyBytes: e.signDoc.bodyBytes,
                        authInfos: e.signDoc.authInfoBytes,
                        accountNumber: e.signDoc.accountNumber);
                    final params = Web3CosmosSignTransaction(
                        account: Web3CosmosChainAccount.fromChainAccount(
                            address: accounts.first.cast<ICosmosAddress>(),
                            id: cosmosChain.network.value,
                            isDefault: false),
                        chainId: e.signDoc.chainId,
                        transaction: transaction);
                    final signature = (await wallet.wallet
                            .localWeb3Request(params))
                        .cast<Web3CosmosSignTransactionDirectSignResponse>();
                    return CosmosSignResponse(
                        bodyBytes: signature.bodyBytes,
                        authBytes: signature.authInfoBytes,
                        signature: signature.signature);
                  });
                });
      case const (SwapRouteSubstrateTransactionBuilder):
        return await (transaction as SwapRouteSubstrateTransactionBuilder)
            .buildTransactions(
                stepsCallBack: statusChanged,
                client: (network) async => client as BaseSwapSubstrateClient,
                signer: (e) async {
                  return SwapWeb3SignerSubstrate(
                      onSigner: () async => accounts
                          .map((e) => e.networkAddress)
                          .cast<BaseSubstrateAddress>()
                          .toList(),
                      onSign: (e) async {
                        final substrateChain =
                            route.sourceChain.cast<SubstrateChain>();
                        final param = Web3SubstrateSendTransaction(
                            json: e.toJson(),
                            address: Web3SubstrateChainAccount.fromChainAccount(
                                address: accounts.first.cast(),
                                id: substrateChain.network.value,
                                isDefault: false));
                        final signature =
                            (await wallet.wallet.localWeb3Request(param));
                        return signature.signature;
                      });
                });
      case const (SwapRouteSolanaTransactionBuilder):
        return await (transaction as SwapRouteSolanaTransactionBuilder)
            .buildTransactions(
                stepsCallBack: statusChanged,
                client: (network) async => client as BaseSwapSolanaClient,
                signer: (e) async {
                  return SwapWeb3SignerSolana(
                      onSigner: () async => accounts
                          .map((e) => e.networkAddress)
                          .cast<SolAddress>()
                          .toList(),
                      onSign: (e) async {
                        final substrateChain =
                            route.sourceChain.cast<SolanaChain>();
                        final param = Web3SolanaSendTransaction(messages: [
                          Web3SolanaSendTransactionData(
                              account: Web3SolanaChainAccount.fromChainAccount(
                                  address: accounts.first.cast(),
                                  id: substrateChain.network.value,
                                  network:
                                      substrateChain.network.coinParam.type,
                                  isDefault: false),
                              messageByte: e.v0.serialize(),
                              sendConfig: null)
                        ], method: Web3SolanaRequestMethods.signTransaction);
                        final signedTransactions =
                            (await wallet.wallet.localWeb3Request(param));
                        return SolanaTransaction.deserialize(
                            signedTransactions.elementAt(0));
                      });
                });
      case const (SwapRouteBitcoinTransactionBuilder):
        final btcAccounts = accounts.cast<IBitcoinAddress>();
        final network =
            source.cast<BitcoinChain>().network.coinParam.transacationNetwork;
        final bitcoinClient = (client as BitcoinClient).clone();
        try {
          return await (transaction as SwapRouteBitcoinTransactionBuilder)
              .buildTransactions(
                  stepsCallBack: statusChanged,
                  client: (network) async =>
                      bitcoinClient as BaseSwapBitcoinClient,
                  signer: (e) async {
                    return SwapWeb3SignerBitcoin(onSigner: () async {
                      return btcAccounts.map((e) {
                        return BitcoinSpenderAddress(
                            address: BitcoinNetworkAddress.fromBaseAddress(
                                address: e.networkAddress, network: network),
                            taprootInternal: e.xOnly(),
                            witnessScript: e.witnessScript(),
                            p2shreedemScript: e.redeemScript());
                      }).toList();
                    }, onSendPayment: (e) async {
                      final bitcoinChain =
                          route.sourceChain.cast<BitcoinChain>();
                      final param = Web3BitcoinSendTransaction(
                          requiredAccount:
                              Web3BitcoinChainAccount.fromChainAccount(
                                  address: accounts
                                      .firstWhere((i) =>
                                          i.address.address ==
                                          e.source.address.toAddress())
                                      .cast(),
                                  isDefault: false,
                                  network: bitcoinChain.network),
                          outputs: e.outputs
                              .map((e) => Web3BitcoinSendTransactionOutput(
                                  value: e.value,
                                  scriptPubKey: e.script,
                                  address: e.address))
                              .toList(),
                          accounts: btcAccounts
                              .map((e) =>
                                  Web3BitcoinChainAccount.fromChainAccount(
                                      address: e,
                                      isDefault: false,
                                      network: bitcoinChain.network))
                              .toList());
                      return await wallet.wallet.localWeb3Request(param);
                    });
                  });
        } finally {
          bitcoinClient.dispose();
        }
      default:
    }
  }

  Future<void> signTransaction() async {
    await _lock.synchronized(() async {
      StreamController<(TransactionOperationStep, String?)> onstatus =
          StreamController();
      _latestError = null;
      _step = TransactionOperationStep.client;
      allowPop = false;
      notify();
      onstatus.stream.listen(
          (event) => _onUpdateState(event.$1, transactionHash: event.$2));
      final r = await MethodUtils.call(() async {
        return _signTransaction(onstatus);
      });
      if (r.hasError) {
        _step = null;
        _latestError = r.error!.tr;
      }
      allowPop = true;
      notify();
      onstatus.close();
    });
  }
}

class SwapWeb3SignerEthereum implements Web3SignerEthereum {
  final Future<String> Function(Web3TransactionEthereum transaction) onSign;
  final Future<List<ETHAddress>> Function() onSigner;
  const SwapWeb3SignerEthereum({required this.onSign, required this.onSigner});
  @override
  Future<String> excuteTransaction(Web3TransactionEthereum transaction) {
    return onSign(transaction);
  }

  @override
  Future<List<ETHAddress>> signers() {
    return onSigner();
  }
}

class SwapWeb3SignerSolana implements Web3SignerSolana {
  final Future<List<SolAddress>> Function() onSigner;
  final Future<SolanaTransaction> Function(Web3TransactionSolana transaction)
      onSign;
  const SwapWeb3SignerSolana({required this.onSigner, required this.onSign});
  @override
  Future<SolanaTransaction> signTransaction(Web3TransactionSolana transaction) {
    return onSign(transaction);
  }

  @override
  Future<List<SolAddress>> signers() {
    return onSigner();
  }
}

class SwapWeb3SignerBitcoin implements Web3SignerBitcoin {
  final Future<List<BitcoinSpenderAddress>> Function() onSigner;
  final Future<String> Function(Web3TransactionBitcoin transaction)
      onSendPayment;
  const SwapWeb3SignerBitcoin(
      {required this.onSigner, required this.onSendPayment});
  @override
  Future<String> signPsbt(Web3TransactionBitcoin transaction) {
    throw UnimplementedError();
  }

  @override
  Future<List<BitcoinSpenderAddress>> signers() {
    return onSigner();
  }

  @override
  BitcoinSigningScheme get signingSchames => BitcoinSigningScheme.sendPayment;

  @override
  Future<String> sendPayment(Web3TransactionBitcoin transaction) {
    return onSendPayment(transaction);
  }
}

class SwapWeb3SignerSubstrate implements Web3SignerSubstrate {
  final Future<List<BaseSubstrateAddress>> Function() onSigner;
  final Future<String> Function(Web3TransactionSubstrate transaction) onSign;
  const SwapWeb3SignerSubstrate({required this.onSigner, required this.onSign});

  @override
  Future<String> signTransaction(Web3TransactionSubstrate transaction) {
    return onSign(transaction);
  }

  @override
  Future<List<BaseSubstrateAddress>> signers() {
    return onSigner();
  }
}

class SwapWeb3SignerCosmos implements Web3SignerCosmos {
  final Future<List<CosmosSpenderAddress>> Function() onSigner;
  final Future<CosmosSignResponse> Function(Web3TransactionCosmos transaction)
      onSign;
  const SwapWeb3SignerCosmos({required this.onSigner, required this.onSign});

  @override
  Future<CosmosSignResponse> signRaw(Web3TransactionCosmos transaction) {
    return onSign(transaction);
  }

  @override
  Future<List<CosmosSpenderAddress>> signers() {
    return onSigner();
  }

  @override
  List<CosmosSigningScheme> get signingSchames =>
      [CosmosSigningScheme.amino, CosmosSigningScheme.direct];
}
