import 'package:on_chain_wallet/app/isolate/types.dart';
import 'package:on_chain_wallet/wallet/api/provider/core/provider.dart';
import 'package:on_chain_wallet/wallet/api/services/core/tracker.dart';
import 'package:on_chain_wallet/wallet/api/services/models/models/protocols.dart';

abstract class BaseServiceProtocol<T extends APIProvider> {
  T get provider;
  abstract final APIServiceTracker tracker;
  void disposeService();
  ServiceProtocol get protocol;
  APPIsolate get isolate;
}
