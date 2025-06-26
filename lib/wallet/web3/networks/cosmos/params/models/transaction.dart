import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/constant/constants/exception.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/params/core/request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/cosmos/permission/models/account.dart';
import 'package:on_chain_wallet/wallet/web3/utils/web3_validator_utils.dart';

abstract class Web3CosmosSignTransactionResponse with CborSerializable {
  final Web3CosmosRequestMethods method;
  final List<int> signature;
  final Any publicKey;
  String singaureAsBase64() {
    return StringUtils.decode(signature, type: StringEncoding.base64);
  }

  Web3CosmosSignTransactionResponse._(
      {required this.method,
      required List<int> signature,
      required this.publicKey})
      : signature = signature.asImmutableBytes;
  Map<String, dynamic> toWalletConnectJson();
  factory Web3CosmosSignTransactionResponse.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: hex);
    final method = Web3NetworkRequestMethods.fromTag(cbor.tags);
    return switch (method) {
      Web3CosmosRequestMethods.signTransactionDirect =>
        Web3CosmosSignTransactionDirectSignResponse.deserialize(obj: cbor),
      Web3CosmosRequestMethods.signTransactionAmino =>
        Web3CosmosSignTransactionAminoSignResponse.deserialize(obj: cbor),
      _ => throw Web3RequestExceptionConst.invalidRequest
    };
  }

  T cast<T extends Web3CosmosSignTransactionResponse>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as T;
  }
}

class Web3CosmosSignTransactionDirectSignResponse
    extends Web3CosmosSignTransactionResponse {
  final List<int> bodyBytes;
  final List<int> authInfoBytes;
  final String chainId;
  final BigInt accountNumber;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(signature),
          CborBytesValue(publicKey.toBuffer()),
          CborBytesValue(bodyBytes),
          CborBytesValue(authInfoBytes),
          chainId,
          accountNumber
        ]),
        method.tag);
  }

  factory Web3CosmosSignTransactionDirectSignResponse.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: Web3CosmosRequestMethods.signTransactionDirect.tag);
    return Web3CosmosSignTransactionDirectSignResponse(
        signature: values.elementAs(0),
        publicKey: Any.deserialize(values.elementAs(1)),
        bodyBytes: values.elementAs(2),
        authInfoBytes: values.elementAs(3),
        chainId: values.elementAs(4),
        accountNumber: values.elementAs(5));
  }
  Web3CosmosSignTransactionDirectSignResponse(
      {required List<int> bodyBytes,
      required List<int> authInfoBytes,
      required super.signature,
      required this.chainId,
      required this.accountNumber,
      required super.publicKey})
      : bodyBytes = bodyBytes.asImmutableBytes,
        authInfoBytes = authInfoBytes.asImmutableBytes,
        super._(method: Web3CosmosRequestMethods.signTransactionDirect);

  factory Web3CosmosSignTransactionDirectSignResponse.fromJson(
      Map<String, dynamic> json) {
    return Web3CosmosSignTransactionDirectSignResponse(
        bodyBytes: (json["bodyBytes"] as List).cast(),
        authInfoBytes: (json["authInfoBytes"] as List).cast(),
        signature: (json["signature"] as List).cast(),
        chainId: json["chainId"],
        accountNumber: BigintUtils.parse(json["accountNumber"]),
        publicKey: Any.fromJson(json["pubKey"]));
  }

  @override
  Map<String, dynamic> toWalletConnectJson() {
    return {
      "signed": {
        "bodyBytes": StringUtils.decode(bodyBytes, type: StringEncoding.base64),
        "authInfoBytes":
            StringUtils.decode(authInfoBytes, type: StringEncoding.base64),
        "chainId": chainId,
        "accountNumber": accountNumber.toString()
      },
      "signature": {
        "signature": singaureAsBase64(),
        "pub_key": {"type": publicKey.typeUrl, "value": publicKey.toBase64}
      },
    };
  }
}

