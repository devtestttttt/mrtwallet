part of 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';

base mixin MoneroChainController
    on
        Chain<
            MoneroAPIProvider,
            MoneroNetworkParams,
            MoneroAddress,
            TokenCore,
            NFTCore,
            IMoneroAddress,
            WalletMoneroNetwork,
            MoneroClient,
            MoneroChainStorage,
            MoneroChainConfig,
            MoneroWalletTransaction,
            MoneroContact,
            MoneroNewAddressParams>,
        MoneroChainRepository {
  MoneroAccountBlocksTracker _defaultTracker =
      MoneroAccountBlocksTracker.start();
  @override
  MoneroAccountBlocksTracker get defaultTracker => _defaultTracker;

  MoneroSyncChain _syncChain = MoneroSyncChain.none;
  MoneroSyncChain get syncChain => _syncChain;
  @override
  MoneroAddressUtxos _accountUtxos = MoneroAddressUtxos();
  MoneroWalletClient? _walletClient;
  bool get syncIsActive => _syncChain.chain == network.coinParam.chainType;
  StreamSubscription? _blockSubscribe;

  Future<T?> _onWalletClient<T>({
    required Future<T> Function(MoneroWalletClient client) onConnect,
    Future<T?> Function(Object err)? onError,
  }) async {
    final client = _walletClient;
    if (client == null) return null;
    try {
      final init = await client.init();
      if (!init) {
        throw WalletException("node_connection_error");
      }
      return await onConnect(client);
    } catch (e) {
      return onError?.call(e);
    }
  }

  List<MoneroAccountIndex> relateAccountIndexes(
    MoneroViewPrimaryAccountDetails viewKey,
  ) {
    final accounts = relatedTxAccounts(viewKey);
    return accounts.map((e) => e.addrDetails.index).toList();
  }

  List<IMoneroAddress> relatedTxAccounts(
      MoneroViewPrimaryAccountDetails viewKey) {
    return addresses.where((e) => e.addrDetails.viewKey == viewKey).toList();
  }

  List<MoneroAddress> relatedAccountAddresses(
      MoneroViewPrimaryAccountDetails viewKey) {
    final accounts = relatedTxAccounts(viewKey);
    return accounts.map((e) => e.networkAddress).toList();
  }

  List<MoneroOutputDetails> getUtxos(MoneroViewPrimaryAccountDetails viewKey) {
    return _accountUtxos.getUtxos(viewKey);
  }

  List<MoneroAccountWithUtxo> relatedTxAccountsUtxos(
      MoneroViewPrimaryAccountDetails viewKey) {
    final utxos = _accountUtxos.getUtxos(viewKey);
    final addresses = relatedTxAccounts(viewKey);
    final List<MoneroAccountWithUtxo> existUtxos = [];
    for (final i in addresses) {
      final accountUtxos = utxos.where((e) => e.index == i.addrDetails.index);
      final addrUtxos = MoneroAccountWithUtxo(
        address: ReceiptAddress(
          view: i.networkAddress.address,
          networkAddress: i.networkAddress,
          account: i,
        ),
        utxos: accountUtxos
            .map(
              (e) => MoneroViewOutputDetails(
                  output: e,
                  amount: IntegerBalance.token(e.amount, network.token)),
            )
            .toList(),
      );
      existUtxos.add(addrUtxos);
    }
    return existUtxos;
  }

  List<MoneroAccountPendingTxes> getAccountsPendingTxes() {
    final List<MoneroAccountPendingTxes> accounts = [];
    for (final i in defaultTracker.accounts) {
      if (!i.hasTx) continue;
      final account = accountFromPrimaryAddress(i.primaryAccount);
      assert(account != null, "account does not exists.");
      if (account == null) continue;
      final indexees = i.indexes.where((e) => e.hasTx).map((e) => e.txes());
      accounts.add(MoneroAccountPendingTxes.request(
          primaryAddress: i.primaryAccount,
          indexes: indexees,
          accountIndex: account.keyIndex.cast()));
    }
    return accounts;
  }

  IMoneroAddress? accountFromPrimaryAddress(
      MoneroViewPrimaryAccountDetails address) {
    return addresses.firstWhereOrNull((e) => e.addrDetails.viewKey == address);
  }

  void _updateChainStatus() {
    final status = config.status;
    MoneroChainStatus updateStatus;
    if (haveAddress && defaultTracker.hasPendingTxes) {
      updateStatus = MoneroChainStatus.outputReceived;
    } else {
      updateStatus = MoneroChainStatus.none;
    }
    if (status != updateStatus) {
      updateConfig(config.copyWith(status: updateStatus));
    }
  }

  Future<void> addUnlockedPayment(
      List<MoneroAccountPendingTxes> payments) async {
    if (payments.isEmpty) return;
    await _callSynchronized(
      t: () async {
        for (final out in payments) {
          final relatedAccount = relatedTxAccounts(out.primaryAddress);
          assert(relatedAccount.isNotEmpty, "invalid utxo account");
          if (relatedAccount.isEmpty) continue;
          _accountUtxos.updateUtxos(out);
          defaultTracker.removeAccountPendingTxes(
              out.primaryAddress, out.indexes);
        }
        await _saveDefaultTracker();
        await _saveUtxos();
        _updateAddressBalance();
        _updateChainStatus();
      },
    );
    await _updateAaccountsBalances();
  }

  Future<void> _getWalletRpcTxes() async {
    await _onWalletClient(
      onConnect: (client) async {
        final txes = await client.readMoneroWalletTxes(this as MoneroChain);
        if (txes.isEmpty) return;
        for (final tx in txes) {
          if (tx.indexes.isEmpty) continue;
          final knownUtxos = _accountUtxos
              .getAccountUtxos(tx.primaryAddress)
              .map((e) => e.txId)
              .toList();
          List<MoneroAccountIndexTxes> pendingTxes = [];
          for (final i in tx.indexes) {
            if (i.txes.isEmpty) continue;
            final unknownTxes = i.txes.where((e) => !knownUtxos.contains(e));
            if (unknownTxes.isEmpty) continue;
            pendingTxes
                .add(MoneroAccountIndexTxes(index: i.index, txes: unknownTxes));
          }
          if (pendingTxes.isEmpty) continue;
          defaultTracker.addAccountPendingTxes(tx.primaryAddress, pendingTxes);
        }
        await _saveDefaultTracker();
        _updateChainStatus();
      },
    );
  }

  Future<void> _updateAaccountsBalances() async {
    await _getWalletRpcTxes();
    await onClient(
      onConnect: (client) async {
        final utxos = _accountUtxos.allUtxos;
        if (utxos.isEmpty) return;
        final keyImages = utxos.map((e) => e.keyImage).toList();
        if (keyImages.isEmpty) return;

        final status = await client.keyImagesStatus(keyImages);
        for (int i = 0; i < keyImages.length; i++) {
          _accountUtxos.updatePaymentStatus(utxos[i], status.spentStatus[i]);
        }
        final updateRequired = utxos.where((e) => e.needUpdate).toList();
        if (updateRequired.isNotEmpty) {
          final txes = await client.getTxesByTxIds(
            txIds: updateRequired.map((e) => e.txId).toList(),
          );
          for (int i = 0; i < txes.length; i++) {
            final tx = txes[i];
            final utxo = updateRequired[i];
            _accountUtxos.updateUtxoInfromation(
              utxo: utxo,
              outoutIndices: tx.outoutIndices,
              confirmations: tx.confirmations,
            );
          }
        }
        await _saveUtxos();
      },
    );
  }

  void _updateAddressBalance() {
    for (final i in _addresses) {
      final balance = _accountUtxos.getAddressBalance(i.addrDetails);
      _internalupdateAddressBalance(
        address: i,
        balance: balance,
        saveAccount: false,
      );
    }
    save();
  }

  /// update address balance
  /// -[address]: address for retrive and update balance
  @override
  Future<void> updateAddressBalance(
    IMoneroAddress address, {
    bool tokens = true,
    bool saveAccount = true,
  }) async {
    _isAccountAddress(address);
    await _updateAaccountsBalances();
    _updateAddressBalance();
    _syncBlock();
  }

  @override
  Future<IMoneroAddress> addNewAddress(
    CryptoPublicKeyData? publicKey,
    MoneroNewAddressParams accountParams,
  ) async {
    return _callSynchronized(
      t: () async {
        if (!network.coins.contains(accountParams.coin)) {
          throw WalletExceptionConst.invalidCoin;
        }
        final IMoneroAddress newAddress = accountParams.toAccount(
          network,
          publicKey,
        );

        final any = addresses.any((element) => element.isEqual(newAddress));
        if (any) {
          throw WalletExceptionConst.addressAlreadyExist;
        }
        _addresses = List.unmodifiable([..._addresses, newAddress]);
        defaultTracker.addAccount(newAddress.addrDetails);
        _accountUtxos.addNewAccount(newAddress.addrDetails);
        await _saveDefaultTracker();
        await _saveUtxos();
        return newAddress;
      },
      type: ChainNotify.address,
      saveAccount: true,
      notifyProgress: _addresses.isEmpty,
    );
  }

  @override
  Future<bool> removeAccount(IMoneroAddress address) async {
    _isAccountAddress(address);
    return _callSynchronized(
      notifyProgress: true,
      wait: true,
      t: () async {
        if (!haveAddress || !addresses.contains(address)) {
          return false;
        }
        final currentAddress = this.address;
        final currentAccounts = List<IMoneroAddress>.from(_addresses);
        currentAccounts.remove(address);
        _addresses = currentAccounts;
        _addressIndex = _addresses.indexOf(currentAddress);
        if (_addressIndex < 0) {
          _addressIndex = 0;
        }
        defaultTracker.removeAccount(
            account: address.addrDetails.viewKey,
            index: address.addrDetails.index);
        _accountUtxos.removeAccount(address.addrDetails);
        await _cleanAddressRepositories(address: address);
        await _saveDefaultTracker();
        await _saveUtxos();
        _refreshTotalBalance();
        await _initAddress(_addresses.elementAtOrNull(_addressIndex));
        _updateChainStatus();
        return true;
      },
      type: ChainNotify.address,
      saveAccount: true,
    );
  }

  void hideStatus() {
    updateConfig(config.copyWith(status: MoneroChainStatus.none));
  }

  Future<void> updateChainSyncOptions({
    required List<MoneroSyncAccountRequest> requests,
    required MoneroSyncChain chain,
  }) async {
    if (requests.isNotEmpty && chain.chain != network.coinParam.chainType) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (chain == _syncChain && requests.isEmpty) return;
    if (requests.isNotEmpty) {
      await onClient(
        onConnect: (client) async {
          final currentHeight = await client.getHeight();
          for (final i in requests) {
            final endHeight = i.endHeight;
            final startHeight = i.startHeight;
            if (endHeight > currentHeight.block) {
              throw WalletException(
                "monero_invalid_end_block_height_validator",
              );
            }
            if (startHeight < network.coinParam.rctHeight) {
              throw WalletExceptionConst.dataVerificationFailed;
            }

            final Map<MoneroViewPrimaryAccountDetails,
                List<MoneroSyncAccountIndexInfo>> syncAccounts = {};
            for (final account in i.addresses) {
              _isAccountAddress(account);
              final primary = account.addrDetails.primaryAccount();
              final index = MoneroSyncAccountIndexInfo(
                index: account.addrDetails.index,
                startHeight: startHeight,
              );
              if (syncAccounts.containsKey(primary)) {
                syncAccounts[primary]?.add(index);
              } else {
                syncAccounts[primary] = [index];
              }
            }
            final accounts = syncAccounts.keys
                .map(
                  (e) => MoneroSyncAccountsInfos(
                    primaryAccount: e,
                    indexes: syncAccounts[e]!,
                  ),
                )
                .toList();

            await defaultTracker.addSyncRequest(
              accounts: accounts,
              startHeight: startHeight,
              endHeight: endHeight,
            );
            await _saveDefaultTracker();
          }
        },
        onError: (err) => throw err,
      );
    }
    await _callSynchronized(
      t: () async {
        await _updateSyncChain(chain);
      },
      type: ChainNotify.account,
    );
  }

  Future<void> _updateSyncChain(MoneroSyncChain chain) async {
    if (chain != _syncChain) {
      await _saveSyncChain(chain);
      _syncChain = chain;
      if (syncIsActive) {
        await defaultTracker.resetTracker();
      }
    }
    _stopSyncBlock();
    _syncBlock();
  }

  Future<void> updateSyncChain(MoneroSyncChain chain) async {
    if (chain == _syncChain) return;
    await _callSynchronized(
      t: () async {
        await _updateSyncChain(chain);
      },
      type: ChainNotify.account,
    );
  }

  Future<void> saveWalletRpc(MoneroAPIProvider? provider) async {
    await _callSynchronized(
      t: () async {
        await _saveWalletRpc(provider);
        _walletClient?.dispose();
        _walletClient = null;
        _walletClient = await _getWalletClient();
      },
    );
  }

  Future<MoneroAPIProvider?> getWalletRPC() async {
    return await _callSynchronized(
      t: () async {
        return _getWalletRPC();
      },
    );
  }

  Future<void> removeSyncRequest(int requestId) async {
    await _callSynchronized(
      t: () async {
        final request = await defaultTracker.removeSyncRequest(requestId);
        if (request == null) return;
        await _saveDefaultTracker();
        if (request.status.isPending) {
          _stopSyncBlock();
          _syncBlock();
        }
      },
    );
  }

  void _stopSyncBlock() {
    if (_blockSubscribe != null) {
      _blockSubscribe?.cancel();
      _blockSubscribe = null;
      return;
    }
  }

  Future<void> _syncBlock() async {
    if (_blockSubscribe != null) return;
    await onClient(
      onError: (err) async {
        return null;
      },
      onConnect: (client) async {
        if (!syncIsActive || _blockSubscribe != null) return;
        final height = await client.getHeight();

        await defaultTracker.updateDefaultTrackerHeight(height.block);

        await _callSynchronized(
          t: () async {
            if (_blockSubscribe != null) return;

            final stream = await defaultTracker.getHeightRequest(
              onTrackerUpdated: () async {
                _saveDefaultTracker();
                _updateChainStatus();
              },
              onRequest: (processId, account) async {
                final MoneroAPIProvider provider = client.service.provider;
                final mode = WorkerMode.values.elementAt(processId + 1);
                final r = await crypto.streamRequest(
                  StreamRequestMoneroBlockTracking(provider: provider),
                  encryptedPart: account.toCbor().encode(),
                  mode: mode,
                );

                return r;
              },
            );
            _blockSubscribe = stream?.listen((a) {
              _blockSubscribe?.cancel();
              _blockSubscribe = null;
            });
          },
        );
      },
    );
  }

  Future<MoneroAccountBlocksTracker> _loadDefaultTracker() async {
    final tracker = await _getDefaultTracker();
    if (tracker.accounts.isEmpty && haveAddress) {
      for (final i in addresses) {
        tracker.addAccount(i.addrDetails);
      }
      await _saveDefaultTracker();
    }
    return tracker;
  }

  Future<MoneroAddressUtxos> _loadAccountsUtxos() async {
    final utxos = await _getAccountUtxos();
    if (utxos.addresses.isEmpty && haveAddress) {
      for (final i in addresses) {
        utxos.addNewAccount(i.addrDetails);
      }
      await _saveUtxos();
    }
    return utxos;
  }

  @override
  Future<void> _initInternal() async {
    await super._initInternal();
    _defaultTracker = await _loadDefaultTracker();
    _syncChain = await _getSyncChain();
    _walletClient = await _getWalletClient();
    _accountUtxos = await _loadAccountsUtxos();
  }
}
