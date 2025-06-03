import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/transaction/controller/impl/fee.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/transaction/controller/impl/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/monero/transaction/controller/impl/transaction.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/progress.dart';

class MoneroTransactionStateController extends MoneroTransactionImpl
    with MoneroTransactionFeeImpl, MoneroTransactionSignerImpl {
  MoneroTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider});

  @override
  Future<void> initTransaction() async {
    progressKey.progressText("retrieving_network_condition".tr);
    final update = await MethodUtils.call(() async {
      await super.initialFee();
      await super.initTransaction();
      if (utxos.isEmpty) return;
      onCalculateAmount();
    });
    if (update.hasError) {
      progressKey.errorText(update.error!.tr, backToIdle: false);
      return;
    }
    if (utxos.isEmpty) {
      progressKey.errorText("lacks_an_utxos".tr, backToIdle: false);
      return;
    }
    progressKey.success(backToIdle: true);
  }

  @override
  void ready() {
    super.ready();
    initTransaction();
  }
}
