part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

final class ITronAddress extends ChainAccount<TronAddress, TronToken, NFTCore,
    TronWalletTransaction> {
  ITronAddress._(
      {required super.keyIndex,
      required super.coin,
      required List<int> publicKey,
      required super.address,
      required super.network,
      required super.networkAddress,
      required super.identifier,
      super.accountName})
      : publicKey = List.unmodifiable(publicKey);

  factory ITronAddress._newAccount({
    required List<int> publicKey,
    required WalletTronNetwork network,
    required TronAddress address,
    required String identifier,
    required AddressDerivationIndex keyIndex,
    required CryptoCoins coin,
  }) {
    final balance =
        AccountBalance(address: address.toAddress(), network: network);
    return ITronAddress._(
        coin: coin,
        publicKey: publicKey,
        address: balance,
        keyIndex: keyIndex,
        networkAddress: address,
        network: network.value,
        identifier: identifier);
  }

  factory ITronAddress.deserialize(WalletTronNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue toCborTag =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    if (BytesUtils.bytesEqual(
        toCborTag.tags, CborTagsConst.tronMultisigAccount)) {
      return ITronMultisigAddress.deserialize(network, obj: toCborTag);
    }
    final CborListValue values = CborSerializable.cborTagValue(
        object: toCborTag, tags: CborTagsConst.tronAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final keyIndex =
        AddressDerivationIndex.deserialize(obj: values.getCborTag(1));
    final List<int> publicKey = values.elementAt(2);
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(3));

    final TronAddress tronAddress = TronAddress(address.toAddress);
    final int networkId = values.elementAs(4);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final String? accountName = values.elementAs(5);
    final String identifier = values.elementAs(6);

    return ITronAddress._(
        coin: coin,
        publicKey: publicKey,
        address: address,
        keyIndex: keyIndex,
        networkAddress: tronAddress,
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
        CborTagsConst.tronAccount);
  }

  @override
  List get variabels {
    return [keyIndex, network];
  }

  @override
  String? get type => null;

  TronAccountResourceInfo? _accountResource;
  TronAccountResourceInfo? get accountResource => _accountResource;
  TronAccountInfo? _account;
  TronAccountInfo? get accountInfo => _account;

  void _setAccountResource(TronAccountResourceInfo? accResource) {
    _accountResource = accResource;
  }

  void _setTronAccount(TronAccountInfo? tronAcc) {
    _account = tronAcc;

    address._updateAddressBalance(_account?.balance ?? BigInt.zero);
    if (tronAcc != null) {
      final trc10Tokens = _tokens.where((e) => e.tronTokenType.isTrc10);
      for (final i in trc10Tokens) {
        final balance =
            tronAcc.assetV2.firstWhereNullable((e) => i.issuer == e.key);
        i._updateBalance(balance?.value ?? BigInt.zero);
      }
    }
  }

  @override
  String get orginalAddress => networkAddress.toAddress();

  @override
  bool isEqual(ChainAccount other) {
    return multiSigAccount == other.multiSigAccount &&
        orginalAddress == other.orginalAddress;
  }

  @override
  TronNewAddressParams toAccountParams() {
    return TronNewAddressParams(deriveIndex: keyIndex, coin: coin);
  }
}

final class ITronMultisigAddress extends ITronAddress
    implements MultiSigCryptoAccountAddress {
  ITronMultisigAddress._(
      {required super.address,
      required super.network,
      required super.coin,
      required super.networkAddress,
      required super.identifier,
      required this.multiSignatureAccount,
      super.accountName})
      : super._(keyIndex: MultiSigAddressIndex(), publicKey: const []);

  factory ITronMultisigAddress._newAccount({
    // required TronMultisigNewAddressParams accountParams,
    required CryptoCoins coin,
    required TronAddress address,
    required TronMultiSignatureAddress multiSigAccount,
    required WalletTronNetwork network,
    required String identifier,
  }) {
    final balance =
        AccountBalance(address: address.toAddress(), network: network);

    return ITronMultisigAddress._(
        coin: coin,
        multiSignatureAccount: multiSigAccount,
        address: balance,
        networkAddress: address,
        network: network.value,
        accountName: null,
        identifier: identifier);
  }

  factory ITronMultisigAddress.deserialize(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.tronMultisigAccount);
    final CryptoCoins coin =
        CustomCoins.getSerializationCoin(values.elementAs(0));
    final TronMultiSignatureAddress multiSignatureAddress =
        TronMultiSignatureAddress.deserialize(obj: values.getCborTag(1));
    final AccountBalance address =
        AccountBalance.deserialize(network, obj: values.getCborTag(2));
    final TronAddress ethAddress = TronAddress(address.toAddress);
    final int networkId = values.elementAt(3);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }

    final String? accountName = values.elementAs(4);
    final String identifier = values.elementAs(5);
    return ITronMultisigAddress._(
        coin: coin,
        multiSignatureAccount: multiSignatureAddress,
        address: address,
        networkAddress: ethAddress,
        network: networkId,
        accountName: accountName,
        identifier: identifier);
  }
  final TronMultiSignatureAddress multiSignatureAccount;
  @override
  List<int> get publicKey => throw UnimplementedError();

  @override
  List get variabels {
    return [keyIndex, network, multiSignatureAccount];
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.toCbor(),
          multiSignatureAccount.toCbor(),
          address.toCbor(),
          network,
          accountName ?? const CborNullValue(),
          identifier
        ]),
        CborTagsConst.tronMultisigAccount);
  }

  @override
  bool get multiSigAccount => true;

  @override
  List<(String, Bip32AddressIndex)> get keyDetails =>
      multiSignatureAccount.signers
          .map((e) => (e.publicKey, e.keyIndex))
          .toList();
  @override
  List<Bip32AddressIndex> signerKeyIndexes() {
    return keyDetails.map((e) => e.$2).toList();
  }

  @override
  TronMultisigNewAddressParams toAccountParams() {
    return TronMultisigNewAddressParams(
        coin: coin,
        masterAddress: networkAddress,
        multiSigAccount: multiSignatureAccount);
  }

  @override
  IAdressType get iAddressType => IAdressType.multisigByAddress;
}
