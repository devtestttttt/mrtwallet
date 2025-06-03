import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:on_chain_wallet/wallet/models/network/core/params/params.dart';
import 'package:on_chain_wallet/wallet/models/token/token/token.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';

enum RippleSupportKeyScheme {
  ed25519(value: 0, name: "ED25519"),
  secp256k1(value: 1, name: "Secp256k1");

  final int value;
  final String name;

  const RippleSupportKeyScheme({required this.value, required this.name});
  static RippleSupportKeyScheme fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "RippleSupportKeyScheme not found $value"));
  }

  EllipticCurveTypes get curve {
    return switch (this) {
      RippleSupportKeyScheme.secp256k1 => EllipticCurveTypes.secp256k1,
      _ => EllipticCurveTypes.ed25519
    };
  }

  // SuiKeyAlgorithm get suiKeyAlgorithm {
  //   return switch (this) {
  //     RippleSupportKeyScheme.secp256k1 => SuiKeyAlgorithm.secp256k1,
  //     RippleSupportKeyScheme.secp256r1 => SuiKeyAlgorithm.secp256r1,
  //     _ => SuiKeyAlgorithm.ed25519
  //   };
  // }

  // static RippleSupportKeyScheme fromCoin(Bip44Coins coin) {
  //   return switch (coin) {
  //     Bip44Coins.sui => RippleSupportKeyScheme.ed25519,
  //     Bip44Coins.suiSecp256k1 => RippleSupportKeyScheme.secp256k1,
  //     Bip44Coins.suiSecp256r1 => RippleSupportKeyScheme.secp256r1,
  //     _ => throw WalletExceptionConst.invalidData(
  //         messsage: "Invalid sui drivation coin")
  //   };
  // }
}

class RippleNetworkParams extends NetworkCoinParams<RippleAPIProvider> {
  final int networkId;

  factory RippleNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.xrpNetworkParam);
    return RippleNetworkParams(
        token: Token.deserialize(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => RippleAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        networkId: values.elementAs(5),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  RippleNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.networkId,
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
          networkId,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.xrpNetworkParam);
  }

  int get identifier => networkId;

  @override
  NetworkCoinParams<RippleAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return RippleNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<RippleAPIProvider>() ?? providers,
        chainType: chainType,
        networkId: networkId,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
