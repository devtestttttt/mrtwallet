import 'package:on_chain_wallet/future/state_managment/extension/app_extensions/string.dart';

extension QuickBooleanExtension on bool {
  String get tr {
    if (this) return "yes".tr;
    return "no".tr;
  }
}
