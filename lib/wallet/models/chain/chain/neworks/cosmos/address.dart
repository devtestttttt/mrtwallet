part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ICosmosAddress extends ChainAccount<CosmosBaseAddress, CW20Token,
    NFTCore, CosmosWalletTransaction> {
  ICosmosAddress._({
    required super.keyIndex,
    required super.coin,
    required List<int> publicKey,
    required super.address,
    required super.network,
    required super.networkAddress,
    super.accountName,
    required this.algorithm,
    required super.identifier,
  }) : publicKey = publicKey.asImmutableBytes;

  factory ICosmosAddress._newAccount({
    required List<int> publicKey,
    required WalletCosmosNetwork network,
    required CosmosKeysAlgs algorithm,
    required CosmosBaseAddress address,
    required CryptoCoins coin,
    required AddressDerivationIndex keyIndex,
    required String identifier,
  }) {
    final balance = AccountBalance(address: address.address, network: network);
    return ICosmosAddress._(
        coin: coin,
        publicKey: publicKey,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        algorithm: algorithm,
        identifier: identifier);
  }

  factory ICosmosAddress.deserialize(WalletCosmosNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.cosmosAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final List<int> publicKey = values.elementAs(2);
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(3));
    final CosmosBaseAddress cosmosAddr = CosmosBaseAddress(address.address,
        forceHrp: network.toNetwork<WalletCosmosNetwork>().coinParam.hrp);
    final int networkId = values.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAs(5);
    final algorithm = CosmosKeysAlgs.fromName(values.elementAs(6));
    final String identifier = values.elementAs(7);
    return ICosmosAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: cosmosAddr,
        network: networkId,
        accountName: accountName,
        algorithm: algorithm,
        identifier: identifier);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  final List<int> publicKey;

  final CosmosKeysAlgs algorithm;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          publicKey,
          address.toCbor(),
          network,
          accountName,
          algorithm.name,
          identifier
        ]),
        CborTagsConst.cosmosAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  String? get type => null;

  CosmosPublicKey toCosmosPublicKey() {
    return CosmosPublicKey.fromBytes(keyBytes: publicKey, algorithm: algorithm);
  }

  SignerInfo get signerInfo => SignerInfo(
      publicKey:
          CosmosPublicKey.fromBytes(keyBytes: publicKey, algorithm: algorithm)
              .toAny(),
      modeInfo: const ModeInfo(ModeInfoSignle(SignMode.signModeDirect)),
      sequence: BigInt.zero);

  @override
  String get orginalAddress => networkAddress.address;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! ICosmosAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  CosmosNewAddressParams toAccountParams() {
    return CosmosNewAddressParams(
        deriveIndex: keyIndex, coin: coin, algorithm: algorithm);
  }
}
