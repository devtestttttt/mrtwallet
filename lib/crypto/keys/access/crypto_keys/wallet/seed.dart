part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

enum SeedTypes {
  bip39(name: "Bip39", value: 0),
  bip39Entropy(name: "Bip39Entropy", value: 1),
  byronLegacySeed(name: "ByronLegacySeed", value: 2),
  icarus(name: "icarus", value: 3);

  final String name;
  final int value;
  const SeedTypes({required this.name, required this.value});
  static SeedTypes fromValue(int? tag) {
    return values.firstWhere((e) => e.value == tag,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'invalid seed type tag.'));
  }
}

enum APPBip39Languages {
  /// Chinese (Simplified)
  chineseSimplified(0),

  /// Chinese (Traditional)
  chineseTraditional(1),

  /// Czech
  czech(2),

  /// English
  english(3),

  /// French
  french(4),

  /// Italian
  italian(5),

  /// Korean
  korean(6),

  /// Portuguese
  portuguese(7),

  /// Japanese
  japanese(8),

  /// Spanish
  spanish(9);

  final int value;
  const APPBip39Languages(this.value);

  static APPBip39Languages findLanguage(Mnemonic mnemonic) {
    try {
      final language = Bip39WordsListFinder().findLanguage(mnemonic);
      return fromBip39Language(language.item2 as Bip39Languages);
    } catch (_) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  static APPBip39Languages fromBip39Language(Bip39Languages language) {
    return switch (language) {
      Bip39Languages.chineseSimplified => chineseSimplified,
      Bip39Languages.chineseTraditional => chineseTraditional,
      Bip39Languages.czech => czech,
      Bip39Languages.english => english,
      Bip39Languages.french => french,
      Bip39Languages.italian => italian,
      Bip39Languages.korean => korean,
      Bip39Languages.portuguese => portuguese,
      Bip39Languages.spanish => spanish,
      Bip39Languages.japanese => japanese,
      _ => throw WalletExceptionConst.invalidMnemonic
    };
  }

  Bip39Languages get language {
    return switch (this) {
      chineseSimplified => Bip39Languages.chineseSimplified,
      chineseTraditional => Bip39Languages.chineseTraditional,
      czech => Bip39Languages.czech,
      english => Bip39Languages.english,
      french => Bip39Languages.french,
      italian => Bip39Languages.italian,
      korean => Bip39Languages.korean,
      portuguese => Bip39Languages.portuguese,
      spanish => Bip39Languages.spanish,
      japanese => Bip39Languages.japanese
    };
  }

  static APPBip39Languages fromValue(int? tag) {
    return values.firstWhere((e) => e.value == tag,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'invalid bip39 language type tag.'));
  }
}
