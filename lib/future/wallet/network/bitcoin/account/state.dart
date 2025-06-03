import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/account_state.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

abstract class BitcoinAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        BaseBitcoinAPIProvider,
        BitcoinBaseAddress,
        TokenCore,
        NFTCore,
        IBitcoinAddress,
        BitcoinClient,
        BitcoinChain,
        BitcoinWalletTransaction> {}
