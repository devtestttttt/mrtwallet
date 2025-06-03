part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class StellarNewAddressParams extends NewAccountParams<IStellarAddress> {
  @override
  bool get isMultiSig => false;

  EllipticCurveTypes get curve => coin.conf.type;
  @override
  final AddressDerivationIndex deriveIndex;

  final BigInt? id;
  @override
  final CryptoCoins coin;
  const StellarNewAddressParams._(
      {required this.deriveIndex, required this.coin, this.id})
      : super._();
  factory StellarNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin,
      BigInt? id}) {
    return StellarNewAddressParams._(
        deriveIndex: deriveIndex, coin: coin, id: id);
  }

  factory StellarNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.stellarNewAddressParams.tag);
    return StellarNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
      id: values.elementAs(1),
      coin: CustomCoins.getSerializationCoin(values.elementAs(2)),
    );
  }
  @override
  IStellarAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletStellarNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final keyBytes = publicKey.keyBytes(immutable: true);
    final BigInt? muxId = id;
    StellarAddress address;
    if (muxId != null) {
      address = StellarMuxedAddress.fromPublicKey(
          publicKey: keyBytes, accountId: muxId);
    } else {
      address = StellarAccountAddress.fromPublicKey(keyBytes);
    }
    return IStellarAddress._newAccount(
        publicKey: keyBytes,
        network: network,
        address: address,
        coin: coin,
        muxId: muxId,
        keyIndex: deriveIndex,
        identifier: NewAccountParams.toIdentifier(address.address));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), id, coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.stellarNewAddressParams;
}
