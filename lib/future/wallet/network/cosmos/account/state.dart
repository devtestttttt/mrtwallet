import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/wallet/wallet.dart';

abstract class CosmosAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        CosmosAPIProvider,
        CosmosBaseAddress,
        CW20Token,
        NFTCore,
        ICosmosAddress,
        CosmosClient,
        CosmosChain,
        CosmosWalletTransaction> {}
