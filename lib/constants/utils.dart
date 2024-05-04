// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/screens/home/match_screen.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/take_picture_view.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/webview.dart';
import 'package:meety_dating_app/widgets/custom_read_more_text.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/subscription_model.dart';
import '../models/user_subscription.dart';
import '../providers/login_user_provider.dart';
import '../widgets/CacheImage.dart';
import '../widgets/banner_widget.dart';
import 'ui_strings.dart';

logX(dynamic msg) {
  try {
    if (msg.toString().length > 1200) {
      developer.log(msg.toString().substring(0, 1199));
      developer.log(msg.toString().substring(1200));
    } else {
      developer.log(msg.toString());
    }
  } catch (e) {
    developer.log("LogX Error: $e");
  }
}

logF(dynamic msg, {name}) {
  try {
    developer.log("------------------- $name");
    developer.log(msg.toString());
    developer.log("------------------- $name");
  } catch (e) {
    developer.log("LogX Error: $e");
  }
}

class Utils {
  static const minInterestLength = 4;
  static const maxInterestLength = 9;
  static const minPhotos = 1;
  static const maxPhotos = 6;

  static String keyGeneration(String id){
    var key = utf8.encode(id);
    var bytes = utf8.encode("channelId");

    var hmacSha256 = Hmac(sha1, key);
    var digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  static String decrypt(String channelId,String encryptedData) {
    String keyString = keyGeneration(channelId);
    final key = enc.Key.fromUtf8(keyString.length > 16 ? keyString.substring(0,16) : keyString);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final initVector = enc.IV.fromUtf8(keyString.substring(0, 16));
    return encrypter.decrypt(enc.Encrypted.fromBase64(encryptedData), iv: initVector);
  }

  static String encryptText(String channelId, String plainText) {
    String keyString = keyGeneration(channelId);
    final key = enc.Key.fromUtf8(keyString.length > 16 ? keyString.substring(0,16) : keyString);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final initVector = enc.IV.fromUtf8(keyString.substring(0, 16));
    enc.Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData.base64;
  }

  static double convertKMToMiles(double tempDistance) {
    return double.parse((tempDistance * 0.6214).toStringAsFixed(3));
  }

  static double convertMilesToKm(double tempDistance) {
    return double.parse((tempDistance / 0.6214).toStringAsFixed(3));
  }

  static showDistanceInMeasurement(String distance) {
    String measure =
        sl<SharedPrefsManager>().getUserDataInfo()?.measure ?? UiString.km;

    if (measure == UiString.km) {
      return '${(double.tryParse(distance) ?? 0).show()} $measure';
    } else {
      return '${convertKMToMiles(double.tryParse(distance) ?? 0).show()} $measure';
    }
  }

  Future<void> shareApp() async {
    // Set the app link and the message to be shared

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appLink =
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
    String message =
        'Look what I have!\nCheck out the best dating app: $appLink';

    // Share the app link and message using the share dialog
    await Share.share(
      message,
    );
  }

  static String isRecentlyOnline(String time) {
    DateTime now = DateTime.now().toUtc();
    DateTime? convertTime = DateTime.tryParse(time);

    if (convertTime != null) {
      final duration = now.difference(convertTime).inMinutes < 2;
      return duration ? '1' : '0';
    }
    return "0";
  }

  static FileTypes getFileType(String url) {
    final File file = File(url);
    final ext = extension(file.path);

    if (ext.toLowerCase().contains('png') ||
        ext.toLowerCase().contains('jpg') ||
        ext.toLowerCase().contains('jpeg') ||
        ext.toLowerCase().contains('webp') ||
        ext.toLowerCase().contains('gif')) {
      return FileTypes.IMAGE;
    } else if (ext.toLowerCase().contains('mp4') ||
        ext.toLowerCase().contains('mov') ||
        ext.toLowerCase().contains('wmv') ||
        ext.toLowerCase().contains('avi') ||
        ext.toLowerCase().contains('mpeg') ||
        ext.toLowerCase().contains('webm') ||
        ext.toLowerCase().contains('flv') ||
        ext.toLowerCase().contains('mkv')) {
      return FileTypes.VIDEO;
    } else {
      return FileTypes.TEXT;
    }
  }

  static Future<bool> checkCameraPermission(BuildContext context) async {
    PermissionStatus cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      Future.delayed(const Duration(seconds: 0), () {
        AlertService.showAlertMessageWithTwoBtn(
          context: context,
          alertTitle: UiString.selectCamera,
          alertMsg: UiString.selectCameraDesc,
          positiveText: UiString.openSetting,
          negativeText: UiString.notNow,
          yesTap: () async {
            await openAppSettings();
          },
        );
        return;
      });
    }
    return cameraPermission == PermissionStatus.granted;
  }

