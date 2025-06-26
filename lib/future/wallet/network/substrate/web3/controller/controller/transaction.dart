import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/utils/substrate/substrate.dart';
import 'package:on_chain_wallet/future/state_managment/extension/app_extensions/string.dart';
import 'package:on_chain_wallet/future/wallet/network/forms/substrate/substrate.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/controller/impl/fee_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/transaction/controller/impl/signer_impl.dart';
import 'package:on_chain_wallet/future/wallet/network/substrate/web3/controller/impl/impl.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/substrate/models/metadata.dart';
import 'package:on_chain_wallet/wallet/models/networks/substrate/models/metadata_fields.dart';
import 'package:on_chain_wallet/wallet/models/networks/substrate/models/transaction_output.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/exception/exception.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class Web3SubstrateTransactionRequestController extends Web3SubstrateImpl<
    Web3SubstrateSendTransactionResponse,
    Web3SubstrateSendTransaction> with SubstrateFeeImpl, SubstrateSignerImpl {
  Web3SubstrateTransactionRequestController({
    required super.walletProvider,
    required super.request,
  });
  Web3SubstrateSendTransaction get transaction => request.params;
  SubstrateChainMetadata get metadata => apiProvider.metadata;
  List<SubstrateKnownCallMethods> _methods = [];
  List<SubstrateKnownCallMethods> get methods => _methods;
  late final ExtrinsicPayloadInfo _extrinsicInfo;
  ExtrinsicPayloadInfo get extrinsicInfo => _extrinsicInfo;
  late final IntegerBalance remindAmount = IntegerBalance.zero(network.token);

  bool get isReady => !remindAmount.isNegative;

  @override
  Web3SubstrateSendTransactionForm get form =>
      liveRequest.validator as Web3SubstrateSendTransactionForm;

  Future<(ExtrinsicPayloadInfo, List<SubstrateKnownCallMethods>)>
      _init() async {
    try {
      if (transaction.specVersion != metadata.specVersion) {
        throw Web3SubstrateExceptionConstant.differentRuntimeMetadata;
      }
      if (!BytesUtils.bytesEqual(
          transaction.genesisHash, metadata.genesisBytes())) {
        throw Web3SubstrateExceptionConstant.differentRuntimeMetadata;
      }
      final decode =
          metadata.metadata.decodeCall<Map<String, dynamic>>(transaction.call);
      List<SubstrateKnownCallMethods> methods =
          SubstrateKnownCallMethods.parseTxMethod(
              data: decode.toJson(), network: network);
      methods = methods.map((e) {
        if (e is SubstrateTransferMethod) {
          return e.copyWith(
              receiver: account.getReceiptAddress(e.receiver.view));
        }
        return e;
      }).toList();
      final era = MortalEra(index: transaction.era[0], era: transaction.era[1]);
      final extrinsic = SubstrateDefaultExtrinsic(
          era: era,
          nonce: transaction.nonce,
          mode: transaction.mode,
          specVersion: metadata.runtimeVersion.specVersion,
          transactionVersion: metadata.runtimeVersion.transactionVersion,
          genesis: transaction.genesisHash,
          mortality: transaction.blockHash,
          tip: transaction.tip,
          metadataHash: transaction.metadataHash,
          assetId: transaction.assetId);
      final extraFields = extrinsic.encode(
          fields: metadata.extrinsic.extrinsicPayloadValidators,
          metadata: metadata.metadata);
      final List<int> serializedExtrinsic =
          [...transaction.call, ...extraFields].asImmutableBytes;
      final info = ExtrinsicPayloadInfo(
          serializedExtrinsic: serializedExtrinsic,
          method: transaction.call,
          payloadInfo: decode.data,
          extrinsic: extrinsic);
      return (info, methods);
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3RequestExceptionConst.invalidTransaction;
    }
  }

  @override
  Future<void> initWeb3() async {
    progressKey.process(text: "transaction_retrieval_requirment".tr);
    final r = await MethodUtils.call(() => _init());
    if (r.hasError) {
      progressKey.errorResponse(error: r.exception);
      request.error(Web3RequestExceptionConst.fromException(r.exception!));
      return;
    }
    await account.updateAccountBalance(addresses: [address]);
    _extrinsicInfo = r.result.$1;
    _methods = r.result.$2.immutable;
    final total = _methods.fold(BigInt.zero, (p, c) => p + c.value);
    remindAmount.updateBalance(address.address.currencyBalance - total);
    progressKey.idle();
    estimateFee();
  }

  @override
  Future<void> estimateFee({ExtrinsicInfo? extrinsic}) async {
    await super.estimateFee(extrinsic: extrinsic);
    final total = _methods.fold(BigInt.zero, (p, c) => p + c.value);
    remindAmount
        .updateBalance(address.address.currencyBalance - total - fee.balance);
    notify();
  }

  Future<ExtrinsicInfo> _buildAndSignTransaction(
      {ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature}) async {
    List<int> signature;
    if (onGenerateSignature == null) {
      signature = SubstrateUtils.createFakeSignature(address.coin.conf.type);
    } else {
      signature = await onGenerateSignature(_extrinsicInfo.payloadBytes);
    }
    return metadata.createExtrinsic(
        signature: signature,
        address: address.networkAddress,
        algorithm: address.keyIndex.currencyCoin.conf.type,
        payload: _extrinsicInfo);
  }

  @override
  Future<ExtrinsicInfo> buildEstimateTransaction() async {
    final extrinsic = await _buildAndSignTransaction();
    return extrinsic;
  }

  @override
  Future<ExtrinsicInfo> buildAndSignTransaction({
    ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
    required ISubstrateAddress address,
    List<String> memos = const [],
  }) async {
    return await _buildAndSignTransaction(
        onGenerateSignature: onGenerateSignature);
  }

  Future<void> signAndSendTransaction() async {
    progressKey.process(
        text: "create_send_transaction"
            .tr
            .replaceOne(network.coinParam.token.name));
    final result = await MethodUtils.call(() async {
      return await signTransaction(address: address, network: network);
    });
    bool withSignedTx = request.params.withSignedTransaction ?? true;
    if (result.hasError) {
      progressKey.error(error: result.exception, showBackButton: true);
    } else {
      request.completeResponse(Web3SubstrateSendTransactionResponse(
          signature: result.result.signature!,
          signedTransaction: withSignedTx ? result.result.serialize() : null));
      progressKey.response(text: 'transaction_signed'.tr);
    }
  }
}
