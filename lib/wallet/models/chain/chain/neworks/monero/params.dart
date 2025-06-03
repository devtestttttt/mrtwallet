part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class MoneroNewAddressParams extends NewAccountParams<IMoneroAddress> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  @override
  final CryptoCoins coin;
  final int minor;
  final int major;
  final MoneroViewAccountDetails? addrDetails;
  final MoneroNetwork network;

  const MoneroNewAddressParams._(
      {required this.deriveIndex,
      required this.minor,
      required this.major,
      required this.coin,
      this.addrDetails,
      required this.network})
      : super._();
  factory MoneroNewAddressParams(
      {required AddressDerivationIndex deriveIndex,
      required int minor,
      required int major,
      required CryptoCoins coin,
      MoneroViewAccountDetails? addrDetails,
      required MoneroNetwork network}) {
    return MoneroNewAddressParams._(
        deriveIndex: deriveIndex,
        minor: minor,
        major: major,
        coin: coin,
        network: network,
        addrDetails: addrDetails);
  }
  MoneroNewAddressParams copyWith(
      {CryptoCoins? coin,
      int? minor,
      int? major,
      AddressDerivationIndex? deriveIndex,
      MoneroViewAccountDetails? addrDetails,
      MoneroNetwork? network}) {
    return MoneroNewAddressParams(
        deriveIndex: deriveIndex ?? this.deriveIndex,
        minor: minor ?? this.minor,
        major: major ?? this.major,
        coin: coin ?? this.coin,
        addrDetails: addrDetails ?? this.addrDetails,
        network: network ?? this.network);
  }

  factory MoneroNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.moneroNewAddressParams.tag);
    return MoneroNewAddressParams(
        deriveIndex:
            AddressDerivationIndex.deserialize(obj: values.getCborTag(0)),
        major: values.elementAs(1),
        minor: values.elementAs(2),
        coin: CustomCoins.getSerializationCoin(values.elementAt(3)),
        addrDetails: values
            .getCborTag(4)
            ?.to((e) => MoneroViewAccountDetails.deserialize(object: e)),
        network: MoneroNetwork.fromName(values.elementAs(5)));
  }

  @override
  IMoneroAddress toAccount(
      WalletNetwork network, CryptoPublicKeyData? publicKey) {
    if (publicKey == null) {
      throw WalletExceptionConst.pubkeyRequired;
    }
    final addrDetails = this.addrDetails;
    if (addrDetails == null) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (network is! WalletMoneroNetwork) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    final address = addrDetails.toAddress(network);
    return IMoneroAddress._newAccount(
        network: network,
        address: address,
        addressDetails: addrDetails,
        coin: coin,
        identifier: NewAccountParams.toIdentifier(address.address),
        keyIndex: deriveIndex);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          deriveIndex.toCbor(),
          major,
          minor,
          coin.toCbor(),
          addrDetails?.toCbor(),
          network.name
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.moneroNewAddressParams;
}
