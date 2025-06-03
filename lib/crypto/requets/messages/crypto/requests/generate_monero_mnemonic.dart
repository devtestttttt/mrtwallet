import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/serialization/cbor/cbor.dart';
import 'package:on_chain_wallet/crypto/coins/coins.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

final class MoneroMnemonicToPrivateKeyMessage
    extends CryptoRequest<ImportCustomKeys, MessageArgsOneBytes> {
  final String mnemonic;
  final CryptoCoins coin;
  const MoneroMnemonicToPrivateKeyMessage._(
      {required this.mnemonic, required this.coin});

  factory MoneroMnemonicToPrivateKeyMessage(
      {required String mnemonic, required CryptoCoins coin}) {
    return MoneroMnemonicToPrivateKeyMessage._(mnemonic: mnemonic, coin: coin);
  }
  factory MoneroMnemonicToPrivateKeyMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoRequestMethod.moneroMnemonicToPrivateKey.tag);
    return MoneroMnemonicToPrivateKeyMessage(
        mnemonic: values.elementAt(0),
        coin: CustomCoins.getSerializationCoin(values.elementAt(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([mnemonic, coin.toCbor()]), method.tag);
  }

  @override
  MessageArgsOneBytes getResult() {
    final importedKey =
        CryptoKeyUtils.tonMoneroPrivateSpendKey(coin: coin, mnemonic: mnemonic);
    return MessageArgsOneBytes(keyOne: importedKey.toCbor().encode());
  }

  @override
  ImportCustomKeys parsResult(MessageArgsOneBytes result) {
    return ImportCustomKeys.deserialize(bytes: result.keyOne);
  }

  @override
  CryptoRequestMethod get method =>
      CryptoRequestMethod.moneroMnemonicToPrivateKey;

  @override
  ImportCustomKeys result() {
    return CryptoKeyUtils.tonMoneroPrivateSpendKey(
        coin: coin, mnemonic: mnemonic);
  }
}

class MoneroMenmonicGenerateMessage
    extends CryptoRequest<String, MessageArgsOneBytes> {
  final MoneroWordsNum wordsNum;
  final MoneroLanguages language;
  const MoneroMenmonicGenerateMessage(
      {required this.wordsNum, required this.language});
  factory MoneroMenmonicGenerateMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        tags: CryptoRequestMethod.generateMoneroMnemonic.tag);
    return MoneroMenmonicGenerateMessage(
        wordsNum: MoneroWordsNum.fromValue(values.elementAs(0)),
        language: MoneroLanguages.fromValue(values.elementAs(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([wordsNum.value, language.name]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.generateMoneroMnemonic;

  @override
  MessageArgsOneBytes getResult() {
    final mnemonic =
        MoneroMnemonicGenerator(language).fromWordsNumber(wordsNum);

    return MessageArgsOneBytes(keyOne: StringUtils.encode(mnemonic.toStr()));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return StringUtils.decode(result.keyOne);
  }

  @override
  String result() {
    return MoneroMnemonicGenerator(language).fromWordsNumber(wordsNum).toStr();
  }
}
