import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/utils/address/utils.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/types.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

typedef ONADDCONTACT<NETWORKADDRESS> = void Function(
    ContactCore<NETWORKADDRESS>);

class AddToContactListView<NETWORKADDRESS> extends StatefulWidget {
  const AddToContactListView(
      {super.key,
      required this.contact,
      required this.chain,
      required this.callBack});
  final ContactCore<NETWORKADDRESS>? contact;
  final APPCHAINNETWORK<NETWORKADDRESS> chain;
  final ONADDCONTACT callBack;

  @override
  State<AddToContactListView<NETWORKADDRESS>> createState() =>
      _AddToContactListViewState<NETWORKADDRESS>();
}

class _AddToContactListViewState<NETWORKADDRESS>
    extends State<AddToContactListView<NETWORKADDRESS>>
    with SafeState<AddToContactListView<NETWORKADDRESS>> {
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "SelectAddress_1");
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  final GlobalKey<AppTextFieldState> addressFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  ContactCore<NETWORKADDRESS>? contact;
  final GlobalKey<PageProgressState> buttonProgressKey =
      GlobalKey<PageProgressState>();
  String address = '';
  late String name = widget.contact?.name ?? "";
  void clearError() {
    if (err != null) {
      err = null;
      updateState();
    }
  }

  void onChange(String v) {
    name = v;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  bool lockAddressField = false;

  void onChangeAddress(String v) {
    address = v;
  }

  String? onAddressValidator(String? v) {
    final address = _validate(v);
    if (address == null) {
      return "invalid_network_address"
          .tr
          .replaceOne(widget.chain.network.networkName);
    }
    return null;
  }

  String? validator(String? v) {
    if (v == null || v.length < 3) {
      return "contact_name_validator".tr;
    }
    return null;
  }

  String? err;

  ContactCore<NETWORKADDRESS>? getCurrentContact() {
    if (!(formKey.currentState?.validate() ?? false)) return null;
    if (this.contact != null) return contact;
    return _validate(address);
  }

  Future<void> onTapAdd() async {
    clearError();
    final contact = getCurrentContact();
    if (contact == null) return;

    buttonProgressKey.progress();
    final ContactCore<NETWORKADDRESS> newContact = ContactCore.newContact(
        network: widget.chain.network,
        address: contact.addressObject,
        name: name);
    final result = await MethodUtils.call(
        () async => await widget.chain.addNewContact(newContact),
        delay: APPConst.animationDuraion);
    if (result.hasError) {
      buttonProgressKey.backToIdle();
      err = result.error?.tr;
      updateState();
    } else {
      buttonProgressKey.successText("contact_saved".tr, backToIdle: false);
      updateState();
      widget.callBack(newContact);
    }
  }

  ContactCore<NETWORKADDRESS>? _validate(String? address) {
    try {
      final addr = BlockchainAddressUtils.validateNetworkAddress(
          address, widget.chain.network);
      if (addr == null) return null;
      return ContactCore.newContact(
          address: addr, network: widget.chain.network, name: name);
    } catch (_) {
      return null;
    }
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    contact = widget.contact;
    if (contact != null) {
      lockAddressField = true;
      address = contact?.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: PageProgress(
        backToIdle: APPConst.oneSecoundDuration,
        key: buttonProgressKey,
        child: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleSubtitle(
                title: "add_to_contacts".tr,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("contact_desc_1"
                        .tr
                        .replaceOne(widget.chain.network.token.name)),
                    Text("add_new_contact_desc".tr),
                  ],
                )),
            AppTextField(
                readOnly: lockAddressField,
                initialValue: address,
                label: "address".tr,
                pasteIcon: true,
                validator: onAddressValidator,
                onChanged: onChangeAddress),
            WidgetConstant.height20,
            AppTextField(
              key: textFieldKey,
              label: "name_of_contact".tr,
              initialValue: name,
              readOnly: buttonProgressKey.inProgress,
              minlines: 1,
              maxLines: 2,
              pasteIcon: true,
              validator: validator,
              onChanged: onChange,
            ),
            ErrorTextContainer(error: err, enableTap: false),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: onTapAdd,
                  child: Text("add_to_contacts".tr),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
