part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

abstract class WalletStateController {
  List<String> coinIds();
  Future<bool> onWeb3Request(Web3Request request);
}

abstract class _WalletCore extends WalletStateController
    with CryptoWokerImpl, WalletStorageWriter, WalletsStoragesManger {}

abstract class WalletCore extends _WalletCore with WalletsManager {
  int get storageVersion;

  @override
  bool get useMemoryStorage => false;
  bool get isJsWallet => false;

  Chain get currentChain => _controller._appChains.chain;
  WalletNetwork get network => _controller.network;
  WalletNetwork? networkById(int id) =>
      _controller._appChains._networks[id]?.network;
  HDWallet get wallet => _controller._wallet;
  List<HDWallet> get wallets => _wallets._wallets.values.toList()
    ..sort((a, b) => b.created.compareTo(a.created));
  String? get defaultWalletId => _wallets.defaultWallet;
  final _lockWeb3 = SynchronizedLock();

  int? get reminingWalletTime => _timeout.remining;

  @override
  List<String> coinIds() =>
      homePageStatus.isOpen ? _controller._appChains.coinIds() : [];

  Future<MethodResult<void>> setup(
      {required HDWallet hdWallet,
      required String password,
      required WalletUpdateInfosData walletInfos}) async {
    final result = await _callSynchronized(() async {
      return await _setup(
          hdWallet: hdWallet, password: password, walletInfos: walletInfos);
    }, conditionStatus: true, progress: true);
    return result;
  }

  Future<MethodResult<void>> setupBackup(
      {required WalletRestoreV2 backup,
      required String password,
      required WalletUpdateInfosData walletInfos}) async {
    return await _callSynchronized(() async {
      await _setup(
          hdWallet: backup.wallet,
          password: password,
          walletInfos: walletInfos,
          chains: backup.chains);
    }, conditionStatus: true, progress: true);
  }

  Future<MethodResult<Web3EncryptedMessage>> web3Request(
      Web3RequestApplicationInformation request) async {
    final result = await _callSynchronized(() async {
      return await _controller._web3Request(request);
    }, conditionStatus: true, lock: _lockWeb3);
    return result;
  }

  Future<RESPONSE> localWeb3Request<RESPONSE>(
      WEB3REQUESTPARAMSRESPONSE<RESPONSE> params) async {
    final result = await _callSynchronized(() async {
      return await _controller._localWeb3Request(params);
    }, conditionStatus: true, lock: _lockWeb3);
    return result.result;
  }

  Future<MethodResult<Web3EncryptedMessage>> getWeb3Authenticated(
      Web3ClientInfo info) async {
    final result = await _callSynchronized(() async {
      return await _controller._getWeb3Authenticated(info);
    }, conditionStatus: true, lock: _lockWeb3, delay: null);
    return result;
  }

  Future<MethodResult<Web3EncryptedMessage>> getWeb3Permission(
      Web3ClientInfo info) async {
    final result = await _callSynchronized(() async {
      return await _controller._getWeb3Permission(info);
    }, conditionStatus: true, lock: _lockWeb3);
    return result;
  }

  Future<MethodResult<T>> walletRequest<T, A extends CborMessageResponseArgs>(
      WalletArgsCompleter<T, A> message) async {
    final result = await _callSynchronized(() async {
      return await _controller._walletRequest(message: message);
    }, conditionStatus: isUnlock);
    return result;
  }

  Future<MethodResult<Web3APPAuthentication>> getOrCreateWeb3AppAuthenticated(
      Web3ClientInfo info) async {
    return _walletAction(() => _controller._getOrCreateAppAuthenticated(info));
  }

  Future<MethodResult<Web3EncryptedMessage>> updateWeb3Application(
      Web3APPAuthentication application,
      {List<NetworkType>? web3Networks}) async {
    return _callSynchronized(
        () async => _controller._updateWeb3Application(application,
            web3Networks: web3Networks),
        conditionStatus: isUnlock);
  }

  Future<MethodResult<void>> changePassword(
      String password, String newPassword) async {
    return await _callSynchronized(() async {
      await _controller._changePassword(password, newPassword);
    }, conditionStatus: isUnlock, progress: true);
  }

  Future<MethodResult<NETWORKCHAINACCOUNT<NETWORKADDRESS>>>
      deriveNewAccount<NETWORKADDRESS>(
          {required NewAccountParams newAccountParams,
          required APPCHAINNETWORK<NETWORKADDRESS> chain}) async {
    return await _callSynchronized(
        () async => await _controller._deriveNewAccount(
            newAccountParams: newAccountParams, chain: chain),
        conditionStatus: newAccountParams.isMultiSig ? isOpen : isUnlock,
        delay: APPConst.milliseconds100);
  }

