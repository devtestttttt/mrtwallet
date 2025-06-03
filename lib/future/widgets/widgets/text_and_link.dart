import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart' show UriUtils;
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/constant/constant.dart';

class TextAndLinkView extends StatelessWidget {
  const TextAndLinkView(
      {required this.text,
      required this.url,
      super.key,
      this.linkDesc,
      this.style});
  final String text;
  final String url;
  final String? linkDesc;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(style: style ?? context.textTheme.bodyMedium, children: [
      TextSpan(text: text),
      const TextSpan(text: " "),
      TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              UriUtils.lunch(url);
            },
          text: linkDesc ?? "read_more".tr,
          style: context.textTheme.titleSmall?.copyWith(color: ColorConst.blue))
    ]));
  }
}
