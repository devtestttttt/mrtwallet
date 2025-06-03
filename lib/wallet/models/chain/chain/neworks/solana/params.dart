part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class SolanaNewAddressParams extends NewAccountParams<ISolanaAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  SolanaNewAddressParams._({required this.deriveIndex, required this.coin})
      : super._();
  factory SolanaNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin}) {
    return SolanaNewAddressParams._(deriveIndex: deriveIndex, coin: coin);
  }

  factory SolanaNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.solanaNewAddressParams.tag);
    return SolanaNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(1)),
    );
  }

  @override
  ISolanaAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletSolanaNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final keyBytes = publicKey.keyBytes(immutable: true);
    final address = SolAddress.fromPublicKey(keyBytes);

    return ISolanaAddress._newAccount(
        publicKey: keyBytes,
        network: network,
        address: address,
        coin: coin,
        keyIndex: deriveIndex,
        identifier: NewAccountParams.toIdentifier(address.address));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.solanaNewAddressParams;
}
