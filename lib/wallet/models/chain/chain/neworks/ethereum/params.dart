part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class EthereumNewAddressParams extends NewAccountParams<IEthAddress> {
  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  const EthereumNewAddressParams._(
      {required this.deriveIndex, required this.coin})
      : super._();
  factory EthereumNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin}) {
    return EthereumNewAddressParams._(deriveIndex: deriveIndex, coin: coin);
  }
  factory EthereumNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.ethereumNewAddressParamss.tag);
    return EthereumNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
      coin: CustomCoins.getSerializationCoin(values.elementAs(1)),
    );
  }

  @override
  IEthAddress toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletEthereumNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final keyBytes = publicKey.keyBytes(immutable: true);
    final address = ETHAddress.fromPublicKey(keyBytes);
    return IEthAddress._newAccount(
        address: address,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        keyIndex: deriveIndex,
        publicKey: keyBytes,
        network: network);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.ethereumNewAddressParamss;
}
