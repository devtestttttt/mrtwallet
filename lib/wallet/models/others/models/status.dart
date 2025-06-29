import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain_wallet/app/euqatable/equatable.dart';

enum WStatus {
  init(0),
  // progress,
  setup(1),
  lock(2),
  readOnly(3),
  unlock(4);

  final int value;
  const WStatus(this.value);
  static WStatus fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: 'Invalid wallet status tag'),
    );
  }

  bool get isInit => this == init;
  bool get isSetup => this == setup;
  bool get isOpen => this == unlock || this == readOnly;
  bool get isLock => this == lock;
  bool get isUnlock => this == unlock;

  bool get isReadOnly => this == readOnly;
  bool get isReady => this != setup && this != init;
}

enum WalletActionEventType {
  init(rebuild: true),
  lock(rebuild: true),
  setup(rebuild: true),
  web3Request(),
  web3Auth(),
  updateWeb3Auth(),
  walletRequest(),
  changePassword(rebuild: true),
  deriveAddress(),
  importKey(),
  switchWallet(rebuild: true),
  switchNetwork(rebuild: true),
  exportKey(),
  exportKeyInfos(),
  removeKey(),
  updateAccount(rebuild: true),
  importNetwork(rebuild: true),
  removeAccount(rebuild: true),
  backup(),
  backupWallet(),
  eraseWallet(rebuild: true),
  updateWallet(rebuild: true),
  accessKey(),
  login(rebuild: true),
  validatePassword(rebuild: true),
  updateBalance(),
  moneroAction(),
  exportAccountKey();

  final bool rebuild;
  bool get isLogin => this == login;
  const WalletActionEventType({this.rebuild = false});
}

enum WalletActionEventStatus {
  pending(inProgress: true),
  success,
  failed;

  final bool inProgress;
  const WalletActionEventStatus({this.inProgress = false});
  bool get isSuccess => this == success;
}

final class WalletActionEvent with Equatable {
  factory WalletActionEvent.init() {
    return WalletActionEvent(
        walletStatus: WStatus.init,
        action: WalletActionEventType.init,
        status: WalletActionEventStatus.success);
  }

  final WStatus walletStatus;
  final WalletActionEventType action;
  final WalletActionEventStatus status;
  final bool inProgress;
  WalletActionEvent(
      {required this.walletStatus, required this.action, required this.status})
      : inProgress = action.rebuild && status.inProgress;

  bool actionIsAllow() {
    switch (action) {
      case WalletActionEventType.setup:
        return !walletStatus.isInit;
      case WalletActionEventType.web3Request:
      case WalletActionEventType.web3Auth:
      case WalletActionEventType.switchWallet:
      case WalletActionEventType.accessKey:
      case WalletActionEventType.login:
      case WalletActionEventType.validatePassword:
        return walletStatus.isReady;
      case WalletActionEventType.walletRequest:
      case WalletActionEventType.updateWallet:
      case WalletActionEventType.updateWeb3Auth:
      case WalletActionEventType.changePassword:
      case WalletActionEventType.exportKey:
      case WalletActionEventType.removeKey:
      case WalletActionEventType.importKey:
      case WalletActionEventType.exportAccountKey:
      case WalletActionEventType.backupWallet:
      case WalletActionEventType.eraseWallet:
      case WalletActionEventType.moneroAction:
        return walletStatus.isUnlock;
      case WalletActionEventType.switchNetwork:
      case WalletActionEventType.updateAccount:
      case WalletActionEventType.importNetwork:
      case WalletActionEventType.removeAccount:
      case WalletActionEventType.exportKeyInfos:
      case WalletActionEventType.lock:
      case WalletActionEventType.updateBalance:
      case WalletActionEventType.deriveAddress:
      case WalletActionEventType.backup:
        return walletStatus.isOpen;
      case WalletActionEventType.init:
        return walletStatus.isSetup;
    }
  }

  @override
  List get variabels => [walletStatus, action, status];
}
