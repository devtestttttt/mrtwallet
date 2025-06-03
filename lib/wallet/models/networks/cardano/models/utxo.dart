import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'utxos.dart';

class CardanoUtxo {
  final ADAAccountUTXOs utxo;
  final IntegerBalance utxoBalance;
  const CardanoUtxo._({required this.utxo, required this.utxoBalance});
  factory CardanoUtxo(
      {required ADAAccountUTXOs utxo, required WalletCardanoNetwork network}) {
    return CardanoUtxo._(
        utxo: utxo,
        utxoBalance: IntegerBalance.token(utxo.sumOflovelace, network.token));
  }
}
