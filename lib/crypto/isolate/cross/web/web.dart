library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:blockchain_utils/crypto/crypto/chacha20poly1305/chacha20poly1305.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:on_chain_bridge/web/api/window/window.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/isolate/core/worker.dart';
import 'package:on_chain_wallet/crypto/isolate/controller/message_controller.dart';
import 'package:on_chain_wallet/crypto/isolate/types/types.dart';
import 'package:on_chain_wallet/crypto/requets/argruments/argruments.dart';
import 'package:on_chain_wallet/crypto/requets/completer/completer.dart';
import 'package:on_chain_wallet/crypto/requets/messages/models/models.dart';
import 'package:on_chain_bridge/web/web.dart' as web;
import '../exception.dart';
part 'browser.dart';

IsolateCryptoWoker getCryptoWorker() {
  return BrowserCryptoWorker._();
}
