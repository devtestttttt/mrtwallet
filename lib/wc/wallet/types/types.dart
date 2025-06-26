import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_wallet/app/utils/map/extension.dart';
import 'package:on_chain_wallet/wallet/web3/core/request/params.dart';
import 'package:on_chain_wallet/wc/wallet/core/network.dart';
import 'package:on_chain_wallet/wc/core/types/types.dart';

abstract class WalletConnectAddress {
  final String address;
  final String chain;
  final List<int>? publicKey;
  WalletConnectAddress(
      {required this.address,
      required this.chain,
      required List<int>? publicKey})
      : publicKey = publicKey?.asImmutableBytes;

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "chains": [chain],
      "publicKey": BytesUtils.tryToHexString(publicKey, prefix: "0x"),
    }.withOutNullValue;
  }

  @override
  String toString() {
    return address;
  }
}

class WalletMessageRequest {
  final Web3WalletRequestParams message;
  final String requestId;
  final String topic;
  final String? wcRequestId;
  const WalletMessageRequest(
      {required this.message,
      required this.requestId,
      required this.topic,
      required this.wcRequestId});
}

class WalletEventRequest {
  final List<WalletConnectClientEvent> event;
  final SessionData? session;
  final String topic;
  const WalletEventRequest(
      {required this.event, required this.topic, this.session});
}
// ///WalletConnectClientEvent
// class
