import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/substrate/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/utils/web3_validator_utils.dart';

class Web3SubstrateSendTransactionResponse with CborSerializable {
  final int id;
  final List<int> signature;
  final List<int>? signedTransaction;
  Web3SubstrateSendTransactionResponse(
      {this.id = 1, required List<int> signature, List<int>? signedTransaction})
      : signature = signature.asImmutableBytes,
        signedTransaction = signedTransaction?.asImmutableBytes;

  factory Web3SubstrateSendTransactionResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3SubstrateSendTransactionResponse(
        signature: values.elementAs(0),
        signedTransaction: values.elementAs(1),
        id: values.elementAs(2));
  }

  String get signatureHex => BytesUtils.toHexString(signature, prefix: "0x");
  String? get signedTransactionHex =>
      BytesUtils.tryToHexString(signedTransaction, prefix: "0x");
  Map<String, dynamic> toWalletConnectJson() {
    return {
      "signature": BytesUtils.toHexString(signature, prefix: "0x"),
      if (signedTransaction != null)
        "signedTransaction": BytesUtils.tryToHexString(signedTransaction),
      "id": id
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(signature),
          signedTransaction == null ? null : CborBytesValue(signedTransaction!),
          id
        ]),
        CborTagsConst.defaultTag);
  }
}

class Web3SubstrateSendTransaction
    extends Web3SubstrateRequestParam<Web3SubstrateSendTransactionResponse> {
  final List<int>? assetId;
  final List<int> blockHash;
  final int blockNumber;
  final List<int> era;
  final List<int> genesisHash;
  final List<int>? metadataHash;
  final List<int> call;
  final int? mode;
  final int nonce;
  final int specVersion;
  final BigInt tip;
  final int transactionVersion;
  final List<String> signedExtensions;
  final int version;
  final bool? withSignedTransaction;
  Web3SubstrateSendTransaction._(
      {required this.assetId,
      required this.blockHash,
      required this.blockNumber,
      required this.era,
      required this.genesisHash,
      required this.metadataHash,
      required this.call,
      required this.mode,
      required this.nonce,
      required this.specVersion,
      required this.tip,
      required this.transactionVersion,
      required this.version,
      required this.withSignedTransaction,
      required this.accessAccount,
      required this.signedExtensions});
  factory Web3SubstrateSendTransaction({
    required Map<String, dynamic> json,
    required Web3SubstrateChainAccount address,
  }) {
    final method = Web3SubstrateRequestMethods.signTransaction;
    return Web3SubstrateSendTransaction._(
        assetId: Web3ValidatorUtils.parseHex<List<int>?>(
            key: "assetId", method: method, json: json),
        blockHash: Web3ValidatorUtils.parseHex<List<int>>(
            key: "blockHash", method: method, json: json),
        genesisHash: Web3ValidatorUtils.parseHex<List<int>>(
            key: "genesisHash", method: method, json: json),
        blockNumber: Web3ValidatorUtils.parseInt<int>(
            key: "blockNumber", method: method, json: json, sign: false),
        tip: Web3ValidatorUtils.parseBigInt<BigInt>(
            key: "tip", method: method, json: json, sign: false),
        specVersion: Web3ValidatorUtils.parseInt<int>(
            key: "specVersion", method: method, json: json, sign: false),
        nonce: Web3ValidatorUtils.parseInt<int>(
            key: "nonce", method: method, json: json, sign: false),
        mode: Web3ValidatorUtils.parseInt<int?>(
            key: "mode", method: method, json: json, sign: false),
        transactionVersion: Web3ValidatorUtils.parseInt<int>(
            key: "transactionVersion", method: method, json: json),
        version: Web3ValidatorUtils.parseInt<int>(
            key: "version", method: method, json: json, sign: false),
        call: Web3ValidatorUtils.parseHex<List<int>>(
            key: "method", method: method, json: json),
        accessAccount: address,
        era: Web3ValidatorUtils.parseHex<List<int>>(
            key: "era", method: method, json: json),
        metadataHash: Web3ValidatorUtils.parseHex<List<int>?>(
            key: "metadataHash", method: method, json: json),
        signedExtensions: Web3ValidatorUtils.parseList<List<String>, String>(
            key: 'signedExtensions', method: method, json: json),
        withSignedTransaction: Web3ValidatorUtils.parseBool<bool?>(
            key: "withSignedTransaction", method: method, json: json));
  }

  factory Web3SubstrateSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SubstrateSendTransaction._(
      accessAccount: Web3SubstrateChainAccount.deserialize(
          object: values.elementAs<CborTagValue>(1)),
      assetId: values.elementAs(2),
      blockHash: values.elementAs(3),
      blockNumber: values.elementAs(4),
      era: values.elementAs(5),
      genesisHash: values.elementAs(6),
      metadataHash: values.elementAs(7),
      call: values.elementAs(8),
      mode: values.elementAs(9),
      nonce: values.elementAs(10),
      specVersion: values.elementAs(11),
      tip: values.elementAs(12),
      transactionVersion: values.elementAs(13),
      signedExtensions: values
          .elementAsListOf<CborStringValue>(14)
          .map((e) => e.value)
          .toList(),
      version: values.elementAs(15),
      withSignedTransaction: values.elementAs(16),
    );
  }

  @override
  Web3SubstrateRequestMethods get method =>
      Web3SubstrateRequestMethods.signTransaction;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          accessAccount.toCbor(),
          assetId == null ? null : CborBytesValue(assetId!),
          CborBytesValue(blockHash),
          blockNumber,
          CborBytesValue(era),
          CborBytesValue(genesisHash),
          metadataHash == null ? null : CborBytesValue(metadataHash!),
          CborBytesValue(call),
          mode,
          nonce,
          specVersion,
          tip,
          transactionVersion,
          CborListValue.fixedLength(
              signedExtensions.map((e) => CborStringValue(e)).toList()),
          version,
          withSignedTransaction
        ]),
        type.tag);
  }

  @override
  Web3SubstrateRequest<Web3SubstrateSendTransactionResponse,
          Web3SubstrateSendTransaction>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SubstrateRequest<Web3SubstrateSendTransactionResponse,
        Web3SubstrateSendTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  final Web3SubstrateChainAccount accessAccount;

  @override
  List<Web3SubstrateChainAccount> get requiredAccounts => [accessAccount];

  @override
  Object? toJsWalletResponse(Web3SubstrateSendTransactionResponse response) {
    return response.toCbor().encode();
  }
}
