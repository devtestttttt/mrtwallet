import 'package:on_chain_wallet/crypto/models/networks.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/cardano/methods/utxos.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:on_chain_wallet/wallet/api/services/service.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain_wallet/wallet/models/networks/cardano/models/utxos.dart';
import 'package:on_chain_wallet/wallet/models/transaction/core/transaction.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/ada.dart';
import 'package:on_chain/ada/src/provider/exception/blockfrost_api_error.dart';
import 'package:on_chain/on_chain.dart';

class CardanoClient
    extends NetworkClient<ADAWalletTransaction, CardanoAPIProvider> {
  CardanoClient({required this.provider, required this.network});
  final BlockFrostProvider provider;
  @override
  final WalletCardanoNetwork network;
  @override
  BaseServiceProtocol<CardanoAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<CardanoAPIProvider>;

  Future<BigInt> getAccountBalance(ADAAddress address) async {
    try {
      final result =
          await provider.request(BlockfrostRequestAddressUTXOs(address));
      return result.sumOflovelace;
    } on BlockfrostError catch (e) {
      if (e.statusCode == BlockfrostStatusCode.resourceDoesNotExist) {
        return BigInt.zero;
      }
      rethrow;
    }
  }

  Future<List<ADAAccountUTXOs>> getUtxos(
      {required ICardanoAddress address, required ADAChain chain}) async {
    final utxos = await provider
        .request(BlockfrostRequestGetAddressUTXOs(address.networkAddress));
    return utxos;
  }

  Future<ADAEpochParametersResponse> latestEpochProtocolParameters() async {
    return await provider
        .request(BlockfrostRequestLatestEpochProtocolParameters());
  }

  Future<ADAGenesisParametersResponse> getNetworkGenesisParameters() async {
    return await provider.request(BlockfrostRequestBlockchainGenesis());
  }

  Future<String> broadcastTransaction(List<int> txCborBytes) async {
    return await provider.request(
        BlockfrostRequestSubmitTransaction(transactionCborBytes: txCborBytes));
  }

  @override
  Future<WalletTransactionStatus> transactionStatus(
      {required String txId}) async {
    try {
      await provider.request(BlockfrostRequestSpecificTransaction(txId));

      return WalletTransactionStatus.block;
    } catch (e) {
      return WalletTransactionStatus.unknown;
    }
  }

  @override
  Future<bool> onInit() async {
    final magic = await getNetworkGenesisParameters();
    return magic.networkMagic == network.coinParam.magic;
  }

  @override
  NetworkType get networkType => NetworkType.cardano;
}