class Web3CosmosSignTransactionAminoSignResponse
    extends Web3CosmosSignTransactionResponse {
  final AminoTx tx;
  Web3CosmosSignTransactionAminoSignResponse({
    required super.signature,
    required this.tx,
    required super.publicKey,
  }) : super._(method: Web3CosmosRequestMethods.signTransactionAmino);
  factory Web3CosmosSignTransactionAminoSignResponse.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: Web3CosmosRequestMethods.signTransactionAmino.tag);
    return Web3CosmosSignTransactionAminoSignResponse(
        signature: values.elementAs(0),
        publicKey: Any.deserialize(values.elementAs(1)),
        tx: AminoTx.fromJson(
            StringUtils.decodeJson<Map<String, dynamic>>(values.elementAs(2))));
  }
  factory Web3CosmosSignTransactionAminoSignResponse.fromJson(
      Map<String, dynamic> json) {
    return Web3CosmosSignTransactionAminoSignResponse(
        signature: (json["signature"] as List).cast(),
        tx: AminoTx.fromJson(json["tx"]),
        publicKey: Any.fromJson(json["pubKey"]));
  }

  @override
  Map<String, dynamic> toWalletConnectJson() {
    return {
      "tx": tx.toJson(),
      "signed": tx.toJson(),
      "signature": {
        "signature": singaureAsBase64(),
        "pub_key": {"type": publicKey.typeUrl, "value": publicKey.toBase64}
      },
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(signature),
          CborBytesValue(publicKey.toBuffer()),
          CborBytesValue(StringUtils.encodeJson(tx.toJson())),
        ]),
        method.tag);
  }
}

abstract class Web3CosmosSignTransactionParams with CborSerializable {
  final Web3CosmosRequestMethods method;
  const Web3CosmosSignTransactionParams({required this.method});
  factory Web3CosmosSignTransactionParams.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: obj, hex: hex);
    final method = Web3CosmosRequestMethods.fromId(tag.tags.firstOrNull);
    return switch (method) {
      Web3CosmosRequestMethods.signTransactionAmino =>
        Web3CosmosSignTransactionAminoParams.deserialize(obj: tag),
      Web3CosmosRequestMethods.signTransactionDirect =>
        Web3CosmosSignTransactionDirectParams.deserialize(obj: tag),
      _ => throw Web3RequestExceptionConst.invalidRequest
    };
  }
}

class Web3CosmosSignTransactionDirectParams
    extends Web3CosmosSignTransactionParams {
  final List<int> bodyBytes;
  final List<int>? authInfos;
  final BigInt? accountNumber;
  Web3CosmosSignTransactionDirectParams({
    required List<int> bodyBytes,
    required List<int>? authInfos,
    required this.accountNumber,
  })  : bodyBytes = bodyBytes.asImmutableBytes,
        authInfos = authInfos?.asImmutableBytes,
        super(method: Web3CosmosRequestMethods.signTransactionDirect);
  factory Web3CosmosSignTransactionDirectParams.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: [Web3CosmosRequestMethods.signTransactionDirect.id]);
    return Web3CosmosSignTransactionDirectParams(
        bodyBytes: values.elementAs(0),
        authInfos: values.elementAs(1),
        accountNumber: values.elementAs(2));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(bodyBytes),
          authInfos == null ? const CborNullValue() : CborBytesValue(authInfos!)
        ]),
        [method.id]);
  }
}

class Web3CosmosSignTransactionAminoParams
    extends Web3CosmosSignTransactionParams {
  final AminoTx tx;
  Web3CosmosSignTransactionAminoParams(this.tx)
      : super(method: Web3CosmosRequestMethods.signTransactionAmino);
  factory Web3CosmosSignTransactionAminoParams.deserialize(
      {List<int>? bytes, String? hex, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: [Web3CosmosRequestMethods.signTransactionAmino.id]);
    final data = StringUtils.decodeJson<Map<String, dynamic>>(
        values.elementAs<List<int>>(0));
    return Web3CosmosSignTransactionAminoParams(AminoTx.fromJson(data));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([CborBytesValue(tx.toBuffer())]),
        [method.id]);
  }
}

