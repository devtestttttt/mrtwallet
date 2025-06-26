import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/exception/exception.dart';

class Web3TonExceptionConstant {
  static Web3RequestException get invalidMessageLength =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction messages. one to four message entries are required.");
}
