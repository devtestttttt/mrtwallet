import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/wallet/constant/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/wallet/hd_wallet.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/models/authenticated.dart';

enum WalletBackupTypes {
  wallet(CborTagsConst.walletBackupWallet, "wallets"),
  walletV2(CborTagsConst.walletBackupWalletV2, "walletsV2"),
  walletV3(CborTagsConst.walletBackupWalletV3, "walletsV3"),
  mnemonic(CborTagsConst.walletBackupMnemonic, "mnemonic"),
  privatekey(CborTagsConst.walletBackupPrivateKey, "private_key"),
  wif(CborTagsConst.walletBackupWif, "wif"),
  keystore([], "keystore"),
  extendedKey(CborTagsConst.walletBackupExtendedKey, "extended_private_key");

  bool get isWalletBackup =>
      this == wallet || this == walletV2 || this == walletV3;
  final List<int> tag;
  final String value;
  const WalletBackupTypes(this.tag, this.value);

  static WalletBackupTypes fromValue(List<int> tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag));
  }

  SecretWalletEncoding get encoding {
    switch (this) {
      case WalletBackupTypes.keystore:
        return SecretWalletEncoding.json;
      default:
        return SecretWalletEncoding.cbor;
    }
  }

  bool get isPrivateKey =>
      this == WalletBackupTypes.privatekey ||
      this == WalletBackupTypes.keystore;

  List<int> toEncryptionBytes(String data) {
    switch (this) {
      case WalletBackupTypes.mnemonic:
        return StringUtils.encode(data);
      case WalletBackupTypes.keystore:
      case WalletBackupTypes.privatekey:
      case WalletBackupTypes.wallet:
      case WalletBackupTypes.walletV2:
      case WalletBackupTypes.walletV3:
        return BytesUtils.fromHexString(data);
      default:
        return Base58Decoder.checkDecode(data);
    }
  }

  String fromDecyrptBytes(List<int> decryptedKeyBytes) {
    switch (this) {
      case WalletBackupTypes.mnemonic:
        return StringUtils.decode(decryptedKeyBytes);
      case WalletBackupTypes.privatekey:
      case WalletBackupTypes.wallet:
      case WalletBackupTypes.walletV2:
      case WalletBackupTypes.walletV3:
      case WalletBackupTypes.keystore:
        return BytesUtils.toHexString(decryptedKeyBytes);

      default:
        return Base58Encoder.checkEncode(decryptedKeyBytes);
    }
  }
}

abstract final class WalletBackupCore {
  abstract final WalletBackupTypes type;
  abstract final DateTime created;
  abstract final String key;
  abstract final bool isEncrypted;
  factory WalletBackupCore.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: hex);
    final type = WalletBackupTypes.fromValue(tag.tags);
    switch (type) {
      case WalletBackupTypes.wallet:
      case WalletBackupTypes.walletV2:
        throw WalletExceptionConst.unsuportedBackupVersion;
      case WalletBackupTypes.walletV3:
        return WalletBackup.deserialize(obj: tag);
      default:
        return WalletKeyBackup.deserialize(obj: tag);
    }
  }
  WalletBackupCore decrypt(List<int> decryptedKey);
}

final class WalletBackupChainRepository with CborSerializable {
  final String value;
  final int storageID;
  final int networkID;
  final String? identifier;

  const WalletBackupChainRepository._(
      {required this.storageID,
      required this.identifier,
      required this.value,
      required this.networkID});
  factory WalletBackupChainRepository(
      {required int storageID,
      required String? identifier,
      required String value,
      required int networkID}) {
    return WalletBackupChainRepository._(
        storageID: storageID,
        identifier: identifier,
        value: value,
        networkID: networkID);
  }
  factory WalletBackupChainRepository.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.walletBackupChainStorageIds);

    return WalletBackupChainRepository(
        value: values.elementAs(0),
        storageID: values.elementAs(1),
        identifier: values.elementAs(2),
        networkID: values.elementAs(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([value, storageID, identifier, networkID]),
        CborTagsConst.walletBackupChainStorageIds);
  }
}

final class WalletChainBackup with CborSerializable {
  final Chain chain;
  final List<WalletBackupChainRepository> repositories;
  WalletChainBackup._(
      {required this.chain,
      List<WalletBackupChainRepository> repositories = const []})
      : repositories = repositories.immutable;
  factory WalletChainBackup(
      {required Chain chain,
      required List<WalletBackupChainRepository> repositories}) {
    return WalletChainBackup._(chain: chain, repositories: repositories);
  }
  factory WalletChainBackup.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: obj,
        tags: CborTagsConst.walletBackupChains);

    return WalletChainBackup(
        chain: Chain.deserialize(obj: values.getCborTag(0)),
        repositories: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => WalletBackupChainRepository.deserialize(obj: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          chain.toCbor(),
          CborListValue.fixedLength(
              repositories.map((e) => e.toCbor()).toList())
        ]),
        CborTagsConst.walletBackupChains);
  }
}

