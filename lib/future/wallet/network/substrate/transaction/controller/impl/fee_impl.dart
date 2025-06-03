import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/stream_bottun.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

mixin SubstrateFeeImpl on StateController {
  WalletSubstrateNetwork get network;
  SubstrateClient get apiProvider;
  Future<ExtrinsicInfo> buildEstimateTransaction();
  late SubstrateFeeInfos _feeInfo = SubstrateFeeInfos.zero(network);
  SubstrateFeeInfos get feeInfo => _feeInfo;
  IntegerBalance get fee => _feeInfo.total;
  String? _feeError;
  final Cancelable _cancelabe = Cancelable();
  final StreamValue<StreamWidgetStatus> feeStatusStream =
      StreamValue(StreamWidgetStatus.idle);

  StreamWidgetStatus get feeStatus => feeStatusStream.value;

  bool get hasFee => _feeInfo.calculated;
  String? get feeError => _feeError;

  Future<void> estimateFee({ExtrinsicInfo? extrinsic}) async {
    _cancelabe.cancel();
    _feeInfo = SubstrateFeeInfos.zero(network);
    _feeError = null;
    feeStatusStream.value = StreamWidgetStatus.progress;
    final result = await MethodUtils.call(() async {
      extrinsic ??= await buildEstimateTransaction();
      return await apiProvider.estimateFee(
          extrinsic: extrinsic!.serialize(encodeLength: false),
          network: network);
    });
    if (result.isCancel) return;
    if (result.hasError) {
      _feeError = result.error;
      feeStatusStream.value = StreamWidgetStatus.error;
    } else {
      final feeInfo = result.result;

      if (!feeInfo.calculated) {
        _feeError = "estimate_fee_error_desc";
        feeStatusStream.value = StreamWidgetStatus.error;
        return;
      }
      _feeInfo = feeInfo;
      feeStatusStream.value = StreamWidgetStatus.success;
    }
  }

  @override
  void close() {
    super.close();
    feeStatusStream.dispose();
    _cancelabe.cancel();
  }
}