  Future<MethodResult<void>> importAccount(
      ImportedKeyStorage newAccountParams, String password) async {
    final result = await _callSynchronized(
        () async => await _controller._importNewKey(newAccountParams, password),
        conditionStatus: isUnlock);
    return result;
  }

  Future<void> switchWallet(HDWallet? wallet) async {
    if (wallet == null) return;
    await _callSynchronized(() async {
      return await _switchWallet(wallet);
    }, conditionStatus: homePageStatus.isReady, progress: true);
  }

  Future<MethodResult<List<EncryptedCustomKey>>> getImportedAccounts(
      String password) {
    final result = _callSynchronized(() async {
      return _controller._getImportedAccounts(password);
    }, conditionStatus: isUnlock);
    return result;
  }

  List<T> networks<T extends WalletNetwork>() {
    if (isOpen) {
      return _controller._appChains.networks().whereType<T>().toList();
    }
    return [];
  }

  List<T> getChains<T extends Chain>() {
    if (isOpen) {
      return _controller._appChains.chains().whereType<T>().toList();
    }
    return [];
  }

  Future<MethodResult<void>> removeImportedKey(
      EncryptedCustomKey key, String password) {
    return _callSynchronized(() async {
      return await _controller._removeKey(key, password);
    }, conditionStatus: isUnlock);
  }

  Future<void> switchNetwork(int? networkId) async {
    if (networkId == null || network.value == networkId) return;
    final result = await _callSynchronized(
        () async => await _controller._switchNetwork(networkId),
        conditionStatus: isOpen,
        progress: true);
    assert(!result.hasError, "failed to switch network ${result.error}");
  }

  Future<MethodResult<List<CryptoPublicKeyData>>> getAccountPubKys(
      {required ChainAccount account}) async {
    final result = await _callSynchronized(
        () async => _controller._getAccountPubKys(account: account),
        conditionStatus: isUnlock);
    return result;
  }

  Future<void> updateImportNetwork(WalletNetwork network) async {
    final result = await _callSynchronized(
        () async => await _controller._updateImportNetwork(network),
        conditionStatus: isOpen,
        progress: network.value == network.value);
    return result.result;
  }

  Future<MethodResult<void>> removeChain(Chain chain) async {
    final result = await _callSynchronized(
        () async => await _controller._removeChain(chain),
        conditionStatus: isOpen,
        progress: _controller._chain == chain);
    return result;
  }

  Future<MethodResult<String>> generateWalletBackup(String password) async {
    final result = await _callSynchronized(() async {
      return await _controller._generateWalletBackup(password);
    }, conditionStatus: isUnlock);
    return result;
  }

  Future<MethodResult<void>> eraseWallet(String password) async {
    final result = await _callSynchronized(() async {
      await _eraseWallet(password);
    }, conditionStatus: isUnlock, progress: true);

    return result;
  }

  Future<MethodResult<T>> signRequest<T>(
      {required WalletSigningRequest<T> request,
      String? password,
      Duration? timeout}) async {
    final result = await _callSynchronized(() async {
      final Set<ChainAccount> addresses = request.addresses.toSet();
      final Set<AddressDerivationIndex> keys =
          addresses.map((e) => e.signerKeyIndexes()).expand((e) => e).toSet();
      return await _controller._signTransaction(
          request: request,
          password: password,
          signers: keys,
          timeout: timeout);
    }, conditionStatus: isUnlock);

    return result;
  }

  Future<MethodResult<void>> updateWalletInfos(
      {required WalletUpdateInfosData walletInfos,
      required String password}) async {
    return await _callSynchronized(() async {
      try {
        return await _controller._updateWalletInfos(
            password: password, walletInfos: walletInfos);
      } finally {}
    }, conditionStatus: isUnlock, progress: true);
  }

  Future<MethodResult<List<CryptoKeyData>>> accsess(
      WalletAccsessType accsessType, String password,
      {ChainAccount? account, String? keyId}) async {
    final result = await _callSynchronized(() async {
      if (accsessType.isUnlock && isUnlock) {
        return [FakeKeyData()];
      } else if (isReadOnly || isLock) {
        await _controller._login(password);
      } else {
        await _controller._validatePassword(password);
      }
      return await _controller._accsess(accsessType,
          account: account, keyId: keyId);
    },
        conditionStatus: homePageStatus.isReady,
        delay: (accsessType.isUnlock && password.isEmpty)
            ? null
            : APPConst.oneSecoundDuration);
    return result;
  }

