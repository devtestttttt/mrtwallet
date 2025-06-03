import 'package:on_chain_wallet/wallet/wallet.dart';

typedef APPCHAINNETWORK<NETWORKADDRESS> = Chain<
    APIProvider,
    NetworkCoinParams,
    NETWORKADDRESS,
    TokenCore,
    NFTCore,
    ChainAccount<NETWORKADDRESS, TokenCore, NFTCore, ChainTransaction>,
    WalletNetwork,
    NetworkClient,
    ChainStorageKey,
    ChainConfig,
    ChainTransaction,
    ContactCore,
    NewAccountParams>;

typedef APPCHAINACCOUNT<CHAINACCOUNT extends ChainAccount> = Chain<
    APIProvider,
    NetworkCoinParams,
    dynamic,
    TokenCore,
    NFTCore,
    CHAINACCOUNT,
    WalletNetwork,
    NetworkClient,
    ChainStorageKey,
    ChainConfig,
    ChainTransaction,
    ContactCore,
    NewAccountParams>;

typedef APPCHAINCLIENT<CL extends NetworkClient> = Chain<
    APIProvider,
    NetworkCoinParams,
    dynamic,
    TokenCore,
    NFTCore,
    ChainAccount,
    WalletNetwork,
    CL,
    ChainStorageKey,
    ChainConfig,
    ChainTransaction,
    ContactCore,
    NewAccountParams>;

typedef APPCHAINACCOUNTCLIENT<CHAINACCOUNT extends ChainAccount,
        CL extends NetworkClient>
    = Chain<
        APIProvider,
        NetworkCoinParams,
        dynamic,
        TokenCore,
        NFTCore,
        CHAINACCOUNT,
        WalletNetwork,
        CL,
        ChainStorageKey,
        ChainConfig,
        ChainTransaction,
        ContactCore,
        NewAccountParams>;

typedef APPCHAINACCOUNTCLIENTNETWORK<CHAINACCOUNT extends ChainAccount,
        CL extends NetworkClient, NETWORK extends WalletNetwork>
    = Chain<
        APIProvider,
        NetworkCoinParams,
        dynamic,
        TokenCore,
        NFTCore,
        CHAINACCOUNT,
        NETWORK,
        CL,
        ChainStorageKey,
        ChainConfig,
        ChainTransaction,
        ContactCore,
        NewAccountParams>;
