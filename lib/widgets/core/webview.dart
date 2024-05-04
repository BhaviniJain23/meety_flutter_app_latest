import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../constants/ui_strings.dart';
import '../../services/internet_service.dart';
import '../../services/singleton_locator.dart';
import '../empty_widget.dart';

class WebViews extends StatefulWidget {
  const WebViews({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  State<WebViews> createState() => _WebViewsState();
}

class _WebViewsState extends State<WebViews> {
  late final PlatformWebViewControllerCreationParams params;
  late final WebViewController _controller;

  ValueNotifier<LoadingState> loading =
      ValueNotifier(LoadingState.Uninitialized);
  ValueNotifier<String> error = ValueNotifier("");

  //String? error;

  @override
  void initState() {
    super.initState();

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

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

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
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(''' Page resource error:  code: ${error.errorCode} 
            description: ${error.description}  errorType: ${error.errorType}
             isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
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
      );

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      fetchPrivacyPolicy();
    });
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      loading.value = LoadingState.Loading;
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (checkInternet) {
        Map<String, dynamic> apiResponse = await UserRepository().getPolicy();
        if (apiResponse[UiString.successText]) {
          if (apiResponse[UiString.dataText] != null) {
   
            var link = '';
            if (widget.title == UiString.helpSupport) {
              link = apiResponse["data"]["faq"];
            } else if (widget.title == UiString.termsAndConditions) {
              link = apiResponse["data"]["terms_and_condition"];
            } else {
              link = apiResponse["data"]["privacy_policy"];
            }

            await _controller.loadRequest(Uri.parse(link));

            loading.value = LoadingState.Success;
          }
        } else {
          error.value = apiResponse[UiString.error];
          loading.value = LoadingState.Failure;
        }
      }
    } catch (e) {
      error.value = e.toString();
      loading.value = LoadingState.Failure;

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarX(
          title: widget.title,
        ),
        body: MultiValueListenableBuilder(
          valueListenables: [loading, error],
          builder: (context, values, child) {
            if (values[0] == LoadingState.Failure) {
              return EmptyWidget(
                titleText: values[1],
              );
            } else if (values[0] == LoadingState.Success) {
              return WebViewWidget(
                controller: _controller,
              );
            } else {
              return const Center(
                child: Loading(
                  height: 200,
                ),
              );
            }
          },
        ));
  }
}
