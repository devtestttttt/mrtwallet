import 'package:on_chain_wallet/app/core.dart';
import 'transaction_form.dart';

typedef OnChangeForm = void Function();

class LiveTransactionForm<T extends ValidatorForm> extends LiveListenable<T> {
  LiveTransactionForm({required this.validator}) : super(validator) {
    validator.onChanged = onChanged;
  }
  final T validator;
  void onChanged() {
    _notifyChangePages();
  }

  void _notifyChangePages() {
    notify();
  }
}
