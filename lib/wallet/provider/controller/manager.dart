// ignore_for_file: library_private_types_in_public_api

part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

mixin WalletManager on _WalletController {
  final Cancelable _balanceUpdaterCancelable = Cancelable();
  StreamSubscription<void>? _balanceUpdaterStream;

  /// emit unlocking walllet
  void _onUnlock() {}

  /// wallet lock timeout handler

  WStatus getStatus() {
    if (_walletKey != null) {
      return WStatus.unlock;
    }
    if (_wallet.requiredPassword) {
      return WStatus.lock;
    } else {
      return WStatus.readOnly;
    }
  }

  /// update wallet status
  void _setDefaultPageStatus() {
    _massterKey = null;
    _walletKey = null;
  }

  void _logout() {
    _setDefaultPageStatus();
  }

  /// unlock wallet
  Future<void> _login(String password) async {
    final storageKey = await crypto.cryptoIsolateRequest(
        CryptoRequestGenerateMasterKey.fromStorageWithStringKey(
            storageData: _wallet._data,
            key: password,
            checksum: _wallet._checksum));
    _massterKey = storageKey.masterKey;
    _walletKey = storageKey.walletKey;
    _onUnlock();
  }

  /// dervie new address for chain
  /// - [newAccountParams] New account parameters.
  /// - [chain] chain for derive new address
  Future<NETWORKCHAINACCOUNT<NETWORKADDRESS>> _deriveNewAccount<NETWORKADDRESS>(
      {required NewAccountParams newAccountParams,
      required APPCHAINNETWORK<NETWORKADDRESS> chain}) async {
    final NETWORKCHAINACCOUNT<NETWORKADDRESS> account;
    if (newAccountParams.isMultiSig) {
      account = await chain.addNewAddress(null, newAccountParams);
    } else {
      if (newAccountParams.deriveIndex.isMultiSig) {
        throw WalletExceptionConst.dataVerificationFailed;
      }
      final updateParams = await crypto.walletArgs(
          message: WalletRequestDeriveAddress(addressParams: newAccountParams),
          key: _walletKey!,
          encryptedMasterKey: _massterKey!.masterKey);
      account = await chain.addNewAddress(
          updateParams.publicKey, updateParams.accountParams);
    }
    return account;
  }

  /// import private key to current wallet
  /// -[newKey]: new private key for import to current wallet.
  /// =[password]: wallet password
  Future<void> _importNewKey(ImportedKeyStorage newKey, String password) async {
    final keyBytes = await _validatePassword(password);
    final encrypt = await crypto.walletArgs(
        message: WalletRequestImportNewKey(newKey),
        key: keyBytes,
        encryptedMasterKey: _massterKey!.masterKey);
    _massterKey = encrypt.masterKey;
    await _updateWallet(_wallet._updateData(encrypt.storageData));
  }

  /// - [removeKey]: private key from current wallet
  /// - [password]: wallet password
  Future<void> _removeKey(EncryptedCustomKey removeKey, String password) async {
    final keyBytes = await _validatePassword(password);
    if (!_massterKey!.customKeys.contains(removeKey)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    await _cleanUpdateRemovedKeyAccounts(removeKey.id);
    final encrypt = await crypto.walletArgs(
        message: WalletRequestRemoveKey(removeKey.id),
        key: keyBytes,
        encryptedMasterKey: _massterKey!.masterKey);
    _massterKey = encrypt.masterKey;
    await _updateWallet(_wallet._updateData(encrypt.storageData));
  }

  /// confirm the current wallet password
  /// - [password]: current wallet password.
  Future<List<int>> _validatePassword(String password) async {
    if (_walletKey == null) {
      throw WalletExceptionConst.walletIsLocked;
    }

    final keyBytes = await _core._toWalletPassword(password, _wallet._checksum);
    if (!BytesUtils.bytesEqual(keyBytes, _walletKey)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    return keyBytes;
  }

  /// change current wallet password.
  /// - [password]: current password
  /// - [newPassword]: new wallet password.
  Future<void> _changePassword(String password, String newPassword) async {
    if (!StrUtils.isStrongPassword(newPassword)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    if (password == newPassword) {
      throw WalletExceptionConst.passwordUsedBefore;
    }
    final keyBytes = await _validatePassword(password);
    final newKey =
        await _core._toWalletPassword(newPassword, _wallet._checksum);
    final encrypt = await crypto.cryptoIsolateRequest(
        CryptoRequestGenerateMasterKey.fromStorage(
            storageData: _wallet._data, key: keyBytes, newKey: newKey));
    await _updateWallet(_wallet._updateData(encrypt.storageData));
    _setDefaultPageStatus();
  }

  /// generate wallet backup
  /// - [type]: backup type (private keys, mnemonic or fully wallet backup)
  /// - [password]: current wallet password
  Future<String> _generateWalletKeyBackup(
      {required String data,
      required WalletBackupTypes type,
      required String password}) async {
    final encrypt = await crypto.cryptoIsolateRequest(CryptoRequestEncodeBackup(
        password: password,
        backup: type.toEncryptionBytes(data),
        encoding: type.encoding));
    if (type == WalletBackupTypes.keystore) {
      return encrypt;
    }
    final walletBackup = WalletKeyBackup(key: encrypt, type: type);
    return walletBackup.toCbor().toCborHex();
  }

  /// generate fully wallet backup
  /// -[password]: current wallet password
  Future<String> _generateWalletBackup(String password) async {
    final key = await _validatePassword(password);
    final encrypt = await crypto.walletArgs(
        message: WalletRequestBackupWallet(password),
        encryptedMasterKey: _massterKey!.masterKey,
        key: key);
    final List<WalletChainBackup> backupChains = [];
    final appChains = _appChains.chains();
    for (final i in appChains) {
      final chainBackup = await i.toBackup();
      backupChains.add(chainBackup);
    }
    final walletBackup = WalletBackup(key: encrypt, chains: backupChains);

    return walletBackup.toCbor().toCborHex();
  }

  /// get access key
  /// some operation required access key and need password like show private keys,
  /// remove wallet, read mnemonic and ....
  /// - [accsessType]: type of key to read.
  /// - [account]: read account private key if provided.
  /// - [keyId]: read imported private key if provided.
  Future<List<CryptoKeyData>> _accsess(WalletAccsessType accsessType,
      {ChainAccount? account, String? keyId}) async {
    if (accsessType.isUnlock && _walletKey != null) {
      return [FakeKeyData()];
    }
    if (accsessType.isAccsessKey && account == null && keyId == null) {
      throw WalletException.invalidArgruments(["ChainAccount", "null"]);
    }
    if (accsessType.isAccsessKey) {
      if (account != null) {
        final indexes = account.accessKeysIndexes();
        final accountKeys = await crypto.walletArgs(
            message: WalletRequestReadPrivateKeys(
                AccessCryptoPrivateKeysRequest(indexes
                    .map((e) => AccessCryptoPrivateKeyRequest(index: e))
                    .toList())),
            key: _walletKey!,
            encryptedMasterKey: _massterKey!.masterKey);
        return accountKeys;
      } else {
        final importedKey = await crypto.walletArgs(
            message: WalletRequestReadImportedKey(keyId!),
            key: _walletKey!,
            encryptedMasterKey: _massterKey!.masterKey);
        return [importedKey];
      }
    } else if (accsessType.isAccessMnemonic) {
      final mnemonic = await crypto.walletArgs(
          message: WalletRequestReadMnemonic(),
          key: _walletKey!,
          encryptedMasterKey: _massterKey!.masterKey);
      return [mnemonic];
    } else {
      return [FakeKeyData()];
    }
  }

  /// get address public key.
  /// does not work for multisig account.
  /// - [account]: account for retrive public key.
  Future<List<CryptoPublicKeyData>> _getAccountPubKys(
      {required ChainAccount account}) async {
    final indexes = account.accessKeysIndexes();
    final pubKeys = await crypto.walletArgs(
        message: WalletRequestReadPublicKeys(AccessCryptoPrivateKeysRequest(
            indexes
                .map((e) => AccessCryptoPrivateKeyRequest(index: e))
                .toList())),
        key: _walletKey!,
        encryptedMasterKey: _massterKey!.masterKey);
    return pubKeys;
  }

  /// signing request
  /// -[password]: required for protected wallet
  /// -[signers]: the key information for read.
  /// -[request]: callback method for provide message for signing
  Future<T> _signTransaction<T>(
      {required String? password,
      required Set<AddressDerivationIndex> signers,
      required WalletSigningRequest<T> request,
      Duration? timeout}) async {
    if (_wallet.protectWallet) {
      if (password == null) {
        throw WalletExceptionConst.incorrectPassword;
      }
      await _validatePassword(password);
    }

    final sign = await request.sign((request) async {
      if (!signers.contains(request.index)) {
        throw WalletExceptionConst.notAuthorizedSigningAccount;
      }
      return await crypto.walletArgs(
          message: WalletRequestSign(request),
          encryptedMasterKey: _massterKey!.masterKey,
          key: _walletKey!,
          timeout: timeout);
    });
    return sign;
  }

  /// find related imported key for coin
  /// -[derivationCoin]: find related imported key for this coin.
  List<EncryptedCustomKey> _getCustomKeysForCoin(CryptoCoins derivationCoin) {
    final List<EncryptedCustomKey> coins = [];
    final customKeys = _massterKey!.customKeys;
    for (final c in customKeys) {
      if (c.canUseFor(derivationCoin)) {
        coins.add(c);
      }
    }
    return coins.toSet().toImutableList;
  }

  /// get imported key private key
  /// -[password]: current wallet password.
  Future<List<EncryptedCustomKey>> _getImportedAccounts(String password) async {
    await _validatePassword(password);
    return List<EncryptedCustomKey>.from(_massterKey!.customKeys);
  }

  /// update wallet settings. like name, unlock time and security options
  /// -[walletInfos]: updated wallet information
  /// -[password]: current wallet password
  Future<void> _updateWalletInfos(
      {required WalletUpdateInfosData walletInfos,
      required String password}) async {
    await _validatePassword(password);
    final requiredPassword = _wallet.requiredPassword;
    final updatedWallet = _wallet._updateSettings(
        newLockTime: walletInfos.lockTime,
        reqPassword: walletInfos.requirmentPassword,
        newName: walletInfos.name,
        protectWallet: walletInfos.protectWallet);
    await _updateWallet(updatedWallet,
        asDefaultWallet: walletInfos.asDefaultWallet);
    if (!requiredPassword && _wallet.requiredPassword) {
      _setDefaultPageStatus();
    }
  }

  /// update or import new network to wallet
  /// -[network]: new or updated network
  Future<void> _updateImportNetwork(WalletNetwork network) async {
    await _appChains.updateImportNetwork(network);
  }

  /// remove network from wallet
  /// -[chain]: network for remove
  Future<void> _removeChain(Chain chain) async {
    await _appChains.removeChain(chain);
    await _core._removeAccount(chain);
  }

  /// update address balance
  /// -[account]: related chain
  /// -[address]: address for retrive and update balance
  Future<void> _updateAddressBalance(
      {required Chain account, required ChainAccount address}) async {
    await account.updateAddressBalance(address);
  }

  /// switch current wallet network
  Future<void> _switchNetwork(int changeNetwork) async {
    final change = await _appChains.switchNetwork(changeNetwork);
    if (change) {
      await _updateWallet(_wallet.updateNetwork(_appChains.network.value));
    }
  }

  /// internal wallet call, to safty get wallet keys and process
  Future<T?> _callWalletInternal<T>(
      Future<T> Function(
              {required List<int> masterKey, required List<int> wKey})
          t) async {
    final masterKey = _massterKey?.masterKey;
    final wKey = _walletKey;
    if (masterKey == null || wKey == null) {
      return null;
    }
    return t(masterKey: masterKey, wKey: wKey);
  }

  /// internal wallet request
  /// this method get wallet keys and run the wallet request message.
  Future<T> _walletRequest<T, A extends CborMessageResponseArgs>(
      {required WalletArgsCompleter<T, A> message,
      List<int>? masterkey,
      List<int>? walletKey}) async {
    return await crypto.walletArgs(
        message: message,
        encryptedMasterKey: masterkey ?? _massterKey!.masterKey,
        key: walletKey ?? _walletKey!);
  }

  /// clear account when removing imported key
  /// retrive all addresses create with current key and remove from wallet.
  /// -[removedKey]: imported key
  Future<void> _cleanUpdateRemovedKeyAccounts(String removedKey) async {
    final List<ChainAccount> removeList = [];
    final List<ChainAccount> accs = _appChains.accounts;
    for (final address in accs) {
      if (address.multiSigAccount) {
        final multiSigAccount = address as MultiSigCryptoAccountAddress;
        for (final i in multiSigAccount.keyDetails) {
          if (i.$2.importedKeyId == removedKey) {
            removeList.add(address);
            break;
          }
        }
      } else {
        if (address.keyIndex.importedKeyId == removedKey) {
          removeList.add(address);
        }
      }
    }

    if (removeList.isEmpty) return;
    for (final address in removeList) {
      final account = _appChains.fromAddress(address);
      if (account == null) {
        continue;
      }
      await account.removeAccount(address);
    }
  }

  /// init the wallet
  Future<void> _onInitController() async {
    await _chain.init();
    if (_core.isJsWallet) return;
    return;
    // final chains = _appChains.chains();
    // _balanceUpdaterStream = MethodUtils.prediocCaller(
    //         () async => await MethodUtils.call(() async {
    //               for (final chain in chains) {
    //                 if (!chain.haveAddress) continue;
    //                 await chain.init();
    //                 await _updateAccountBalance(chain);
    //                 if (chain != this._chain) {
    //                   chain.disposeProvider();
    //                 }
    //               }
    //             }),
    //         canclable: _balanceUpdaterCancelable,
    //         waitOnSuccess: const Duration(minutes: 10),
    //         waitOnError: const Duration(minutes: 1))
    //     .listen((s) {});
  }

  /// dispose wallet before switching wallet.
  void _dispose() {
    MethodUtils.nullOnException(() {
      _balanceUpdaterStream?.cancel();
      _balanceUpdaterStream = null;
      _balanceUpdaterCancelable.cancel();
    });
  }
}
