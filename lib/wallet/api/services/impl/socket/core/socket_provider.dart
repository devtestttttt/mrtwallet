import 'dart:async';
import 'package:on_chain_wallet/app/error/exception/exception.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/services/core/base_service.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models.dart';

abstract class BaseSocketService<T extends APIProvider>
    extends NetworkServiceProtocol<T> {
  Future<void> connect(Duration timeout);
  bool get isConnected;
  @override
  APPIsolate get isolate => APPIsolate.current;
  Future<Map<String, dynamic>> providerCaller(
      {required Future<Map<String, dynamic>> Function() t,
      required SocketRequestCompleter param,
      required Duration timeout}) async {
    Map<String, dynamic>? response;
    try {
      response = await _onException(t: t, timeout: timeout);
      return response;
    } on ApiProviderException catch (e) {
      tracker.addRequest(ApiRequest(
          error: e, identifier: provider.identifier, uri: provider.callUrl));
      rethrow;
    } finally {
      if (response != null) {
        tracker.addRequest(
            ApiRequest(identifier: provider.identifier, uri: provider.callUrl));
      }
    }
  }

  Future<Map<String, dynamic>> _onException(
      {required Future<Map<String, dynamic>> Function() t,
      required Duration timeout}) async {
    try {
      await connect(timeout);
      if (!isConnected) {
        throw ApiProviderException.error("node_connection_error");
      }
      final response = await t();
      return response;
    } catch (e) {
      throw ApiProviderException.fromException(message: e);
    }
  }
}
