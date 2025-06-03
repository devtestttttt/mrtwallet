import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/account_state.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';
import 'package:on_chain/sui/src/src.dart';

abstract class SuiAccountState<W extends StatefulWidget>
    extends ChainAccountState<W, SuiAPIProvider, SuiAddress, TokenCore, NFTCore,
        ISuiAddress, SuiClient, SuiChain, SuiWalletTransaction> {}
