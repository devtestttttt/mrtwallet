import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/widgets/widgets/copy_icon_widget.dart';
import 'package:on_chain_wallet/future/widgets/widgets/text_view.dart';

class LargeTextContainer extends StatelessWidget {
  final String text;
  final int maxLines;
  final Color? color;

  const LargeTextContainer(
      {required this.color, required this.text, this.maxLines = 3, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: context.textTheme.bodyMedium);
        final tp = TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start);
        tp.layout(maxWidth: constraints.maxWidth);
        final List<ui.LineMetrics> lines = tp.computeLineMetrics();
        if (lines.length > maxLines) {
          return Row(
            children: [
              Expanded(
                  child: CopyableTextWidget(
                text: text,
                maxLines: maxLines,
                color: color,
              )),
              IconButton(
                  onPressed: () {
                    context.openDialogPage('name',
                        child: (context) => APPTextView(text: text, title: ''));
                  },
                  icon: Icon(
                    Icons.open_in_full_sharp,
                    color: color,
                  ))
            ],
          );
        }
        return CopyableTextWidget(
          text: text,
          maxLines: maxLines,
          color: color,
        );
      },
    );
  }
}
