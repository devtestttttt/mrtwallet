part of 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';

final class MoneroPublicKeyData extends CryptoPublicKeyData {
  @override
  final String? extendedKey;
  @override
  final String comprossed;
  @override
  final String? uncomprossed = null;
  final MoneroPublicKey spendPublicKey;
  final MoneroPublicKey viewPublicKey;
  final MoneroPrivateKey viewPrivateKey;
  @override
  final String? chainCode;
  @override
  final String keyName;

  @override
  PublicKeysView get toViewKey => MoneroPublicKeysView._(
      extendKey: extendedKey,
      comprossed: comprossed,
      uncomprossed: uncomprossed,
      chainCode: chainCode,
      spendPublicKey: spendPublicKey.toHex(),
      viewPublicKey: viewPublicKey.toHex(),
      keyName: keyName,
      keyType: type);

  MoneroPublicKeyData.__(
      {required this.extendedKey,
      required this.keyName,
      required this.spendPublicKey,
      required this.viewPublicKey,
      required this.viewPrivateKey,
      required this.chainCode,
      required this.comprossed})
      : super._();
  factory MoneroPublicKeyData._fromBip32(
      {required Bip32Base account, required String keyName}) {
    final moneroAccount =
        MoneroAccount.fromBip44PrivateKey(account.privateKey.raw);
    return MoneroPublicKeyData.__(
        extendedKey: account.publicKey.toExtended,
        keyName: keyName,
        chainCode: account.chainCode.toHex(),
        spendPublicKey: moneroAccount.publicSpendKey,
        viewPrivateKey: moneroAccount.privateViewKey,
        viewPublicKey: moneroAccount.publicViewKey,
        comprossed: account.publicKey.toHex());
  }
  factory MoneroPublicKeyData._(
      {required MoneroPrivateKey privateKey, required String keyName}) {
    final moneroAccount = MoneroAccount.fromPrivateSpendKey(privateKey.key);
    return MoneroPublicKeyData.__(
        extendedKey: null,
        keyName: keyName,
        chainCode: null,
        spendPublicKey: moneroAccount.publicSpendKey,
        viewPrivateKey: moneroAccount.privateViewKey,
        viewPublicKey: moneroAccount.publicViewKey,
        comprossed: moneroAccount.publicSpendKey.toHex());
  }
  factory MoneroPublicKeyData.deserialize({List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CryptoKeyConst.accessMoneroPublicKeyResponse);
    return MoneroPublicKeyData.__(
        extendedKey: values.elementAs(0),
        keyName: values.elementAs(1),
        chainCode: values.elementAs(2),
        spendPublicKey: MoneroPublicKey.fromBytes(values.elementAs(3)),
        viewPrivateKey: MoneroPrivateKey.fromBytes(values.elementAs(4)),
        viewPublicKey: MoneroPublicKey.fromBytes(values.elementAs(5)),
        comprossed: values.elementAs(6));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          extendedKey,
          keyName,
          chainCode,
          CborBytesValue(spendPublicKey.key),
          CborBytesValue(viewPrivateKey.key),
          CborBytesValue(viewPublicKey.key),
          comprossed
        ]),
        type.tag);
  }

  @override
  CryptoPublicKeyDataType get type => CryptoPublicKeyDataType.monero;
}
