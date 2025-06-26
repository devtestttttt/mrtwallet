import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/personal_sign_response.dart';

final class WalletRequestBitcoinSignMessage extends WalletRequest<
    CryptoBitcoinPersonalSignResponse, MessageArgsTwoBytes> {
  final List<int> message;
  final Bip32AddressIndex index;
  final String messagePrefix;
  final BIP137Mode? mode;
  final bool useTaproot;
  WalletRequestBitcoinSignMessage._({
    required this.message,
    required this.index,
    required this.messagePrefix,
    required this.mode,
    required this.useTaproot,
  });

  factory WalletRequestBitcoinSignMessage(
      {required List<int> message,
      required Bip32AddressIndex index,
      required bool useTaproot,
      required BIP137Mode mode,
      required String messagePrefix}) {
    return WalletRequestBitcoinSignMessage._(
        message: message.asImmutableBytes,
        index: index,
        messagePrefix: messagePrefix,
        mode: useTaproot ? null : mode,
        useTaproot: useTaproot);
  }

  factory WalletRequestBitcoinSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.bitcoinSignMessage.tag);
    return WalletRequestBitcoinSignMessage._(
        message: values.elementAt(0),
        index: Bip32AddressIndex.deserialize(obj: values.getCborTag(1)),
        messagePrefix: values.elementAt(2),
        mode: values.elemetMybeAs<BIP137Mode, CborIntValue>(
            3, (e) => BIP137Mode.fromValue(e.value)),
        useTaproot: values.elementAs(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(message),
          index.toCbor(),
          messagePrefix,
          mode?.header,
          useTaproot
        ]),
        method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.bitcoinSignMessage;
  static MessageArgsTwoBytes sign(
      {required WalletMasterKeys wallet,
      required Bip32AddressIndex index,
      required List<int> message,
      required bool useTaproot,
      required BIP137Mode? mode,
      required String messagePrefix}) {
    final responseKeys = wallet
        .readKeys([AccessCryptoPrivateKeyRequest(index: index)])
        .keys
        .first;
    final signer =
        BitcoinKeySigner.fromKeyBytes(responseKeys.privateKeyBytes());
    final digest = QuickCrypto.sha256Hash(
            BitcoinSignerUtils.magicMessage(message, messagePrefix))
        .asImmutableBytes;
    List<int> signature;
    if (useTaproot) {
      signature = signer.signBip340Const(digest: digest);
    } else {
      signature = signer.signMessageConst(message: digest, hashMessage: false);
      if (mode != null) {
        final int rId = signature[0] + mode.header;
        signature = [rId, ...signature.sublist(1)];
      }
    }

    return MessageArgsTwoBytes(keyOne: signature, keyTwo: digest);
  }

  @override
  Future<MessageArgsTwoBytes> getResult(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    return sign(
        wallet: wallet,
        index: index,
        message: message,
        mode: mode,
        messagePrefix: messagePrefix,
        useTaproot: useTaproot);
  }

  @override
  Future<CryptoBitcoinPersonalSignResponse> parsResult(
      MessageArgsTwoBytes result) async {
    return CryptoBitcoinPersonalSignResponse(
        signature: result.keyOne, digest: result.keyTwo);
  }

  @override
  Future<CryptoBitcoinPersonalSignResponse> result(
      {required WalletMasterKeys wallet, required List<int> key}) async {
    final signature = sign(
        wallet: wallet,
        index: index,
        message: message,
        mode: mode,
        useTaproot: useTaproot,
        messagePrefix: messagePrefix);
    return CryptoBitcoinPersonalSignResponse(
        signature: signature.keyOne, digest: signature.keyTwo);
  }
}
