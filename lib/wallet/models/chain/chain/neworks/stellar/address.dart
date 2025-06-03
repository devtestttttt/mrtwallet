part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

enum StellarAddressType {
  muxedAddress("muxed_address"),
  pubkey("pubkey_address");

  final String value;
  const StellarAddressType(this.value);
}

final class IStellarAddress extends ChainAccount<StellarAddress,
    StellarIssueToken, NFTCore, StellarWalletTransaction> {
  IStellarAddress._(
      {required super.keyIndex,
      required super.coin,
      required List<int> publicKey,
      required super.address,
      required super.network,
      required super.networkAddress,
      required this.id,
      required super.identifier,
      super.accountName})
      : publicKey = publicKey.asImmutableBytes,
        addressType = id == null
            ? StellarAddressType.pubkey
            : StellarAddressType.muxedAddress;

  factory IStellarAddress._newAccount(
      {
      // required StellarNewAddressParams accountParams,
      required List<int> publicKey,
      required WalletStellarNetwork network,
      required StellarAddress address,
      required AddressDerivationIndex keyIndex,
      required CryptoCoins coin,
      required BigInt? muxId,
      required String identifier}) {
    final balance = AccountBalance(address: address.address, network: network);
    return IStellarAddress._(
        coin: coin,
        publicKey: publicKey,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        id: muxId,
        identifier: identifier);
  }

  factory IStellarAddress.deserialize(WalletStellarNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue toCborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);

    final CborListValue values = CborSerializable.cborTagValue(
        object: toCborTag, tags: CborTagsConst.stellarAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final List<int> publicKey = values.elementAs(2);
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(3));
    final StellarAddress stellarAddress =
        StellarAddress.fromBase32Addr(address.toAddress);

    final BigInt? id = values.elementAs(4);
    final int networkId = values.elementAs(5);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAs(6);
    final String identifier = values.elementAs(7);
    return IStellarAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: stellarAddress,
        network: networkId,
        id: id,
        accountName: accountName,
        identifier: identifier);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final List<int> publicKey;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          id,
          network,
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.stellarAccount);
  }

  @override
  List get variabels {
    return [id, keyIndex, network];
  }

  final StellarAddressType addressType;
  final BigInt? id;

  @override
  String get type => addressType.value;

  @override
  String get orginalAddress => networkAddress.baseAddress;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! IStellarAddress) return false;
    return networkAddress == other.networkAddress &&
        multiSigAccount == other.multiSigAccount;
  }

  @override
  StellarNewAddressParams toAccountParams() {
    return StellarNewAddressParams(deriveIndex: keyIndex, coin: coin, id: id);
  }
}
