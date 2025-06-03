part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class IEthAddress extends ChainAccount<ETHAddress, ETHERC20Token, NFTCore,
    EthWalletTransaction> {
  IEthAddress._(
      {required super.keyIndex,
      required super.coin,
      required super.address,
      required super.network,
      required super.networkAddress,
      required super.identifier,
      required List<int> publicKey,
      super.accountName})
      : publicKey = publicKey.asImmutableBytes;

  factory IEthAddress._newAccount({
    required List<int> publicKey,
    required WalletEthereumNetwork network,
    required CryptoCoins coin,
    required ETHAddress address,
    required String identifier,
    required AddressDerivationIndex keyIndex,
  }) {
    final balance = AccountBalance(address: address.address, network: network);
    return IEthAddress._(
        coin: coin,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        publicKey: publicKey,
        identifier: identifier);
  }

  factory IEthAddress.deserialize(WalletEthereumNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.ethAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final ETHAddress ethAddress = ETHAddress(address.toAddress);
    final int networkId = values.elementAs(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }

    final String? accountName = values.elementAs(4);
    final List<int> publicKey = values.elementAs(5);
    final String identifier = values.elementAs(6);
    return IEthAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex,
        networkAddress: ethAddress,
        network: networkId,
        accountName: accountName,
        publicKey: publicKey,
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
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          CborBytesValue(publicKey),
          identifier
        ]),
        CborTagsConst.ethAccount);
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
    if (other is! IEthAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  EthereumNewAddressParams toAccountParams() {
    return EthereumNewAddressParams(deriveIndex: keyIndex, coin: coin);
  }
}
