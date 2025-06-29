import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:on_chain_wallet/app/core.dart';

class ExtentionWalletKey with CborSerializable {
  final String key;
  const ExtentionWalletKey(this.key);

  factory ExtentionWalletKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: ExtentionSessionStorageConst.historyTag);
    return ExtentionWalletKey(values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.dynamicLength([key]),
        ExtentionSessionStorageConst.historyTag);
  }
}

class ExtentionKey with CborSerializable {
  final String key;
  final String nonce;
  List<int> get keyBytes => BytesUtils.fromHexString(key);
  List<int> get nonceBytes => BytesUtils.fromHexString(nonce);
  ExtentionKey({required List<int> key, required List<int> nonce})
      : key = BytesUtils.toHexString(key),
        nonce = BytesUtils.toHexString(nonce);
  ExtentionKey.fromHex(this.key, this.nonce);
  factory ExtentionKey.generate() {
    return ExtentionKey(
        key: QuickCrypto.generateRandom(),
        nonce: QuickCrypto.generateRandom(12));
  }
  factory ExtentionKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: ExtentionSessionStorageConst.keyTag);
    return ExtentionKey.fromHex(values.elementAt(0), values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([key, nonce]),
        ExtentionSessionStorageConst.keyTag);
  }
}

class ExtentionSessionStorageConst {
  static const String key = "extention_setting";
  static const String history = "extention_history";
  static const String expireKey = "extention_expire";
  static const String extentionType = "popup";
  static const String normalTabType = "normal";
  static const List<int> keyTag = [23, 123, 21, 10];
  static const List<int> historyTag = [123, 21, 10, 21];
  static const String iframeName = "iframe";
  static const String viewQueryParameters = "view";
  static const String contextQueryParameters = "context";
  static const String updateTabCompleteStatus = "complete";
  static const Map<String, dynamic> closeEvent = {
    "message": "close_iframe",
    "source": "wallet",
  };
}

enum ExtensionWalletContextType {
  action(0),
  sidePanel(1),
  popup(2),
  tab(3),
  sidebarAction(4);

  bool get isAction => this == action;
  bool get isSidePanel => this == sidePanel;
  bool get isSidebarAction => this == sidebarAction;
  bool get isTab => this == tab;
  bool get isPopup => this == popup;
  final int value;
  const ExtensionWalletContextType(this.value);

  static ExtensionWalletContextType? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }

  static ExtensionWalletContextType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'invalid extension context type tag'));
  }
}

class ExtensionWalletContext {
  final ExtensionWalletContextType context;
  final int windowId;
  final String instanceId;
  final int? tabId;
  final bool iframe;
  const ExtensionWalletContext(
      {required this.context,
      required this.windowId,
      required this.instanceId,
      required this.tabId,
      required this.iframe});
  static const ExtensionWalletContext init = ExtensionWalletContext(
      context: ExtensionWalletContextType.action,
      windowId: 0,
      instanceId: '',
      tabId: null,
      iframe: false);
}
