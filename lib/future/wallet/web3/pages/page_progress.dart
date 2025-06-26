import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/core.dart';
import 'package:on_chain_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
import 'package:on_chain_wallet/wallet/models/network/core/network/network.dart';
import 'package:on_chain_wallet/wallet/web3/core/exception/exception.dart';
import 'package:on_chain_wallet/wallet/web3/core/request/web_request.dart';

enum Web3ProgressStatus {
  progress(true),
  error(true),
  idle(true),
  successResponse(false),
  errorResponse(false),
  successRequest(false),
  failedRequest(false);

  final bool canUpdate;
  const Web3ProgressStatus(this.canUpdate);

  static Web3ProgressStatus fromWeb3Status(
      Web3RequestCompleterEventType? status) {
    switch (status) {
      case Web3RequestCompleterEventType.response:
        return Web3ProgressStatus.successResponse;
      case Web3RequestCompleterEventType.error:
        return Web3ProgressStatus.errorResponse;
      case Web3RequestCompleterEventType.closed:
        return Web3ProgressStatus.failedRequest;
      case Web3RequestCompleterEventType.success:
        return Web3ProgressStatus.successRequest;
      default:
        return Web3ProgressStatus.idle;
    }
  }
}

class Web3PageProgress extends StatefulWidget {
  const Web3PageProgress(
      {super.key,
      required this.child,
      this.initialStatus = Web3ProgressStatus.idle,
      this.initialWidget});
  final Web3ProgressStatus initialStatus;
  final FuncWidgetContext child;
  final Widget? initialWidget;

  @override
  State<Web3PageProgress> createState() => Web3PageProgressState();
}

class Web3PageProgressState extends State<Web3PageProgress>
    with SafeState<Web3PageProgress> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;
  StreamValue<Web3ProgressStatus> _statusLive =
      StreamValue(Web3ProgressStatus.idle);
  Web3ProgressStatus get status => _statusLive.value;
  Widget? _responseWidget;
  Widget? _child;
  ScaffoldMessengerState? key;

  @override
  void onInitOnce() {
    super.onInitOnce();
    _statusLive = StreamValue(widget.initialStatus);
    _responseWidget = widget.initialWidget;
    key = ScaffoldMessenger.maybeOf(context);
    key?.clearSnackBars();
  }

  void _shwoRequestStatus() async {
    controller ??= key?.showSnackBar(_requestStatusView(
      context: context,
      status: _statusLive,
      onHide: () {
        controller?.close();
        controller = null;
      },
    ));
  }

  void _updateStream(Web3ProgressStatus status) {
    _statusLive.value = status;

    updateState();
    if (!status.canUpdate) {
      _shwoRequestStatus();
    }
  }

  void _update({required Web3ProgressStatus status, Widget? widget}) {
    if (this.status.canUpdate) {
      _responseWidget = widget;
      _updateStream(status);
    }
  }

  void response({String? text, Widget? widget}) {
    _update(
        status: Web3ProgressStatus.successResponse,
        widget: widget ??
            PageProgressChildWidget(ProgressWithTextView(
                text: text ?? "", icon: WidgetConstant.checkCircleLarge)));
  }

  void processs({String? text}) {
    _update(
        status: Web3ProgressStatus.progress,
        widget:
            PageProgressChildWidget(ProgressWithTextView(text: text ?? "")));
  }

  void _error(
      {String? text,
      Widget? widget,
      Duration? backToIdle = APPConst.twoSecoundDuration,
      required Web3ProgressStatus status}) {
    _update(
        status: status,
        widget: widget ??
            PageProgressChildWidget(ProgressWithTextView(
                text: text ?? "", icon: WidgetConstant.errorIconLarge)));
    if (backToIdle != null) {
      Future.delayed(
          backToIdle, () => _update(status: Web3ProgressStatus.idle));
    }
  }

  void closedRequest({String? error}) {
    if (_responseWidget == null || status == Web3ProgressStatus.progress) {
      _responseWidget = PageProgressChildWidget(ProgressWithTextView(
          text: error?.tr ?? "client_closed_durning_request".tr,
          icon: WidgetConstant.errorIconLarge));
    }

    _updateStream(Web3ProgressStatus.failedRequest);
  }

  void successRequest() {
    if (_responseWidget == null || status == Web3ProgressStatus.progress) {
      _responseWidget = PageProgressChildWidget(ProgressWithTextView(
          text: "web3_response_successfully_desc".tr,
          icon: WidgetConstant.checkCircleLarge));
    }
    _updateStream(Web3ProgressStatus.successRequest);
  }

  void idle() {
    _update(status: Web3ProgressStatus.idle);
  }

  @override
  void safeDispose() {
    _child = null;
    _statusLive.dispose();
    MethodUtils.after(() async {
      key?.clearSnackBars();
    });
    super.safeDispose();
  }

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher<Web3ProgressStatus>(
      duration: APPConst.animationDuraion,
      enable: status,
      widgets: {
        Web3ProgressStatus.idle: (c) => FutureBuilder(
              future: MethodUtils.after(() async => widget.child(c)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WidgetConstant.errorIcon,
                      Text(snapshot.error?.toString() ?? "")
                    ],
                  );
                }
                if (snapshot.hasData) {
                  _child = snapshot.data!;
                }
                return _child ?? WidgetConstant.sizedBox;
              },
            ),
        Web3ProgressStatus.progress: (c) => _responseWidget,
        Web3ProgressStatus.error: (c) => _responseWidget,
        Web3ProgressStatus.errorResponse: (c) => _responseWidget,
        Web3ProgressStatus.successResponse: (c) => _responseWidget,
        Web3ProgressStatus.failedRequest: (c) => _responseWidget,
        Web3ProgressStatus.successRequest: (c) => _responseWidget
      },
    );
  }
}

