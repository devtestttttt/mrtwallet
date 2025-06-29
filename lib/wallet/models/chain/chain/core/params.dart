part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

enum NewAccountParamsType {
  bitcoinCashNewAddressParams(CborTagsConst.bitcoinCashNewAddressParams),
  bitcoinCashMultiSigNewAddressParams(
      CborTagsConst.bitcoinCashMultiSigNewAddressParams),
  bitcoinNewAddressParams(CborTagsConst.bitcoinNewAddressParams),
  bitcoinMultiSigNewAddressParams(
      CborTagsConst.bitcoinMultiSigNewAddressParams),
  cardanoNewAddressParams(CborTagsConst.cardanoNewAddressParams),
  cosmosNewAddressParams(CborTagsConst.cosmosNewAddressParams),
  ethereumNewAddressParamss(CborTagsConst.ethereumNewAddressParamss),
  solanaNewAddressParams(CborTagsConst.solanaNewAddressParams),
  substrateNewAddressParams(CborTagsConst.substrateNewAddressParams),
  tronNewAddressParams(CborTagsConst.tronNewAddressParams),
  tronMultisigNewAddressParams(CborTagsConst.tronMultisigNewAddressParams),
  tonNewAddressParams(CborTagsConst.tonNewAddressParams),
  rippleNewAddressParams(CborTagsConst.rippleNewAddressParams),
  rippleMultiSigNewAddressParams(CborTagsConst.rippleMultiSigNewAddressParams),
  stellarNewAddressParams(CborTagsConst.stellarNewAddressParams),
  moneroNewAddressParams(CborTagsConst.moneroNewAddressParams),

  suiNewAddressParams(CborTagsConst.suiNewAddressParams),
  suiMultisigNewAddressParams(CborTagsConst.suiMultisigNewAddressParams),
  aptosNewAddressParams(CborTagsConst.aptosNewAddressParams),
  aptosMultisigNewAddressParams(CborTagsConst.aptosMultisigNewAddressParams);

  final List<int> tag;
  const NewAccountParamsType(this.tag);
  static NewAccountParamsType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

abstract final class NewAccountParams<ACCOUNT extends ChainAccount>
    with CborSerializable {
  const NewAccountParams._();
  abstract final CryptoCoins coin;
  abstract final AddressDerivationIndex deriveIndex;
  abstract final NewAccountParamsType type;
  bool get isMultiSig;
  ACCOUNT toAccount(WalletNetwork network, CryptoPublicKeyData? publicKey);

  static String toIdentifier(String address) {
    final hash = MD4.hash(StringUtils.encode(address));
    return StringUtils.decode(hash, type: StringEncoding.base64UrlSafe);
  }

  factory NewAccountParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object, hex: hex);
    final type = NewAccountParamsType.fromTag(decode.tags);
    final NewAccountParams params;
    switch (type) {
      case NewAccountParamsType.bitcoinCashNewAddressParams:
        params = BitcoinCashNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.bitcoinCashMultiSigNewAddressParams:
        params =
            BitcoinCashMultiSigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.bitcoinNewAddressParams:
        params = BitcoinNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.bitcoinMultiSigNewAddressParams:
        params = BitcoinMultiSigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.cardanoNewAddressParams:
        params = CardanoNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.cosmosNewAddressParams:
        params = CosmosNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.ethereumNewAddressParamss:
        params = EthereumNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.solanaNewAddressParams:
        params = SolanaNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.substrateNewAddressParams:
        params = SubstrateNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.tronNewAddressParams:
        params = TronNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.tronMultisigNewAddressParams:
        params = TronMultisigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.tonNewAddressParams:
        params = TonNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.rippleNewAddressParams:
        params = RippleNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.rippleMultiSigNewAddressParams:
        params = RippleMultiSigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.stellarNewAddressParams:
        params = StellarNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.moneroNewAddressParams:
        params = MoneroNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.aptosNewAddressParams:
        params = AptosNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.suiNewAddressParams:
        params = SuiNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.suiMultisigNewAddressParams:
        params = SuiMultiSigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.aptosMultisigNewAddressParams:
        params = AptosMultiSigNewAddressParams.deserialize(object: decode);
        break;
    }
    if (params is! NewAccountParams<ACCOUNT>) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return params;
  }
}
