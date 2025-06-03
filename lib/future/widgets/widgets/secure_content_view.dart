import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/app.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/security/pages/secure_backup.dart';
import 'package:on_chain_wallet/wallet/models/backup/models/wallet.dart';
import 'animated/widgets/animated_switcher.dart';
import 'barcode/widgets/barcode_view.dart';
import 'conditional_widget.dart';
import 'container_with_border.dart';
import 'copy_icon_widget.dart';
import 'widget_constant.dart';

class SecureContentView extends StatefulWidget {
  const SecureContentView(
      {required this.content,
      this.showBarcode = true,
      this.isSensitive = true,
      this.backupType,
      this.showButtonTitle,
      this.contentName,
      this.password,
      super.key});
  final String content;
  final WalletBackupTypes? backupType;
  final String? password;
  final String? showButtonTitle;
  final String? contentName;
  final bool showBarcode;
  final bool isSensitive;

  @override
  State<SecureContentView> createState() => _SecureContentView2State();
}

class _SecureContentView2State extends State<SecureContentView>
    with SafeState<SecureContentView> {
  bool show = false;
  double opacity = 0.05;
  void showContent() {
    show = !show;
    opacity = 1;
    updateState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    if (!widget.isSensitive) {
      opacity = 1;
      show = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ContainerWithBorder(
          onRemove: () {},
          enableTap: false,
          onRemoveWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CopyTextIcon(
                  dataToCopy: widget.content,
                  color: context.onPrimaryContainer,
                  isSensitive: widget.isSensitive),
              ConditionalWidget(
                  enable: widget.backupType != null && widget.password != null,
                  onActive: (context) => IconButton(
                      onPressed: () {
                        context.openSliverDialog(
                            (ctx) => GenerateBackupView(
                                data: widget.content,
                                password: widget.password!,
                                type: widget.backupType!),
                            "backup_mnemonic".tr);
                      },
                      icon: Icon(Icons.backup,
                          color: context.onPrimaryContainer))),
              ConditionalWidget(
                enable: widget.showBarcode,
                onActive: (context) => BarcodeImageIconView(
                    data: widget.content,
                    color: context.onPrimaryContainer,
                    isSensitive: widget.isSensitive),
              )
            ],
          ),
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: opacity,
                duration: APPConst.animationDuraion,
                child: SelectableText(widget.content,
                    style: context.onPrimaryTextTheme.bodyMedium),
              ),
              Positioned.fill(
                child: APPAnimatedSwitcher(enable: show, widgets: {
                  true: (context) => WidgetConstant.sizedBox,
                  false: (context) => FilledButton.icon(
                      onPressed: showContent,
                      icon: const Icon(Icons.remove_red_eye),
                      label: Text(widget.showButtonTitle ?? "show_content".tr))
                }),
              )
            ],
          ),
        ),
      ],
    );
  }
}
