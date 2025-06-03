import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/future/state_managment/extension/app_extensions/string.dart';
import 'package:on_chain_wallet/wallet/models/networks/bitcoin/models/models.dart';

mixin BitcoinTransactionMemoImpl {
  List<BitcoinMemo> _memoScripts = [];

  List<BitcoinMemo> get memoScripts => _memoScripts;
  bool _allowAddMemo = true;
  bool get allowAddMemo => _allowAddMemo;
  bool get hasMemo => _memoScripts.isNotEmpty;
  int? get opReturnLength;
  bool get allowMultipleOpReturn;

  Future<void> onTapMemo(FutureNullString onAdd) async {
    final newMemo = await onAdd();
    if (newMemo != null) {
      _memoScripts = List<BitcoinMemo>.unmodifiable(
          [..._memoScripts, BitcoinMemo(newMemo)]);
    }
    _checkMemo();
  }

  String? onValidateMemo(String? memo) {
    final length = opReturnLength;
    if (length == null || memo == null) return null;
    final bytes = StringUtils.toBytes(memo);
    if (bytes.length <= length) return null;
    return "op_return_length_validator".tr.replaceOne(length.toString());
  }

  void onRemoveMemo(BitcoinMemo? memo) {
    final memos = List<BitcoinMemo>.from(_memoScripts);
    memos.removeWhere((element) => element == memo);
    _memoScripts = List<BitcoinMemo>.unmodifiable(memos);
    _checkMemo();
  }

  void addBCMR(BitcoinMemo bcmr) {
    _memoScripts = List<BitcoinMemo>.unmodifiable([..._memoScripts, bcmr]);
    _checkMemo();
  }

  void _checkMemo() {
    _allowAddMemo = _memoScripts.isEmpty || allowMultipleOpReturn;
  }
}
