import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/euqatable/equatable.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class APPSwapSettingsConst {
  static const double minTelerance = 0;
  static const double maxTolerance = 100;
}

class APPSwapSettings with CborSerializable, Equatable {
  APPSwapSettings._(
      {required this.chainType,
      required List<SwapServiceProvider> swapProviders,
      this.tolerance})
      : swapProviders = swapProviders.immutable;
  final List<SwapServiceProvider> swapProviders;
  final ChainType chainType;
  final double? tolerance;

  APPSwapSettings copyWith(
      {required List<SwapServiceProvider> swapProviders,
      required ChainType chainType,
      required double tolerance}) {
    assert(tolerance >= 0 && tolerance <= 100);

    return APPSwapSettings._(
        swapProviders: swapProviders,
        chainType: chainType,
        tolerance: (tolerance == 0 ? null : tolerance));
  }

  factory APPSwapSettings.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    try {
      final CborListValue values = CborSerializable.cborTagValue(
          hex: hex,
          cborBytes: bytes,
          object: obj,
          tags: CborTagsConst.swapSetting);
      List<SwapServiceProvider> providers = values
          .elementAsListOf<CborStringValue>(0)
          .map((e) => SwapConstants.findProvider(e.value))
          .whereType<SwapServiceProvider>()
          .toList();
      if (providers.isEmpty) {
        providers = SwapConstants.supportProviders;
      }
      final chainType = ChainType.fromValue(values.elementAs(1));
      return APPSwapSettings._(
          swapProviders: providers,
          chainType: chainType,
          tolerance: values.elementAs(2));
    } catch (_) {
      return APPSwapSettings._(
          swapProviders: SwapConstants.supportProviders,
          chainType: ChainType.mainnet);
    }
  }
  factory APPSwapSettings() {
    return APPSwapSettings._(
        chainType: ChainType.mainnet,
        swapProviders: SwapConstants.supportProviders);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              swapProviders.map((e) => CborStringValue(e.identifier)).toList()),
          chainType.name,
          tolerance
        ]),
        CborTagsConst.swapSetting);
  }

  @override
  List get variabels => [swapProviders, chainType, tolerance];
}
