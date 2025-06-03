import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/future/router/page_router.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/wallet_signing_password.dart';
import 'package:on_chain_wallet/marketcap/prices/live_currency.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';
import 'package:on_chain_wallet/wallet/web3/core/request/web_request.dart';
import 'package:on_chain_wallet/wallet/web3/networks/global/params/core/core.dart';

abstract class UIWallet extends WalletCore {
  UIWallet({required this.navigatorKey, required this.storageVersion});
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  final int storageVersion;
  bool get isolate => true;

  final LiveCurrencies currency = LiveCurrencies();
  StreamSubscription<WStatus>? _onWalletStatus;
  void _listener(WStatus status) {
    switch (status) {
      case WStatus.init:
      case WStatus.setup:
      case WStatus.lock:
        navigatorKey.currentContext?.popToHome();
        break;
      case WStatus.readOnly:
      case WStatus.unlock:
        currency.streamPrices(coinIds());
        break;
    }
  }

  Future<String> _getPassword(
      {required Set<AddressDerivationIndex> keys,
      required Set<ChainAccount> addresses}) async {
    final pw = await navigatorKey.currentContext?.openSliverBottomSheet<String>(
      "sign_transaction".tr,
      initiaalExtend: 1,
      bodyBuilder: (controller) => WalletSigningPassword(
        addresses: addresses,
        keys: keys,
        controller: controller,
        onPasswordForm: (password) async {
          final result = await login(password);
          return result.hasResult;
        },
      ),
    );
    if (pw == null) {
      throw WalletExceptionConst.rejectSigning;
    }
    return pw;
  }

  Future<MethodResult<T>> signTransaction<T>(
      {required WalletSigningRequest<T> request, Duration? timeout}) async {
    return await MethodUtils.call(() async {
      late final Set<ChainAccount> addresses = request.addresses.toSet();
      late final Set<AddressDerivationIndex> keys =
          addresses.map((e) => e.signerKeyIndexes()).expand((e) => e).toSet();
      if (wallet.protectWallet) {
        final password = await _getPassword(addresses: addresses, keys: keys);
        final r = (await super.signRequest(
            request: request, password: password, timeout: timeout));
        return r.result;
      }
      return (await super.signRequest(request: request, timeout: timeout))
          .result;
    });
  }

  Future<void> updateBalance() async {
    if (!isOpen) return;
    await updateCurrentAccountBalance();
  }

  @override
  Future<bool> onWeb3Request(Web3Request request) async {
    String? page;
    if (request is Web3NetworkRequest) {
      page = PageRouter.web3Page(request.chain.network);
    } else if (request is Web3GlobalRequest) {
      page = PageRouter.web3Global;
    }
    if (page == null) return false;
    return navigatorKey.currentContext?.toSync(page, argruments: request) ??
        false;
  }

  void dispose() {
    _onWalletStatus?.cancel();
    _onWalletStatus = null;
  }

  Future<void> init() async {
    _onWalletStatus = status.stream.listen(_listener);
    await initWallet();
  }
}
