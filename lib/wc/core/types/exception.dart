import 'package:on_chain_wallet/app/core.dart';

class WalletConnectException extends AppException {
  const WalletConnectException(super.message);
}

class WalletConnectExceptionConst {
  static const WalletConnectException invalidPairUrl =
      WalletConnectException("invalid_pairing_url");
  static const WalletConnectException unsuportedPairingUrl =
      WalletConnectException("unsuported_pairing_url");
  static const WalletConnectException unsuportedMethod =
      WalletConnectException("unsuported_wc_method");

  static const WalletConnectException pairingCanceledByDapp =
      WalletConnectException("pairing_canceled_by_dapp");
  static const WalletConnectException requiredNamespacesNotSupported =
      WalletConnectException("unsuported_required_namespace");
  static const WalletConnectException internalError =
      WalletConnectException("wc_internal_error");
  static const WalletConnectException publishMessageExpired =
      WalletConnectException("wc_publis_message_timeout");
  static const WalletConnectException sessionRequestExpired =
      WalletConnectException("wc_client_request_timed_out");
  static const WalletConnectException pairingRequestTimedout =
      WalletConnectException("pairing_request_timed_out");
  static const WalletConnectException connectionTerminated =
      WalletConnectException("connection_terminated");
}
