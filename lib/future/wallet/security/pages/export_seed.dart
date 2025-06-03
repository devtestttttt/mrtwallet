import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/tools/secure_state/secure_state.dart';
import 'package:on_chain_wallet/future/wallet/security/security.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/crypto/keys/keys.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class ExportSeedView extends StatelessWidget {
  const ExportSeedView({super.key});
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.seed,
        onAccsess: (crendential, password, network) {
          return _ExportSeedView(
              mnemonic: crendential.first as AccessMnemonicResponse,
              password: password);
        },
        title: "export_mnemonic".tr,
        subtitle: PageTitleSubtitle(
            title: "export_mnemonic_desc".tr,
            body: Text("export_mnemonic_desc2".tr)));
  }
}

class _ExportSeedView extends StatefulWidget {
  const _ExportSeedView({required this.mnemonic, required this.password});
  final AccessMnemonicResponse mnemonic;
  final String password;

  @override
  State<_ExportSeedView> createState() => _ExportSeedViewState();
}

class _ExportSeedViewState extends State<_ExportSeedView>
    with SafeState<_ExportSeedView>, SecureState<_ExportSeedView> {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "ExportSeedView");
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  late final String _mnemonic = widget.mnemonic.mnemonic.toStr();
  late final List<String> mnemonicList = widget.mnemonic.mnemonic.toList();

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => Center(
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    WidgetConstant.height20,
                    PageTitleSubtitle(
                        title: "export_mnemonic_desc".tr,
                        body: LargeTextView([
                          "export_mnemonic_desc2".tr,
                          "mnemonic_security_des1".tr,
                          "mnemonic_security_des2".tr,
                          "mnemonic_security_des3".tr
                        ])),
                    SecureContentView(
                        content: _mnemonic,
                        password: widget.password,
                        backupType: WalletBackupTypes.mnemonic),
                    WidgetConstant.height20,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
