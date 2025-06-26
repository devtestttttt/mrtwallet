class WalletProviderConst {
  static const int version = 1;
  static const int encryptionKeyLength = 32;
  static const int encryptionNonceLength = 12;
}

class CborTagsConst {
  static const List<int> wallet = [60];
  static const List<int> wallets = [60, 1];
  static const List<int> walletInfo = [60, 2];

  /// chain handler
  static const List<int> chainHandler = [60, 3];

  static const List<int> coingeckoInfo = [60, 12];
  static const List<int> coingeckoCoins = [60, 13];

  static const List<int> setting = [160];
  static const List<int> backup = [170];
  static const List<int> backupV2 = [170, 2];
  static const List<int> backupV3 = [170, 3];

  static const int walletBackupVersion = 1;
  static const List<int> walletBackupWallet = [walletBackupVersion, 170, 2];
  static const List<int> walletBackupMnemonic = [walletBackupVersion, 170, 3];
  static const List<int> walletBackupPrivateKey = [walletBackupVersion, 170, 4];
  static const List<int> walletBackupExtendedKey = [
    walletBackupVersion,
    170,
    5
  ];
  static const List<int> walletBackupWif = [walletBackupVersion, 170, 6];
  static const List<int> walletBackupChainStorageIds = [
    walletBackupVersion,
    170,
    7
  ];
  static const List<int> walletBackupChains = [walletBackupVersion, 170, 8];
  static const List<int> walletBackupWalletV2 = [walletBackupVersion, 170, 9];
  static const List<int> walletBackupWalletV3 = [walletBackupVersion, 170, 10];
  static const List<int> walletBackupStorageIds = [
    walletBackupVersion,
    170,
    11
  ];

  static const List<int> mnemonic = [180];
  static const List<int> walletCustomKey = [180, 0];
  static const List<int> derivedKeys = [180, 1];
  static const List<int> iAccount = [200];
  static const List<int> address = [200, 80];
  static const List<int> accoutKeyIndex = [200, 81];
  static const List<int> multiSigAccountKeyIndex = [200, 83];

  static const List<int> bitcoinCashAccount = [200, 191];
  static const List<int> bitcoinCashMultiSigAccount = [200, 191, 1];
  static const List<int> bitcoinAccount = [200, 192];
  static const List<int> bitcoinMultiSigAccount = [200, 192, 1];
  static const List<int> bitcoinMultiSignaturAddress = [200, 192, 1, 0];
  static const List<int> bitcoinMultiSigSignerAddress = [200, 192, 1, 0, 0];

  static const List<int> bitcoinWalletTransactionAmount = [200, 191, 25];
  static const List<int> bitcoinWalletTransactionInput = [200, 191, 26];
  static const List<int> bitcoinWalletTransactionScriptOutput = [200, 191, 27];

  // xrp
  static const List<int> rippleAccount = [200, 193];
  static const List<int> rippleMultisigAccount = [200, 193, 1];
  static const List<int> rippleMultiSignaturAddress = [200, 193, 1, 0];
  static const List<int> rippleMultiSigSignerAddress = [200, 193, 1, 0, 0];
  // ethereum
  static const List<int> ethAccount = [200, 194];
// tron
  static const List<int> tronAccount = [200, 195];
  static const List<int> tronMultisigAccount = [200, 195, 1];
  static const List<int> tronMultiSignaturAddress = [200, 195, 1, 0];
  static const List<int> tronMultiSigSignerAddress = [200, 195, 1, 0, 0];
  static const List<int> tronAccountInfo = [200, 195, 100];
  static const List<int> tronAccountResource = [200, 195, 101];

  // solana address
  static const List<int> solAccount = [200, 196];

  // cardano address
  static const List<int> cardanoAccount = [200, 197];

  static const List<int> cardanoAccountDetails = [200, 197, 100];

  // cosmos address
  static const List<int> cosmosAccount = [200, 198];
  static const List<int> cosmosIbcChannelId = [198, 0];
  static const List<int> cosmosAccountChannelId = [200, 198, 0];

  ///
  static const List<int> tonAccount = [200, 199];
  static const List<int> tonAddressLegacy = [200, 199, 0];
  static const List<int> tonAddressSubWallet = [200, 199, 1];
  static const List<int> tonAddressV5 = [200, 199, 2];
  static const List<int> tonAddressV5SubWallet = [200, 199, 3];

  /// substrate
  static const List<int> substrateAccount = [200, 200];

