import 'package:flutter/material.dart';
import 'package:on_chain_bridge/models/models.dart';
import 'package:on_chain_wallet/app/core.dart' show APPConst, ShareUtils;
import 'package:on_chain_wallet/future/widgets/widgets/animated/widgets/animated_switcher.dart';
import 'package:on_chain_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import '../../constraints_box_view.dart';
import '../qr_code/qr_view.dart';
import '../../widget_constant.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

class BarcodeImageView extends StatefulWidget {
  final String data;
  final bool isSensitive;
  final String? title;
  final String? shareTitle;
  const BarcodeImageView(
      {required this.data,
      this.shareTitle,
      this.title,
      this.isSensitive = false,
      super.key});

  @override
  State<BarcodeImageView> createState() => _BarcodeImageViewState();
}

class _BarcodeImageViewState extends State<BarcodeImageView>
    with SafeState<BarcodeImageView> {
  final buttonState = GlobalKey<StreamWidgetState>();

  Future<void> share() async {
    buttonState.process();
    try {
      final toFile = await QrUtils.qrCodeToFile(
        data: widget.data,
        uderImage: '',
        color: context.theme.colorScheme,
      );

      if (!context.mounted) return;
      await ShareUtils.shareFile(toFile!.$1, toFile.$2,
          mimeType: FileMimeTypes.imagePng, text: widget.shareTitle);
      buttonState.success();
    } catch (e) {
      buttonState.error();
    }
  }

  bool show = false;
  double opacity = 0.1;
  void showContent() {
    show = !show;
    opacity = 1;
    updateState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    if (!widget.isSensitive) {
      show = true;
      opacity = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverAppBar(
          title: Text(widget.title ?? ''),
          actions: [
            ButtonProgress(
                child: (context) =>
                    IconButton(onPressed: share, icon: Icon(Icons.share)),
                backToIdle: Duration.zero,
                key: buttonState)
          ],
        ),
        SliverConstraintsBoxView(
          padding: WidgetConstant.padding20,
          sliver: SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: WidgetConstant.border8,
              child: Center(
                child: SizedBox(
                  width: APPConst.qrCodeWidth,
                  child: Stack(
                    children: [
                      AnimatedOpacity(
                        opacity: opacity,
                        duration: APPConst.animationDuraion,
                        child: QrImageView(
                          data: widget.data,
                          backgroundColor: context.colors.onSurface,
                          errorStateBuilder: (context, error) =>
                              WidgetConstant.errorIcon,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: context.theme.colorScheme.surface,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: context.theme.colorScheme.surface,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: APPAnimatedSwitcher(enable: show, widgets: {
                          true: (context) => WidgetConstant.sizedBox,
                          false: (context) => FilledButton.icon(
                              onPressed: showContent,
                              icon: const Icon(Icons.remove_red_eye),
                              label: Text("show_barcode".tr))
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BarcodeImageIconView extends StatelessWidget {
  const BarcodeImageIconView(
      {required this.data,
      this.color,
      super.key,
      this.isSensitive = false,
      this.title,
      this.shareTitle});
  final String data;
  final Color? color;
  final bool isSensitive;
  final String? title;
  final String? shareTitle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        color: color,
        onPressed: () {
          context.openDialogPage(
            '',
            child: (context) => BarcodeImageView(
                data: data,
                isSensitive: isSensitive,
                shareTitle: shareTitle,
                title: title),
            maxWidth: APPConst.qrCodeWidth,
          );
        },
        icon: Icon(Icons.qr_code_2));
  }
}
