import 'package:on_chain_wallet/future/wallet/network/ripple/transaction/controller/impl/transaction_impl.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/crypto/utils/ripple/ripple.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

mixin RippleFeeImpl on RippleTransactionImpl {
  @override
  Map<String, IntegerBalance> get fees => _fees;
  XRPLTransactionType get transactionType;
  String? _fulfillment;
  int _multiSigners = 0;
  void updateFee([String? fulFillment]) {
    if (fulFillment == _fulfillment) return;
    _fulfillment = fulFillment;
    _fees = _buildFees();
    setFee(feeType?.name);
  }

  Map<String, IntegerBalance> _buildFees() {
    return {
      XrplFeeType.open.name: IntegerBalance.token(
          RippleUtils.calculateFee(
              _xrpLedger!.getFeeType(type: XrplFeeType.open), transactionType,
              fulfillment: _fulfillment, multiSigners: _multiSigners),
          network.token),
      XrplFeeType.minimum.name: IntegerBalance.token(
          RippleUtils.calculateFee(
              _xrpLedger!.getFeeType(type: XrplFeeType.minimum),
              transactionType,
              fulfillment: _fulfillment,
              multiSigners: _multiSigners),
          network.token),
      XrplFeeType.dynamic.name: IntegerBalance.token(
          RippleUtils.calculateFee(
              _xrpLedger!.getFeeType(type: XrplFeeType.dynamic),
              transactionType,
              fulfillment: _fulfillment,
              multiSigners: _multiSigners),
          network.token)
    };
  }

  late Map<String, IntegerBalance> _fees;
  @override
  late final IntegerBalance fee = IntegerBalance.zero(network.token);
  @override
  XrplFeeType? get feeType => _feeType;
  LedgerInfo? _xrpLedger;
  XrplFeeType? _feeType = XrplFeeType.open;

  int getBaseFee(XrplFeeType feeType) {
    return _xrpLedger!.getFeeType(type: feeType);
  }

  @override
  void setFee(String? feeType, {BigInt? customFee}) {
    if (feeType == null && customFee == null) return;
    _feeType = feeType == null
        ? null
        : XrplFeeType.values.firstWhere((element) => element.name == feeType);
    if (_feeType == null) {
      fee.updateBalance(customFee!);
    } else {
      fee.updateBalance(RippleUtils.calculateFee(
          _xrpLedger!.getFeeType(type: _feeType!), transactionType,
          fulfillment: _fulfillment, multiSigners: _multiSigners));
    }
  }

  int _checkSignerLength() {
    if (!address.multiSigAccount) return 0;
    final IXRPMultisigAddress multiSigAddress = address as IXRPMultisigAddress;
    if (multiSigAddress.multiSignatureAccount.isRegular) return 0;
    return multiSigAddress.multiSignatureAccount.signers.length;
  }

  Future<void> fetchFee() async {
    _xrpLedger ??= await apiProvider.provider.request(XRPRequestFee());
    _multiSigners = _checkSignerLength();
    fee.updateBalance(RippleUtils.calculateFee(
        _xrpLedger!.getFeeType(type: _feeType!), transactionType,
        multiSigners: _multiSigners));
    _fees = _buildFees();
  }
}