  // stellar
  static const List<int> stellarAccount = [200, 201];
  static const List<int> stellarMultisigAccount = [200, 201, 1];
  static const List<int> stellarMultiSignaturAddress = [200, 201, 1, 0];
  static const List<int> stellarMultiSigSignerAddress = [200, 201, 1, 0, 0];

  // monero
  static const List<int> moneroAccount = [200, 202];
  static const List<int> moneroUtxo = [200, 202, 1];
  static const List<int> moneroChainTrackerInfo = [200, 202, 2];

  static const List<int> moneroUtxoRequestTxId = [200, 202, 3];
  static const List<int> moneroUtxoRequestBlock = [200, 202, 4];
  static const List<int> moneroUtxoRequestTransaction = [200, 202, 5];
  static const List<int> moneroUtxoPaymentInfo = [200, 202, 6];
  static const List<int> moneroUtxoDetails = [200, 202, 7];
  static const List<int> moneroUtxoRequestTxInfo = [200, 202, 8];
  static const List<int> moneroTxDestinationWithProof = [200, 202, 9];
  static const List<int> moneroSignedTxData = [200, 202, 10];
  static const List<int> moneroSigningTxResponse = [200, 202, 11];
  static const List<int> monerogenerateRingOutput = [200, 202, 12];

  static const List<int> moneroDefaultChainTracker = [200, 202, 13];
  static const List<int> moneroChainTrackingResponse = [200, 202, 14];
  static const List<int> moneroChainTrackedOffsets = [200, 202, 15];
  static const List<int> moneroSyncRequestChainTracker = [200, 202, 16];
  static const List<int> moneroViewPrimaryAccountDetails = [200, 202, 17];
  static const List<int> moneroSyncAccountResponse = [200, 202, 18];
  static const List<int> moneroThreadChainTrackedOffsets = [200, 202, 19];
  static const List<int> moneroProcessTxIdRequest = [200, 202, 20];
  static const List<int> moneroProcessTxesResponse = [200, 202, 21];
  static const List<int> moneroBatchProcessTxesResponse = [200, 202, 22];
  static const List<int> moneroAccountPendingTxes = [200, 202, 23];
  static const List<int> moneroSyncAccountInfo = [200, 202, 24];
  static const List<int> moneroWalletTransactionAmount = [200, 202, 25];
  static const List<int> moneroWalletTransactionInput = [200, 202, 26];
  static const List<int> moneroWalletTransactionOutput = [200, 202, 27];
  static const List<int> moneroBlockInfoResponse = [200, 202, 30];
  static const List<int> moneroSyncAccountIndexInfo = [200, 202, 31];
  static const List<int> moneroSyncBlocksInfoRequest = [200, 202, 32];
  static const List<int> moneroSyncTrackBlocksRequest = [200, 202, 33];
  static const List<int> moneroSyncTrackersRequests = [200, 202, 34];
  static const List<int> moneroAddressUtxos = [200, 202, 35];
  static const List<int> moneroSyncChain = [200, 202, 36];
  static const List<int> moneroSyncAccountRequestInfo = [200, 202, 37];
  static const List<int> moneroChainFailedOffsets = [200, 202, 38];
  static const List<int> moneroRequestBlockTrackingInfo = [200, 202, 39];

  static const List<int> aptosAccount = [200, 203];
  static const List<int> aptosMultisigAccount = [200, 203, 0];
  static const List<int> aptosMultisigAccountInfo = [200, 203, 1];
  static const List<int> aptosMultisigAccountPublicKey = [200, 203, 2];

  static const List<int> suiAccount = [200, 204];
  static const List<int> suiMultisigAccount = [200, 204, 0];
  static const List<int> suiMultisigAccountInfo = [200, 204, 1];
  static const List<int> suiMultisigAccountPublicKey = [200, 204, 2];

  // contacts
  static const List<int> bitcoinContact = [100, 0];
  static const List<int> rippleContact = [100, 1];
  static const List<int> ethereumContact = [100, 2];
  static const List<int> tronContact = [100, 3];
  static const List<int> solanaContact = [100, 4];
  static const List<int> cardanoContct = [100, 5];
  static const List<int> cosmosContact = [100, 6];
  static const List<int> tonContact = [100, 7];
  static const List<int> substrateContact = [100, 8];
  static const List<int> stellarContact = [100, 9];
  static const List<int> moneroContact = [100, 10];
  static const List<int> aptosContact = [100, 11];
  static const List<int> suiContact = [100, 12];

