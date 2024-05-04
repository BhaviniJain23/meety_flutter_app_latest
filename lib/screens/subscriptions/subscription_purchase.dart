import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/subscription_model.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:provider/provider.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../services/singleton_locator.dart';

class SubscriptionPurchaseScreen extends StatefulWidget {
  const SubscriptionPurchaseScreen(
      {super.key, required this.paymentLink, this.subscriptionModel});

  final String paymentLink;
  final SubscriptionModel? subscriptionModel;

  @override
  State<SubscriptionPurchaseScreen> createState() =>
      _SubscriptionPurchaseScreenState();
}

class _SubscriptionPurchaseScreenState
    extends State<SubscriptionPurchaseScreen> {
  late final WebViewController _controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            // showLoaderDialog(context);
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            debugPrint('Page finished loading: $isLoading ');

            if (isLoading) {
              Navigator.pop(context);
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                        ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');

            var newURL = Uri.parse(request.url);
            debugPrint('allowing loading: ${newURL.origin + newURL.path}');

            if ((newURL.origin + newURL.path)
                .contains(Constants.failurePaymentRedirectURL)) {
              paymentFailed();
              return NavigationDecision.prevent;
            }
            if ((newURL.origin + newURL.path)
                .contains(Constants.successPaymentRedirectURL)) {
              paymentSucceed();
              return NavigationDecision.prevent;
            }
            showLoaderDialog(context);

            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.paymentLink));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
    Future.delayed(const Duration(milliseconds: 300), () {
      showLoaderDialog(context);
    });
  }

  @override
  void dispose() {
    _controller.clearCache();
    _controller.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        showExitPopup(context);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBarX(
            height: ResponsiveDesign.screenHeight(context) * 0.045,
            title: '',
          ),
          backgroundColor: Colors.white,
          body: SafeArea(child: WebViewWidget(controller: _controller))),
    );
  }

  Future<void> showExitPopup(BuildContext context) async {
    unawaited(showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: ResponsiveDesign.height(140, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text("Are you sure you want to quit?"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        width: ResponsiveDesign.screenWidth(context) * 0.45,
                        height: ResponsiveDesign.height(50, context),
                        child: FillBtnX(
                          onPressed: () async {
                            sl<NavigationService>().pop();
                            Navigator.pop(context);
                          },
                          text: 'Yes',
                        ),
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: SizedBox(
                        width: ResponsiveDesign.screenWidth(context) * 0.45,
                        height: ResponsiveDesign.height(50, context),
                        child: FillBtnX(
                          onPressed: () async {
                            sl<NavigationService>().pop();
                          },
                          text: 'No',
                        ),
                      ))
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        }));
  }

  void showLoaderDialog(BuildContext context) {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      //const Loading();
      var alert = AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(
                margin: ResponsiveDesign.only(context, left: 20),
                child: const Text("Loading...")),
          ],
        ),
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  void paymentSucceed() {
//    Provider.of(context);
    context.read<SubscriptionProvider>().sendInvoiceWithEmail();
    debugPrint('allowing loading: SUCCESS');

    AlertService.subscriptionPaymentSuccessfully(
        context,
        widget.subscriptionModel?.planImage,
        widget.subscriptionModel?.priceInfo ?? [],
        widget.subscriptionModel?.planTitle ?? '',
        widget.subscriptionModel?.planId.toString() ?? '');
    // context.read<LoginUserProvider>().fetchLoginUser();
    // sl<NavigationService>().navigateTo(RoutePaths.home,
    //             withPushAndRemoveUntil: true,);
  }

  void paymentFailed() {
    debugPrint('allowing loading: FAIL');

    AlertService.subscriptionPaymentFailed(context, widget.subscriptionModel!);
    Navigator.pop(context);
  }
}
