import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:on_chain_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

class ChangeWalletPasswordView extends StatelessWidget {
  const ChangeWalletPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.seed,
        onAccsess: (crendential, password, network) {
          return _ChangePasswordView(password: password);
        },
        title: "change_password".tr,
        subtitle: PageTitleSubtitle(
            title: "wallet_password_desc".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("enter_wallet_password_to_continue".tr)],
            )));
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView({required this.password});

  final String password;

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView>
    with SafeState<_ChangePasswordView> {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "_ChangePasswordView");
  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  final FocusNode nextFocus = FocusNode();
  String password = "";
  void onChangePassword(String v) {
    password = v;
  }

  String? validator(String? value) {
    if (value == widget.password) {
      return "password_used_before".tr;
    }
    if (StrUtils.isStrongPassword(value)) {
      return null;
    }
    return "weak_password".tr;
  }

  String? confirmForm(String? value) {
    if (value != password) {
      return "p_does_not_match".tr;
    }
    return null;
  }

  Future<void> setupPassword() async {
    if (form.ready()) {
      progressKey.progressText("changing_password".tr);
      final model = context.watch<WalletProvider>(StateConst.main);
      final result =
          await model.wallet.changePassword(widget.password, password);
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
      } else {
        progressKey.successText("password_changed".tr, backToIdle: false);
        await MethodUtils.wait();
        navigatorKey?.currentContext?.popToHome();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => UnfocusableChild(
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: form,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height20,
                        PageTitleSubtitle(
                            title: "wallet_password_desc".tr,
                            body: LargeTextView(
                              [
                                "p_note1".tr,
                                "p_note2".tr,
                                "p_note3".tr,
                                "p_note4".tr,
                                "change_password_desc".tr
                              ],
                            )),
                        AppTextField(
                          obscureText: true,
                          onChanged: onChangePassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.go,
                          disableContextMenu: true,
                          nextFocus: nextFocus,
                          validator: validator,
                          label: "enter_new_password".tr,
                          helperText: "password_desc".tr,
                        ),
                        AppTextField(
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          focusNode: nextFocus,
                          disableContextMenu: true,
                          validator: confirmForm,
                          label: "c_password".tr,
                        ),
                        WidgetConstant.height20,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FixedElevatedButton(
                                padding: WidgetConstant.paddingVertical40,
                                onPressed: setupPassword,
                                child: Text("change_password".tr)),
                          ],
                        )
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
