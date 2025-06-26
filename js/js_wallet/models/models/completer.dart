import 'dart:async';
import 'package:blockchain_utils/uuid/uuid.dart';
import 'requests.dart';

class PageRequestCompleter {
  final String id;
  PageRequestCompleter._(this.id);
  factory PageRequestCompleter.nextRequest() {
    return PageRequestCompleter._(UUID.generateUUIDv4());
  }
  final Completer<WalletMessageResponse> _completer = Completer();

  Future<WalletMessageResponse> get wait => _completer.future;
  void completeMessage(WalletMessageResponse response) {
    _completer.complete(response);
  }
}
