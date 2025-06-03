import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/app/utils/method/utiils.dart';
import 'package:on_chain_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:on_chain_wallet/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models/request_completer.dart';
import 'package:on_chain_wallet/wallet/api/services/models/networks/ethereum.dart';
import 'package:on_chain/on_chain.dart';

class _EthereumWebsocketServiceConst {
  static const String subscriptionMethodName = "eth_subscription";
  static const String params = "params";
  static const String method = "method";
}

class EthereumWebsocketService extends WebSocketService<EthereumAPIProvider>
    implements EthereumServiceProvider {
  EthereumWebsocketService(
      {required super.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});
  final List<ONETHSubsribe> _listeners = [];

  void addSubscriptionListener(ONETHSubsribe listener) {
    _listeners.add(listener);
  }

  void removeSubscriptionListener(ONETHSubsribe listener) {
    _listeners.remove(listener);
  }

  void _emitListeners(EthereumSubscribeResult result) {
    for (final i in [..._listeners]) {
      MethodUtils.nullOnException(() => i(result));
    }
  }

  @override
  Map<String, dynamic>? onMessge(String event) {
    final message = super.onMessge(event);
    if (message != null &&
        message[_EthereumWebsocketServiceConst.method] ==
            _EthereumWebsocketServiceConst.subscriptionMethodName) {
      final result = MethodUtils.nullOnException(() {
        return EthereumSubscribeResult.fromJson(
            message[_EthereumWebsocketServiceConst.params]);
      });
      if (result != null) {
        _emitListeners(result);
      }
    }
    return message;
  }

  final Duration defaultTimeOut;

  @override
  void disposeService() {
    super.disposeService();
    _listeners.clear();
  }

  @override
  Future<EthereumServiceResponse<T>> doRequest<T>(EthereumRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
