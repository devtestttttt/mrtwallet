class Web3BitcoinConst {
  static const String signTransaction = "bitcoin_signTransaction";
  static const String signPersonalMessage = "bitcoin_signPersonalMessage";
  static const String requestAccounts = "bitcoin_requestAccounts";
  static const String switchNetwork = "wallet_switchBitcoinChain";
  static const String sendTransaction = "bitcoin_sendTransaction";
  static const String sendTransfer = "sendTransfer";
  static const String signMessage = "signMessage";
  static const String signPsbt = "signPsbt";
  static const String getAccountAddresses = "getAccountAddresses";
  static const String bitcoinGetAccountAddresses =
      "bitcoin_getAccountAddresses";
  static const int requestAccountTag = 100;
  static const int signTransactionTag = 101;
  static const int signPersonalMessagTag = 108;
  static const int changeNetworkTag = 107;
  static const int sendTransactionTag = 109;
  static const int signMessageTag = 110;
  static const int getAccountAddressesTag = 111;
}
