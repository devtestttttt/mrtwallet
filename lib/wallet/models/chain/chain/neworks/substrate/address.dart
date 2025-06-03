part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ISubstrateAddress extends ChainAccount<BaseSubstrateAddress,
    TokenCore, NFTCore, SubstrateWalletTransaction> {
  ISubstrateAddress._(
      {required super.keyIndex,
      required super.coin,
      required List<int> publicKey,
      required super.address,
      required super.network,
      required super.networkAddress,
      required super.identifier,
      super.accountName})
      : publicKey = publicKey.asImmutableBytes;

  factory ISubstrateAddress._newAccount({
    required List<int> publicKey,
    required WalletSubstrateNetwork network,
    required BaseSubstrateAddress address,
    required CryptoCoins coin,
    required AddressDerivationIndex keyIndex,
    required String identifier,
  }) {
    final balance = AccountBalance(address: address.address, network: network);
    return ISubstrateAddress._(
        coin: coin,
        publicKey: publicKey,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        identifier: identifier);
  }
  factory ISubstrateAddress.deserialize(WalletSubstrateNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.substrateAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final List<int> publicKey = values.elementAs(2);
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(3));
    final BaseSubstrateAddress addr = BaseSubstrateAddress(address.toAddress);
    final int networkId = values.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAt(5);
    final String identifier = values.elementAs(6);
    return ISubstrateAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: addr,
        network: networkId,
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
          network,
          accountName ?? const CborNullValue(),
          identifier,
        ]),
        CborTagsConst.substrateAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  String? get type => null;

  @override
  String get orginalAddress => networkAddress.address;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! ISubstrateAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  SubstrateNewAddressParams toAccountParams() {
    return SubstrateNewAddressParams(deriveIndex: keyIndex);
  }
}