  /// network tokens
  static const List<int> token = [110];
  static const List<int> decimalToken = [110, 0];
  static const List<int> cosmosNativeToken = [110, 1];
  static const List<int> rippleIssueToken = [110, 10];
  static const List<int> erc20Token = [110, 20];
  static const List<int> trc20Token = [110, 30];
  static const List<int> trc10Token = [110, 31];
  static const List<int> spltoken = [110, 32];
  static const List<int> jettonToken = [110, 33];
  static const List<int> stellarIssueToken = [110, 34];
  static const List<int> cw20 = [110, 35];
  static const List<int> fats = [110, 36];
  static const List<int> suiToken = [110, 37];

  /// network nfts
  static const List<int> nft = [120];
  static const List<int> rippleNfts = [120, 10];

  static const List<int> networks = [0, 0, 0];
  static const List<int> network = [80];

  static const List<int> bitconNetwork = [80, 0, 1];
  static const List<int> xrpNetwork = [80, 0, 2];
  static const List<int> evmNetwork = [80, 0, 3];
  static const List<int> tvmNetwork = [80, 0, 4];
  static const List<int> solanaNetwork = [80, 0, 5];
  static const List<int> cardanoNetwork = [80, 0, 6];
  static const List<int> cosmosNetwork = [80, 0, 7];
  static const List<int> bitcoinCashNetwork = [80, 0, 10];
  static const List<int> tonNetwork = [80, 0, 11];
  static const List<int> substrateNetwork = [80, 0, 12];
  static const List<int> stellarNetwork = [80, 0, 14];
  static const List<int> moneroNetwork = [80, 0, 15];
  static const List<int> aptosNetwork = [80, 0, 16];
  static const List<int> suiNetwork = [80, 0, 17];

  static const List<int> bitconNetworkParam = [80, 1, 1];
  static const List<int> xrpNetworkParam = [80, 1, 2];
  static const List<int> evmNetworkParam = [80, 1, 3];
  static const List<int> tvmNetworkParam = [80, 1, 4];
  static const List<int> cardanoNetworkParams = [80, 1, 5];
  static const List<int> cosmosNetworkParams = [80, 1, 6];
  static const List<int> solNetworkParam = [80, 1, 7];
  static const List<int> tonNetworkParam = [80, 1, 8];
  static const List<int> substrateNetworkParams = [80, 1, 9];
  static const List<int> stellarNetworkParam = [80, 1, 10];
  static const List<int> moneroNetworkParams = [80, 1, 11];
  static const List<int> aptosNetworkParams = [80, 1, 12];
  static const List<int> suiNetworkParams = [80, 1, 13];

  ///

  static const List<int> electrumApiServiceProvider = [90, 0];
  static const List<int> apiServiceAuthSettings = [90, 1];
  static const List<int> bitcoinExplorerApiProvider = [90, 2];
  static const List<int> evmApiServiceProvider = [90, 3];
  static const List<int> tronApiServiceProvider = [90, 4];
  static const List<int> solApiServiceProvider = [90, 5];
  static const List<int> cardanoApiServiceProvider = [90, 6];
  static const List<int> cosmosApiServiceProvider = [90, 7];
  static const List<int> tonApiServiceProvider = [90, 8];
  static const List<int> rippleApiServiceProvider = [90, 9];
  static const List<int> substrateApiServiceProvider = [90, 10];
  static const List<int> stellarApiProvider = [90, 11];
  static const List<int> moneroApiServiceProvider = [90, 12];
  static const List<int> aptosApiServiceProvider = [90, 13];
  static const List<int> suiApiServiceProvider = [90, 14];
  static const List<int> customApiProvider = [90, 100];

  /// web3 permission
  static const List<int> appPermission = [150, 1];
  static const List<int> ethereumAppPermisionSetting = [150, 1];

  static const List<int> permisionTag = [151, 0];
  static const List<int> permissionActivityTag = [151, 1];

  ///
  static const List<int> web3App = [161, 0, 0];
  static const List<int> web3ChainIdentifier = [161, 0, 1];
  static const List<int> web3EthereumChainIdentifier = [161, 0, 2];
  static const List<int> web3TronChainIdentifier = [161, 0, 4];
  static const List<int> web3AptosChainIdentifier = [161, 0, 5];
  static const List<int> web3AppAuthKey = [162, 0, 0];
  static const List<int> web3SubstrateChainIdentifier = [161, 0, 3];
  static const List<int> web3CosmosChainIdentifier = [161, 0, 6];
  static const List<int> web3BitcoinChainIdentifier = [161, 0, 7];
  static const List<int> web3EthereumAccount = [161, 1, 1];
  static const List<int> web3EthereumTransactionAccessList = [161, 1, 1, 0];