final class WalletBackup implements WalletBackupCore {
  final List<WalletChainBackup> chains;
  final List<Web3APPAuthentication> dapps;
  WalletBackup._(
      {required this.key,
      required List<WalletChainBackup> chains,
      List<Web3APPAuthentication> dapps = const [],
      DateTime? created,
      this.isEncrypted = true})
      : chains = chains.immutable,
        created = created ?? DateTime.now(),
        dapps = dapps.immutable;
  factory WalletBackup(
      {required String key,
      required List<WalletChainBackup> chains,
      List<Web3APPAuthentication> dapps = const [],
      DateTime? created}) {
    return WalletBackup._(
        key: key, chains: chains, created: created, dapps: dapps);
  }
  factory WalletBackup.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: WalletBackupTypes.walletV3.tag);

    /// id: "backup"
    return WalletBackup(
        key: values.elementAs(0),
        chains: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => WalletChainBackup.deserialize(obj: e))
            .toList(),
        created: values.elementAs(2),
        dapps: values
            .elementAsListOf<CborTagValue>(3, emyptyOnNull: true)
            .map((e) => Web3APPAuthentication.deserialize(object: e))
            .toList());
  }

  @override
  final String key;

  @override
  final DateTime created;

  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborStringValue(key),
          CborListValue.fixedLength(chains.map((e) => e.toCbor()).toList()),
          CborEpochIntValue(created),
          CborListValue.fixedLength(dapps.map((e) => e.toCbor()).toList()),
        ]),
        type.tag);
  }

  @override
  WalletBackupTypes get type => WalletBackupTypes.walletV3;

  @override
  final bool isEncrypted;

  @override
  WalletBackupCore decrypt(List<int> decryptedKeyBytes) {
    return WalletBackup._(
        key: type.fromDecyrptBytes(decryptedKeyBytes),
        created: created,
        isEncrypted: false,
        chains: chains,
        dapps: dapps);
  }
}

final class WalletKeyBackup implements WalletBackupCore {
  WalletKeyBackup._(
      {required this.key,
      required this.type,
      required this.created,
      this.isEncrypted = true});
  factory WalletKeyBackup(
      {required String key,
      required WalletBackupTypes type,
      DateTime? created}) {
    if (type == WalletBackupTypes.wallet) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    switch (type) {
      case WalletBackupTypes.wallet:
      case WalletBackupTypes.walletV2:
      case WalletBackupTypes.walletV3:
        throw WalletExceptionConst.dataVerificationFailed;
      default:
        break;
    }
    return WalletKeyBackup._(
        key: key, type: type, created: created ?? DateTime.now());
  }
  factory WalletKeyBackup.deserialize(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: hex);
    final CborListValue values = CborSerializable.cborTagValue(object: tag);
    return WalletKeyBackup(
        key: values.elementAs(0),
        created: values.elementAs(1),
        type: WalletBackupTypes.fromValue(tag.tags));
  }

  @override
  final String key;
  @override
  final DateTime created;

  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborStringValue(key), CborEpochIntValue(created)]),
        type.tag);
  }

  @override
  final WalletBackupTypes type;

  @override
  final bool isEncrypted;

  @override
  WalletBackupCore decrypt(List<int> decryptedKeyBytes) {
    return WalletKeyBackup._(
        key: type.fromDecyrptBytes(decryptedKeyBytes),
        type: type,
        created: created,
        isEncrypted: false);
  }
}

final class WalletRestoreV2 {
  WalletRestoreV2._({
    required this.masterKeys,
    required List<WalletChainBackup> chains,
    required List<ChainAccount> invalidAddresses,
    required List<Web3APPAuthentication> dapps,
    required this.wallet,
    this.verifiedChecksum,
  })  : chains = chains.immutable,
        invalidAddresses = invalidAddresses.immutable,
        totalAccounts = chains.fold(0, (p, c) => p + c.chain.addresses.length) +
            invalidAddresses.length,
        dapps = dapps.immutable;
  factory WalletRestoreV2({
    required WalletMasterKeys masterKeys,
    required List<WalletChainBackup> chains,
    required List<ChainAccount> invalidAddresses,
    required HDWallet wallet,
    required bool verifiedChecksum,
    required List<Web3APPAuthentication> dapps,
  }) {
    return WalletRestoreV2._(
        masterKeys: masterKeys,
        chains: chains,
        invalidAddresses: invalidAddresses,
        wallet: wallet,
        verifiedChecksum: verifiedChecksum,
        dapps: dapps);
  }
  final WalletMasterKeys masterKeys;
  final List<WalletChainBackup> chains;
  final List<ChainAccount> invalidAddresses;
  final List<Web3APPAuthentication> dapps;

  final HDWallet wallet;
  final bool? verifiedChecksum;
  final int totalAccounts;
  bool get hasFailedAccount => invalidAddresses.isNotEmpty;
}

final class GenerateWalletBackupOptions {
  final List<Chain> chains;
  final bool backupDapps;
  final String? passphrase;
  final String? newPassword;
  GenerateWalletBackupOptions(
      {required List<Chain> chains,
      required this.backupDapps,
      required this.passphrase,
      required this.newPassword})
      : chains = chains.immutable;
}
