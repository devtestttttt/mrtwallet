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

  StreamValue<WalletActionEvent> get status => _homePageStatus;
  // bool _inProgress = false;
  // bool get inProgress => _inProgress;
  final StreamValue<WalletActionEvent> _homePageStatus =
      StreamValue(WalletActionEvent.init());
  WalletActionEvent get latestEvent => _homePageStatus.value;
  WStatus get homePageStatus => _homePageStatus.value.walletStatus;
  bool get isOpen => homePageStatus.isOpen;
  bool get isLock => homePageStatus.isLock;
  bool get isUnlock => homePageStatus.isUnlock;
  bool get isReadOnly => homePageStatus.isReadOnly;
  bool get isReady => homePageStatus.isReady;
  bool get isSetup => homePageStatus.isSetup;

  HDWallets _wallets = HDWallets.init();

  void _onCurrentChainListener(ChainEvent _) {
    if (homePageStatus.isUnlock) {
      _timeout.init();
    }
  }

  WalletActionEvent _buildEvent(
      {required WalletActionEventType action,
      required WalletActionEventStatus status}) {
    final wStatus = _wallet?.getStatus() ?? WStatus.setup;
    return WalletActionEvent(
        walletStatus: wStatus, action: action, status: status);
  }

  void _emitStatus(WalletActionEvent event) {
    _homePageStatus.value = event;
    if (latestEvent.status.inProgress) return;
    if (homePageStatus.isLock) {
      _wallet?.walletConnectHandler.dispose();
    }
    if (!homePageStatus.isUnlock) {
      _timeout.dispose();
    } else {
      if (_timeout.disposed) {
        _timeout.init();
      }
    }
    if (!latestEvent.action.rebuild) return;
    switch (latestEvent.action) {
      case WalletActionEventType.lock:
      case WalletActionEventType.updateAccount:
      case WalletActionEventType.updateWallet:
        return;
      default:
    }
    _onChainEvent?.cancel();
    _onChainEvent = null;
    _onChainEvent =
        _wallet?._appChains.chain.stream.listen(_onCurrentChainListener);
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
    if (!homePageStatus.isSetup) {
      return;
    }
    crypto.init(useIsolate);
    _wallets = await _readWallet();
    await _initPage();
    if (initialPassword != null) {
      await _controller._login(initialPassword);
    }
  }

  Future<void> _updateWallet(HDWallet wallet) async {
    await _wallets.updateWallet(wallet);
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
      {bool Function()? conditionStatus,
      bool Function()? event,
      required WalletActionEventType Function() action,
      Duration? delay = APPConst.animationDuraion,
      LockId lockId = LockId.one}) async {
    return await _lock.synchronized(() async {
      final request = action();
      final event =
          _buildEvent(action: request, status: WalletActionEventStatus.pending);
      _emitStatus(event);
      MethodResult<T>? result;
      try {
        result = await _walletAction(() async {
          if (!(event.actionIsAllow() && (conditionStatus?.call() ?? true))) {
            throw WalletExceptionConst.incorrectStatus;
          }
          return await t();
        }, delay: delay);
        return result;
      } finally {
        final status = (result?.hasError ?? true)
            ? WalletActionEventStatus.failed
            : WalletActionEventStatus.success;
        final event = _buildEvent(action: request, status: status);
        _emitStatus(event);
      }
    }, lockId: lockId);
  }

  Future<void> _initPage({HDWallet? slectedWallet}) async {
    final currentController = _wallet;
    if (_wallets.hasWallet) {
      final wallet =
          await _wallets.getInitializeWallet(name: slectedWallet?.name);
      final controller =
          await WalletController._setup(this as WalletCore, wallet);
      _wallet = controller;
    } else {
      _wallet = null;
    }
    currentController?._dispose();
  }

  Future<void> _setup(
      {required HDWallet hdWallet,
      required String password,
      required WalletUpdateInfosData walletInfos,
      WalletRestoreV2? backup}) async {
    if (!StrUtils.isStrongPassword(password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final updatedWallet = HDWallet(
        checksum: hdWallet.checksum,
        name: walletInfos.name,
        data: hdWallet.data,
        requiredPassword: walletInfos.requirmentPassword,
        locktime: walletInfos.lockTime,
        network: 0,
        protectWallet: walletInfos.protectWallet);
    final pw = await _toWalletPassword(password, updatedWallet.checksum);
    await crypto.cryptoIsolateRequest(
        CryptoRequestGenerateMasterKey.fromStorage(
            storageData: updatedWallet.data, key: pw));
    await _wallets.setupNewWallet(updatedWallet);
    await _initializeWallet(wallet: updatedWallet, backup: backup);
    await _initPage(slectedWallet: updatedWallet);
    await _writeHdWallet(_wallets);
  }

  Future<void> _initializeWallet(
      {required HDWallet wallet, WalletRestoreV2? backup}) async {
    await _removeWalletStorage(wallet);
    if (backup == null) return;
    await _setupWalletBackupAccounts(wallet: wallet, backup: backup);
  }

  Future<List<int>> _toWalletPassword(
      String password, String walletCheckSum) async {
    return await crypto.cryptoIsolateRequest(CryptoRequestWalletKey.fromString(
        key: password, checksum: walletCheckSum));
  }

  Future<bool> _switchWallet(HDWallet switchWallet) async {
    if (switchWallet.name == _controller._wallet.name) return false;
    await _initPage(slectedWallet: switchWallet);
    await _writeHdWallet(_wallets);
    return true;
  }

  Future<void> _eraseWallet(String password) async {
    final controller = _controller;
    await controller._validatePassword(password);
    await _wallets.removeWallet(controller._wallet);
    await _removeWalletStorage(controller._wallet);
    await _initPage();
    await _writeHdWallet(_wallets);
  }

  Future<void> lock() async {
    await _callSynchronized(
      () async {
        _controller._logout();
      },
      // conditionStatus: isOpen,
      delay: null,
      action: () => WalletActionEventType.lock,
    );
  }
}