SnackBar _requestStatusView(
    {required BuildContext context,
    required StreamValue<Web3ProgressStatus> status,
    required DynamicVoid onHide}) {
  return SnackBar(
      duration: switch (status.value) {
        Web3ProgressStatus.successRequest => APPConst.tenSecoundDuration,
        Web3ProgressStatus.failedRequest => APPConst.tenSecoundDuration,
        _ => const Duration(minutes: 10)
      },
      action: SnackBarAction(label: 'close'.tr, onPressed: onHide),
      content: StreamWidget(
        value: status,
        builder: (context, status) => Row(
          children: [
            switch (status) {
              Web3ProgressStatus.successResponse ||
              Web3ProgressStatus.errorResponse =>
                APPCircularProgressIndicator(
                    color: context.colors.onInverseSurface),
              Web3ProgressStatus.failedRequest =>
                Icon(Icons.error, color: context.colors.onInverseSurface),
              _ =>
                Icon(Icons.check_circle, color: context.colors.onInverseSurface)
            },
            WidgetConstant.width8,
            Flexible(
                child: switch (status) {
              Web3ProgressStatus.successResponse ||
              Web3ProgressStatus.errorResponse =>
                OneLineTextWidget(
                    maxLine: 2,
                    "web3_sending_response_to_client".tr,
                    style: context.textTheme.labelLarge
                        ?.copyWith(color: context.colors.onInverseSurface)),
              Web3ProgressStatus.failedRequest => OneLineTextWidget(
                  maxLine: 2,
                  "web3_sending_response_error_desc".tr,
                  style: context.textTheme.labelLarge
                      ?.copyWith(color: context.colors.onInverseSurface)),
              _ => OneLineTextWidget(
                  maxLine: 2,
                  "web3_response_successfully_desc".tr,
                  style: context.textTheme.labelLarge
                      ?.copyWith(color: context.colors.onInverseSurface)),
            }),
          ],
        ),
      ));
}

