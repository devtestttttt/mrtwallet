part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

mixin ChainRepository<
    ADDRESS extends ChainAccount,
    NETWORK extends WalletNetwork,
    CLIENT extends NetworkClient,
    STORAGE extends ChainStorageKey,
    CONFIG extends ChainConfig,
    TOKEN extends TokenCore,
    NFT extends NFTCore,
    TRANSACTION extends ChainTransaction,
    CONTACT extends ContactCore,
    ADDRESSPARAM extends NewAccountParams> {
  Future<CLIENT?> clientOrNull();
  ChainStorageManager get _storage;
  NETWORK get network;

  Future<List<CONTACT>> _getContacts() async {
    final storagekey = _storage.config.contactsStorageKey;
    final data = await _storage.readStorages(storage: storagekey);
    final contacts = data
        .map((e) => ContactCore.deserialize<CONTACT>(network, bytes: e))
        .toList()
        .whereType<CONTACT>()
        .toList();
    assert(
        contacts.length == data.length, "some contact deserialization failed.");
    return contacts;
  }

  Future<void> _saveContact(CONTACT cotact) async {
    final storageKey = _storage.config.contactsStorageKey;
    await _storage.writeStorageItem(
        storage: storageKey, item: cotact, identifier: cotact.identifier);
  }

  Future<void> _removeContact(CONTACT contact) async {
    final storageKey = _storage.config.contactsStorageKey;
    await _storage.writeStorageItem(
        storage: storageKey, item: null, identifier: contact.identifier);
  }

  ///

  Future<List<TOKEN>> _getTokens(ADDRESS address) async {
    final storagekey = _storage.config.tokenStorageKey;
    assert(address.network == network.value, "address does not exists");
    if (storagekey == null || address.network != network.value) return [];
    final data = await _storage.readAccountStorages(
        account: address, storageKey: storagekey);
    final tokens = data
        .map((e) => TokenCore.deserialize<TOKEN>(bytes: e))
        .toList()
        .whereType<TOKEN>()
        .toList();
    assert(tokens.length == data.length, "some token deserialization failed.");
    return tokens;
  }

  Future<void> _saveToken(
      {required ADDRESS address, required TOKEN token}) async {
    final storageKey = _storage.config.tokenStorageKey;
    assert(storageKey != null, "unknown token storage key");
    assert(address.tokens.contains(token), 'asset not found an account');
    assert(address.network == network.value, "address does not exists");
    if (storageKey == null ||
        !address.tokens.contains(token) ||
        address.network != network.value) {
      return;
    }
    await _storage.writeAccountStorage(
        account: address,
        storageKey: storageKey,
        item: token,
        identifier: token.identifier);
  }

  Future<void> _removeToken(
      {required ADDRESS address, required TOKEN token}) async {
    final storageKey = _storage.config.tokenStorageKey;
    assert(storageKey != null, "unknown token storage key");
    assert(address.tokens.contains(token), 'asset not found an account');
    assert(address.network == network.value, "address does not exists");
    if (storageKey == null ||
        !address.tokens.contains(token) ||
        address.network != network.value) {
      return;
    }

    await _storage.writeAccountStorage(
        account: address,
        storageKey: storageKey,
        item: null,
        identifier: token.identifier);
  }

  Future<void> _cleanAddressRepositories({required ADDRESS address}) async {
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) return;
    final storages = _storage.config.addressStorage;
    for (final i in storages) {
      await _storage.cleanAddressStorage(account: address, storageKey: i);
    }
  }

  Future<List<NFT>> _getNfts(ADDRESS address) async {
    final storagekey = _storage.config.nftStorageKey;
    if (storagekey == null) return [];
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) {
      return [];
    }
    final data = await _storage.readAccountStorages(
        account: address, storageKey: storagekey);
    final nfts = data
        .map((e) => MethodUtils.nullOnException(
            () => NFTCore.deserialize<NFT>(bytes: e)))
        .toList()
        .whereType<NFT>()
        .toList();
    assert(nfts.length == data.length, "some nft deserialization failed.");
    return nfts;
  }

  Future<void> _saveNFT({required ADDRESS address, required NFT nft}) async {
    final storageKey = _storage.config.nftStorageKey;
    assert(address.nfts.contains(nft), 'asset not found an account');
    assert(storageKey != null, "unknown nft storage key");
    assert(address.network == network.value, "address does not exists");
    if (storageKey == null ||
        !address.nfts.contains(nft) ||
        address.network != network.value) {
      return;
    }
    await _storage.writeAccountStorage(
        account: address,
        storageKey: storageKey,
        item: nft,
        identifier: nft.identifier);
  }

  Future<void> _removeNFT({required ADDRESS address, required NFT nft}) async {
    final storageKey = _storage.config.nftStorageKey;
    assert(storageKey != null, "unknown nft storage key");
    assert(address.nfts.contains(nft), 'asset not found an account');
    assert(address.network == network.value, "address does not exists");
    if (storageKey == null ||
        !address.nfts.contains(nft) ||
        address.network != network.value) {
      return;
    }
    await _storage.writeAccountStorage(
        account: address,
        storageKey: storageKey,
        item: null,
        identifier: nft.identifier);
  }

  Future<List<TRANSACTION>> _getTransactions(ADDRESS address) async {
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) {
      return [];
    }
    final data = await _storage.readAccountStorages(
        account: address, storageKey: _storage.config.transactionStorageKey);
    final txes = data
        .map((e) => MethodUtils.nullOnException(
            () => ChainTransaction.deserialize<TRANSACTION>(network, bytes: e)))
        .toList()
        .whereType<TRANSACTION>()
        .toList();
    assert(
        txes.length == data.length, "some transaction deserialization failed.");
    return txes;
  }

  Future<void> _saveTransaction(
      {required ADDRESS address, required TRANSACTION transaction}) async {
    assert(address.network == network.value, "address does not exists");
    if (address.network != network.value) {
      return;
    }
    await _storage.writeAccountStorage(
        account: address,
        storageKey: _storage.config.transactionStorageKey,
        item: transaction,
        identifier: transaction.txId);
  }

  Future<void> _removeTransaction(
      {required ADDRESS address, required TRANSACTION transaction}) async {
    assert(address.network == network.value, "address does not exists");
    assert(address.transactions.contains(transaction),
        "transaction does not exists");
    if (address.network != network.value ||
        !address.transactions.contains(transaction)) {
      return;
    }
    await _storage.writeAccountStorage(
        account: address,
        storageKey: _storage.config.transactionStorageKey,
        item: null,
        identifier: transaction.txId);
  }
}
