import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/subscription_model.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/screens/subscriptions/subscription_list.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/assets.dart';
import '../../constants/size_config.dart';
import '../../constants/ui_strings.dart';
import '../../providers/login_user_provider.dart';
import '../../services/navigation_service.dart';
import '../../services/singleton_locator.dart';
import 'buttons.dart';

class AlertService {
  static void showToast(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          msg,
          style: const TextStyle(
            color: white,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.grey[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showAlertMessage(
    BuildContext context, {
    String? msg,
    IconData? icon,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Timer(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon ?? Icons.error_outline_rounded,
                  size: 60,
                ),
                Text(msg ?? 'Something went wrong'),
              ],
            ),
            titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
          ),
        );
      },
    );
  }

  static void showAlertMessageWithTwoBtn(
      {required BuildContext context,
      required String alertTitle,
      required String alertMsg,
      required String positiveText,
      required String negativeText,
      required Function() yesTap,
      Function()? noTap}) {
    // set up the buttons
    Widget noButton = TextButton(
      onPressed: noTap ??
          () {
            Navigator.of(context).pop();
          },
      child: Text(
        negativeText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      ),
    );
    Widget yesButton = TextButton(
      child: Text(
        positiveText,
        style: const TextStyle(
          fontSize: 16.0,
          color: red,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        yesTap();
      },
    );
    // set up the AlertDialog
    AlertDialog alert;
    if (alertTitle.isNotEmpty) {
      alert = AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          alertTitle,
          style: const TextStyle(fontSize: 15),
        ),
        content: Text(
          alertMsg,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [noButton, yesButton],
      );
    } else {
      alert = AlertDialog(
        content: Text(alertMsg),
        actions: [noButton, yesButton],
      );
    }

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showAlertMessageWithTwoBtns(
      {required BuildContext context,
      required String alertTitle,
      required String alertMsg,
      required String positiveText,
      required String negativeText,
      required Function() yesTap,
      Function()? noTap}) {
    // set up the buttons
    Widget noButton = TextButton(
      onPressed: noTap ??
          () {
            Navigator.of(context).pop();
          },
      child: Text(
        textAlign: TextAlign.center,
        negativeText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
        ),
      ),
    );
    Widget yesButton = TextButton(
      child: Text(
        textAlign: TextAlign.center,
        positiveText,
        style: const TextStyle(
          fontSize: 14.0,
          color: red,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        yesTap();
      },
    );
    // set up the AlertDialog
    AlertDialog alert;
    if (alertTitle.isNotEmpty) {
      alert = AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          alertTitle,
          style: const TextStyle(fontSize: 15),
        ),
        content: Text(
          alertMsg,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [noButton, yesButton],
      );
    } else {
      alert = AlertDialog(
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.center,
        content: Text(alertMsg),
        actions: [noButton, yesButton],
      );
    }

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showAlertMessageWithBtn(
      {required BuildContext context,
      required String alertMsg,
      required String positiveText,
      required String negativeText,
      required Function() yesTap,
      Function()? noTap,
      bool? barrierDismissible}) {
    // set up the buttons
    Widget noButton = TextButton(
      onPressed: noTap ??
          () {
            Navigator.of(context).pop();
          },
      child: Text(
        negativeText,
        style: const TextStyle(
          color: red,
          fontSize: 16.0,
        ),
      ),
    );
    Widget yesButton = TextButton(
      child: Text(
        positiveText,
        style: const TextStyle(
          fontSize: 16.0,
          color: black,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        yesTap();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(alertMsg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: [yesButton, noButton],
    );
    // show the dialog
    showDialog(
      barrierDismissible: barrierDismissible ?? false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void premiumPopUpService(
      BuildContext context, List<SubscriptionModel> subscriptionModel) {
    Color colors = white;
    String premiumPlanDesign = Assets.premiumPlanPopup3;
    final CarouselController controller = CarouselController();
    final ValueNotifier<int> index = ValueNotifier(0);

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: ResponsiveDesign.horizontal(30, context),
              child: Image.asset(
                premiumPlanDesign,
                height: ResponsiveDesign.height(620, context),
                width: ResponsiveDesign.width(double.infinity, context),
                fit: BoxFit.fill,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: ResponsiveDesign.height(150, context),
                ),
                Text(
                  "Meety Plus, Gold, or Platinum?",
                  style: TextStyle(
                      fontSize: ResponsiveDesign.height(18, context),
                      fontWeight: FontWeight.bold,
                      color: colors,
                      decoration: TextDecoration.none),
                ),
                Text(
                  "Your Passport to Experience Love at Its Best.",
                  style: TextStyle(
                      fontSize: ResponsiveDesign.height(11, context),
                      fontWeight: FontWeight.bold,
                      color: colors,
                      decoration: TextDecoration.none),
                ),
                SizedBox(
                  height: ResponsiveDesign.height(15, context),
                ),
                if (subscriptionModel.isNotEmpty) ...[
                  Padding(
                    padding: ResponsiveDesign.horizontal(30, context),
                    child: SizedBox(
                      height: ResponsiveDesign.height(400, context),
                      width: ResponsiveDesign.width(double.infinity, context),
                      child: CarouselSlider.builder(
                        carouselController: controller,
                        options: CarouselOptions(
                            scrollPhysics: const BouncingScrollPhysics(),
                            height: ResponsiveDesign.height(420, context),
                            enableInfiniteScroll: true,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (val, _) {
                              index.value = val;
                            }),
                        itemCount: subscriptionModel.length,
                        itemBuilder:
                            (BuildContext context, int index, int realIndex) {
                          return Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: ResponsiveDesign.width(
                                    double.infinity, context),
                                height: ResponsiveDesign.height(90, context),
                                padding:
                                    ResponsiveDesign.horizontal(15, context),
                                decoration: BoxDecoration(
                                  color: colors,
                                  border: Border.all(width: 2, color: black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (subscriptionModel[index].planImage !=
                                        null) ...[
                                      CachedNetworkImage(
                                        imageUrl: subscriptionModel[index]
                                            .planImage[0],
                                        width: ResponsiveDesign.width(
                                            300, context),
                                        height: ResponsiveDesign.height(
                                            75, context),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveDesign.height(10, context),
                              ),
                              Flexible(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  ConstantList.premiumPlanList2[index],
                                  style: context.textTheme.bodyMedium?.copyWith(
                                      fontSize: ResponsiveDesign.fontSize(
                                          13, context),
                                      color: colors,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveDesign.height(10, context),
                              ),
                              Text(
                                textAlign: TextAlign.start,
                                ConstantList.premiumPlanList[index],
                                style: context.textTheme.bodyMedium?.copyWith(
                                    fontSize:
                                        ResponsiveDesign.fontSize(11, context),
                                    color: colors),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
                SizedBox(
                    width: ResponsiveDesign.width(175, context),
                    height: ResponsiveDesign.height(50, context),
                    child: OutLineBtnX(
                        fontWeight: FontWeight.w400,
                        color: black,
                        fillColor: white,
                        textColor: black,
                        onPressed: () async {
                          Navigator.pop(context);
                          sl<NavigationService>()
                              .navigateTo(RoutePaths.subscriptionScreen,
                                  nextScreen: SubscriptionListScreen(
                                    isToShowPop: subscriptionModel[index.value],
                                  ));
                        },
                        text: UiString.continueText)),
              ],
            ),
            Positioned(
                top: ResponsiveDesign.height(110, context),
                right: ResponsiveDesign.width(10, context),
                child: SizedBox(
                  height: ResponsiveDesign.height(45, context),
                  width: ResponsiveDesign.width(45, context),
                  child: OutLineBtnX2(
                    elevation: 5,
                    bgColor: white,
                    radius: 10,
                    onPressed: () {
                      sl<NavigationService>().pop();
                    },
                    child: const Align(
                      child: Icon(Icons.close_rounded, color: black, size: 25),
                    ),
                  ),
                ))
          ],
        );
      },
    );
  }

  static void moreMessagePopUpService(BuildContext context) {
    Color colors = white;
    SubscriptionProvider subscription =
        Provider.of<SubscriptionProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              Assets.getMoreMessagePopup,
              height: ResponsiveDesign.height(620, context),
              width: ResponsiveDesign.width(620, context),
            ),
            Column(
              children: [
                SizedBox(
                  height: ResponsiveDesign.height(170, context),
                ),
                SizedBox(
                  width: ResponsiveDesign.width(200, context),
                  height: ResponsiveDesign.height(200, context),
                  child: Image.asset(
                    Assets.getMoreMessage,
                    width: ResponsiveDesign.width(190, context),
                    height: ResponsiveDesign.height(180, context),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(
                  width: ResponsiveDesign.width(double.infinity, context),
                  height: ResponsiveDesign.height(275, context),
                  child: Column(
                    children: [
                      Padding(
                        padding: ResponsiveDesign.horizontal(50, context),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            textAlign: TextAlign.center,
                            Utils.getRandomThings(
                                ConstantList.messageHeadingList),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    ResponsiveDesign.fontSize(15, context),
                                color: colors),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveDesign.height(10, context),
                      ),
                      Padding(
                        padding: ResponsiveDesign.horizontal(60, context),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            textAlign: TextAlign.center,
                            Utils.getRandomThings(
                                ConstantList.getMoreMessageList),
                            style: TextStyle(
                              color: colors,
                              fontSize: ResponsiveDesign.fontSize(13, context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveDesign.height(30, context),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    width: ResponsiveDesign.width(175, context),
                    height: ResponsiveDesign.height(50, context),
                    child: OutLineBtnX(
                      fontWeight: FontWeight.w400,
                      color: black,
                      radius: 15,
                      fillColor: white,
                      onPressed: () async {
                        EasyLoading.show(status: 'loading...');

                        Future.delayed(const Duration(milliseconds: 1000), () {
                          Utils.CheckSubscriptionScreen(
                              context,
                              subscription.isIHaveSubscription == true
                                  ? subscription.subscriptionsOnlyAddOns.first
                                      .priceInfo!.last.planPriceId
                                  : subscription.subscriptionsOnlyAddOns.first
                                      .priceInfo!.first.planPriceId,
                              subscription.subscriptionsOnlyAddOns.first.planId,
                              false,
                              true);
                        });
                      },
                      text: "",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          subscription.isIHaveSubscription == true
                              ? Text(
                                  "₹ ${subscription.subscriptionsOnlyAddOns.first.priceInfo!.last.totalPlanPrice} |",
                                  style: TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveDesign.fontSize(
                                          15, context)),
                                )
                              : Text(
                                  "₹ ${subscription.subscriptionsOnlyAddOns.first.priceInfo!.first.totalPlanPrice} |",
                                  style: TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveDesign.fontSize(
                                          15, context)),
                                ),
                          Text(
                            "Buy Now",
                            style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveDesign.fontSize(
                                15,
                                context,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            Positioned(
                top: ResponsiveDesign.height(110, context),
                right: ResponsiveDesign.width(20, context),
                child: SizedBox(
                  height: ResponsiveDesign.height(45, context),
                  width: ResponsiveDesign.width(45, context),
                  child: OutLineBtnX2(
                    elevation: 5,
                    bgColor: white,
                    radius: 10,
                    onPressed: () {
                      sl<NavigationService>().pop();
                    },
                    child: const Align(
                      child: Icon(Icons.close_rounded, color: black, size: 25),
                    ),
                  ),
                ))
          ],
        );
      },
    );
  }

  static void moreVisitorPopUpService(BuildContext context) {
    Color colors = black;
    SubscriptionProvider subscription =
        Provider.of<SubscriptionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              Assets.getMoreMessagePopup2,
              height: ResponsiveDesign.height(620, context),
              width: ResponsiveDesign.width(620, context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: ResponsiveDesign.height(170, context),
                ),
                Image.asset(
                  Assets.viewVisitor,
                  width: ResponsiveDesign.width(190, context),
                  height: ResponsiveDesign.height(180, context),
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  width: ResponsiveDesign.width(double.infinity, context),
                  height: ResponsiveDesign.height(275, context),
                  child: Column(
                    children: [
                      Padding(
                        padding: ResponsiveDesign.horizontal(50, context),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            textAlign: TextAlign.center,
                            Utils.getRandomThings(
                                ConstantList.visitorHeadingList),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    ResponsiveDesign.fontSize(15, context),
                                color: colors),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveDesign.height(10, context),
                      ),
                      Padding(
                        padding: ResponsiveDesign.horizontal(60, context),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            textAlign: TextAlign.center,
                            Utils.getRandomThings(
                                ConstantList.getMoreVisitorList),
                            style: TextStyle(
                              color: colors,
                              fontSize: ResponsiveDesign.fontSize(13, context),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveDesign.height(30, context),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    width: ResponsiveDesign.width(175, context),
                    height: ResponsiveDesign.height(50, context),
                    child: OutLineBtnX(
                      fontWeight: FontWeight.w400,
                      color: black,
                      fillColor: white,
                      radius: 15,
                      textColor: white,
                      onPressed: () async {
                        EasyLoading.show(status: 'loading...');

                        Future.delayed(const Duration(milliseconds: 1000), () {
                          Utils.CheckSubscriptionScreen(
                              context,
                              subscription.isIHaveSubscription == true
                                  ? subscription.subscriptionsOnlyAddOns.first
                                      .priceInfo!.last.planPriceId
                                  : subscription.subscriptionsOnlyAddOns.first
                                      .priceInfo!.first.planPriceId,
                              subscription.subscriptionsOnlyAddOns.first.planId,
                              false,
                              true);
                        });
                      },
                      text: "",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          subscription.isIHaveSubscription == true
                              ? Text(
                                  "₹ ${subscription.subscriptionsOnlyAddOns.last.priceInfo!.last.totalPlanPrice} |",
                                  style: TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveDesign.fontSize(
                                          15, context)),
                                )
                              : Text(
                                  "₹ ${subscription.subscriptionsOnlyAddOns.first.priceInfo!.last.totalPlanPrice} |",
                                  style: TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveDesign.fontSize(
                                          15, context)),
                                ),
                          Text(
                            "Buy Now",
                            style: TextStyle(
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveDesign.fontSize(15, context),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            Positioned(
                top: ResponsiveDesign.height(110, context),
                right: ResponsiveDesign.width(20, context),
                child: SizedBox(
                  height: ResponsiveDesign.height(45, context),
                  width: ResponsiveDesign.width(45, context),
                  child: OutLineBtnX2(
                    elevation: 5,
                    bgColor: white,
                    radius: 10,
                    onPressed: () {
                      sl<NavigationService>().pop();
                    },
                    child: const Align(
                      child: Icon(Icons.close_rounded, color: black, size: 25),
                    ),
                  ),
                ))
          ],
        );
      },
    );
  }

  static void subscriptionPaymentSuccessfully(
    BuildContext context,
    dynamic subscriptionModel,
    List<PriceInfo> list,
    String? s, String planId,
  ) {
    Widget paymentDetails({required String title, required String subtitle}) {
      return Flexible(
        child: Container(
          width: ResponsiveDesign.width(160, context),
          padding: ResponsiveDesign.only(context, top: 10, left: 10),
          decoration: BoxDecoration(
              border: Border.all(color: grey.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodySmall,
              ),
              Text(
                subtitle,
                style: context.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return Material(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: ResponsiveDesign.only(context, top: 20, left: 20),
                child: Container(
                    width: ResponsiveDesign.width(40, context),
                    height: ResponsiveDesign.height(40, context),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: grey.withOpacity(0.4))),
                    child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          sl<NavigationService>().pop();
                        },
                        child: const Icon(Icons.close))),
              ),
              SizedBox(
                height: ResponsiveDesign.height(30, context),
              ),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Image.asset(
                    Assets.receipt,
                    fit: BoxFit.fill,
                    height: ResponsiveDesign.height(663, context),
                  ),
                  Padding(
                    padding: ResponsiveDesign.horizontal(30, context),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: ResponsiveDesign.height(100, context),
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              "Thank You For Your Purchase",
                              style: context.textTheme.titleSmall,
                            ),
                            if (subscriptionModel != null) ...[
                              CacheImage(
                                imageUrl: subscriptionModel[0],
                                height: 35,
                                width: context.width * 0.7,
                                boxFit: BoxFit.contain,
                              ),
                            ] else ...[
                              Text(
                                s?.toString() ?? '',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: red),
                              ),
                            ],
                            const SizedBox(
                              height: 5,
                            ),
                            if (planId.toString() == "1" ||
                               planId.toString() == "2" ||
                               planId.toString() == "3") ...[
                              Padding(
                                padding:
                                    ResponsiveDesign.horizontal(10, context),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "Congratulations! Your premium subscription has been successfully renewed. You can now continue to delight in the perks of your premium membership.",
                                  style: TextStyle(
                                      fontSize: ResponsiveDesign.fontSize(
                                          16, context),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                            if (planId.toString() == "5") ...[
                              Padding(
                                padding:
                                    ResponsiveDesign.horizontal(10, context),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "Congratulations! Now you have access to send 50 Direct Messages. You can now continue to delight in the perks of your premium feature.",
                                  style: TextStyle(
                                      fontSize: ResponsiveDesign.fontSize(
                                          16, context),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                            if (planId.toString() == "4") ...[
                              Padding(
                                padding:
                                    ResponsiveDesign.horizontal(10, context),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "Congratulations! Now you have access to See Last 7 Days Visitors. You can now continue to delight in the perks of your premium feature.",
                                  style: TextStyle(
                                      fontSize: ResponsiveDesign.fontSize(
                                          16, context),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(
                              indent: 10,
                              endIndent: 10,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Purchase Details:",
                              style: TextStyle(
                                  fontSize:
                                      ResponsiveDesign.fontSize(16, context),
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: ResponsiveDesign.height(20, context),
                            ),
                            Padding(
                              padding: ResponsiveDesign.horizontal(10, context),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  paymentDetails(
                                      title: 'Invoice Number',
                                      subtitle: planId.toString()),
                                  SizedBox(
                                    width: ResponsiveDesign.width(5, context),
                                  ),
                                  paymentDetails(
                                      title: 'Amount',
                                      subtitle:
                                          '₹ ${list.first.totalPlanPrice}/m')
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveDesign.height(15, context),
                            ),
                            Container(
                              width: double.infinity,
                              height: ResponsiveDesign.height(70, context),
                              margin: ResponsiveDesign.only(context,
                                  left: 17, right: 17),
                              padding: ResponsiveDesign.only(context,
                                  top: 10, left: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: grey.withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (planId.toString() ==
                                      '4') ...[
                                    Text(
                                      'Description',
                                      style: context.textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Access To See Last 7 Days Visitors',
                                      style: context.textTheme.titleSmall,
                                    ),
                                  ],
                                  if (planId.toString() ==
                                      '5') ...[
                                    Text(
                                      'Description',
                                      style: context.textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Access To Send 50 Direct Messages',
                                      style: context.textTheme.titleSmall,
                                    ),
                                  ] else ...[
                                    Text(
                                      'Plan Name',
                                      style: context.textTheme.bodySmall,
                                    ),
                                    Text(
                                      s!,
                                      style: context.textTheme.titleSmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveDesign.height(15, context),
                            ),
                            Padding(
                              padding: ResponsiveDesign.only(context, left: 13),
                              child: Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: "Your Plan will Expire ",
                                    style: TextStyle(
                                        color: black,
                                        fontSize: ResponsiveDesign.fontSize(
                                            15, context),
                                        fontWeight: FontWeight.w500)),
                                TextSpan(
                                    text: sl<SharedPrefsManager>()
                                                .getUserDataInfo()
                                                ?.pastSubscription
                                                ?.expiryDate !=
                                            null
                                        ? "After ${Utils.calculateDaysRemaining() != 1 ? '${Utils.calculateDaysRemaining()} Days.' : 'Day.'}"
                                        : '',
                                    style: TextStyle(
                                        color: black,
                                        fontSize: ResponsiveDesign.fontSize(
                                            15, context),
                                        fontWeight: FontWeight.bold))
                              ])),
                            ),
                            TextBtnX(
                                onPressed: () async {
                                  String url =
                                      'https://pay.stripe.com/invoice/acct_1MhmEuSDLKc8inuY/test_YWNjdF8xTWhtRXVTRExLYzhpbnVZLF9QV3hRTndXREticXE5dUE4UUxyZDBudlRlZHNlck9sLDk4MDIzNzE00200Dgh8OC3T/pdf?s=ap';
                                  await downloadAndOpenPdf(url);
                                },
                                text: 'Download Receipt'),
                          ],
                        ),
                        Positioned(
                            top: -8.5,
                            child: Image.asset(
                              width: ResponsiveDesign.width(100, context),
                              height: ResponsiveDesign.height(100, context),
                              Assets.paymentSuccess,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveDesign.height(72, context),
              ),
              Expanded(
                child: Padding(
                  padding: ResponsiveDesign.horizontal(20, context),
                  child: SizedBox(
                    height: ResponsiveDesign.height(60, context),
                    child: FillBtnX(
                        radius: 10,
                        onPressed: () async {
                          context.read<LoginUserProvider>().fetchLoginUser();
                          sl<NavigationService>().navigateTo(
                            RoutePaths.home,
                            withPushAndRemoveUntil: true,
                          );
                        },
                        text: "Done"),
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveDesign.height(20, context),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> downloadAndOpenPdf(String url) async {
    try {
      // Initialize Dio
      Dio dio = Dio();

      // Send GET request
      Response response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Get external storage directory
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw const FileSystemException(
            'External storage directory is not available');
      }

      // Define file path
      String filePath = '${externalDir.path}/payment_receipt.pdf';

      // Write response bytes to file
      await File(filePath).writeAsBytes(response.data!, flush: true);

      // Open the downloaded PDF file using a file viewer application
      OpenFile.open(filePath);
    } catch (e) {
      // Handle errors
      print('Error downloading and opening PDF: $e');
    }
  }

  static void subscriptionPaymentFailed(
      BuildContext context, SubscriptionModel subscriptionModel) {
    Widget paymentFailedText(
        {required String errorTitle,
        required String errorText,
        required String errorText1}) {
      return Column(
        children: [
          Text(
            textAlign: TextAlign.center,
            errorTitle,
            style: context.textTheme.titleLarge,
          ),
          SizedBox(
            height: ResponsiveDesign.height(15, context),
          ),
          Text(
            errorText,
            style: TextStyle(
                fontSize: ResponsiveDesign.fontSize(14.5, context),
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: ResponsiveDesign.height(10, context),
          ),
          Text(
            errorText1,
            style: TextStyle(
                fontSize: ResponsiveDesign.fontSize(14.5, context),
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          )
        ],
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          color: white,
          child: Material(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: ResponsiveDesign.only(context, top: 20, left: 20),
                  child: Container(
                      width: ResponsiveDesign.width(40, context),
                      height: ResponsiveDesign.height(40, context),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: grey.withOpacity(0.4))),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            sl<NavigationService>().pop();
                          },
                          child: const Icon(Icons.close))),
                ),
                SizedBox(
                  height: ResponsiveDesign.height(30, context),
                ),
                Padding(
                  padding: ResponsiveDesign.horizontal(30, context),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        height: ResponsiveDesign.height(670, context),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: whitesmoke,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade400,
                                  blurRadius: 2,
                                  blurStyle: BlurStyle.normal,
                                  spreadRadius: 1,
                                  offset: const Offset(2, 3))
                            ]),
                        child: Padding(
                          padding: ResponsiveDesign.horizontal(30, context),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height:
                                        ResponsiveDesign.height(70, context),
                                  ),
                                  if (subscriptionModel.planId.toString() == "1" ||
                                      subscriptionModel.planId.toString() ==
                                          "2" ||
                                      subscriptionModel.planId.toString() ==
                                          "3") ...[
                                    paymentFailedText(
                                        errorTitle:
                                            '🚨 Payment failed for Meety Premium Renewal 🚨',
                                        errorText:
                                            "We hope this message finds you well. We're writing to inform you that the recent payment attempt for your Meety Premium subscription renewal was unsuccessful.",
                                        errorText1:
                                            "To ensure uninterrupted access to your premium features and continued enjoyment of the perks that come with it, we kindly ask you to try again to gain access of Meety’s Premium Plan.")
                                  ],
                                  if (subscriptionModel.planId.toString() ==
                                      "4") ...[
                                    paymentFailedText(
                                        errorTitle:
                                            "Payment failed for Last 7 Days Visitors Feature",
                                        errorText:
                                            "We hope this message finds you well. We're reaching out to inform you that the recent payment attempt for your access to the See Last 7 Days Visitors feature was unsuccessful.",
                                        errorText1:
                                            "To ensure uninterrupted access to this premium feature, kindly try with your correct payment details at your earliest convenience.")
                                  ],
                                  if (subscriptionModel.planId.toString() ==
                                      "5") ...[
                                    paymentFailedText(
                                        errorTitle:
                                            "Payment failed for 50 Direct Messages📬",
                                        errorText:
                                            "We hope this message finds you well. We're reaching out to inform you that the recent payment attempt for your access to send 50 Direct Messages was unsuccessful.",
                                        errorText1:
                                            "To ensure you can continue enjoying this premium feature, please update your payment information promptly.")
                                  ],
                                  SizedBox(
                                    height:
                                        ResponsiveDesign.height(25, context),
                                  ),
                                  FillBtnX(
                                      onPressed: () async {
                                        SubscriptionProvider subscription =
                                            Provider.of<SubscriptionProvider>(
                                                context,
                                                listen: false);
                                        Utils.CheckSubscriptionScreen(
                                            context,
                                            subscription.isIHaveSubscription ==
                                                    true
                                                ? subscription
                                                    .subscriptionsOnlyAddOns
                                                    .first
                                                    .priceInfo!
                                                    .last
                                                    .planPriceId
                                                : subscription
                                                    .subscriptionsOnlyAddOns
                                                    .first
                                                    .priceInfo!
                                                    .first
                                                    .planPriceId,
                                            subscription.subscriptionsOnlyAddOns
                                                .first.planId,
                                            false,
                                            true);
                                      },
                                      text: "Try Again"),
                                  SizedBox(
                                    height:
                                        ResponsiveDesign.height(25, context),
                                  ),
                                  if (subscriptionModel.planId.toString() == "1" ||
                                      subscriptionModel.planId.toString() ==
                                          "2" ||
                                      subscriptionModel.planId.toString() ==
                                          "3") ...[
                                    Text(
                                      "Thank you for being a valued member of the Meety community. We appreciate your prompt attention to this matter and look forward to ensuring your premium experience continues without interruption.",
                                      style: TextStyle(
                                          fontSize: ResponsiveDesign.fontSize(
                                              15, context),
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                  if (subscriptionModel.planId.toString() ==
                                      "4") ...[
                                    Text(
                                      "Thank you for being a valued member of the Meety community. We appreciate your prompt attention to this matter and look forward to resolving it swiftly.",
                                      style: TextStyle(
                                          fontSize: ResponsiveDesign.fontSize(
                                              15, context),
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                  if (subscriptionModel.planId.toString() ==
                                      "5") ...[
                                    Text(
                                      "Thank you for being a valued member of the Meety community. We appreciate your prompt attention to this matter and look forward to resolving it swiftly.",
                                      style: TextStyle(
                                          fontSize: ResponsiveDesign.fontSize(
                                              15, context),
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
