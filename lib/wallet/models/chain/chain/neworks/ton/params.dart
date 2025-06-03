part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class TonNewAddressParams extends NewAccountParams<ITonAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;
  final TonAccountContext context;
  @override
  final AddressDerivationIndex deriveIndex;

  const TonNewAddressParams._(
      {required this.deriveIndex, required this.coin, required this.context})
      : super._();
  factory TonNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin,
      required TonAccountContext context}) {
    return TonNewAddressParams._(
        deriveIndex: deriveIndex, coin: coin, context: context);
  }

  factory TonNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.tonNewAddressParams.tag);
    return TonNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
      context: TonAccountContext.deserialize(
          object: values.elementAs<CborTagValue>(1)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }

  TonAddress _toAddress(
      {required List<int> publicKey, required TonChain chain}) {
    final wallet = context.toWalletContract(publicKey: publicKey, chain: chain);
    return wallet.address;
  }

  @override
  ITonAddress toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletTonNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final keyBytes = publicKey.keyBytes(immutable: true);
    final address =
        _toAddress(publicKey: keyBytes, chain: network.coinParam.chain);
    return ITonAddress._newAccount(
        publicKey: keyBytes,
        network: network,
        address: address,
        coin: coin,
        addressContext: context,
        identifier: NewAccountParams.toIdentifier(address.toRawAddress()),
        keyIndex: deriveIndex);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [deriveIndex.toCbor(), context.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.tonNewAddressParams;
}
