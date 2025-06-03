import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class DuplicateExtensionInstanceAlert extends StatelessWidget {
  const DuplicateExtensionInstanceAlert({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("duplicate_wallet_instance_alert".tr),
        WidgetConstant.height20,
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("close".tr))
        ])
      ],
    );
  }
}
