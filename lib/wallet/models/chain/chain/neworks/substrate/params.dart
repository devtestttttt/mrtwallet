part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class SubstrateNewAddressParams
    extends NewAccountParams<ISubstrateAddress> {
  @override
  bool get isMultiSig => false;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;

  @override
  final AddressDerivationIndex deriveIndex;

  const SubstrateNewAddressParams._({required this.deriveIndex}) : super._();
  factory SubstrateNewAddressParams(
      {required AddressDerivationIndex deriveIndex}) {
    return SubstrateNewAddressParams._(deriveIndex: deriveIndex);
  }

  factory SubstrateNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.substrateNewAddressParams.tag);
    return SubstrateNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
    );
  }

  // BaseSubstrateAddress toAddress(
  //     {required List<int> publicKey,
  //     required int ss58Format,
  //     required SubstrateChainType type}) {
  //   return SubstrateUtils.toAddress(
  //       publicKey: publicKey,
  //       ss58Format: ss58Format,
  //       curve: deriveIndex.currencyCoin.conf.type,
  //       isEthereum: type.isEthereum);
  // }

  @override
  ISubstrateAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletSubstrateNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final keyBytes = publicKey.keyBytes(immutable: true);
    final address = SubstrateUtils.toAddress(
        publicKey: keyBytes,
        ss58Format: network.coinParam.ss58Format,
        curve: coin.conf.type,
        isEthereum: network.coinParam.substrateChainType.isEthereum);
    return ISubstrateAddress._newAccount(
        publicKey: keyBytes,
        network: network,
        address: address,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        keyIndex: deriveIndex);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor()]), type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.substrateNewAddressParams;
}