extension QuickAccsessWeb3PageProgressState
    on GlobalKey<Web3PageProgressState> {
  void idle() {
    currentState?.idle();
  }

  void response({String? text, Widget? widget}) {
    currentState?.response(text: text, widget: widget);
  }

  void responseTx({required String hash, required WalletNetwork network}) {
    currentState?.response(
        widget:
            Web3SuccessTransactionTextView(txIds: [hash], network: network));
  }

  void process({String? text}) {
    currentState?.processs(text: text);
  }

  void error({
    Object? error,
    String? message,
    Duration backToIdle = APPConst.twoSecoundDuration,
    bool showBackButton = false,
  }) {
    _errorResponseFromException(
        status: Web3ProgressStatus.error,
        showBackButton: showBackButton,
        backToIdle: backToIdle,
        error: error,
        message: message);
  }

  void errorResponse({Object? error, String? message}) {
    _errorResponseFromException(
        status: Web3ProgressStatus.errorResponse,
        error: error,
        message: message,
        backToIdle: null);
  }

  void _errorResponseFromException(
      {Object? error,
      String? message,
      Duration? backToIdle = APPConst.twoSecoundDuration,
      bool showBackButton = false,
      required Web3ProgressStatus status}) {
    showBackButton = showBackButton && status.canUpdate;
    if (error == WalletExceptionConst.rejectSigning) {
      showBackButton = false;
      backToIdle = APPConst.oneSecoundDuration;
    }
    if (showBackButton) {
      backToIdle = null;
    }
    if (!status.canUpdate) {
      backToIdle = null;
      showBackButton = false;
    }
    final key = showBackButton ? this : null;
    if (error is WalletException) {
      currentState?._error(
          widget: _Web3ErrorMessageView(null, key, message: error.message.tr),
          backToIdle: backToIdle,
          status: status);
    } else if (error is Web3RequestException) {
      currentState?._error(
          backToIdle: backToIdle,
          widget: _Web3ErrorMessageView(error.message, key),
          status: status);
    } else if (error is ApiProviderException) {
      currentState?._error(
          backToIdle: backToIdle,
          widget: _Web3ErrorMessageView(error.message.toString().tr, key),
          status: status);
    } else if (error is BlockchainUtilsException) {
      currentState?._error(
          backToIdle: backToIdle,
          widget: _Web3ErrorMessageView(error.message, key),
          status: status);
    } else {
      currentState?._error(
          widget: _Web3ErrorMessageView(null, key, message: message),
          backToIdle: backToIdle,
          status: status);
    }
  }

  void closedRequest({String? error}) {
    currentState?.closedRequest(error: error);
  }

  void successRequest() {
    currentState?.successRequest();
  }
}

class _Web3ErrorMessageView extends StatelessWidget {
  const _Web3ErrorMessageView(this.error, this.progressKey, {this.message});
  final String? message;
  final String? error;
  final GlobalKey<Web3PageProgressState>? progressKey;

  @override
  Widget build(BuildContext context) {
    return PageProgressChildWidget(_Web3ProgressWithTextView(
      progressKey: progressKey,
      text: message ?? "request_error".tr,
      icon: WidgetConstant.errorIconLarge,
      bottomWidget: error == null
          ? null
          : ContainerWithBorder(
              onRemove: () {},
              enableTap: false,
              onRemoveIcon:
                  Icon(Icons.error, color: context.onPrimaryContainer),
              child: SelectableText(error!,
                  minLines: 1,
                  maxLines: 3,
                  style: context.onPrimaryTextTheme.bodyMedium)),
    ));
  }
}

class _Web3ProgressWithTextView extends StatelessWidget {
  const _Web3ProgressWithTextView(
      {required this.text,
      required this.progressKey,
      this.icon,
      this.bottomWidget});
  final String text;
  final Widget? icon;
  final Widget? bottomWidget;
  final GlobalKey<Web3PageProgressState>? progressKey;

  @override
  Widget build(BuildContext context) {
    final canUpdate = progressKey?.currentState?.status.canUpdate ?? false;
    return _ProgressWithTextView(
        text: Column(
          children: [
            LargeTextView([text], maxLine: 3, textAligen: TextAlign.center),
            if (bottomWidget != null) bottomWidget!,
            if (canUpdate) ...[
              WidgetConstant.height20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                      onPressed: () {
                        progressKey?.idle();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text("back_to_the_page".tr))
                ],
              )
            ]
          ],
        ),
        icon: icon);
  }
}

class _ProgressWithTextView extends StatelessWidget {
  const _ProgressWithTextView({required this.text, this.icon});
  final Widget text;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon ?? const CircularProgressIndicator(),
        WidgetConstant.height8,
        text
      ],
    );
  }
}
