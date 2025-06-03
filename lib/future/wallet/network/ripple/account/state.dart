import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class RippleAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        RippleAPIProvider,
        XRPAddress,
        RippleIssueToken,
        RippleNFToken,
        IXRPAddress,
        RippleClient,
        RippleChain,
        XRPWalletTransaction> {}
