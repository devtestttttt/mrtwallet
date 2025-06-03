part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ISolanaAddress extends ChainAccount<SolAddress, SolanaSPLToken,
    NFTCore, SolanaWalletTransaction> {
  ISolanaAddress._(
      {required super.keyIndex,
      required super.coin,
      required super.address,
      required super.network,
      required super.networkAddress,
      required super.identifier,
      super.accountName});

  factory ISolanaAddress._newAccount(
      {required List<int> publicKey,
      required WalletSolanaNetwork network,
      required AddressDerivationIndex keyIndex,
      required SolAddress address,
      required String identifier,
      required CryptoCoins coin}) {
    final balance = AccountBalance(address: address.address, network: network);
    return ISolanaAddress._(
        coin: coin,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        identifier: identifier);
  }

  factory ISolanaAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.solAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final SolAddress solAddress = SolAddress(address.toAddress);
    final int networkId = values.elementAt(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAs(4);
    final String identifier = values.elementAs(5);
    return ISolanaAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex,
        networkAddress: solAddress,
        network: networkId,
        accountName: accountName,
        identifier: identifier);
  }

  @override
  String accountToString() {
    return address.toAddress;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.solAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  List<int> get publicKey => networkAddress.toBytes();

  @override
  String? get type => null;

  @override
  String get orginalAddress => networkAddress.address;

  SolAddress associatedTokenAccount(
          {required SolAddress mint,
          SolAddress tokenProgramId = SPLTokenProgramConst.tokenProgramId}) =>
      AssociatedTokenAccountProgramUtils.associatedTokenAccount(
              mint: mint, owner: networkAddress, tokenProgramId: tokenProgramId)
          .address;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! ISolanaAddress) return false;
    return other.networkAddress == networkAddress;
  }

  @override
  SolanaNewAddressParams toAccountParams() {
    return SolanaNewAddressParams(deriveIndex: keyIndex, coin: coin);
  }
}
