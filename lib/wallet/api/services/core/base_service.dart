import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/services/core/tracker.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models/protocols.dart';

abstract class BaseServiceProtocol<T extends APIProvider> {
  void disposeService();
  ServiceProtocol get protocol;
  APPIsolate get isolate;
}

abstract class NetworkServiceProtocol<T extends APIProvider>
    extends BaseServiceProtocol {
  T get provider;
  abstract final APIServiceTracker tracker;
}
