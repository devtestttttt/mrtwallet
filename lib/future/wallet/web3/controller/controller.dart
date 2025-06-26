import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/types.dart';
import 'package:on_chain_wallet/future/wallet/web3/web3.dart';
import 'package:on_chain_wallet/wallet/api/client/core/client.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/web3/web3.dart';

abstract class Web3StateContoller<WEB3REQUEST extends Web3Request>
    extends StateController {
  WEB3REQUEST get request;
  ChainAccount? get permissionAccount;

  final GlobalKey<Web3PageProgressState> progressKey =
      GlobalKey<Web3PageProgressState>();
  StreamSubscription<dynamic>? onRequestError;
  Future<void> initWeb3();
  bool get web3Closed => request.info.isClosed;

  void _onChangeStatus(Web3RequestCompleterEvent event) {
    switch (event.type) {
      case Web3RequestCompleterEventType.success:
        progressKey.successRequest();
        break;
      case Web3RequestCompleterEventType.closed:
        progressKey.closedRequest(error: event.message);
        break;
      default:
    }
  }

  @override
  void close() {
    onRequestError?.cancel();
    onRequestError = null;
    super.close();
  }
}

mixin Web3GlobalRequestControllerState<WEB3REQUEST extends Web3GlobalRequest>
    on Web3StateContoller<WEB3REQUEST> {
  @override
  ChainAccount? get permissionAccount => null;
  Future<void> _readyWeb3() async {
    notify();
    final isReady = await MethodUtils.after(() async => _init());
    if (isReady) {
      final r = await MethodUtils.call(() => initWeb3());
      if (r.hasError) {
        progressKey.errorResponse(error: r.exception);
        final error = Web3RequestExceptionConst.fromException(r.exception!);
        request.error(error);
      }
    }
  }

  Future<bool> _init() async {
    if (web3Closed) {
      progressKey.closedRequest();
    } else {
      onRequestError = request.info.stream.listen(_onChangeStatus);
      return true;
    }

    return false;
  }

  @override
  void ready() {
    super.ready();
    _readyWeb3();
  }
}

// typedef WEB3NETWORKREQUESTCONTROLLERSTATE =
abstract class Web3NetworkRequestControllerState<
    RESPONSE,
    NETWORK extends WalletNetwork,
    CLIENT extends NetworkClient,
    WALLETACCOUNT extends ChainAccount,
    CHAIN extends APPCHAINACCOUNTCLIENTNETWORK<WALLETACCOUNT, CLIENT, NETWORK>,
    CHANACCOUNT extends Web3ChainAccount,
    WEB3CHAIN extends Web3Chain<dynamic, CHAIN, WALLETACCOUNT, CHANACCOUNT,
        WalletNetwork>,
    PARAMS extends Web3RequestParams<RESPONSE, dynamic, CHAIN, WALLETACCOUNT,
        CHANACCOUNT, WEB3CHAIN>,
    WEB3REQUEST extends Web3NetworkRequest<
        RESPONSE,
        dynamic,
        CHAIN,
        CHANACCOUNT,
        WALLETACCOUNT,
        WEB3CHAIN,
        PARAMS>> extends Web3StateContoller<WEB3REQUEST> {
  Web3NetworkRequestControllerState({
    required this.request,
    required this.walletProvider,
  })  : permissionAccount = request.accounts.firstOrNull,
        network = request.chain.network,
        account = request.chain;

  CLIENT? _client;
  CLIENT get apiProvider => _client!;
  CLIENT? get clientOrNull => _client;

  bool get clientRequired => true;
  @override
  final WALLETACCOUNT? permissionAccount;
  WALLETACCOUNT get address => permissionAccount!;
  final CHAIN account;
  final NETWORK network;
  final WalletProvider walletProvider;
  @override
  final WEB3REQUEST request;

  Future<bool> _init() async {
    if (web3Closed) {
      progressKey.closedRequest();
    } else {
      onRequestError = request.info.stream.listen(_onChangeStatus);
      if (clientRequired) {
        progressKey.process(text: 'node_connectiong_please_wait'.tr);
        final client = await request.chain.clientOrNull();
        if (client == null) {
          progressKey.errorResponse(
              message: "web3_client_connection_failed".tr);
          request.error(Web3RequestExceptionConst.disconnectedChain);
          return false;
        }
        _client = client;
      }
      return true;
    }

    return false;
  }

  Future<void> _readyWeb3() async {
    notify();
    final isReady = await MethodUtils.after(() async => _init());
    if (isReady) {
      final r = await MethodUtils.call(() => initWeb3());
      if (r.hasError) {
        progressKey.errorResponse(error: r.exception);
        final error = Web3RequestExceptionConst.fromException(r.exception!);
        request.error(error);
      }
    }
  }

  @override
  void ready() {
    super.ready();
    _readyWeb3();
  }
}
