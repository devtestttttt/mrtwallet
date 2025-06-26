import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/crypto/requets/messages.dart';
import 'package:on_chain_wallet/future/future.dart';
import 'package:on_chain_wallet/wallet/models/chain/chain/chain.dart';
import 'package:on_chain_wallet/wallet/models/networks/bch/models/cash_token_bcmr.dart';
import 'package:on_chain_wallet/crypto/utils/bitcoin_cash/bitcoin_cash_utils.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';

enum _MetadataUriTypes {
  ipfs("ipfs"),
  https("https");

  final String value;
  const _MetadataUriTypes(this.value);
}

class BCMRUriValidateView extends StatefulWidget {
  final BitcoinChain account;
  const BCMRUriValidateView({required this.account, super.key});

  @override
  State<BCMRUriValidateView> createState() => __MetadataContentState();
}

class __MetadataContentState extends State<BCMRUriValidateView> with SafeState {
  final GlobalKey<FormState> form = GlobalKey();
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriKey = GlobalKey();
  _MetadataUriTypes metadataUri = _MetadataUriTypes.https;
  bool get isIpfs => metadataUri == _MetadataUriTypes.ipfs;
  String? onChainUri;
  String _uri = "";
  void onChangeUri(String v) {
    _uri = v;
  }

  void onSelectMetaDataUri(_MetadataUriTypes? uriMethod) {
    metadataUri = uriMethod ?? metadataUri;
    onPasteUri("");
    updateState(() {});
  }

  String? _validateIpfs(String? v) {
    final cid = StrUtils.validateIpfsCIDV1(v);
    if (cid == null) {
      return "invalid_ipfs_v1_cid".tr;
    }
    return null;
  }

  String? _validateHttps(String? v) {
    final httpsUri = StrUtils.validateUri(v, schame: ["https"]);
    if (httpsUri == null) {
      return "validate_https".tr;
    }
    return null;
  }

  String? onValidateUri(String? v) {
    if (isIpfs) return _validateIpfs(v);
    return _validateHttps(v);
  }

  CashTokenBCMR? bcmr;

  Future<CashTokenBCMR> getBCMR(WalletProvider wallet, String uri) async {
    final MethodResult<String> result =
        await wallet.wallet.currency.httpGet<String>(uri);
    final Map<String, dynamic>? inJson =
        MethodUtils.nullOnException(() => StringUtils.toJson(result.result));
    if (inJson == null) {
      throw ApiProviderException.error("invalid_json_response");
    }
    final hash = await wallet.wallet.nonEncryptedRequest(
      NoneEncryptedRequestHashing.string(
          type: CryptoRequestHashingType.sha256, data: result.result),
    );
    return CashTokenBCMR(
        hash: BytesUtils.toHexString(hash),
        uri: BCHUtils.cleanUpBCMRUri(uri),
        content: inJson);
  }

  void readContent() async {
    if (!form.ready()) return;
    progressKey.progressText("fetching_uri_content".tr);
    final walletProvider = context.watch<WalletProvider>(StateConst.main);
    String uri = _uri;
    if (isIpfs) {
      uri = StrUtils.toIpfsV1Uri(uri);
    }
    final result =
        await MethodUtils.call(() async => await getBCMR(walletProvider, uri));
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      bcmr = result.result;
      progressKey.success();
    }
  }

  void onPasteUri(String v) {
    uriKey.currentState?.updateText(v);
  }

  void onSetup() {
    if (bcmr == null) return;
    context.pop(bcmr);
  }

  void onUpdateBCMrUri(String? uri) {
    if (uri == null) return;
    bcmr = bcmr?.copyWith(uri: uri);
    updateState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => Form(
        key: form,
        child: AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: bcmr != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("on_chain_uri".tr,
                        style: context.textTheme.titleMedium),
                    Text("on_chain_uri_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      onRemoveIcon: const Icon(Icons.edit),
                      onRemove: () {
                        context
                            .openSliverBottomSheet<String>(
                              "on_chain_uri".tr,
                              child: StringWriterView(
                                defaultValue: bcmr!.uri,
                                title: PageTitleSubtitle(
                                    title: "on_chain_uri".tr,
                                    body: Text("on_chain_uri_desc".tr)),
                                buttonText: "setup_input".tr,
                                label: "on_chain_uri".tr,
                              ),
                            )
                            .then(onUpdateBCMrUri);
                      },
                      child: Text(
                        bcmr!.uri,
                        style: context.onPrimaryTextTheme.bodyMedium,
                      ),
                    ),
                    WidgetConstant.height20,
                    Text("content".tr, style: context.textTheme.titleMedium),
                    Text("content_of_uri".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      child: ConstraintsBoxView(
                          maxHeight: 100,
                          child: SingleChildScrollView(
                            child: SelectableText(
                              bcmr!.content.toString(),
                              style: context.onPrimaryTextTheme.bodyMedium,
                            ),
                          )),
                    ),
                    WidgetConstant.height20,
                    Text("bcmr_hash".tr, style: context.textTheme.titleMedium),
                    Text("bcmr_hash_desc".tr),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                        child: Text(
                      bcmr!.hash,
                      style: context.onPrimaryTextTheme.bodyMedium,
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FixedElevatedButton(
                          padding: WidgetConstant.paddingVertical20,
                          onPressed: onSetup,
                          child: Text("setup_bcmr".tr),
                        )
                      ],
                    )
                  ],
                )
              : Column(
                  children: [
                    AnimatedSwitcher(
                      duration: APPConst.animationDuraion,
                      child: Column(
                        key: ValueKey<_MetadataUriTypes>(metadataUri),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PageTitleSubtitle(
                              title: "bitcoin_cash_meta_data_registeries".tr,
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextAndLinkView(
                                      text: "cash_tokens_metadata_desc1".tr,
                                      url: LinkConst.cashTokensPCMRReview),
                                  WidgetConstant.height8,
                                  Text("cash_token_creation_desc1".tr),
                                ],
                              )),
                          WidgetConstant.height20,
                          Text("where_meta_data_uoloaded".tr,
                              style: context.textTheme.titleMedium),
                          WidgetConstant.height8,
                          AppDropDownBottom(
                              onChanged: onSelectMetaDataUri,
                              value: metadataUri,
                              items: {
                                for (final i in _MetadataUriTypes.values)
                                  i: Text(i.value.tr)
                              },
                              hint: "meta_data_uploaded_in".tr),
                          WidgetConstant.height20,
                          if (isIpfs) ...[
                            Text("ipfs_cid".tr,
                                style: context.textTheme.titleMedium),
                            Text("input_your_meta_data_ipfs_cid".tr),
                          ] else ...[
                            Text("uri".tr,
                                style: context.textTheme.titleMedium),
                            Text("input_your_meta_data_uri_desc".tr),
                          ],
                          WidgetConstant.height8,
                        ],
                      ),
                    ),
                    AppTextField(
                      key: uriKey,
                      label: isIpfs ? "ipfs_cid".tr : "uri".tr,
                      initialValue: _uri,
                      onChanged: onChangeUri,
                      validator: onValidateUri,
                      suffixIcon: PasteTextIcon(
                          onPaste: onPasteUri, isSensitive: false),
                      hint:
                          isIpfs ? BCHUtils.hintIPFSUri : BCHUtils.hintWebsite,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FixedElevatedButton(
                          padding: WidgetConstant.paddingVertical40,
                          onPressed: readContent,
                          child: Text("read_uri_content".tr),
                        )
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
