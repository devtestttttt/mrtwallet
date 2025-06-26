part of 'package:on_chain_wallet/wc/wc.dart';

class WalletConnectUtils {
  static WcUriData parseUri(Uri uri) {
    String protocol = uri.scheme;
    String path = uri.path;
    final List<String> splitParams = path.split('@');
    final queryParameters = uri.queryParameters;
    final relayProtocol = queryParameters["relay-protocol"];
    final symKey = queryParameters["symKey"];
    final relayData = queryParameters["relay-data"];
    final expiryTimestamp =
        IntUtils.tryParse(queryParameters["expiryTimestamp"]);
    final topic = splitParams[0];
    if (splitParams.length == 1 || relayProtocol == null || symKey == null) {
      throw WalletConnectExceptionConst.invalidPairUrl;
    }
    final int? version = IntUtils.tryParse(splitParams[1]);
    if (version == 1) {
      throw WalletConnectExceptionConst.unsuportedPairingUrl;
    }
    List<String> methods = uri.queryParameters['methods']
            ?.split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    return WcUriData(
        protocol: protocol,
        topic: topic,
        expire: DateTimeUtils.detectEpochUnit(expiryTimestamp ?? -1) ??
            defaultPairExpireTime(),
        methods: methods,
        relay: WcProtocolOptions(protocol: relayProtocol, data: relayData),
        symkey: symKey);
  }

  static String generateRelayUrl(
      {required String relayUrl,
      required String projectId,
      required String auth}) {
    final uri = Uri.parse(relayUrl);
    final params = {"auth": auth, "projectId": projectId};
    return uri.replace(queryParameters: params).toString();
  }

  static int defaultSessionExpire() {
    final expire = DateTime.now().add(const Duration(days: 7)).toUtc();
    return DateTimeUtils.secondsSinceEpoch(expire);
  }

  static DateTime defaultSessionExpireTime() {
    return DateTime.now().add(const Duration(days: 7)).toUtc();
  }

  static DateTime defaultPairExpireTime() {
    return DateTime.now().add(const Duration(minutes: 5));
  }

  static DateTime defaultRequestExpireTime() {
    return DateTime.now().add(const Duration(minutes: 5));
  }
}
