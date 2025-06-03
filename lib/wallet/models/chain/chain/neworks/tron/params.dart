part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class TronNewAddressParams extends NewAccountParams<ITronAddress> {
  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  TronNewAddressParams._({required this.deriveIndex, required this.coin})
      : super._();
  factory TronNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required CryptoCoins coin}) {
    return TronNewAddressParams._(deriveIndex: deriveIndex, coin: coin);
  }
  factory TronNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.tronNewAddressParams.tag);
    return TronNewAddressParams(
      deriveIndex:
          AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
      coin: CustomCoins.getSerializationCoin(values.elementAt(1)),
    );
  }
  @override
  ITronAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    if (network is! WalletTronNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final keyBytes = publicKey.keyBytes(immutable: true);
    final address = TronAddress.fromPublicKey(keyBytes);
    return ITronAddress._newAccount(
        publicKey: keyBytes,
        network: network,
        address: address,
        keyIndex: deriveIndex,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.toAddress()));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.tronNewAddressParams;
}

final class TronMultisigNewAddressParams implements TronNewAddressParams {
  TronMultisigNewAddressParams._(
      {required this.multiSigAccount,
      required this.masterAddress,
      required this.coin});
  factory TronMultisigNewAddressParams(
      {required TronMultiSignatureAddress multiSigAccount,
      required TronAddress masterAddress,
      required CryptoCoins coin}) {
    return TronMultisigNewAddressParams._(
        multiSigAccount: multiSigAccount,
        masterAddress: masterAddress,
        coin: coin);
  }
  @override
  bool get isMultiSig => true;

  final TronAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex = MultiSigAddressIndex();

  final TronMultiSignatureAddress multiSigAccount;
  @override
  final CryptoCoins coin;

  factory TronMultisigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.tronMultisigNewAddressParams.tag);
    return TronMultisigNewAddressParams(
      masterAddress: TronAddress(values.elementAs(0)),
      multiSigAccount: values
          .getCborTag(1)!
          .to((e) => TronMultiSignatureAddress.deserialize(obj: e)),
      coin: CustomCoins.getSerializationCoin(values.elementAs(2)),
    );
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterAddress.toAddress(),
          multiSigAccount.toCbor(),
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  ITronMultisigAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (network is! WalletTronNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    return ITronMultisigAddress._newAccount(
        address: masterAddress,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(masterAddress.toAddress()),
        multiSigAccount: multiSigAccount,
        network: network);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.tronMultisigNewAddressParams;
}
