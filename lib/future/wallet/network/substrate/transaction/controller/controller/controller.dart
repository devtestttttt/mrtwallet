import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/extension/app_extensions/string.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/substrate/transfer/extrinsic.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/controller/impl/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/controller/impl/memo_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/controller/impl/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/controller/impl/transaction.dart';
import 'package:blockchain_utils/utils/compare/compare.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/api/client/networks/substrate/models/models/models.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/substrate/models/metadata_fields.dart';
import 'package:on_chain_wallet/wallet/models/transaction/networks/substrate.dart';

class SubstrateTransactionStateController extends SubstrateTransactiomImpl
    with SubstrateSignerImpl, SubstrateFeeImpl, SubstrateMemoImpl {
  SubstrateTransactionStateController(
      {required super.walletProvider,
      required super.account,
      required super.apiProvider,
      required this.validator});
  final LiveTransactionForm<SubstrateTransactionForm> validator;
  bool _trIsReady = false;
  bool get trIsReady => _trIsReady;

  String? _error;
  String? get error => _error;

  @override
  Future<void> onTapMemo(OnAddSubstrateMemo onAddMemo) async {
    final mem = List<String>.from(memos);
    await super.onTapMemo(onAddMemo);
    _checkMemos(mem);
  }

  @override
  void removeMemo(int index) {
    final mem = List<String>.from(memos);
    super.removeMemo(index);
    _checkMemos(mem);
  }

  void _checkMemos(List<String> previusMemos) {
    if (CompareUtils.iterableIsEqual(previusMemos, memos)) return;
    notify();
    if (_trIsReady) {
      estimateFee();
    }
  }

  void sendTransaction() {
    signAndSendTransaction();
  }

  void _onReadyForm() {
    estimateFee();
  }

  @override
  Future<void> estimateFee({ExtrinsicInfo? extrinsic}) async {
    validator.validator.setupFee(BigInt.zero);
    await super.estimateFee();
    validator.validator.setupFee(feeInfo.total.balance);
    notify();
  }

  bool _isReady() {
    _error = validator.validator.validateError();
    return !remindAmount.isNegative && _error == null;
  }

  @override
  void onCalculateAmount() {
    final totalAmounts = validator.validator.callValue;
    final remind = address.address.currencyBalance - totalAmounts;
    remindAmount.updateBalance(remind);

    _trIsReady = _isReady();
    notify();
  }

  void _onChangeForm() {
    onCalculateAmount();
    notify();
  }

  Future<void> _init() async {
    final r = await MethodUtils.call(
        () async => await validator.validator.initForm(
            account: account,
            address: address,
            client: apiProvider,
            network: network),
        delay: APPConst.oneSecoundDuration);
    if (r.hasError) {
      progressKey.errorText(r.error!.tr, backToIdle: false);
      return;
    }
    validator.validator.onReadyField = _onReadyForm;
    validator.addListener(_onChangeForm);
    progressKey.backToIdle();
  }

  void _checkIsReady() {
    _trIsReady = _isReady();
    notify();
  }

  Future<void> createMetadataExtrinsic() async {
    _checkIsReady();
    if (!_trIsReady) return;
    progressKey.progressText("create_and_review_extrinsic".tr);
    final form = validator.validator.cast<SubstrateExtersincForm>();
    final r = await MethodUtils.call(() async {
      return await form.createExtrinsic(address);
    });
    if (r.hasError) {
      progressKey.errorText(r.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      if (form.signedTx) {
        estimateFee(extrinsic: r.result);
      }
      progressKey.backToIdle();
    }
  }

  void _close() {
    validator.validator.onReadyField = null;
    validator.removeListener(_onChangeForm);
    validator.validator.close();
  }

  @override
  void ready() {
    super.ready();
    _init();
  }

  @override
  void close() {
    super.close();
    _close();
  }

  @override
  Future<ExtrinsicInfo> buildAndSignTransaction(
      {ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
      required ISubstrateAddress address,
      List<String> memos = const [],
      bool fakeSignature = false}) {
    return validator.validator.buildAndSignTransaction(
        onGenerateSignature: onGenerateSignature, memos: memos);
  }

  @override
  Future<ExtrinsicInfo> buildEstimateTransaction() {
    return validator.validator.buildAndSignTransaction(memos: memos);
  }

  Future<void> _saveTransaction(
      {required SubstrateTxIdWithBlock txInfo,
      required ExtrinsicInfo extrinsic}) async {
    final s = await MethodUtils.call(() async {
      final SubstrateWalletTransaction transaction = validator.validator
          .toWalletTransaction(
              txId: txInfo.txId, extrinsic: extrinsic, block: txInfo.block);
      await account.saveTransaction(address: address, transaction: transaction);
    });
    assert(!s.hasError, "save substrate transaction failed ${txInfo.txId}");
  }

  Future<void> signAndSendTransaction() async {
    if (!_trIsReady) return;
    progressKey.progressText(
        "create_send_transaction".tr.replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      final extrinsic =
          await signTransaction(address: address, network: network);
      final txInfo =
          await apiProvider.broadcastTransaction(extrinsic.serialize());
      _saveTransaction(txInfo: txInfo, extrinsic: extrinsic);
      return txInfo;
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
    } else {
      progressKey.success(
          progressWidget: SuccessTransactionTextView(
              network: network, txIds: [result.result.txId]),
          backToIdle: false);
    }
  }
}
