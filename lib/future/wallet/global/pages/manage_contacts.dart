import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';
import 'package:on_chain_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:on_chain_wallet/future/wallet/global/pages/add_to_contact_list.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/wallet/api/api.dart';
import 'package:on_chain_wallet/wallet/models/models.dart';

import 'chain_stream.dart';

class ManageAccountContactsView extends StatelessWidget {
  const ManageAccountContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<NetworkClient?, ChainAccount?, Chain>(
        childBulder: (wallet, account, client, address, onAccountChanged) {
          return _ManageAccountContacts(account);
        },
        addressRequired: false,
        clientRequired: false);
  }
}

class _ManageAccountContacts extends StatefulWidget {
  const _ManageAccountContacts(this.account);
  final Chain account;

  @override
  State<_ManageAccountContacts> createState() => __ManageAccountContactsState();
}

class __ManageAccountContactsState extends State<_ManageAccountContacts> {
  List<ContactCore> get contacts => widget.account.contacts;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text("contacts".tr),
          actions: [
            IconButton(
                onPressed: () {
                  context.openMaxExtendSliverBottomSheet(
                    "new_contact".tr,
                    child: AddToContactListView(
                        contact: null,
                        chain: widget.account,
                        callBack: (p0) {}),
                  );
                },
                icon: Icon(Icons.add_box))
          ],
        ),
        SliverConstraintsBoxView(
            sliver: ChainStreamBuilder(
                allowNotify: [ChainNotify.contacts],
                builder: (context, chain, lastNotify) {
                  return EmptyItemSliverWidgetView(
                    isEmpty: contacts.isEmpty,
                    itemBuilder: (context) {
                      return SliverList.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ContainerWithBorder(
                            onRemove: () {},
                            enableTap: false,
                            onRemoveIcon: IconButton(
                                onPressed: () {
                                  context.openSliverDialog(
                                      (ctx) => DialogTextView(
                                          buttonWidget:
                                              AsyncDialogDoubleButtonView(
                                                  firstButtonPressed: () =>
                                                      chain.removeContact(
                                                          contact)),
                                          text:
                                              "remove_contact_from_account".tr),
                                      'remove_contact'.tr);
                                },
                                icon: Icon(Icons.delete,
                                    color: context.onPrimaryContainer)),
                            child: CopyableTextWidget(
                              text: contact.address,
                              color: context.onPrimaryContainer,
                              widget: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(contact.name,
                                              style: context.onPrimaryTextTheme
                                                  .labelSmall),
                                        ),
                                        Text(contact.created.toDateAndTime())
                                      ],
                                    ),
                                    OneLineTextWidget(contact.address,
                                        style: context
                                            .onPrimaryTextTheme.bodyMedium),
                                  ]),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icons.contacts,
                  );
                },
                account: widget.account))
      ],
    );
  }
}
