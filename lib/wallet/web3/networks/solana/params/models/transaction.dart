import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/solana/src/rpc/models/models/commitment.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/constant/constants/constant.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/constant/constants/exception.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/solana/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/utils/web3_validator_utils.dart';

class Web3SolanaSendTransactionOptions with CborSerializable {
  final String? preflightCommitment;
  final int? minContextSlot;
  final bool? skipPreflight;
  final String? commitment;
  final int? maxRetries;
  const Web3SolanaSendTransactionOptions(
      {this.maxRetries,
      this.skipPreflight = false,
      this.commitment,
      this.minContextSlot,
      this.preflightCommitment});
  factory Web3SolanaSendTransactionOptions.fromJson(
      {required Map<String, dynamic> json,
      required Web3SolanaRequestMethods method}) {
    final bool isSignTx = method == Web3SolanaRequestMethods.signTransaction ||
        method == Web3SolanaRequestMethods.signAllTransactions;
    return Web3SolanaSendTransactionOptions(
        skipPreflight: isSignTx
            ? null
            : Web3ValidatorUtils.parseBool(
                key: "skipPreflight", method: method, json: json),
        maxRetries: isSignTx
            ? null
            : Web3ValidatorUtils.parseInt(
                key: "maxRetries", method: method, json: json),
        minContextSlot: Web3ValidatorUtils.parseInt(
            key: "minContextSlot", method: method, json: json),
        preflightCommitment: Web3ValidatorUtils.parseParams2(() {
          if (json["preflightCommitment"] == null) return null;
          return Commitment.values
              .firstWhere((e) => e.value == json["preflightCommitment"])
              .value;
        },
            errorOnNull: false,
            error: Web3SolanaExceptionConstant.invalidCommitmentOptions),
        commitment: Web3ValidatorUtils.parseParams2(() {
          if (isSignTx || json["commitment"] == null) return null;
          return Commitment.values
              .firstWhere((e) => e.value == json["commitment"])
              .value;
        },
            errorOnNull: false,
            error: Web3SolanaExceptionConstant.invalidCommitmentOptions));
  }
  factory Web3SolanaSendTransactionOptions.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final values = CborSerializable.cborTagValue<CborListValue>(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3SolanaConst.sendTransactionDataConfigTag);
    return Web3SolanaSendTransactionOptions(
      preflightCommitment: values.elementAs(0),
      maxRetries: values.elementAs(1),
      skipPreflight: values.elementAs(2),
      commitment: values.elementAs(3),
      minContextSlot: values.elementAt(4),
    );
  }
  // factory Web3SolanaSendTransactionOptions.fromJson(Map<String, dynamic> json) {
  //   return Web3SolanaSendTransactionOptions(
  //       commitment: json["preflightCommitment"],
  //       skipPreflight: json["skipPreflight"] ?? false,
  //       maxRetries: json["maxRetries"],
  //       minContextSlot: json["minContextSlot"],
  //       preflightCommitment: json["preflightCommitment"]);
  // }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          preflightCommitment,
          maxRetries,
          skipPreflight,
          commitment,
          minContextSlot
        ]),
        Web3SolanaConst.sendTransactionDataConfigTag);
  }
}

class Web3SolanaSendTransactionData with CborSerializable {
  final Web3SolanaChainAccount account;
  final List<int> messageBytes;
  final Web3SolanaSendTransactionOptions? sendConfig;

  Web3SolanaSendTransactionData({
    required this.account,
    required List<int> messageByte,
    required this.sendConfig,
  }) : messageBytes = messageByte.asImmutableBytes;
  factory Web3SolanaSendTransactionData.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final values = CborSerializable.cborTagValue<CborListValue>(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3SolanaConst.sendTransactionDataTag);
    return Web3SolanaSendTransactionData(
        account: Web3SolanaChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(0)),
        messageByte: values.elementAt(1),
        sendConfig:
            values.elemetMybeAs<Web3SolanaSendTransactionOptions, CborTagValue>(
                2,
                (e) =>
                    Web3SolanaSendTransactionOptions.deserialize(object: e)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          account.toCbor(),
          CborBytesValue(messageBytes),
          sendConfig?.toCbor()
        ]),
        Web3SolanaConst.sendTransactionDataTag);
  }
}

