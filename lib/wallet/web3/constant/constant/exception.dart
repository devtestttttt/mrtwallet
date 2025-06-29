import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_wallet/app/error/exception/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/exception/exception.dart';

class Web3RequestExceptionConst {
  static Web3RequestException fromException(Object exception) {
    if (exception is Web3RequestException) return exception;
    if (exception is RPCError) {
      return Web3RequestException(
          message: exception.message,
          code: exception.errorCode ?? -1,
          walletCode: "WALLET-001",
          data: StringUtils.tryFromJson(exception.details));
    } else if (exception is ApiProviderException) {
      return Web3RequestException(
          message: "The Provider is disconnected.",
          code: 4901,
          walletCode: "WALLET-001",
          data: exception.isTimeout ? "Request timeout" : exception.toString());
    }
    return internalError;
  }

  static const Web3RequestException internalError = Web3RequestException(
      message: "An error occurred during the request",
      walletCode: "WALLET-000",
      code: -32603);

  static const Web3RequestException rejectedByUser = Web3RequestException(
    message: "The user rejected the request.",
    walletCode: "WALLET-3000",
    code: 4001,
  );

  static const Web3RequestException invalidRequest = Web3RequestException(
      message: "The request is not a valid Request object.",
      walletCode: "WALLET-4050",
      code: -32000);

  static const Web3RequestException invalidNetwork = Web3RequestException(
      message: "The specified network is invalid or does not exist.",
      walletCode: "WALLET-4000",
      code: -32000);

  static const Web3RequestException missingPermission = Web3RequestException(
      message:
          "The requested method and/or account has not been authorized by the user.",
      data:
          "The Web3 application does not have the required permissions. Please send a permission request first.",
      walletCode: "WEB3-4010",
      code: 4100);

  static const Web3RequestException methodDoesNotExist = Web3RequestException(
      message:
          "The requested method does not exist. Please check the method name and try again.",
      walletCode: "WEB3-4030",
      code: 4200);

  static const Web3RequestException methodDoesNotSupport = Web3RequestException(
      message: "The requested method does not supported.",
      walletCode: "WEB3-4030",
      code: 4200);

  static const Web3RequestException disconnectedChain = Web3RequestException(
      message: "The Provider is not connected to the requested chain.",
      walletCode: "WEB3-6000",
      code: 4901);

  static const Web3RequestException invalidHost = Web3RequestException(
      message:
          "Invalid host: Ensure that the request comes from a valid host and try again.",
      walletCode: "WEB3-4020",
      code: -1);
  static const Web3RequestException walletNotInitialized = Web3RequestException(
      message: "Wallet not initialized.", walletCode: "WEB3-5020", code: -1);

  static const Web3RequestException bannedHost = Web3RequestException(
      message:
          "The requested method and/or account has not been authorized by the user. The client is disable by the owner of the wallet.",
      walletCode: "WEB3-4040",
      code: 4100);

  static const Web3RequestException invalidParams = Web3RequestException(
      message: "Invalid method parameters.",
      walletCode: "WEB3-5100",
      code: -32602);

  static Web3RequestException invalidStringArgrument(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. $parameterName is not a valid string.",
          walletCode: "WEB3-0020",
          code: -32602);

