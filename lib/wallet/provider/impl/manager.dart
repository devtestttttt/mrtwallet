part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

// ignore: library_private_types_in_public_api
mixin WalletsManager on _WalletCore {
  final _lock = SynchronizedLock();
  WalletController? _wallet;
  StreamSubscription<ChainEvent>? _onChainEvent;
  WalletController get _controller {
    if (_wallet == null) {
      throw WalletExceptionConst.walletIsNotavailable;
    }
    return _wallet!;
  }

  StreamValue<WStatus> get status => _homePageStatus;
  bool _inProgress = false;
  bool get inProgress => _inProgress;
  final StreamValue<WStatus> _homePageStatus = StreamValue(WStatus.init);
  WStatus get homePageStatus => _homePageStatus.value;
  bool get isOpen => homePageStatus.isOpen;
  bool get isLock => homePageStatus.isLock;
  bool get isUnlock => homePageStatus.isUnlock;
  bool get isReadOnly => homePageStatus.isReadOnly;
  bool get isReady => homePageStatus.isReady;
  HDWallets _wallets = HDWallets.init();

  void _onCurrentChainListener(ChainEvent _) {
    if (homePageStatus.isUnlock) {
      _timeout.init();
    }
  }

  void _listenOnChainEvent() {
    _onChainEvent?.cancel();
    _onChainEvent = null;
    _onChainEvent =
        _wallet?._appChains.chain.stream.listen(_onCurrentChainListener);
  }

  void _setStatus() {
    final status = _wallet?.getStatus() ?? WStatus.setup;
    if (_inProgress) {
      _inProgress = false;
      _homePageStatus.updateValue = status;
    } else {
      _homePageStatus.value = status;
    }
    if (!homePageStatus.isUnlock) {
      _timeout.dispose();
    } else {
      if (_timeout.disposed) {
        _timeout.init();
      }
    }
  }

  void _setProgress() {
    _inProgress = true;
    _homePageStatus.notify();
  }

  late final WalletTimeoutListener _timeout = WalletTimeoutListener(() {
    lock();
  }, () {
    if (homePageStatus.isUnlock) {
      return _wallet?._wallet.locktime.value;
    }
    return null;
  });

  Future<void> _initWallet(
      {bool useIsolate = true, String? initialPassword}) async {
    if (!homePageStatus.isInit) {
      return;
    }
    crypto.init(useIsolate);
    _wallets = await _readWallet();
    await _initPage();
    if (initialPassword != null) {
      await _controller._login(initialPassword);
    }
  }

  Future<void> _updateWallet(HDWallet wallet, {bool? asDefaultWallet}) async {
    _wallets.updateWallet(wallet, asDefaultWallet: asDefaultWallet);
    await _writeHdWallet(_wallets);
  }

  Future<MethodResult<T>> _walletAction<T>(
    Future<T> Function() t, {
    Duration? delay,
  }) async {
    _timeout.init();
    return await MethodUtils.call(() async {
      return t();
    }, delay: delay);
  }

  Future<MethodResult<T>> _callSynchronized<T>(Future<T> Function() t,
      {required bool conditionStatus,
      Duration? delay = APPConst.animationDuraion,
      SynchronizedLock? lock,
      bool progress = false}) async {
    final currentLock = lock ?? _lock;
    return await currentLock.synchronized(() async {
      if (progress) _setProgress();
      try {
        return await _walletAction(() async {
          if (!conditionStatus) {
            throw WalletExceptionConst.incorrectStatus;
          }
          return await t();
        }, delay: delay);
      } finally {
        _setStatus();
        if (progress) {
          _listenOnChainEvent();
        }
      }
    });
  }

  Future<void> _initPage({HDWallet? slectedWallet}) async {
    if (_wallets.hasWallet) {
      final wallet = _wallets.getInitializeWallet(name: slectedWallet?.name);
      final controller =
          await WalletController._setup(this as WalletCore, wallet);
      final currentController = _wallet;
      currentController?._dispose();
      _wallet = controller;
    } else {
      _wallet = null;
    }
  }

  Future<void> _setup(
      {required HDWallet hdWallet,
      required String password,
      required WalletUpdateInfosData walletInfos,
      List<WalletChainBackup> chains = const []}) async {
    if (!StrUtils.isStrongPassword(password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final updatedWallet = HDWallet(
        checksum: hdWallet._checksum,
        name: walletInfos.name,
        data: hdWallet._data,
        requiredPassword: walletInfos.requirmentPassword,
        locktime: walletInfos.lockTime,
        network: 0,
        protectWallet: walletInfos.protectWallet);
    _wallets.validateImport(updatedWallet);
    final pw = await _toWalletPassword(password, updatedWallet._checksum);
    await crypto.cryptoIsolateRequest(
        CryptoRequestGenerateMasterKey.fromStorage(
            storageData: updatedWallet._data, key: pw));
    _wallets.setupWallet(updatedWallet, asDefault: walletInfos.asDefaultWallet);
    await _initializeWallet(updatedWallet, chains: chains);
    await _initPage(slectedWallet: updatedWallet);
    await _writeHdWallet(_wallets);
  }

  Future<void> _initializeWallet(HDWallet wallet,
      {List<WalletChainBackup> chains = const []}) async {
    await _removeWalletStorage(wallet);
    await _setupWalletAccounts(chains, wallet);
  }

  Future<List<int>> _toWalletPassword(
      String password, String walletCheckSum) async {
    return await crypto.cryptoIsolateRequest(CryptoRequestWalletKey.fromString(
        key: password, checksum: walletCheckSum));
  }

  Future<bool> _switchWallet(HDWallet switchWallet) async {
    if (switchWallet.name == _controller._wallet.name) return false;
    await _initPage(slectedWallet: switchWallet);
    return true;
  }

  Future<void> _eraseWallet(String password) async {
    final controller = _controller;
    await controller._validatePassword(password);
    controller._dispose();
    _wallets.removeWallet(controller._wallet);
    await _writeHdWallet(_wallets);
    await _removeWalletStorage(controller._wallet);
    await _initPage();
  }

  Future<void> lock() async {
    await _callSynchronized(() async {
      _controller._logout();
    }, conditionStatus: isOpen, delay: null, progress: true);
  }
}