  Future<MethodResult<WalletLockTime>> login(String password) async {
    return await _callSynchronized(() async {
      if (isReadOnly || isLock) {
        await _controller._login(password);
      } else {
        await _controller._validatePassword(password);
      }
      return _wallet!._wallet.locktime;
    }, conditionStatus: homePageStatus.isReady);
  }

  Future<MethodResult<void>> updateCurrentAccountBalance() async {
    return await _walletAction(() async {
      final chain = _wallet?._chain;
      if (chain != null && chain.haveAddress) {
        return await _controller._updateAddressBalance(
            account: chain, address: chain.address);
      }
    });
  }

  Future<MethodResult<List<MoneroUnlockedPaymentRequestDetails>>>
      moneroUpdatePendingTxes(
          {required MoneroChain account,
          List<MoneroAccountPendingTxes>? txIds}) async {
    return await _callSynchronized(() async {
      return await _controller._moneroUpdatePendingTxes(
          account: account, txIds: txIds);
    }, conditionStatus: isUnlock);
  }

  Future<List<EncryptedCustomKey>> getCustomKeysForCoin(
      CryptoCoins coin) async {
    if (!isOpen) return const [];
    final result = await _callSynchronized(() async {
      return _controller._getCustomKeysForCoin(coin);
    }, conditionStatus: isOpen, delay: Duration.zero);
    return result.result;
  }

  Future<List<int>> restoreKeysBackup(
      {required String backup,
      required String password,
      required SecretWalletEncoding encoding}) async {
    return await crypto.cryptoIsolateRequest(
      CryptoRequestDecodeBackup(
          password: password, backup: backup, encoding: encoding),
    );
  }

  Future<T> cryptoMainRequest<T, A extends CborMessageResponseArgs,
      E extends CryptoArgsCompleter<T, A>>(E request) async {
    return crypto.cryptoMainRequest(request);
  }

  Future<T> cryptoIsolateRequest<T, A extends CborMessageResponseArgs,
      E extends CryptoArgsCompleter<T, A>>(E request) async {
    return crypto.cryptoIsolateRequest(request);
  }

  Future<T> nonEncryptedRequest<T, A extends CborMessageResponseArgs>(
      NoneEncryptedArgsCompleter<T, A> message,
      {List<int>? encryptedPart,
      WorkerMode mode = WorkerMode.main,
      bool isolate = true}) async {
    return crypto.nonEncryptedRequest<T, A>(message,
        mode: mode, encryptedPart: encryptedPart, isolate: isolate);
  }

  Future<void> initWallet(
      {bool useIsolate = true, String? initialPassword}) async {
    await _callSynchronized(
        () async => await _initWallet(
            useIsolate: useIsolate, initialPassword: initialPassword),
        conditionStatus: homePageStatus.isInit,
        delay: null);
  }

  Future<WalletBackupCore> restoreWalletBackup(
      {required String backup, required String password}) async {
    WalletBackupCore walletBackup;
    final toBytes = BytesUtils.tryFromHexString(backup);
    if (toBytes != null) {
      walletBackup = WalletBackupCore.deserialize(bytes: toBytes);
    } else {
      walletBackup =
          WalletKeyBackup(key: backup, type: WalletBackupTypes.keystore);
    }
    final decodeBytes = await restoreKeysBackup(
        backup: walletBackup.key,
        password: password,
        encoding: walletBackup.type.encoding);
    return walletBackup.decrypt(decodeBytes);
  }

  Future<MethodResult<String>> generateWalletKeyBackup(
      {required String data,
      required WalletBackupTypes type,
      required String password}) async {
    if (type == WalletBackupTypes.wallet) {
      throw WalletExceptionConst.dataVerificationFailed;
    }

    final result = await MethodUtils.call(() async {
      return await _controller._generateWalletKeyBackup(
          data: data, password: password, type: type);
    });
    return result;
  }

