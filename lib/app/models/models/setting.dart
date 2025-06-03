import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:on_chain_bridge/models/models.dart';
import 'package:on_chain_wallet/app/constant/global/serialization.dart';
import 'package:on_chain_wallet/app/models/models/currencies.dart';
import 'package:on_chain_wallet/app/serialization/serialization.dart';

class APPWalletSetting with CborSerializable {
  final bool showTestnetNetworks;
  final bool enableWebView;
  final bool enableSwap;
  const APPWalletSetting(
      {this.showTestnetNetworks = false,
      this.enableWebView = true,
      this.enableSwap = true});

  factory APPWalletSetting.deserialize({
    List<int>? cborBytes,
    CborObject? object,
    String? hex,
  }) {
    try {
      final CborListValue values = CborSerializable.cborTagValue(
          cborBytes: cborBytes,
          hex: hex,
          object: object,
          tags: APPSerializationConst.walletSetting);

      return APPWalletSetting(
          showTestnetNetworks: values.elementAs(0),
          enableWebView: values.elementAs(1),
          enableSwap: values.elementAs(2));
    } catch (_) {
      return APPWalletSetting();
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [showTestnetNetworks, enableWebView, enableSwap]),
        APPSerializationConst.walletSetting);
  }

  APPWalletSetting copyWith(
      {bool? showTestnetNetworks, bool? enableWebView, bool? enableSwap}) {
    return APPWalletSetting(
        enableWebView: enableWebView ?? this.enableWebView,
        showTestnetNetworks: showTestnetNetworks ?? this.showTestnetNetworks,
        enableSwap: enableSwap ?? this.enableSwap);
  }
}

class APPSetting with CborSerializable {
  const APPSetting._(
      {required this.appColor,
      required this.appBrightness,
      required this.currency,
      required this.config,
      required this.walletSetting,
      this.size});
  final String? appColor;
  final String? appBrightness;
  final Currency currency;
  final PlatformConfig config;
  final WidgetRect? size;
  final APPWalletSetting walletSetting;

  bool get supportBarcodeScanner => config.hasBarcodeScanner;

  APPSetting copyWith(
      {String? appColor,
      String? appBrightness,
      Currency? currency,
      WidgetRect? size,
      APPWalletSetting? walletSetting}) {
    return APPSetting._(
        appColor: appColor ?? this.appColor,
        appBrightness: appBrightness ?? this.appBrightness,
        currency: currency ?? this.currency,
        config: config,
        size: size ?? this.size,
        walletSetting: walletSetting ?? this.walletSetting);
  }

  factory APPSetting.deserialize(
    PlatformConfig config, {
    String? hex,
  }) {
    if (hex == null) {
      return APPSetting._(
          appColor: null,
          appBrightness: null,
          currency: Currency.USD,
          config: config,
          walletSetting: APPWalletSetting());
    }
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          hex: hex, tags: APPSerializationConst.appSettingTag);
      final String? colorHex = cbor.elementAs(0);
      final String? brightnessName = cbor.elementAs(1);
      final Currency currency =
          Currency.fromName(cbor.elementAs(2)) ?? Currency.USD;
      WidgetRect? rect = WidgetRect.fromString(cbor.elementAs(3));
      APPWalletSetting walletSetting =
          cbor.elemetMybeAs<APPWalletSetting, CborTagValue>(
                  4, (e) => APPWalletSetting.deserialize(object: e)) ??
              APPWalletSetting();
      return APPSetting._(
          appColor: colorHex,
          appBrightness: brightnessName,
          currency: currency,
          config: config,
          size: rect,
          walletSetting: walletSetting);
    } catch (e) {
      assert(false, 'setting deserialization failed. $e');
      return APPSetting._(
          appColor: null,
          appBrightness: null,
          currency: Currency.USD,
          config: config,
          walletSetting: APPWalletSetting());
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          appColor,
          appBrightness,
          currency.name,
          size?.toString(),
          walletSetting.toCbor()
        ]),
        APPSerializationConst.appSettingTag);
  }
}
