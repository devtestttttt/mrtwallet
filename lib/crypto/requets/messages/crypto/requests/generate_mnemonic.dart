import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';

class CryptoRequestGenerateBip39Mnemonic
    extends CryptoRequest<Mnemonic, MessageArgsOneBytes> {
  final Bip39Languages language;
  final Bip39WordsNum wordNums;
  CryptoRequestGenerateBip39Mnemonic._(
      {required this.language, required this.wordNums});

  factory CryptoRequestGenerateBip39Mnemonic(
      {required Bip39Languages language, required Bip39WordsNum wordNums}) {
    return CryptoRequestGenerateBip39Mnemonic._(
        language: language, wordNums: wordNums);
  }
  factory CryptoRequestGenerateBip39Mnemonic.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.generateBip39Mnemonic.tag);
    return CryptoRequestGenerateBip39Mnemonic(
      language: Bip39Languages.values.firstWhere(
          (e) => e.name == values.elementAt<String?>(0),
          orElse: () => throw WalletExceptionConst.dataVerificationFailed),
      wordNums: Bip39WordsNum.values.firstWhere(
          (e) => e.value == values.elementAt<int?>(1),
          orElse: () => throw WalletExceptionConst.dataVerificationFailed),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([language.name, wordNums.value]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.generateBip39Mnemonic;
  static Mnemonic generateMenemonic(
      {required Bip39Languages language, required Bip39WordsNum wordNums}) {
    final generator = Bip39MnemonicGenerator(language);
    final mnemonic = generator.fromWordsNumber(wordNums);
    return mnemonic;
  }

  @override
  MessageArgsOneBytes getResult() {
    final mnemonic = generateMenemonic(language: language, wordNums: wordNums);
    return MessageArgsOneBytes(keyOne: StringUtils.encode(mnemonic.toStr()));
  }

  @override
  Mnemonic parsResult(MessageArgsOneBytes result) {
    final mnemonic = StringUtils.decode(result.keyOne);
    return Mnemonic.fromString(mnemonic);
  }

  @override
  Mnemonic result() {
    return generateMenemonic(language: language, wordNums: wordNums);
  }
}
