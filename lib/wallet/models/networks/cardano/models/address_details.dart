import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';

import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/crypto/keys/keys.dart';
import 'package:on_chain/ada/src/address/address.dart';
import 'package:on_chain/ada/src/models/ada_models.dart';

class CardanoAddrDetails with Equatable, CborSerializable {
  final List<int> publicKey;
  final List<int>? stakePubkey;
  final List<int>? chainCode;
  final List<int>? hdPathKey;
  final String? hdPath;
  late final String? hdPathKeyHex = BytesUtils.tryToHexString(hdPathKey);
  final ADAAddressType addressType;
  bool get isLegacy => hdPath != null;

  PolicyID policyId() {
    final keyHash = Ed25519KeyHash.fromPubkey(publicKey);
    final mintScript = NativeScriptScriptPubkey(keyHash);
    return PolicyID(mintScript.toHash().data);
  }

  NativeScript toNativeScript() {
    final keyHash = Ed25519KeyHash.fromPubkey(publicKey);
    return NativeScriptScriptPubkey(keyHash);
  }

  factory CardanoAddrDetails.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.cardanoAccountDetails);
    return CardanoAddrDetails._(
        publicKey: cbor.elementAs(0),
        addressType: ADAAddressType.fromHeader(cbor.elementAs(1)),
        stakePubkey: cbor.elementAs(2),
        chainCode: cbor.elementAs(3),
        hdPathKey: cbor.elementAs(4),
        hdPath: cbor.elementAs(5));
  }
  CardanoAddrDetails._({
    required List<int> publicKey,
    required this.addressType,
    List<int>? stakePubkey,
    List<int>? chainCode,
    List<int>? hdPathKey,
    this.hdPath,
  })  : publicKey = publicKey.asImmutableBytes,
        stakePubkey = stakePubkey?.asImmutableBytes,
        chainCode = chainCode?.asImmutableBytes,
        hdPathKey = hdPathKey?.asImmutableBytes;
  factory CardanoAddrDetails.shelley(
      {required List<int> publicKey,
      required ADAAddressType addressType,
      required SeedTypes seedGeneration,
      List<int>? stakePubkey}) {
    if (addressType == ADAAddressType.byron ||
        addressType == ADAAddressType.pointer) {
      throw const WalletException("invalid_cardano_address_details");
    }
    if (addressType == ADAAddressType.base && stakePubkey == null) {
      throw const WalletException("invalid_cardano_address_details");
    }
    if (addressType != ADAAddressType.base && stakePubkey != null) {
      throw const WalletException("invalid_cardano_address_details");
    }
    return CardanoAddrDetails._(
        publicKey: publicKey,
        addressType: addressType,
        stakePubkey: stakePubkey);
  }
  factory CardanoAddrDetails.byron(
      {required List<int> publicKey,
      required List<int> chainCode,
      required SeedTypes seedGeneration,
      List<int>? hdPathKey,
      String? hdPath}) {
    if (hdPath != null && hdPathKey == null ||
        hdPath == null && hdPathKey != null) {
      throw const WalletException("invalid_cardano_address_details");
    }
    return CardanoAddrDetails._(
        publicKey: publicKey,
        addressType: ADAAddressType.byron,
        hdPathKey: hdPathKey,
        chainCode: chainCode,
        hdPath: hdPath);
  }

  ADAAddress toAddress(CryptoCoins coin, bool testnet) {
    final adaNetwork = testnet ? ADANetwork.testnetPreprod : ADANetwork.mainnet;
    switch (addressType) {
      case ADAAddressType.base:
        return ADABaseAddress.fromPublicKey(
            basePubkeyBytes: publicKey,
            stakePubkeyBytes: stakePubkey!,
            network: adaNetwork);
      case ADAAddressType.enterprise:
        return ADAEnterpriseAddress.fromPublicKey(
            pubkeyBytes: publicKey, network: adaNetwork);
      case ADAAddressType.reward:
        return ADARewardAddress.fromPublicKey(
            pubkeyBytes: publicKey, network: adaNetwork);
      case ADAAddressType.byron:
        return ADAByronAddress.fromPublicKey(
            publicKey: publicKey,
            chaincode: chainCode!,
            hdPath: hdPath,
            hdPathKey: hdPathKey,
            network: adaNetwork);
      default:
        throw const WalletException("invalid_cardano_address_details");
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(publicKey),
          CborIntValue(addressType.header),
          stakePubkey == null
              ? const CborNullValue()
              : CborBytesValue(stakePubkey!),
          chainCode == null
              ? const CborNullValue()
              : CborBytesValue(chainCode!),
          hdPathKey == null
              ? const CborNullValue()
              : CborBytesValue(hdPathKey!),
          hdPath == null ? const CborNullValue() : CborStringValue(hdPath!),
        ]),
        CborTagsConst.cardanoAccountDetails);
  }

  @override
  List get variabels =>
      [publicKey, hdPath, hdPathKeyHex, chainCode, addressType];
}
