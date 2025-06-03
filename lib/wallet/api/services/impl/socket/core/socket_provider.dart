import 'dart:async';
import 'package:on_chain_wallet/app/error/exception/exception.dart';
import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/services/core/base_service.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models.dart';

abstract class BaseSocketService<T extends APIProvider>
    extends BaseServiceProtocol<T> {
  Future<void> connect();
  bool get isConnected;
  @override
  APPIsolate get isolate => APPIsolate.current;
  Future<Map<String, dynamic>> providerCaller(
      Future<Map<String, dynamic>> Function() t,
      SocketRequestCompleter param) async {
    Map<String, dynamic>? response;
    try {
      response = await _onException(t);
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
      Future<Map<String, dynamic>> Function() t) async {
    try {
      await connect().timeout(const Duration(seconds: 30));
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
