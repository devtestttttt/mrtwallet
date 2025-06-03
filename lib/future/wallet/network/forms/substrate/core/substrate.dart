import 'package:on_chain_wallet/app/models/models.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/core/core.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

typedef ONSUBSTRATEREQUESTSIGNATURE = Future<List<int>> Function(
    List<int> digest);

abstract class SubstrateTransactionForm extends TransactionForm<SubstrateClient,
    ISubstrateAddress, WalletSubstrateNetwork, SubstrateChain> {
  BigInt get callValue;
  @override
  String? validateError();
  DynamicVoid? onReadyField;
  void calculateNativeValue();
  Future<ExtrinsicInfo> buildAndSignTransaction(
      {ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
      List<String> memos = const []});
  SubstrateWalletTransaction toWalletTransaction({
    required String txId,
    required int block,
    required ExtrinsicInfo extrinsic,
  });

  BigInt _fee = BigInt.zero;
  BigInt get fee => _fee;
  void setupFee(BigInt fee) {
    _fee = fee;
    calculateNativeValue();
    onChanged?.call();
  }
}

abstract class SubstrateWeb3Form<
        CLIENT extends SubstrateClient?,
        ADDRESS extends ISubstrateAddress?,
        PARAMS extends Web3SubstrateRequestParam>
    extends Web3Form<
        BaseSubstrateAddress,
        CLIENT,
        ADDRESS,
        WalletSubstrateNetwork,
        SubstrateChain,
        ISubstrateAddress,
        Web3SubstrateChainAccount,
        Web3SubstrateChain,
        PARAMS> {
  abstract final Web3SubstrateRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
