import 'dart:async';
import 'package:blockchain_utils/uuid/uuid.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';
import 'package:on_chain_wallet/wallet/web3/state/core/network.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/utils/list/extension.dart';
import 'package:on_chain_wallet/crypto/models/networks.dart';

class MessageCompleterHandler {
  final Map<String, MessageCompleter> _awaitingMessages = {};

  MessageCompleter get nextRequest {
    final requestId = UUID.generateUUIDv4();
    final completer = MessageCompleter(requestId);
    _awaitingMessages[requestId] = completer;
    return completer;
  }

  bool hasRequest(String id) {
    return _awaitingMessages.containsKey(id);
  }

  void complete(
      {required Web3MessageCore response, required String? requestId}) {
    final completer = _awaitingMessages.remove(requestId);
    completer?.complete(response);
  }
}

class MessageCompleter {
  final String id;
  MessageCompleter(this.id);
  final Completer<Web3MessageCore> _completer = Completer();
  Future<Web3MessageCore> get wait => _completer.future;
  void complete(Web3MessageCore value) {
    _completer.complete(value);
  }
}

enum Web3NetworkState {
  init,
  disconnect,
  block;

  bool get isBlock => this == block;
  bool get isInit => this == init;
}

typedef SENDINTERNALWALLETMESSAGE = Future<Web3MessageCore> Function(
    {required NetworkType network, required Web3WalletRequestParams request});
typedef FINALIZEERROR<RESPONSE, REQUEST> = RESPONSE Function(
    {required REQUEST message,
    required Web3RequestParams? params,
    required Web3ExceptionMessage error});
typedef FINALIZEWALLLETRESPONSE<RESPONSE, REQUEST> = RESPONSE Function(
    {required REQUEST message,
    required Web3RequestParams? params,
    required Web3WalletResponseMessage response});
typedef INTERNALMESSAGE<RESPONSE, REQUEST> = Future<RESPONSE> Function(
    {required REQUEST message,
    required Web3RequestParams? params,
    required Web3WalletResponseMessage response});

enum Web3StateProtocol {
  web,
  walletConnect;

  bool get isWeb => this == web;
  bool get isWalletConnect => this == walletConnect;
}

enum Web3RequestSource {
  walletStandard,
  walletConnect,
  injected;

  bool get isInjected => this == Web3RequestSource.injected;
}

class DefaultStateAddress {
  final String address;
  final String? chain;
  const DefaultStateAddress._({required this.address, required this.chain});
  static DefaultStateAddress? parse(dynamic json) {
    try {
      if (json is String) {
        return DefaultStateAddress._(address: json, chain: null);
      }
      if (json is Map &&
          json.containsKey("address") &&
          json.containsKey("chains")) {
        return DefaultStateAddress._(
            address: json["address"],
            chain: (json["chains"] as List).firstOrNull);
      }
    } catch (_) {}
    return null;
  }
}

abstract class Web3WalletHandler<STATE extends Web3StateHandler,
    REQUEST extends Web3ClientRequest> {
  final MessageCompleterHandler completer = MessageCompleterHandler();
}
