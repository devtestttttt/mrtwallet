part of 'package:on_chain_wallet/wallet/provider/wallet_provider.dart';

mixin WalletMoneroImpl on WalletManager {
  /// import monero pending transactions to account
  /// -[account]: related monero account.
  /// -[txIds]: transaction ids for importing.
  Future<List<MoneroUnlockedPaymentRequestDetails>> _moneroUpdatePendingTxes(
      {required MoneroChain account,
      List<MoneroAccountPendingTxes>? txIds}) async {
    final txids = txIds ?? account.getAccountsPendingTxes();
    if (txids.isEmpty) return [];
    final client = await account.client();
    final r = await _callWalletInternal(
      ({required masterKey, required wKey}) async {
        final unlockedInfo = await _walletRequest(
            masterkey: masterKey,
            walletKey: wKey,
            message: WalletRequestMoneroOutputUnlocker(
                requests: txids, provider: client.service.provider));
        await account.addUnlockedPayment(unlockedInfo.payments);
        return unlockedInfo.payments;
      },
    );
    return r?.map((e) => e.responses).expand((e) => e).toList() ?? [];
  }

  @override
  Future<void> _onInitController() async {
    await super._onInitController();
  }

  @override
  void _onUnlock() async {
    super._onUnlock();
    final chains = _appChains.chains().whereType<MoneroChain>();
    for (final i in chains) {
      await i.init();
      _moneroUpdatePendingTxes(account: i);
    }
  }
}
