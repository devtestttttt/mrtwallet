import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/cardano/models/utxo.dart';
import 'package:on_chain_wallet/wallet/models/network/network.dart';
import 'package:on_chain/ada/src/address/address.dart';
import 'utxos.dart';

class CardanoUtxoWithOwner {
  final ADAAddress owner;
  final List<CardanoUtxo>? utxos;
  final IntegerBalance utxoAmounts;
  bool get hasUtxo => utxos != null;
  CardanoUtxoWithOwner._(
      {required this.owner,
      List<CardanoUtxo>? utxos,
      required this.utxoAmounts})
      : utxos = utxos == null ? null : List<CardanoUtxo>.unmodifiable(utxos);
  factory CardanoUtxoWithOwner(
      {required ADAAddress owner,
      List<ADAAccountUTXOs>? utxos,
      required WalletCardanoNetwork network}) {
    final amount = IntegerBalance.token(
        utxos?.sumOflovelace ?? BigInt.zero, network.token);
    return CardanoUtxoWithOwner._(
        owner: owner,
        utxoAmounts: amount,
        utxos:
            utxos?.map((e) => CardanoUtxo(utxo: e, network: network)).toList());
  }
}
