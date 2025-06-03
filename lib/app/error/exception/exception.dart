import 'dart:async';
import 'dart:io';

import 'package:blockchain_utils/exception/exception/rpc_error.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:http/http.dart' show ClientException;
import 'package:on_chain_wallet/app/utils/string/utils.dart';

class ApiProviderExceptionConst {
  static const int timeoutStatucCode = 10001;
  static ApiProviderException connectionClosed =
      ApiProviderException._(message: 'http_connection_closed');
}

class ApiProviderException implements Exception {
  static const List<int> validStatusCode = [
    404,
    400,
    401,
    403,
    405,
    408,
    500,
    503
  ];

  bool get resourceNotFound => statusCode == 404;

  final String message;
  final int? statusCode;
  final int? code;
  final Map<String, dynamic>? responseData;
  bool get isTimeout => code == ApiProviderExceptionConst.timeoutStatucCode;
  const ApiProviderException._(
      {required this.message, this.statusCode, this.responseData, this.code});
  factory ApiProviderException.fromStatucCode(int statusCode) {
    final defaultError = validStatusCode.contains(statusCode)
        ? "http_error_$statusCode"
        : "request_error";
    return ApiProviderException._(
        message: defaultError, statusCode: statusCode);
  }
  factory ApiProviderException.error(String message) {
    return ApiProviderException._(message: message);
  }
  factory ApiProviderException.fromException(
      {Object? message, int? statusCode, int? code}) {
    final defaultError = validStatusCode.contains(statusCode)
        ? "http_error_$statusCode"
        : "request_error";
    if (message == null) {
      return ApiProviderException._(
          message: defaultError, code: code, statusCode: statusCode);
    } else if (message is ClientException) {
      return ApiProviderException._(
          message: "api_http_client_error", statusCode: statusCode, code: code);
    } else if (message is TimeoutException) {
      return ApiProviderException._(
          message: "api_http_timeout_error",
          statusCode: statusCode,
          code: code);
    } else if (message is FormatException) {
      return ApiProviderException._(
          message: "format_exception", statusCode: statusCode, code: code);
    } else if (message is SocketException) {
      return ApiProviderException._(
          message: "socket_exception", statusCode: statusCode, code: code);
    } else if (message is HttpException) {
      return ApiProviderException._(
          message: "http_exception", statusCode: statusCode, code: code);
    } else if (message is ApiProviderException) {
      return message;
    } else if (message is RPCError) {
      return ApiProviderException._(
          message: message.message,
          statusCode: statusCode,
          code: message.errorCode);
    } else if (message is String && StrUtils.isHtml(message)) {
      return ApiProviderException._(
          code: code, message: defaultError, statusCode: statusCode);
    }
    final Map<String, dynamic>? decode = StringUtils.tryToJson(message);
    String? msg = (decode?["message"] ?? decode?["error"] ?? decode?["Error"])
        ?.toString();
    if (msg == null && message is String && message.trim().isNotEmpty) {
      msg = message;
    }
    if (msg == null && !validStatusCode.contains(statusCode)) {
      return ApiProviderException._(
          code: code,
          message: 'api_unknown_error',
          statusCode: statusCode,
          responseData: decode);
    }
    return ApiProviderException._(
        code: code,
        message: msg ?? defaultError,
        statusCode: statusCode,
        responseData: decode);
  }

  @override
  String toString() {
    return message;
  }
}
