import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/messages/core/message.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models/create_wallet.dart';
import 'package:on_chain_wallet/crypto/utils/crypto/utils.dart';

class CreateHDWalletConst {
  static const int checksumLength = 4;
}

class CryptoRequestCreateHDWallet
    extends CryptoRequest<CryptoCreateWalletResponse, MessageArgsThreeBytes> {
  final String mnemonic;
  final String? passphrase;
  final String password;
  final List<int> checksum;
  CryptoRequestCreateHDWallet._(
      {required this.mnemonic,
      required this.passphrase,
      required this.password,
      required this.checksum});

  factory CryptoRequestCreateHDWallet({
    required String mnemonic,
    required String? passphrase,
    required String password,
    required List<int> checksum,
  }) {
    return CryptoRequestCreateHDWallet._(
        mnemonic: mnemonic,
        passphrase: passphrase,
        password: password,
        checksum: checksum.asImmutableBytes);
  }
  factory CryptoRequestCreateHDWallet.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.createWallet.tag);
    return CryptoRequestCreateHDWallet(
        mnemonic: values.elementAt(0),
        passphrase: values.elementAt(1),
        password: values.elementAt(2),
        checksum: values.elementAt(3));
  }

  /// MasterKey, storage encryptedBytes, checksum
  static (EncryptedMasterKey a, List<int>, List<int>) createHdWallet({
    required String mnemonic,
    required String? passphrase,
    required String password,
    required List<int> checksum,
  }) {
    final masterKey =
        WalletMasterKeys.generate(mnemonic: mnemonic, passphrase: passphrase);
    final key = WorkerCryptoUtils.hashKey(
        key: StringUtils.encode(password), checksum: checksum);
    final encrypt = masterKey.encrypt(key: key);
    return (encrypt.$1, encrypt.$2, checksum);
  }

  @override
  MessageArgsThreeBytes getResult() {
    final data = createHdWallet(
        mnemonic: mnemonic,
        passphrase: passphrase,
        password: password,
        checksum: checksum);
    return MessageArgsThreeBytes(
        keyOne: data.$1.toCbor().encode(), keyTwo: data.$2, keyThree: data.$3);
  }

  @override
  CryptoCreateWalletResponse parsResult(MessageArgsThreeBytes result) {
    return CryptoCreateWalletResponse(
        masterKey: EncryptedMasterKey.deserialize(bytes: result.keyOne),
        storageData:
            StringUtils.decode(result.keyTwo, type: StringEncoding.base64),
        checksum: result.keyThree);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [mnemonic, passphrase, password, CborBytesValue(checksum)]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.createWallet;

  @override
  CryptoCreateWalletResponse result() {
    final data = createHdWallet(
        mnemonic: mnemonic,
        passphrase: passphrase,
        password: password,
        checksum: checksum);
    return CryptoCreateWalletResponse(
        masterKey: data.$1,
        storageData: StringUtils.decode(data.$2, type: StringEncoding.base64),
        checksum: data.$3);
  }
}
