part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class MoneroPrivateKeyData extends CryptoPrivateKeyData {
  @override
  final CryptoCoins coin;
  @override
  final String privateKey;
  final MoneroPrivateKey viewPrivateKey;
  final MoneroPrivateKey spendPrivateKey;
  @override
  final String? extendedKey;
  @override
  final String? wif;
  @override
  final String keyName;

  @override
  MoneroPrivateKeysView get toViewKey => MoneroPrivateKeysView._(
      extendKey: extendedKey,
      privateKey: privateKey,
      wif: wif,
      keyName: keyName,
      keyType: type,
      spendPrivateKey: spendPrivateKey.toHex(),
      viewPrivateKey: viewPrivateKey.toHex(),
      curve: coin.conf.type);

  MoneroAccount toMoneroAccount() {
    return MoneroAccount.fromPrivateSpendKey(spendPrivateKey.key);
  }

  @override
  final MoneroPublicKeyData publicKey;
  factory MoneroPrivateKeyData.deserialize(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessMoneroPrivateKeyResponse);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    return MoneroPrivateKeyData.__(
      privateKey: values.elementAs(1),
      extendedKey: values.elementAs(2),
      coin: coin,
      wif: values.elementAs(3),
      keyName: values.elementAs(4),
      publicKey: MoneroPublicKeyData.deserialize(obj: values.getCborTag(5)),
      spendPrivateKey: MoneroPrivateKey.fromBytes(values.elementAs(6)),
      viewPrivateKey: MoneroPrivateKey.fromBytes(values.elementAs(7)),
    );
  }

  const MoneroPrivateKeyData.__(
      {required this.privateKey,
      required this.extendedKey,
      required this.coin,
      required this.wif,
      required this.keyName,
      required this.publicKey,
      required this.viewPrivateKey,
      required this.spendPrivateKey})
      : super._();
  factory MoneroPrivateKeyData._fromBip32({
    required Bip32Base account,
    required CryptoCoins coin,
    required String keyName,
  }) {
    final moneroAccount =
        MoneroAccount.fromBip44PrivateKey(account.privateKey.raw);
    final wifKey =
        CryptoKeyUtils.toWif(privateKey: account.privateKey.raw, coin: coin);
    return MoneroPrivateKeyData.__(
      privateKey: account.privateKey.toHex(),
      extendedKey: account.privateKey.toExtended,
      coin: coin,
      wif: wifKey,
      keyName: keyName,
      viewPrivateKey: moneroAccount.privVkey,
      spendPrivateKey: moneroAccount.privateSpendKey,
      publicKey:
          MoneroPublicKeyData._fromBip32(account: account, keyName: keyName),
    );
  }
  factory MoneroPrivateKeyData._({
    required MoneroPrivateKey spendPrivateKey,
    required CryptoCoins coin,
    required String keyName,
  }) {
    final moneroAccount =
        MoneroAccount.fromPrivateSpendKey(spendPrivateKey.key);
    final wifKey =
        CryptoKeyUtils.toWif(privateKey: spendPrivateKey.key, coin: coin);
    return MoneroPrivateKeyData.__(
      privateKey: spendPrivateKey.toHex(),
      extendedKey: null,
      coin: coin,
      wif: wifKey,
      keyName: keyName,
      viewPrivateKey: moneroAccount.privVkey,
      spendPrivateKey: moneroAccount.privateSpendKey,
      publicKey:
          MoneroPublicKeyData._(privateKey: spendPrivateKey, keyName: keyName),
    );
  }

  factory MoneroPrivateKeyData._fromExtendedKey(
      {required String extendedKey,
      required CryptoCoins coin,
      required String keyName}) {
    final account = CryptoKeyUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey, coin: coin);
    return MoneroPrivateKeyData._fromBip32(
        account: account, coin: coin, keyName: keyName);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          privateKey,
          extendedKey,
          wif ?? const CborNullValue(),
          keyName,
          publicKey.toCbor(),
          CborBytesValue(spendPrivateKey.key),
          CborBytesValue(viewPrivateKey.key),
        ]),
        type.tag);
  }

  @override
  Bip32Base toBipKey() {
    if (extendedKey == null) {
      return CryptoKeyUtils.privteKeyToBip32(
          privateKey: privateKey, coin: coin);
    }
    return CryptoKeyUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey!, coin: coin);
  }

  @override
  List<int> privateKeyBytes() {
    return BytesUtils.fromHexString(privateKey);
  }

  @override
  CryptoPrivateKeyDataType get type => CryptoPrivateKeyDataType.monero;
}
