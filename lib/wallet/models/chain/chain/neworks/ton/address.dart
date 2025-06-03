part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ITonAddress extends ChainAccount<TonAddress, TonJettonToken,
    NFTCore, TonWalletTransaction> {
  ITonAddress._({
    required super.keyIndex,
    required super.coin,
    required List<int> publicKey,
    required super.address,
    required super.network,
    required super.networkAddress,
    required this.context,
    required super.identifier,
    super.accountName,
  }) : publicKey = List.unmodifiable(publicKey);

  factory ITonAddress._newAccount({
    // required TonNewAddressParams accountParams,
    required List<int> publicKey,
    required WalletTonNetwork network,
    required CryptoCoins coin,
    required TonAddress address,
    required String identifier,
    required AddressDerivationIndex keyIndex,
    required TonAccountContext addressContext,
  }) {
    final balance = AccountBalance(
        address:
            address.toFriendlyAddress(bounceable: addressContext.bouncable),
        network: network);
    return ITonAddress._(
        coin: coin,
        publicKey: publicKey,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        context: addressContext,
        identifier: identifier);
  }

  factory ITonAddress.deserialize(WalletTonNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.tonAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(cbor.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: cbor.getCborTag(1));
    final List<int> publicKey = cbor.elementAs(2);
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: cbor.getCborTag(3));
    final TonAddress tonAddress = TonAddress(address.toAddress);
    final int networkId = cbor.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = cbor.elementAs(5);
    final context =
        TonAccountContext.deserialize(object: cbor.elementAs<CborTagValue>(6));
    final String identifier = cbor.elementAs(7);
    return ITonAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: tonAddress,
        network: networkId,
        accountName: accountName,
        context: context,
        identifier: identifier);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  final TonAccountContext context;

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
          context.toCbor(),
          identifier,
        ]),
        CborTagsConst.tonAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network, context];
  }

  @override
  late final String? type =
      "${networkAddress.type.name} (${context.version.name})";

  @override
  late final String orginalAddress = networkAddress.toRawAddress();

  VersionedWalletContract toWalletContract() {
    return context.toWalletContract(
        publicKey: publicKey,
        chain: TonChain.fromWorkchain(networkAddress.workChain));
  }

  @override
  bool isEqual(ChainAccount other) {
    if (other is! ITonAddress) return false;
    return context == other.context &&
        BytesUtils.bytesEqual(other.networkAddress.hash, networkAddress.hash);
  }

  @override
  TonNewAddressParams toAccountParams() {
    return TonNewAddressParams(
        deriveIndex: keyIndex, coin: coin, context: context);
  }
}
