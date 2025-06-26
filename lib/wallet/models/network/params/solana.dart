import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/error/exception.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/wallet/api/provider/provider.dart';

import 'package:on_chain_wallet/wallet/models/network/core/params/params.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';

enum SolanaNetworkType {
  mainnet(
      identifier: 'solana:mainnet',
      value: 0,
      genesis: "5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp"),
  testnet(
      identifier: 'solana:testnet',
      value: 1,
      genesis: "4uhcVJyU9pJkvQyS88uRDiswHXSCkY3z"),

  devnet(
      identifier: 'solana:devnet',
      value: 2,
      genesis: "EtWTRABZaYq6iMfeYKouRu166VU2xqa1");

  final String identifier;
  final int value;
  final String genesis;
  const SolanaNetworkType(
      {required this.identifier, required this.value, required this.genesis});
  static SolanaNetworkType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'Solana network type not found.'));
  }
}

class SolanaNetworkParams extends NetworkCoinParams<SolanaAPIProvider> {
  final int chainId;
  final SolanaNetworkType type;

  factory SolanaNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.solNetworkParam);

    return SolanaNetworkParams(
        token: Token.deserialize(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => SolanaAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        chainId: values.elementAs(6),
        type: SolanaNetworkType.fromValue(values.elementAs(7)),
        addressExplorer: values.elementAs(8),
        transactionExplorer: values.elementAs(9));
  }
  SolanaNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.chainId,
      required this.type,
      super.addressExplorer,
      super.transactionExplorer});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          const CborNullValue(),
          chainId,
          type.value,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.solNetworkParam);
  }

  @override
  NetworkCoinParams<SolanaAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return SolanaNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<SolanaAPIProvider>() ?? providers,
        chainType: chainType,
        chainId: chainId,
        type: type,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