  // static const List<int> web3EthereumExistsChains = [161, 1, 1, 1];
  static const List<int> web3TronAccount = [161, 2, 1];
  static const List<int> web3SolanaAccount = [161, 2, 2];
  static const List<int> web3SolanaSignInParams = [161, 2, 2, 0];
  static const List<int> web3SolanaSignMessageParams = [161, 2, 2, 1];
  static const List<int> web3TonAccount = [161, 2, 3];
  static const List<int> web3StellarAccount = [161, 2, 4];
  static const List<int> web3SubstrateAccount = [161, 2, 5];

  static const List<int> web3AptosAccount = [161, 2, 6];
  static const List<int> web3SuiAccount = [161, 2, 7];
  static const List<int> web3CosmosAccount = [161, 2, 8];
  static const List<int> web3BitcoinAccount = [161, 2, 9];
  static const List<int> web3BitcoinSendTransactionParams = [161, 2, 9, 0];

  /// address params
  static const List<int> bitcoinCashNewAddressParams = [12, 0];
  static const List<int> bitcoinCashMultiSigNewAddressParams = [12, 1];
  static const List<int> bitcoinNewAddressParams = [12, 2];
  static const List<int> bitcoinMultiSigNewAddressParams = [12, 4];
  static const List<int> cardanoNewAddressParams = [12, 5];
  static const List<int> cosmosNewAddressParams = [12, 6];
  static const List<int> ethereumNewAddressParamss = [12, 7];
  static const List<int> solanaNewAddressParams = [12, 8];
  static const List<int> substrateNewAddressParams = [12, 9];
  static const List<int> tronNewAddressParams = [12, 10];
  static const List<int> tronMultisigNewAddressParams = [12, 11];
  static const List<int> tonNewAddressParams = [12, 12];
  static const List<int> rippleNewAddressParams = [12, 13];
  static const List<int> rippleMultiSigNewAddressParams = [12, 14];
  static const List<int> stellarNewAddressParams = [12, 15];
  static const List<int> moneroNewAddressParams = [12, 17];
  static const List<int> aptosNewAddressParams = [12, 18];
  static const List<int> aptosMultisigNewAddressParams = [12, 18, 1];
  static const List<int> suiNewAddressParams = [12, 19];
  static const List<int> suiMultisigNewAddressParams = [12, 19, 1];

  static const List<int> defaultChainConfig = [201, 0];
  static const List<int> moneroChainConfig = [201, 1];
  static const List<int> cosmosChainConfig = [201, 2];
  static const List<int> bitcoinChainConfig = [201, 3];
  static const List<int> aptosChainConfig = [201, 4];
  static const List<int> cardanoChainConfig = [201, 5];
  static const List<int> ethChainConfig = [201, 6];
  static const List<int> suiChainConfig = [201, 7];
  static const List<int> solanaChainConfig = [201, 8];
  static const List<int> stellarChainConfig = [201, 9];
  static const List<int> tonChainConfig = [201, 10];
  static const List<int> xrpChainConfig = [201, 11];
  static const List<int> tronChainConfig = [201, 12];
  static const List<int> substrateChainConfig = [201, 13];
  //// transactions
  static const List<int> transactionOutputTransfer = [0, 0];
  static const List<int> transactionOutputOperation = [0, 1];
  static const List<int> transactionOutputContract = [0, 2];
  static const List<int> transactionInput = [1, 0];
  static const List<int> transactionInputUtxos = [1, 1];
  static const List<int> transactionWeb3Client = [2, 0];
  static const List<int> transactionIntegerAmount = [3, 0];
  static const List<int> transactionDecimalsAmount = [4, 0];

  static const List<int> swapSetting = [10, 0];

  static const List<int> defaultTag = [21, 31, 41];

  /// wc
  static const List<int> wcSessionData = [77, 0];
  static const List<int> wcRedirect = [77, 1];
  static const List<int> wcMetadata = [77, 2];
  static const List<int> wcRelay = [77, 3];
  static const List<int> wcNamespace = [77, 4];
  static const List<int> wcChainNamespace = [77, 5];
  static const List<int> wcSessionNamespace = [77, 6];
  static const List<int> wcPendigMessage = [77, 7];
}
