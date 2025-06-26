import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/constant/global/app.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/web3/core/core.dart';

///
class Web3ApplicationView extends StatelessWidget {
  const Web3ApplicationView({required this.permission, this.info, super.key});
  final Web3RequestAuthentication permission;
  final Web3RequestInformation? info;

  @override
  Widget build(BuildContext context) {
    return _Web3ClientInfoView(
        permission: permission,
        info: info is Web3RequestApplicationInformation
            ? info as Web3RequestApplicationInformation
            : null);
  }
}

class _Web3ClientInfoView extends StatelessWidget {
  const _Web3ClientInfoView({required this.permission, this.info});
  final Web3RequestAuthentication permission;
  final Web3RequestApplicationInformation? info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("client".tr, style: context.textTheme.titleMedium),
        Text("web3_client_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: Row(
            children: [
              CircleAPPImageView(
                permission.icon,
                radius: APPConst.circleRadius25,
                onError: (c) =>
                    const Icon(Icons.broken_image, size: APPConst.double40),
              ),
              WidgetConstant.width8,
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OneLineTextWidget(permission.name,
                      style: context.onPrimaryTextTheme.labelLarge),
                  Text(permission.url ?? permission.applicationId,
                      style: context.onPrimaryTextTheme.bodySmall),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class Web3ClientInfoView extends StatelessWidget {
  const Web3ClientInfoView({super.key, required this.cleint});
  final Web3ClientInfo cleint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("client".tr, style: context.textTheme.titleMedium),
        Text("web3_client_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: Row(
            children: [
              CircleAPPImageView(
                cleint.image,
                radius: APPConst.circleRadius25,
                onError: (c) =>
                    const Icon(Icons.broken_image, size: APPConst.double40),
              ),
              WidgetConstant.width8,
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OneLineTextWidget(cleint.name,
                      style: context.onPrimaryTextTheme.labelLarge),
                  OneLineTextWidget(cleint.view,
                      style: context.onPrimaryTextTheme.bodySmall),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
}

typedef ONWEB3CLIENTTAP = void Function(Web3ClientInfo? client);

class Web3ClientInfoIconView extends StatelessWidget {
  const Web3ClientInfoIconView(
      {super.key, required this.client, required this.onTap});
  final Web3ClientInfo? client;
  final ONWEB3CLIENTTAP onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onTap(client),
      icon: ConditionalWidget(
          onActive: (context) => ConditionalWidget(
                enable: client?.image != null,
                onActive: (context) => CircleAPPImageView(
                  client?.image,
                  radius: APPConst.circleRadius12,
                  onError: (context) => Icon(Icons.security),
                  onProgress: (context) => APPCircularProgressIndicator(),
                ),
                onDeactive: (context) => Icon(Icons.security),
              ),
          enable: client != null,
          onDeactive: (context) => Icon(Icons.security)),
    );
  }
}
