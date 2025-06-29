part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

abstract class _WalletController with CryptoWokerImpl {
  _WalletController(this._walletCore, this._appChains);

  /// base wallet
  WalletCore? _walletCore;
  WalletCore get _core {
    if (_walletCore == null) {
      throw WalletExceptionConst.walletIsNotavailable;
    }
    return _walletCore!;
  }

  /// wallet key
  List<int>? _walletKey;

  /// wallet encryption data
  EncryptedMasterKey? _massterKey;

  /// wallet information like name, settings and etc.
  HDWallet get _wallet => _appChains.wallet;

  /// wallet networks controller.
  final ChainsHandler _appChains;

  /// current wallet account
  Chain get _chain => _appChains.chain;

  /// current wallet network
  WalletNetwork get network => _chain.network;

  /// update wallet storage.
  Future<void> _updateWallet() async {
    await _core._updateWallet(_wallet);
  }
}

class WalletController extends _WalletController
    with WalletManager, Web3Impl, WalletMoneroImpl {
  WalletController._(WalletCore super.core, super.chains);

  /// setup wallet.
  static Future<WalletController> _setup(
      WalletCore core, HDWallet wallet) async {
    final List<Chain> chains = [];
    final values = await core._readAccounts(wallet);
    for (final i in values) {
      try {
        final chain = Chain.deserialize(hex: i);
        chains.add(chain);
      } catch (_) {}
    }
    final handler = await ChainsHandler.setup(chains: chains, wallet: wallet);
    final controller = WalletController._(core, handler);
    await controller._onInitController();
    return controller;
  }

  /// dispose wallet.
  @override
  void _dispose() {
    _walletCore = null;
    _walletKey = null;
    _massterKey = null;
    _chain.dispose();
    super._dispose();
  }
}
