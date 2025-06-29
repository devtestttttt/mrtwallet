import 'package:flutter/material.dart';
import 'package:on_chain_bridge/platform_interface.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:on_chain_wallet/wallet/web3/core/request/params.dart';
import 'package:on_chain_wallet/wallet/web3/core/request/web_request.dart';

class TestWallet extends WalletCore {
  @override
  bool get useMemoryStorage => true;

  @override
  int get storageVersion => 0;

  @override
  Future<bool> onWeb3Request(
      Web3Request<dynamic, Web3WalletRequestParams, Web3RequestAuthentication>
          request) {
    throw UnimplementedError();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformInterface.instance.getConfig();
  const mnemonic =
      "kiss dad garment soft that place balance resist hat uncle submit recall";
  final wallet = TestWallet();
  await wallet.initWallet(useIsolate: false);
  final initializeWallet = await wallet.createWallet(
      mnemonic: mnemonic, passphrase: null, password: "MyPassowrd##1234");
  await wallet.setup(
      hdWallet: initializeWallet,
      password: "MyPassowrd##1234",
      walletInfos: const WalletUpdateInfosData(
          name: "MyWallet",
          lockTime: WalletLockTime.fiveMinute,
          requirmentPassword: false,
          protectWallet: false));
}
