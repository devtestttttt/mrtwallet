import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/r.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

abstract class ChainAccountState<
    W extends StatefulWidget,
    PROVIDER extends APIProvider,
    NETWORKADDRESS,
    T extends TokenCore,
    N extends NFTCore,
    ADDRESS extends ChainAccount<NETWORKADDRESS, T, N, ChainTransaction>,
    CL extends NetworkClient,
    CHAIN extends APPCHAINACCOUNTCLIENT<ADDRESS, CL>,
    TRANSACTION extends ChainTransaction> extends State<W> with SafeState<W> {
  CHAIN get account;
  ADDRESS get address => account.address;
  List<ADDRESS> get addresses => account.addresses;
  List<T> get addressTokens => address.tokens;
  CL? get client => null;
}
