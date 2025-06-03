import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/exception/exception.dart';

class Web3StellarExceptionConstant {
  static Web3RequestException get invalidAccountOrTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account or transaction. The parameters must contain both 'account' and 'transaction' as base64(envlope).");
}