  Future<HDWallet> createWallet(
      {required String mnemonic,
      required String? passphrase,
      required String password}) async {
    if (passphrase?.isEmpty ?? false) {
      throw WalletExceptionConst.invalidMnemonicPassphrase;
    }
    final checksum = await crypto.generateRandomBytes(
        length: CreateHDWalletConst.checksumLength,
        existsKeys:
            _wallets._wallets.values.map((e) => e.checkSumBytes).toList());
    final encrypt = await crypto.cryptoIsolateRequest(
        CryptoRequestCreateHDWallet(
            mnemonic: mnemonic,
            passphrase: passphrase,
            password: password,
            checksum: checksum));
    return HDWallet.setup(
        checksum: BytesUtils.toHexString(checksum),
        name: StrUtils.addNumberToMakeUnique(
            _wallets.walletNames, HDWalletsConst.initializeName),
        data: encrypt.storageData);
  }

  Future<WalletRestoreV2> restoreWalletBackupV3(
      {required WalletBackupCore backup,
      required String? passhphrase,
      required String password}) async {
    try {
      if (backup.type != WalletBackupTypes.walletV3) {
        throw WalletExceptionConst.invalidBackup;
      }
      if (passhphrase?.isEmpty ?? false) {
        throw WalletExceptionConst.invalidMnemonicPassphrase;
      }
      final checksum = await crypto.generateRandomHex(
        length: CreateHDWalletConst.checksumLength,
        existsKeys:
            _wallets._wallets.values.map((e) => e.checkSumBytes).toList(),
      );
      final key = await _toWalletPassword(password, checksum);
      final resotreKey = await crypto.cryptoIsolateRequest(
          CryptoRequestRestoreBackupMasterKey(
              key: key,
              backup: BytesUtils.fromHexString(backup.key),
              passphrase: passhphrase));
      return await _validateBackupAccounts(
          chains: (backup as WalletBackup).chains,
          checksum: checksum,
          resotreKey: resotreKey,
          key: key);
    } on WalletException catch (e) {
      if (e == WalletExceptionConst.invalidBackupChecksum) {
        rethrow;
      }
      throw WalletExceptionConst.invalidBackup;
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }

  Future<WalletRestoreV2> _validateBackupAccounts({
    required List<WalletChainBackup> chains,
    required CryptoRestoreBackupMasterKeyResponse resotreKey,
    required String checksum,
    required List<int> key,
  }) async {
    final setupKey = resotreKey.masterKey;
    if (!resotreKey.isValid) {
      return WalletRestoreV2._(
          masterKeys: resotreKey.masterKey,
          chains: [],
          invalidAddresses: const [],
          verifiedChecksum: false,
          wallet: HDWallet.setup(
              checksum: checksum,
              name: StrUtils.addNumberToMakeUnique(
                  _wallets.walletNames, HDWalletsConst.initializeName),
              data: resotreKey.storageData));
    }
    final List<WalletChainBackup> validateChains = [];
    final List<ChainAccount> invalidAddresses = [];
    try {
      for (final c in chains) {
        final List<ChainAccount> addresses = [];

        for (final address in c.chain.addresses) {
          try {
            final network = c.chain.network;
            if (address.multiSigAccount) {
              final multiSigAccount =
                  address.toAccountParams().toAccount(network, null);
              final isValid = multiSigAccount == address &&
                  address.isEqual(multiSigAccount) &&
                  address.identifier == multiSigAccount.identifier;
              if (isValid) {
                addresses.add(multiSigAccount);
              } else {
                invalidAddresses.add(address);
              }

              continue;
            }
            final addr = await crypto.walletArgs(
                message: WalletRequestDeriveAddress(
                    addressParams: address.toAccountParams()),
                encryptedMasterKey: resotreKey.encryptedKey.masterKey,
                key: key);
            final account =
                addr.accountParams.toAccount(network, addr.publicKey);
            final isValid = account == address &&
                address.isEqual(account) &&
                address.identifier == account.identifier;
            if (isValid) {
              addresses.add(account);
            } else {
              invalidAddresses.add(address);
            }
          } catch (e) {
            invalidAddresses.add(address);
          }
        }
        final chain = WalletChainBackup(
            chain: c.chain.copyWith(
                addresses: c.chain.addresses
                    .where((e) => addresses.contains(e))
                    .toList(),
                id: checksum),
            repositories: c.repositories);

        validateChains.add(chain);
      }
      // ignore: empty_catches
    } catch (_) {}
    return WalletRestoreV2._(
        masterKeys: setupKey,
        chains: validateChains,
        invalidAddresses: invalidAddresses,
        wallet: HDWallet.setup(
            checksum: checksum,
            name: StrUtils.addNumberToMakeUnique(
                _wallets.walletNames, HDWalletsConst.initializeName),
            data: resotreKey.storageData),
        verifiedChecksum: true);
  }
}
