import 'dart:async';
import 'package:flutter/material.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:on_chain_bridge/web/api/chrome/api/core.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/keys/access/crypto_keys/crypto_keys.dart';
import 'package:on_chain_wallet/future/wallet/controller/extension/impl/extention_wallet.dart';
import 'package:on_chain_wallet/future/wallet/controller/wallet/ui_wallet.dart';
import 'package:on_chain_wallet/future/wallet/web3/controller/web3_request_controller.dart';
import 'package:on_chain_wallet/wallet/models/access/wallet_access.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/setting/models/lock_time.dart';
import 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';
import 'package:on_chain_wallet/crypto/impl/worker_impl.dart';
import 'io.dart';

UIWallet uiWallet(GlobalKey<NavigatorState> navigatorKey, int storageVersion) {
  if (PlatformInterface.isWeb && isExtension) {
    return ExtentionWallet(
        navigatorKey: navigatorKey, storageVersion: storageVersion);
  }
  return Wallet(navigatorKey: navigatorKey, storageVersion: storageVersion);
}

class ExtentionWallet extends UIWallet
    with CryptoWokerImpl, Web3RequestControllerImpl, ExtentionWalletHandler {
  ExtentionWallet({required super.navigatorKey, required super.storageVersion});
  final _lock = SynchronizedLock();

  @override
  Future<MethodResult<WalletLockTime>> login(String password) async {
    final bool isReadOnly = this.isReadOnly || isLock;
    final result = await super.login(password);
    if (isReadOnly && isUnlock) {
      await _lock.synchronized(() async {
        await saveLoginHistory(password);
      });
    }
    return result;
  }

  @override
  Future<MethodResult<List<CryptoKeyData>>> accsess(
      WalletAccsessType accsessType, String password,
      {ChainAccount? account, String? keyId}) async {
    final bool isReadOnly = this.isReadOnly || isLock;
    final result = await super
        .accsess(accsessType, password, account: account, keyId: keyId);
    if (isReadOnly && isUnlock) {
      await _lock.synchronized(() async {
        await saveLoginHistory(password);
      });
    }
    return result;
  }

  @override
  Future<void> lock() async {
    await _lock.synchronized(() async {
      await clearLoginHistory();
    });
    await super.lock();
  }

  @override
  Future<void> initWallet(
      {bool useIsolate = true,
      String? initialPassword,
      DateTime? locktime}) async {
    crypto.init(true);
    final loginHistory = await _lock.synchronized(() async {
      return await getLoginHistory();
    });
    await super.initWallet(initialPassword: loginHistory);
    if (loginHistory != null && isUnlock) {
      _lock.synchronized(() async {
        return await saveLoginHistory(loginHistory);
      });
    }
  }

  @override
  Future<void> init() async {
    await initContext();
    await super.init();
    await initExtension();
  }

  @override
  WalletCore get walletCore => this;
}
