import 'dart:js_interop';
import 'package:on_chain_bridge/models/events/models/wallet_event.dart';
import 'package:on_chain_bridge/web/web.dart';
import 'package:on_chain_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/messages/models/models/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'js_wallet/constant/constant.dart';
import 'js_wallet/models/models/exception.dart';
import 'js_wallet/wallet/core/wallet.dart';
import 'js_wallet/models/models/requests.dart';

void main() async {
  final applicationId =
      Web3APPAuthentication.toApplicationId(jsWindow.location.origin);
  if (applicationId == null) {
    throw Web3RequestExceptionConst.invalidHost;
  }
  final backgroundEvent = await JSExtentionWallet.sendBackgroudMessage(
      JSWalletConstant.requestAuthEvent,
      allowTargets: [WalletEventTarget.wallet, WalletEventTarget.background]);
  WalletMessageResponse message;
  if (backgroundEvent.type == WalletEventTypes.exception) {
    final exception =
        Web3ExceptionMessage.deserialize(bytes: backgroundEvent.data);
    message = WalletMessageResponse.fail(exception.toWalletError());
  } else {
    message = WalletMessageResponse.success(backgroundEvent.clientId.jsify());
  }
  JSExtentionWallet? wallet;
  if (message.statusType == JSWalletResponseType.success) {
    wallet = JSExtentionWallet.initialize(backgroundEvent);
  }
  jsWindow.dispatchEvent(CustomEvent.create(
      type: JSWalletConstant.activationEventName,
      detail: WalletMessage.response(
          requestId: "0", client: JSClientType.global, data: message),
      clone: true));
  wallet?.initClients();
}