class Web3CosmosSignTransaction
    extends Web3CosmosRequestParam<Web3CosmosSignTransactionResponse> {
  final Web3CosmosChainAccount accessAccount;
  final String chainId;
  final Web3CosmosSignTransactionParams transaction;
  final bool? preferNoSetFee;
  final bool? preferNoSetMemo;
  final bool? disableBalanceCheck;
  final BigInt? timeoutHeight;

  Web3CosmosSignTransaction._(
      {required this.accessAccount,
      required this.chainId,
      required this.transaction,
      required this.preferNoSetFee,
      required this.preferNoSetMemo,
      required this.disableBalanceCheck,
      required this.timeoutHeight});
  factory Web3CosmosSignTransaction({
    required Web3CosmosChainAccount account,
    required String chainId,
    required Web3CosmosSignTransactionParams transaction,
    bool? preferNoSetFee,
    bool? preferNoSetMemo,
    bool? disableBalanceCheck,
    BigInt? timeoutHeight,
  }) {
    switch (transaction.method) {
      case Web3CosmosRequestMethods.signTransactionAmino:
      case Web3CosmosRequestMethods.signTransactionDirect:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    return Web3CosmosSignTransaction._(
        accessAccount: account,
        chainId: chainId,
        disableBalanceCheck: disableBalanceCheck,
        preferNoSetFee: preferNoSetFee,
        preferNoSetMemo: preferNoSetMemo,
        transaction: transaction,
        timeoutHeight: timeoutHeight);
  }

  factory Web3CosmosSignTransaction.fromJson(
      {required Map<String, dynamic> json,
      required Web3CosmosRequestMethods method,
      required Web3CosmosChainAccount account,
      required String chainId}) {
    // final String? requestChainId = Web3ValidatorUtils.parseString(
    //     key: "chainId", method: method, json: json);
    if (method == Web3CosmosRequestMethods.signTransactionAmino) {
      final aminoJson = Web3ValidatorUtils.tryObjectAsMap(json["signDoc"]);
      if (aminoJson == null) {
        throw Web3CosmosExceptionConstant.invalidAminoSignDoc;
      }
      final AminoTx amino = AminoTx.fromJson(aminoJson);
      if (chainId != amino.chainId) {
        throw Web3CosmosExceptionConstant.mismatchChainId;
      }
      return Web3CosmosSignTransaction(
          account: account,
          chainId: amino.chainId,
          transaction: Web3CosmosSignTransactionAminoParams(amino));
    }
    final Map<String, dynamic> signDoc = Web3ValidatorUtils.parseMap(
        key: "signDoc",
        method: method,
        json: json,
        requiredKeys: ["bodyBytes"]);
    final List<int> bodyBytes = Web3ValidatorUtils.parseBase64(
        key: "bodyBytes", method: method, json: signDoc, allowBytes: true);
    final List<int>? authInfoBytes = Web3ValidatorUtils.parseBase64(
        key: "authInfoBytes", method: method, json: signDoc, allowBytes: true);
    final BigInt? accountNumber = Web3ValidatorUtils.parseBigInt(
        key: "accountNumber", method: method, json: signDoc);
    return Web3CosmosSignTransaction(
        account: account,
        chainId: chainId,
        transaction: Web3CosmosSignTransactionDirectParams(
            bodyBytes: bodyBytes,
            authInfos: authInfoBytes,
            accountNumber: accountNumber));
  }

  factory Web3CosmosSignTransaction.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3CosmosSignTransaction(
        account: Web3CosmosChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        chainId: values.elementAs(2),
        transaction: Web3CosmosSignTransactionParams.deserialize(
            obj: values.getCborTag(3)),
        disableBalanceCheck: values.elementAs(4),
        preferNoSetFee: values.elementAs(5),
        preferNoSetMemo: values.elementAs(6));
  }

  @override
  Web3CosmosRequestMethods get method => transaction.method;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          accessAccount.toCbor(),
          chainId,
          transaction.toCbor(),
          disableBalanceCheck,
          preferNoSetFee,
          preferNoSetMemo
        ]),
        type.tag);
  }

  @override
  Object? toJsWalletResponse(Web3CosmosSignTransactionResponse response) {
    return response.toCbor().encode();
  }

  @override
  Web3CosmosRequest<Web3CosmosSignTransactionResponse,
          Web3CosmosSignTransaction>
      toRequest(
          {required Web3RequestInformation request,
          required Web3RequestAuthentication authenticated,
          required List<Chain> chains}) {
    final chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3CosmosRequest<Web3CosmosSignTransactionResponse,
        Web3CosmosSignTransaction>(
      params: this,
      authenticated: authenticated,
      chain: chain.$1,
      info: request,
      accounts: chain.$2,
    );
  }

  @override
  List<Web3CosmosChainAccount> get requiredAccounts => [accessAccount];
}
