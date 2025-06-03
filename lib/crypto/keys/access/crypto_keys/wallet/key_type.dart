part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

enum CustomKeyType {
  privateKey(0),
  extendedKey(1);

  final int value;
  const CustomKeyType(this.value);

  static CustomKeyType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'invalid crypto key tag.'));
  }

  bool get isPrivateKey => this == CustomKeyType.privateKey;
}
