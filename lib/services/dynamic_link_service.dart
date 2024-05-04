import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/screens/profile/view_profile.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinkService {
  late final FirebaseDynamicLinks _instance;
  final NavigationService _navigationService = sl<NavigationService>();

  DynamicLinkService() {
    _instance = FirebaseDynamicLinks.instance;
  }

  Future handleDynamicLinks(/*context*/) async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData? data = await _instance.getInitialLink();

    // 2. handle link that has been retrieved
    if (data != null) {
      _handleDeepLink(data /*, context*/);
    }

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    _instance.onLink.listen((dynamicLinkData) {
      _handleDeepLink(dynamicLinkData /*,context*/);
    }).onError((e) {
      if (kDebugMode) {
      }
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data /*, context*/) {
    final Uri deepLink = data.link;
    if (kDebugMode) {

      var params = deepLink.queryParameters['id'];
      if (params != null) {
        _navigationService.navigateTo(RoutePaths.viewProfile,
            arguments: params,
            nextScreen: ProfileScreen(
              userId: params.toString(),
            ));
      }
    }
  }

  Future<String> generateDynamicShortLink(String id,
      {String? title, String? description, String? image}) async {
    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: Constants.uriPrefix,
        link: Uri.parse('${Constants.linkPrefix}id=$id'),
        androidParameters: const AndroidParameters(
          packageName: Constants.androidPackageName,
        ),
        iosParameters: const IOSParameters(
          bundleId: Constants.iosBundleId,
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: title ?? '',
          description: description ?? '',
          imageUrl: image != null ? Uri.parse(image) : null,
        ),
      );

      final ShortDynamicLink shortDynamicLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);

      final Uri shortUrl = shortDynamicLink.shortUrl;
      await Share.share('$title \nCheck out the link ${shortUrl.toString()}');

      return shortUrl.toString();
    } catch (e) {
      return "error";
    }
  }
}
