import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/exception/exception.dart';

class Web3BitcoinExceptionConstant {
  static Web3RequestException get invalidRequestAccounts =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid request accounts: All accounts must belong to the same network.");
  static Web3RequestException get emptyOutput =>
      Web3RequestExceptionConst.invalidParameters(
          "At least one output required for create transaction.");
  static Web3RequestException txInputNotFound(String txId, int index) =>
      Web3RequestExceptionConst.invalidParameters(
          "Transaction input with TXID $txId and index $index not found in the list of unspent inputs.");
  static Web3RequestException get invalidPSBT =>
      Web3RequestExceptionConst.invalidParameters(
          "The PSBT request must include either an 'account' for single-address spending or 'accounts' for multiple-address spending, along with a valid base64-encoded PSBT string containing valid inputs and outputs.");
  static Web3RequestException get noRelatedInput =>
      Web3RequestExceptionConst.message("No related inputs found for signing.");
  static Web3RequestException unsuportedSigningMessageAccount(String address) =>
      Web3RequestExceptionConst.message(
          "The $address address does not support message signing. Only non-multisig accounts are allowed to sign messages.");
  static Web3RequestException parsingOutputScriptFailed(String data) =>
      Web3RequestExceptionConst.invalidParameters(
          "Failed to parse output script. Please ensure it is a valid Bitcoin script serialized as hex.");
  static Web3RequestException get invalidTransferOutput =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transfer output. Either recipientAddress or script required for generate output.");
}
