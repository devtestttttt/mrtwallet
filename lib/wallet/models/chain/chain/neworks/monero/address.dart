part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class IMoneroAddress extends ChainAccount<MoneroAddress, TokenCore,
    NFTCore, MoneroWalletTransaction> {
  factory IMoneroAddress._newAccount({
    required WalletMoneroNetwork network,
    required MoneroAddress address,
    required MoneroViewAccountDetails addressDetails,
    required AddressDerivationIndex keyIndex,
    required CryptoCoins coin,
    required String identifier,
  }) {
    final balance = AccountBalance(address: address.address, network: network);
    return IMoneroAddress._(
        coin: coin,
        address: balance,
        identifier: identifier,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        addrDetails: addressDetails);
  }

  factory IMoneroAddress.deserialize(WalletMoneroNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.moneroAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final addrDetails =
        MoneroViewAccountDetails.deserialize(object: values.getCborTag(2));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(3));
    final networkAddress = MoneroAddress(address.toAddress);
    final int networkId = values.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? name = values.elementAs(5);
    final String identifier = values.elementAs(6);
    return IMoneroAddress._(
        coin: coin,
        address: address,
        keyIndex: keyIndex.cast(),
        networkAddress: networkAddress,
        network: network.value,
        accountName: name,
        addrDetails: addrDetails,
        identifier: identifier);
  }
  IMoneroAddress._(
      {required super.keyIndex,
      required super.coin,
      required super.networkAddress,
      required super.address,
      required super.network,
      required this.addrDetails,
      required super.identifier,
      super.accountName});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          keyIndex.toCbor(),
          addrDetails.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.moneroAccount);
  }

  final MoneroViewAccountDetails addrDetails;

  MoneroAddress get primaryAddress => addrDetails.viewKey.primaryAddress;

  @override
  List get variabels => [addrDetails, keyIndex, network];

  @override
  String accountToString() {
    return "${networkAddress.type.name}\n${address.toAddress}";
  }

  @override
  String get type => networkAddress.type.name;

  @override
  String get orginalAddress => networkAddress.address;

  @override
  bool isEqual(ChainAccount other) {
    if (other is! IMoneroAddress) return false;
    return networkAddress == other.networkAddress;
  }

  @override
  MoneroNewAddressParams toAccountParams() {
    return MoneroNewAddressParams(
        deriveIndex: keyIndex,
        major: addrDetails.index.major,
        minor: addrDetails.index.minor,
        addrDetails: addrDetails,
        coin: coin,
        network: addrDetails.viewKey.network);
  }

  // bool updateUtxos(List<MoneroOutputDetails> utxos) {
  //   final indexUtxos =
  //       utxos.where((e) => e.index == addrDetails.index).toList();
  //   if (indexUtxos.isEmpty) return false;
  //   _utxos.updateUtxos(indexUtxos);
  //   // final unspent = indexUtxos.where((e) => e.status.isUnspent);
  //   // final spent = indexUtxos.where((e) => e.status.isSpent);
  //   // final allUtxos =
  //   //     [...this.utxos, ...unspent].where((e) => !spent.contains(e));
  //   // _utxos = allUtxos.toSet().toImutableList;
  //   return true;
  // }

  // void replaceUtxos(List<MoneroOutputDetails> utxos) {
  //   final indexUtxos = utxos.where((e) => e.index == addrDetails.index);
  //   // _utxos = indexUtxos.toSet().toImutableList;
  //   _utxos.replaceUtxos(indexUtxos.toList());
  // }

  // void _setUtxos(MoneroAddressUtxos utxo) {
  //   _utxos = MoneroAddressUtxos();
  // }

  @override
  List<int>? get publicKey => addrDetails.viewKey.viewPrivateKey;
}
