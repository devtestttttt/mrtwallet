import 'dart:js_interop';

import 'package:on_chain_wallet/wallet/web3/core/messages/models/models/exception.dart';

@JS("Error")
extension type JSError._(JSAny _) implements JSAny {
  external factory JSError({String? message});
  external String? get message;
}

extension type JSWalletError._(JSAny _) implements JSError {
  external factory JSWalletError(
      {String? message,
      int? code,
      String? walletCode,
      String? data,
      String? stack});
  // external String? get stack;
  // external set stack(String? info);
  @JS("toString")
  external set toStr(JSFunction f);
}

extension ToWalletError on Web3ExceptionMessage {
  JSWalletError toWalletError({String? stack}) {
    final error = JSWalletError(
        message: message, code: code, walletCode: walletCode, data: data);
    return error;
  }
}