enum SolanaSignAndSendAllTransactionMode {
  parallel,
  serial;

  factory SolanaSignAndSendAllTransactionMode.fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3SolanaExceptionConstant.invalidModeOptions);
  }
}

class Web3SolanaTransactionResponse with CborSerializable {
  final List<int> signature;
  final List<int> signedTx;
  Web3SolanaTransactionResponse({
    required List<int> signature,
    required List<int> signedTx,
  })  : signature = signature.asImmutableBytes,
        signedTx = signedTx.asImmutableBytes;
  factory Web3SolanaTransactionResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.defaultTag);
    return Web3SolanaTransactionResponse(
        signature: values.elementAs(0), signedTx: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(signature),
          CborBytesValue(signedTx),
        ]),
        CborTagsConst.defaultTag);
  }

  Map<String, dynamic> toWalletConnectJson() {
    return {
      "signature": Base58Encoder.encode(signature),
      "signedTransaction":
          StringUtils.decode(signedTx, type: StringEncoding.base64),
    };
  }
}

class Web3SolanaSendTransaction
    extends Web3SolanaRequestParam<List<Web3SolanaTransactionResponse>> {
  final List<Web3SolanaSendTransactionData> messages;
  final SolanaSignAndSendAllTransactionMode? mode;

  Web3SolanaSendTransaction._(
      {required this.messages, required this.method, this.mode});

  factory Web3SolanaSendTransaction(
      {required List<Web3SolanaSendTransactionData> messages,
      required Web3NetworkRequestMethods method,
      SolanaSignAndSendAllTransactionMode? mode}) {
    switch (method) {
      case Web3SolanaRequestMethods.signAndSendAllTransactions:
      case Web3SolanaRequestMethods.signAllTransactions:
      case Web3SolanaRequestMethods.sendTransaction:
      case Web3SolanaRequestMethods.signTransaction:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (messages.isEmpty) {
      throw Web3RequestExceptionConst.invalidTransaction;
    }
    if (messages.map((e) => e.account.id).toSet().length != 1) {
      throw Web3RequestExceptionConst.multipleBatchRequestNetwork;
    }
    return Web3SolanaSendTransaction._(
        messages: messages,
        method: method as Web3SolanaRequestMethods,
        mode: mode);
  }

  factory Web3SolanaSendTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAt(0));
    return Web3SolanaSendTransaction(
        messages: values
            .elementAs<CborListValue>(1)
            .castValue<CborTagValue>()
            .map((e) => Web3SolanaSendTransactionData.deserialize(object: e))
            .toList(),
        method: method,
        mode: values
            .elemetMybeAs<SolanaSignAndSendAllTransactionMode, CborStringValue>(
                2,
                (e) => SolanaSignAndSendAllTransactionMode.fromName(e.value)));
  }

  @override
  final Web3SolanaRequestMethods method;

  late final bool isSend = method == Web3SolanaRequestMethods.sendTransaction ||
      method == Web3SolanaRequestMethods.signAndSendAllTransactions;
  late final bool isBatchRequest = messages.length > 1;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          CborListValue.fixedLength(messages.map((e) => e.toCbor()).toList()),
          mode?.name
        ]),
        type.tag);
  }

  @override
  Web3SolanaRequest<List<Web3SolanaTransactionResponse>,
          Web3SolanaSendTransaction>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SolanaRequest<List<Web3SolanaTransactionResponse>,
        Web3SolanaSendTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3SolanaChainAccount> get requiredAccounts =>
      messages.map((e) => e.account).toList();

  @override
  Object? toJsWalletResponse(List<Web3SolanaTransactionResponse> response) {
    return response.map((e) => e.toCbor().encode()).toList();
  }
}