  static Future<bool> checkGalleryPermission(BuildContext context) async {
    PermissionStatus photosPermission;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      photosPermission = await Permission.photos.request();
    } else {
      photosPermission = await Permission.storage.request();
    }

    if (photosPermission != PermissionStatus.granted) {
      Future.delayed(const Duration(seconds: 0), () {
        AlertService.showAlertMessageWithTwoBtn(
          context: context,
          alertTitle: UiString.selectGallery,
          alertMsg: UiString.selectCameraDesc,
          positiveText: UiString.openSetting,
          negativeText: UiString.notNow,
          yesTap: () async {
            await openAppSettings();
          },
        );
        return;
      });
    }
    return photosPermission == PermissionStatus.granted;
  }

  static String generateRandomString() {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    return List.generate(3, (index) => chars[r.nextInt(chars.length)]).join();
  }

  static int generateRandomInt() {
    var r = Random();
    const chars = '1234567890';
    try {
      return int.parse(
          List.generate(3, (index) => chars[r.nextInt(chars.length)]).join());
    } catch (e) {
      return 119;
    }
  }

  // Function to generate a random match message
  static String getRandomMatchMessage(String name) {
    List<String> messages = [
      "Congratulations! You've just matched with $name. Why not start a conversation and see where it goes?",
      "You've got a new match! Take this opportunity to get to know each other and see if there's a connection.",
      "Great news! You and $name have just matched. Why not say hello and see if you have any common interests?",
      "It's a match! Now's your chance to make a connection with $name. Don't be shy - say hello!",
      "You're in luck - you and $name are a match! Start a conversation and see where things lead."
    ];

    // Generate a random index
    int randomIndex = Random().nextInt(messages.length);

    // Retrieve the random match message using the generated index
    return messages[randomIndex];
  }

  // Function to generate a random match message
  static String getRandomThings(List<String> messages) {
    ConstantList.getMoreMessageList;

    // Generate a random index
    int randomIndex = Random().nextInt(messages.length);

    // Retrieve the random match message using the generated index
    return messages[randomIndex];
  }

  static String getSentRequests(List<String> messages) {
    ConstantList.sentRequestsHeading;
    int randomIndex = Random().nextInt(messages.length);
    return messages[randomIndex];
  }

  static String getSentRequestsCaption(List<String> messages) {
    ConstantList.sentRequestsHeadingCaption;
    int randomIndex = Random().nextInt(messages.length);
    return messages[randomIndex];
  }

  static String addonsMessage(List<String> messages) {
    ConstantList.visitorHeading;

    // Generate a random index
    int randomIndex = Random().nextInt(messages.length);

    // Retrieve the random match message using the generated index
    return messages[randomIndex];
  }

  static String backWithoutChanges(List<String> messages) {
    ConstantList.backWithoutAnyChanges;

    // Generate a random index
    int randomIndex = Random().nextInt(messages.length);

    // Retrieve the random match message using the generated index
    return messages[randomIndex];
  }

  static String getGenderString(String? json) {
    if (json != null) {
      if (json == 'M') {
        return "Male";
      } else if (json == 'F') {
        return "Female";
      } else if (json == 'T') {
        return "Trans";
      }
      return json;
    }

    return "";
  }

  static void showMatchPopUp(
      BuildContext context,
      LikeListProvider likeListProvider,
      UserBasicInfo userBasicInfo,
      String message) {
    final loggedInUser = sl<SharedPrefsManager>().getUserDataInfo();

    if (message.isEmpty) {
      message = Utils.getRandomMatchMessage(userBasicInfo.name ?? '');
    }

    if (loggedInUser != null) {
      int sentLikedIndex = likeListProvider.likeSentList
          .indexWhere((element) => element.id == userBasicInfo.id);
      if (sentLikedIndex != -1) {
        likeListProvider.likeSentList =
            List.from(likeListProvider.likeSentList..removeAt(sentLikedIndex));
      }

      likeListProvider.matchesList = likeListProvider.matchesList
        ..insert(0, userBasicInfo);

      BottomSheetService.showBottomSheet(
          context: context,
          builder: (context, _) {
            return MatchScreen(
                loginUser: UserBasicInfo.fromUser(loggedInUser),
                otherUser: userBasicInfo,
                message: message);
          });
    }
  }

  static void showVerifiedNowDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  Assets.verifiedIcon,
                  height: 40,
                  width: 40,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Get Photo Verified',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Verify your profile with video: verified = '
                  '😍 match!',
                  style: context.textTheme.bodyMedium?.copyWith(color: black),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'We will compares the face in your '
                  'video selfie to the pics in your profile. '
                  'After that, we will delete your recognition information '
                  'once verification is complete - usually '
                  'in less than 24  hours.',
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Before you continue',
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    const Text(
                      '\u2022',
                      style: TextStyle(fontSize: 16, height: 1.55, color: grey),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        "Check your background",
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Find a well-lit area. Adjust your brightness settings. Avoid harsh glares and backlighting',
                    style: context.textTheme.bodySmall
                        ?.copyWith(fontSize: 12, color: grey),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      '\u2022',
                      style: TextStyle(fontSize: 16, height: 1.55, color: grey),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        "Show your face",
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Position yourself directly facing the camera.Make sure to remove hats, sunglasses, and face coverings',
                    style: context.textTheme.bodySmall
                        ?.copyWith(fontSize: 12, color: grey),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FillBtnX(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    sl<NavigationService>()
                        .customMaterialPageRoute(const TakePictureView());
                    context.read<LoginUserProvider>().profileCompleteProgress();
                  },
                  text: UiString.continueText,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 45,
                  child: OutLineBtnX(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                    },
                    text: UiString.mayBeLaterText,
                    radius: 15,
                    color: red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static showPendingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Image.asset(
                  Assets.verifiedIcon,
                  height: 40,
                  width: 40,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Verification Under Review',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'We are currently reviewing your video and will get back to you shortly.',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: black, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 15,
                ),
                FillBtnX(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                  },
                  text: UiString.okayText,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showRejectedDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Image.asset(
                  Assets.verifiedIcon,
                  height: 40,
                  width: 40,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Verification Rejected',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Your verification is rejected because $message',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: black, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 15,
                ),
                FillBtnX(
                  textStyle: const TextStyle(color: white),
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    sl<NavigationService>()
                        .customMaterialPageRoute(const TakePictureView());
                  },
                  text: UiString.verifiedAgainText,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool premiumPopUp(
    BuildContext context,
  ) {
    /// subscription change
    List<UserSubscription>? subscriptionList =
        sl<SharedPrefsManager>().getUserDataInfo()?.subscription;

    // final SubscriptionModel = context.read<SubscriptionProvider>().subscriptions.indexWhere((element) => planIds.con(element.planId))
    if (subscriptionList != null) {
      int index =
          subscriptionList.indexWhere((element) => element.planId == '0');
      if (index != -1) {
        //list of meetyplus,gold,platnium add on
      } else {
        // add on
        AlertService.moreMessagePopUpService(context);
      }
    } else {
      //list of meetyplus,gold,platnium add on
      // AlertService.premiumPopUpService(context);
    }
    return false;
  }

  static void printingAllPremiumInfo(
    BuildContext context, {
    bool isForLike = false,
    bool isForDislike = false,
    bool isForRewind = false,
    bool isForMsg = false,
    bool isForLikeList = false,
    bool isForLikeSentList = false,
    bool isForVisitorList = false,
    bool isForOnlineOfflineStatus = false,
    bool isForProfileVerified = false,
  }) {
    /// subscription change
    List<String> planIds = sl<SharedPrefsManager>()
            .getUserDataInfo()
            ?.subscription
            ?.map((e) => e.planId.toString())
            .toList() ??
        [];

    final subscriptionProvider = context.read<SubscriptionProvider>();

    // Define premium and add-on plans
    final List<String> addOns = subscriptionProvider.subscriptionsOnlyAddOns
        .map((e) => (e.planId ?? 0).toString())
        .toList();
    final List<String> premiumPlan = subscriptionProvider
        .subscriptionsWithOutMeetyExplorer
        .map((e) => (e.planId ?? 0).toString())
        .toList();

    // Check user's subscription status
    final bool isNonPremium = planIds.isEmpty;
    final bool aPremiumPlan =
        !isNonPremium && planIds.every(premiumPlan.contains);
    final bool anAddOnPlan = !isNonPremium && planIds.every(addOns.contains);

    List<String> returnList = [];

    // Determine the returnList based on subscription status and user actions
    if (isNonPremium) {
      if ([
        isForLike,
        isForDislike,
        isForRewind,
        isForLikeSentList,
        isForVisitorList
      ].any((bool isFlag) => isFlag)) {
        returnList = List.from(premiumPlan);
      } else if (isForMsg) {
        returnList = ['5'];
      } else if ([isForLikeList, isForOnlineOfflineStatus, isForProfileVerified]
          .any((bool isFlag) => isFlag)) {
        returnList = ['2', '3'];
      } else {
        returnList = List.from(premiumPlan);
      }
    } else if (aPremiumPlan) {
      if ([
        isForLike,
        isForDislike,
        isForRewind,
        isForLikeSentList,
        isForVisitorList
      ].any((bool isFlag) => isFlag)) {
        returnList = planIds.contains("1")
            ? ["2", "3"]
            : (planIds.contains("2") ? ["3"] : []);
      } else if (isForMsg) {
        returnList = ['5'];
      } else if ([isForLikeList, isForOnlineOfflineStatus, isForProfileVerified]
          .any((bool isFlag) => isFlag)) {
        returnList = planIds.contains("1")
            ? ["2", "3"]
            : (planIds.contains("2") ? ["3"] : []);
      } else {
        returnList = List.from(premiumPlan);
      }
    } else if (anAddOnPlan) {
      if ([
        isForLike,
        isForDislike,
        isForRewind,
        isForLikeSentList,
        isForVisitorList
      ].any((bool isFlag) => isFlag)) {
        returnList = List.from(premiumPlan);
      } else if (isForMsg) {
        returnList = planIds.contains('5') ? ['5'] : List.from(premiumPlan);
      } else if ([isForLikeList, isForOnlineOfflineStatus, isForProfileVerified]
          .any((bool isFlag) => isFlag)) {
        returnList = List.from(premiumPlan)
          ..removeWhere((e) => planIds.contains(e) || e == '1');
      } else {
        returnList = List.from(premiumPlan);
      }
    } else {
      if ([
        isForLike,
        isForDislike,
        isForRewind,
        isForLikeSentList,
        isForVisitorList
      ].any((bool isFlag) => isFlag)) {
        returnList = planIds.contains("1")
            ? ["2", "3"]
            : (planIds.contains("2") ? ["3"] : []);
      } else if (isForMsg) {
        returnList = ['5'];
      } else if ([isForLikeList, isForOnlineOfflineStatus, isForProfileVerified]
          .any((bool isFlag) => isFlag)) {
        returnList = planIds.contains("1")
            ? ["2", "3"]
            : (planIds.contains("2") ? ["3"] : []);
      } else {
        returnList = List.from(premiumPlan);
      }
    }

    final subscriptionModel = subscriptionProvider.subscriptions
        .where((element) => returnList.contains(element.planId?.toString()))
        .toList();
    if (returnList.contains("5")) {
      AlertService.moreMessagePopUpService(context);
    } else {
      AlertService.premiumPopUpService(context, subscriptionModel);
    }
  }

  static void hideLoader() {}

  static void showLoader() {
    const Loading();
  }

  static int calculateDaysRemaining() {
    DateTime? expirationDate = sl<SharedPrefsManager>()
        .getUserDataInfo()
        ?.pastSubscription
        ?.expiryDate;

    Duration difference = expirationDate!.difference(DateTime.now());
    return difference.inDays;
  }

  static void showBottomSheet(
      SubscriptionModel subscriptionModel, BuildContext context) {
    final ValueNotifier<int> selectedIndex = ValueNotifier(-1);
    final ValueNotifier<bool> autoRenew = ValueNotifier(true);

    Widget SubscriptionPlanCard(
      PriceInfo priceInfo,
      int index,
    ) {
      return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: selectedIndex.value == index ? red : grey, width: 0.7),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Container(
          alignment: Alignment.center,
          width: ResponsiveDesign.width(120, context),
          height: ResponsiveDesign.height(130, context),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(
                color: selectedIndex.value == index ? red : grey, width: 0.7),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                  color: selectedIndex.value == index
                      ? red.toMaterialColor.shade500
                      : grey.toMaterialColor.shade500,
                  offset: const Offset(0, 2),
                  blurRadius: 3.5)
            ],
          ),
          child: InkWell(
            onTap: () {
              if (selectedIndex.value != index) {
                selectedIndex.value = index;
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(TextSpan(
                    children: [
                      const TextSpan(
                          text: '₹ ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal)),
                      TextSpan(
                          text: '${priceInfo.planPricePerM ?? 0}/m',
                          style: TextStyle(
                              fontSize: ResponsiveDesign.fontSize(15, context),
                              fontWeight: FontWeight.bold)),
                    ],
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold))),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${((int.tryParse(priceInfo.planDayLimit.toString()) ?? 0) / 30).round()} months',
                  style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(12, context),
                      fontWeight: FontWeight.w100,
                      color: black),
                ),
              ],
            ),
          ),
        ),
      );
    }

    showModalBottomSheet(
      elevation: 5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (bscontext) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subscriptionModel.planImage != null) ...[
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 15, left: 15, top: 15),
                      child: CacheImage(
                        imageUrl: subscriptionModel.planImage[0],
                        height: 35,
                        width: context.width * 0.7,
                        boxFit: BoxFit.contain,
                      ),
                    ),
                  ),
                ] else ...[
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 15, left: 15, top: 15),
                      child: Text(
                        subscriptionModel.planTitle?.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: red),
                      ),
                    ),
                  ),
                ],
                subscriptionModel.planDescription?.toString().isHtml() ?? false
                    ? Flexible(
                        child: Padding(
                          padding: ResponsiveDesign.horizontal(25, context),
                          child: html.Html(
                            extensions: const [TableHtmlExtension()],
                            shrinkWrap: true,
                            data:
                                subscriptionModel.planDescription?.toString() ??
                                    '',
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        child: Text(
                          subscriptionModel.planDescription?.toString() ?? '',
                        ),
                      ),
                if (subscriptionModel.planId.toString() == "0") ...[
                  const SizedBox(
                    height: 10,
                  )
                ],
                Padding(
                  padding: ResponsiveDesign.horizontal(13, context),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 5,
                    runAlignment: WrapAlignment.start,
                    children: List.generate(
                        subscriptionModel.priceInfo?.length ?? 0, (index) {
                      PriceInfo priceInfo = subscriptionModel.priceInfo![index];
                      return ValueListenableBuilder(
                        valueListenable: selectedIndex,
                        builder: (context, selectingVal, _) {
                          return CustomBannerWidget(
                            borderRadius: BorderRadius.circular(17),
                            showBanner: false,
                            child: Material(
                              borderRadius: BorderRadius.circular(17),
                              color: Colors.transparent,
                              child: SubscriptionPlanCard(
                                priceInfo,
                                index,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                if (subscriptionModel.planId.toString() == "1") ...[
                  const SizedBox(
                    height: 20,
                  )
                ],
                if (subscriptionModel.planId.toString() == "0") ...[
                  const SizedBox(
                    height: 10,
                  )
                ] else ...[
                  const SizedBox(
                    height: 10,
                  )
                ],
                Padding(
                  padding: ResponsiveDesign.horizontal(20, context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: autoRenew,
                          builder: (context, value, child) {
                            return SizedBox(
                              width: ResponsiveDesign.width(20, context),
                              height: ResponsiveDesign.height(24, context),
                              child: Checkbox(
                                value: autoRenew.value,
                                onChanged: (checkNewVal) {
                                  autoRenew.value = checkNewVal ?? false;
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3)),
                              ),
                            );
                          }),
                      SizedBox(
                        width: ResponsiveDesign.width(5, context),
                      ),
                      Expanded(
                          child: Text.rich(TextSpan(children: [
                        WidgetSpan(
                            child: ReadMoreTextScreen(
                          "By tapping Continue,you will be charged,your "
                          "subscription will auto - renew for the same price"
                          " & package length until you cancel via Play Store"
                          " Settings,and you agree to our",
                          trimLines: 2,
                          style: TextStyle(
                              fontSize: ResponsiveDesign.fontSize(11, context)),
                          moreStyle: const TextStyle(
                              fontWeight: FontWeight.normal, color: red),
                          colorClickableText: red,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'Read more',
                          trimExpandedText: ' Show less',
                          extraLeadingText: "Terms",
                          onClickExtraText: () {
                            sl<NavigationService>().navigateTo(
                                RoutePaths.webViews,
                                nextScreen: const WebViews(
                                    title: UiString.termsAndConditions,
                                    value: "false"));
                          },
                        )),
                      ])))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: ResponsiveDesign.only(context,
                      left: 20, right: 20, bottom: 10, top: 0),
                  child: FillBtnX(
                    onPressed: () async {
                      if (selectedIndex.value != -1) {
                        if (subscriptionModel
                                .priceInfo![selectedIndex.value].planPriceId !=
                            null) {
                          SubscriptionProvider subscription =
                              Provider.of<SubscriptionProvider>(context,
                                  listen: false);
                          Utils.CheckSubscriptionScreen(
                              context,
                              subscription.subscriptions[selectedIndex.value]
                                  .priceInfo![selectedIndex.value].planPriceId,
                              subscription.subscriptions.indexWhere((element) =>
                                  element.planId.toString() ==
                                  subscriptionModel.planId.toString()),
                              true,
                              false);
                        }
                      } else {
                        AlertService.showToast(
                            "Please Select at least one card", context);
                      }
                    },
                    text: "SUBSCRIBE NOW",
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> CheckSubscriptionScreen(BuildContext context,
      int? planPriceId, int? planId, bool autoRenew, bool isAddOns) async {
    await context
        .read<SubscriptionProvider>()
        .fetchTakeSubscription(planPriceId, planId, autoRenew, isAddOns);
  }
  static void configLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..backgroundColor = white
      ..indicatorColor = red
      ..textColor = black
      ..progressColor = black
      ..maskColor = red
      ..userInteractions = false
      ..maskType = EasyLoadingMaskType.black
      ..dismissOnTap = false;
  }
}

class BackgroundTimer with WidgetsBindingObserver {
  Timer? timer;
  Timer? checkTimer;
  bool isAppInForeground = true;

  void startTimer(Function callback, bool toCheckTimer) {
    const duration = Duration(minutes: 1);
    if (!toCheckTimer) {
      timer = Timer.periodic(duration, (Timer timer) {
        if (!isAppInForeground) {
          timer.cancel(); // Stop the timer if the app is in the background
        } else {
          callback();
        }
      });
    } else {
      checkTimer = Timer.periodic(duration, (Timer checkTimer) {
        if (!isAppInForeground) {
          checkTimer.cancel(); // Stop the timer if the app is in the background
        } else {
          callback();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isAppInForeground = state == AppLifecycleState.resumed;
  }

  void startBackgroundTimer(Function callback, bool toCheckTimer) {
    WidgetsBinding.instance.addObserver(this);
    startTimer(callback, toCheckTimer);
  }

  void stopBackgroundTimer(bool toCheckTimer) {
    WidgetsBinding.instance.removeObserver(this);
    if (!toCheckTimer) {
      timer?.cancel();
    } else {
      checkTimer?.cancel();
    }
  }
}
