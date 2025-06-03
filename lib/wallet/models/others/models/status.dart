import 'package:on_chain_wallet/app/error/exception/wallet_ex.dart';

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
  bool get isOpen => this == unlock || this == readOnly;
  bool get isLock => this == lock;
  bool get isUnlock => this == unlock;

  bool get isReadOnly => this == readOnly;
  bool get isReady => this != setup && this != init;
}