  static Web3RequestException invalidBytesArgrument2(
          {required String arg, required List<StringEncoding> encoding}) =>
      Web3RequestException(
          message:
              "Invalid method parameters. $arg is not a valid bytes. Accepted formats (${encoding.map((e) => e.name).join(", ")}).",
          walletCode: "WEB3-0020",
          code: -32602);
  static Web3RequestException invalidBytesArgrumentElement({
    required int index,
    required List<StringEncoding> encoding,
  }) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Parameters at index $index is not a valid bytes. Accepted formats (${encoding.map((e) => e.name).join(", ")}).",
          walletCode: "WEB3-0020",
          code: -32602);

  ///

  static Web3RequestException invalidBoolean(String key) =>
      Web3RequestException(
          message: "Invalid method parameters. $key is not a valid boolean.",
          walletCode: "WEB3-0020",
          code: -32602);

  static Web3RequestException invalidAddressArgrument(
          {required String key, required String network}) =>
      Web3RequestException(
          message:
              "Invalid method parameters. $key is not a valid $network address.",
          walletCode: "WEB3-0030",
          code: -32602);

  static Web3RequestException invalidAddress(
      {required String? key, required String network}) {
    if (key == null) {
      return Web3RequestException(
          message: "Failed to parse $network address.",
          walletCode: "WEB3-0030",
          code: -32602);
    }
    return Web3RequestException(
        message:
            "Failed to parse address. `$key` is not a valid $network address.",
        walletCode: "WEB3-0030",
        code: -32602);
  }

  static Web3RequestException invalidBase58(String key) => Web3RequestException(
      message: "Invalid method parameters. $key is not a valid Base58 string.",
      walletCode: "WEB3-0030",
      code: -32602);

  static Web3RequestException invalidHexBytes(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. $parameterName is not a valid hex string.",
          walletCode: "WEB3-0040",
          code: -32602);

  static Web3RequestException invalidBase64Bytes(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. $parameterName is not a valid base64 string.",
          walletCode: "WEB3-0040",
          code: -32602);

  static Web3RequestException invalidListArgument(String key) =>
      Web3RequestException(
          message: "Invalid method parameters. $key is not a valid list.",
          walletCode: "WEB3-0050",
          code: -32602);

  static Web3RequestException invalidMapParameters(
          {List<String> keys = const []}) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Parameters must be a valid object.",
          walletCode: "WEB3-0050",
          code: -32602);
  static Web3RequestException invalidMapArguments(
      {required String name, List<String> keys = const []}) {
    if (keys.isNotEmpty) {
      return Web3RequestException(
          message:
              "Invalid method parameters. $name must be a valid object contains (${keys.join(', ')})",
          walletCode: "WEB3-0060",
          code: -32602);
    }
    return Web3RequestException(
        message: "Invalid method parameters. $name must be a valid object.",
        walletCode: "WEB3-0060",
        code: -32602);
  }

  static Web3RequestException invalidListOfObject(
      {List<String> keys = const []}) {
    if (keys.isNotEmpty) {
      return Web3RequestException(
          message:
              "Invalid method parameters. Parameters must be a list of object contains (${keys.join(', ')})",
          walletCode: "WEB3-0060",
          code: -32602);
    }
    return Web3RequestException(
        message:
            "Invalid method parameters. Parameters must be a list of object.",
        walletCode: "WEB3-0060",
        code: -32602);
  }

  static Web3RequestException invalidNumbers(String arg) => Web3RequestException(
      message:
          "Invalid method parameters. $arg is not a valid number. Accepted formats (Integer, hexadecimal string)",
      walletCode: "WEB3-0070",
      code: -32602);

  static Web3RequestException invalidDecimalsNumbers(String arg) =>
      Web3RequestException(
          message:
              "Invalid method parameters. $arg is not a valid decimal number.",
          walletCode: "WEB3-0070",
          code: -32602);

  static Web3RequestException invalidObjectKeys(
          String parameterName, List<String> keys) =>
      Web3RequestException(
          message:
              "Invalid method parameters. $parameterName must be a object and contain one of the following keys: ${keys.join(", ")}",
          walletCode: "WEB3-0070",
          code: -32602);

  // Invalid gas data object. The object must contain one of the following keys: Result, Input, or NestedResult
  static const Web3RequestException invalidMethodArgruments =
      Web3RequestException(
          message: "Invalid method parameters.",
          walletCode: "WEB3-0080",
          code: -32602);

  /// eth

  static Web3RequestException networkIdDoesNotExists(String chainId) =>
      Web3RequestException(
          message: "Unsuported network. $chainId network does not exists.",
          walletCode: "WEB3-5080",
          code: -32600);
  static Web3RequestException get invalidCaip2ChainIdStyle => Web3RequestException(
      message:
          "Invalid method parameters. each chainId must be a valid CAIP-2 stryle like (eip1159:1)",
      walletCode: "WEB3-5080",
      code: -32600);
  static const Web3RequestException networkDoesNotExists = Web3RequestException(
      message:
          "Invalid method parameters. The specified Network does not exist.",
      walletCode: "WEB3-5080",
      code: -32600);
  static const Web3RequestException ethereumRpcWrongChainId = Web3RequestException(
      message:
          "The provided RPC link returned a different chain ID. Please ensure the RPC URL matches the expected chain ID.",
      walletCode: "WEB3-5090",
      code: -32600);
  static const Web3RequestException disconnectProvider = Web3RequestException(
      message: "The Provider is disconnected.",
      walletCode: "WEB3-5090",
      code: 4900);

  static Web3RequestException invalidParameters(String message) =>
      Web3RequestException(
          message: "Invalid method parameters: $message",
          data: message,
          walletCode: "WEB3-5100",
          code: -32602);

  static Web3RequestException unsuportedfeatures(String message,
          {String? data, Map<String, dynamic>? dataJson}) =>
      Web3RequestException(
          message: "Unsuported features: $message",
          walletCode: "WEB3-4030",
          code: 4200);
  static Web3RequestException excuteTransactionFailed(String error) =>
      Web3RequestException(
          message: "Excute transaction failed: $error",
          walletCode: "WEB3-4030",
          code: -32602);

  static Web3RequestException signingTransactionFailed(String error) =>
      Web3RequestException(
          message: "Signing transaction failed: $error",
          walletCode: "WEB3-4030",
          code: -32602);
  static Web3RequestException get invalidRequestStateAccount =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account argument. account is not valid wallet account.");

  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction: Failed to parse or validate the transaction parameters.");

  static Web3RequestException get badSignMessage =>
      Web3RequestExceptionConst.message(
          "Invalid sign message data: cannot sign transaction using this request.");

  static Web3RequestException failedToParse(String key) =>
      Web3RequestExceptionConst.message(
          "Invalid method parameters: failed to parse '$key'.");

  static Web3RequestException get multipleBatchRequestNetwork =>
      Web3RequestExceptionConst.message(
          "Invalid request accounts. for batch request all accounts must be related to same netowrk.");

  static Web3RequestException message(String message, {String? data}) =>
      Web3RequestException(
          message: message, data: data, walletCode: "WEB3-5100", code: -32602);

  static Web3RequestException invalidBytesOrHexArgrument2(String key) =>
      Web3RequestException(
          message:
              "Invalid method parameters. `$key` is not a valid bytes. Accepted formats are hexadecimal strings or Uint8Array. ",
          walletCode: "WEB3-0020",
          code: -32602);

  static Web3RequestException get invalidRpcUrl =>
      Web3RequestExceptionConst.invalidParameters(
          "rpcUrl must start with a valid scheme: http, https, ws, or wss.");
}
