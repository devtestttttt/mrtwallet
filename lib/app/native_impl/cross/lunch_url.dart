import 'package:on_chain_wallet/app/native_impl/core/core.dart';

mixin LunchUrlImpl {
  static Future<bool> lunchUri(String uri) async {
    return await AppNativeMethods.platform.launchUri(uri);
  }
}
