import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

final class WalletRequestReadMnemonic
    extends WalletRequest<AccessMnemonicResponse, MessageArgsOneBytes> {
  WalletRequestReadMnemonic._();

  factory WalletRequestReadMnemonic() {
    return WalletRequestReadMnemonic._();
  }

  factory WalletRequestReadMnemonic.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.readMnemonic.tag);
    return WalletRequestReadMnemonic();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.readMnemonic;

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final mnemonic = wallet.mnemonic();
    return MessageArgsOneBytes(keyOne: mnemonic.toCbor().encode());
  }

  @override
  AccessMnemonicResponse parsResult(MessageArgsOneBytes result) {
    final response = AccessMnemonicResponse.deserialize(bytes: result.keyOne);
    return response;
  }

  @override
  AccessMnemonicResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    return wallet.mnemonic();
  }
}
