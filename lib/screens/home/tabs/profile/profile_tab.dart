import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:tuple/tuple.dart';
import '../../../../config/routes_path.dart';
import '../../../../constants/assets.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/constants_list.dart';
import '../../../../constants/size_config.dart';
import '../../../../constants/ui_strings.dart';
import '../../../../constants/utils.dart';
import '../../../../models/user.dart';
import '../../../../providers/login_user_provider.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../../services/navigation_service.dart';
import '../../../../services/shared_pref_manager.dart';
import '../../../../services/singleton_locator.dart';
import '../../../../widgets/CacheImage.dart';
import '../../../../widgets/core/alerts.dart';
import '../../../../widgets/core/appbars.dart';
import '../../../../widgets/core/buttons.dart';
import '../../../../widgets/utils/extensions.dart';
import '../../../../widgets/utils/material_color.dart';
import '../../../profile/view_profile.dart';
import '../../../subscriptions/subscription_list.dart';
import '../profile/profile/edit_profile.dart';
import '../profile/setting/setting_screen.dart';

import '../profile/setting/upgrade_plan_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  //final int progress = 15;
  User? loginUser;
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    // context.read<LoginUserProvider>().fetchLoginUser(refresh: true);
    if (loginUser != null) {
      log("loginUser: ${loginUser!.toJson().toString()}");
    } else {
      log("loginUser is null");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarX(
          centerTitle: true,
          title: '',
          elevation: 0,
          textStyle: context.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
          height: ResponsiveDesign.screenHeight(context) * 0.04,
          mobileBar: Container(
            height: ResponsiveDesign.height(80, context),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: ResponsiveDesign.only(context, top: 35, left: 15),
                  child: Image.asset(
                    "assets/logos/only-logo.png",
                    height: ResponsiveDesign.height(55, context),
                    width: ResponsiveDesign.height(55, context),
                  ),
                ),
                Padding(
                  padding: ResponsiveDesign.only(context, top: 35, right: 15),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          sl<NavigationService>().navigateTo(
                            RoutePaths.subscriptionScreen,
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: ResponsiveDesign.height(37, context),
                          width: ResponsiveDesign.width(37, context),
                          padding: ResponsiveDesign.only(context,
                              top: 4, bottom: 4, left: 3, right: 3),
                          decoration: const BoxDecoration(
                            color: white,
                            //border: Border.all(color: red),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: ResponsiveDesign.only(context,
                                bottom: 3, right: 2, left: 3, top: 3),
                            child: Image.asset(
                              Assets.subscriptionIcon,
                              //fit: BoxFit.fitWidth,
                              height: ResponsiveDesign.height(30, context),
                              width: ResponsiveDesign.width(30, context),
                              // color: red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          sl<NavigationService>().navigateTo(
                              RoutePaths.settingScreen,
                              nextScreen: const SettingScreen());
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: ResponsiveDesign.height(37, context),
                          width: ResponsiveDesign.width(37, context),
                          padding: ResponsiveDesign.only(context,
                              top: 1, bottom: 1, left: 0, right: 0),
                          decoration: BoxDecoration(
                            color: white,
                            border: Border.all(color: red),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: ResponsiveDesign.only(context,
                                bottom: 0, right: 0, top: 0, left: 0),
                            child: const Icon(
                              Icons.settings,
                              color: red,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: FutureBuilder(
            future: LoginUserProvider().fetchLoginUser(),
            builder: (context, snapshot) {
              return SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                header: WaterDropHeader(
                  waterDropColor: grey1.toMaterialColor.shade300,
                ),
                onRefresh: () {
                  _onRefresh(context);
                },
                child: /*
                    Container(),*/
                    Selector<LoginUserProvider, User?>(
                        selector: (context, provider) => provider.user,
                        builder: (context, loginUserVal, child) {
                          // log("message: ${loginUserVal.toString()}");
                          SubscriptionProvider subscriptionProvider =
                              Provider.of(context, listen: false);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (loginUserVal?.pastSubscription !=
                                        null) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        child: Container(
                                          // height: ResponsiveDesign.screenHeight(context) * 0.07,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: lightBlue
                                                  .toMaterialColor.shade50,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 2,
                                                    blurStyle: BlurStyle.normal,
                                                    spreadRadius: 1,
                                                    offset: const Offset(2, 3))
                                              ]),
                                          child: Padding(
                                            padding: ResponsiveDesign.only(
                                                context,
                                                left: 10,
                                                bottom: 10,
                                                top: 10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (loginUserVal
                                                            ?.pastSubscription
                                                            ?.planImage !=
                                                        null) ...[
                                                      Row(children: [
                                                        CacheImage(
                                                          imageUrl: (loginUserVal
                                                                      ?.pastSubscription
                                                                      ?.planImage
                                                                      ?.isNotEmpty ??
                                                                  false)
                                                              ? loginUserVal
                                                                      ?.pastSubscription
                                                                      ?.planImage![0] ??
                                                                  ''
                                                              : '',
                                                          width:
                                                              ResponsiveDesign
                                                                  .width(150,
                                                                      context),
                                                          boxFit:
                                                              BoxFit.contain,
                                                        ),
                                                        if (Utils
                                                                .calculateDaysRemaining() <=
                                                            0) ...[
                                                          Padding(
                                                            padding:
                                                                ResponsiveDesign
                                                                    .only(
                                                                        context,
                                                                        top: 7),
                                                            child: const Text(
                                                              " is Expired",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          )
                                                        ]
                                                      ]),
                                                    ] else ...[
                                                      Text(
                                                        "${subscriptionProvider.currentSubscription?.planTitle}",
                                                        style: TextStyle(
                                                            fontSize:
                                                                ResponsiveDesign
                                                                    .fontSize(13,
                                                                        context),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: red),
                                                      ),
                                                    ],
                                                    InkWell(
                                                      onTap: () {
                                                        sl<NavigationService>().navigateTo(
                                                            RoutePaths
                                                                .profileTab,
                                                            nextScreen:
                                                                UpgradePlanScreen(
                                                                    subscriptionProvider,
                                                                    loginUserVal));
                                                      },
                                                      child: Text(
                                                          loginUserVal!.email
                                                              .toString()
                                                              .replaceRange(
                                                                  1, 5, "****"),
                                                          style: TextStyle(
                                                              height:
                                                                  ResponsiveDesign
                                                                      .height(1,
                                                                          context),
                                                              fontSize:
                                                                  ResponsiveDesign
                                                                      .fontSize(
                                                                          14,
                                                                          context))),
                                                    ),
                                                    (loginUserVal.phone !=
                                                                null &&
                                                            loginUserVal.phone!
                                                                .isNotEmpty)
                                                        ? InkWell(
                                                            onTap: () {
                                                              sl<NavigationService>().navigateTo(
                                                                  RoutePaths
                                                                      .profileTab,
                                                                  nextScreen: UpgradePlanScreen(
                                                                      subscriptionProvider,
                                                                      loginUserVal));
                                                            },
                                                            child: Text(
                                                                (loginUserVal.phone?.toString().length ??
                                                                            0) >=
                                                                        12
                                                                    ? loginUserVal
                                                                        .phone
                                                                        .toString()
                                                                        .replaceRange(
                                                                            5,
                                                                            12,
                                                                            "*******")
                                                                    : loginUserVal
                                                                        .phone
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    height: 1.5,
                                                                    fontSize: ResponsiveDesign
                                                                        .fontSize(
                                                                            14,
                                                                            context))),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ],
                                                ),
                                                if (loginUserVal.pastSubscription!
                                                                .planId !=
                                                            null &&
                                                        loginUserVal
                                                                .pastSubscription!
                                                                .planId !=
                                                            "3" ||
                                                    Utils.calculateDaysRemaining() <=
                                                        0) ...[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: SizedBox(
                                                        height: ResponsiveDesign
                                                            .height(
                                                                45, context),
                                                        width: ResponsiveDesign
                                                            .width(
                                                                125, context),
                                                        child: FillBtnX(
                                                            elevation: 5,
                                                            color: red,
                                                            radius: 10,
                                                            onPressed:
                                                                () async {
                                                              if (Utils
                                                                      .calculateDaysRemaining() <=
                                                                  0) {
                                                                int index = subscriptionProvider
                                                                    .subscriptionsWithOutMeetyExplorer
                                                                    .indexWhere(
                                                                        (element) {
                                                                  return element
                                                                          .planId
                                                                          .toString() ==
                                                                      loginUserVal
                                                                          .pastSubscription
                                                                          ?.planId;
                                                                });
                                                                if (index !=
                                                                    -1) {
                                                                  Utils.showBottomSheet(
                                                                      subscriptionProvider
                                                                              .subscriptionsWithOutMeetyExplorer[
                                                                          index],
                                                                      context);
                                                                }
                                                              } else {
                                                                sl<NavigationService>().navigateTo(
                                                                    RoutePaths
                                                                        .subscriptionScreen,
                                                                    nextScreen:
                                                                        const SubscriptionListScreen());
                                                              }
                                                            },
                                                            text: Utils.calculateDaysRemaining() <=
                                                                    0
                                                                ? "Renew"
                                                                : "Upgrade")),
                                                  )
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      const SizedBox.shrink()
                                    ],
                                    if (loginUserVal?.isProfileVerifiedStatus ==
                                            "1" &&
                                        loginUserVal
                                                ?.profileVerificationReason ==
                                            "2") ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 4),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: lightBlue
                                                  .toMaterialColor.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 2,
                                                    blurStyle: BlurStyle.normal,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 4))
                                              ]),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, bottom: 10, top: 10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Your profile is not\nverified verification\nagain",
                                                      style: TextStyle(
                                                          fontSize:
                                                              ResponsiveDesign
                                                                  .fontSize(17,
                                                                      context),
                                                          height:
                                                              ResponsiveDesign
                                                                  .height(1.3,
                                                                      context)),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: SizedBox(
                                                    height:
                                                        ResponsiveDesign.height(
                                                            45, context),
                                                    width:
                                                        ResponsiveDesign.width(
                                                            160, context),
                                                    child: FillBtnX(
                                                        textStyle: TextStyle(
                                                            fontSize:
                                                                ResponsiveDesign
                                                                    .fontSize(
                                                                        13,
                                                                        context)),
                                                        elevation: 5,
                                                        radius: 10,
                                                        color: red,
                                                        onPressed: () async {
                                                          Utils.showRejectedDialog(
                                                              context,
                                                              ",You Not Perfectly Verified,Please Verified Again");
                                                        },
                                                        text: UiString
                                                            .verifiedAgainText),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: ResponsiveDesign.height(
                                              115, context),
                                          width: ResponsiveDesign.width(
                                              150, context),
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle),
                                          child: Stack(
                                            //alignment: Alignment.center,
                                            children: [
                                              Selector<LoginUserProvider,
                                                  Tuple2<List, int>>(
                                                selector: (context, provider) =>
                                                    Tuple2(
                                                        provider.user?.images ??
                                                            [],
                                                        provider
                                                            .profileCompletePercentage),
                                                builder:
                                                    (context, values, child) {
                                                  return SfRadialGauge(
                                                      enableLoadingAnimation:
                                                          true,
                                                      axes: <RadialAxis>[
                                                        RadialAxis(
                                                            minimum: 0,
                                                            maximum: 100,
                                                            startAngle: 120,
                                                            endAngle: 60,
                                                            showLabels: false,
                                                            showTicks: false,
                                                            axisLineStyle:
                                                                const AxisLineStyle(
                                                              thickness: 0.08,
                                                              cornerStyle:
                                                                  CornerStyle
                                                                      .bothCurve,
                                                              color: Color(
                                                                  0xedd7d7d7),
                                                              thicknessUnit:
                                                                  GaugeSizeUnit
                                                                      .factor,
                                                            ),
                                                            pointers: <GaugePointer>[
                                                              RangePointer(
                                                                color: red,
                                                                value: values
                                                                    .item2
                                                                    .toDouble(),
                                                                cornerStyle:
                                                                    CornerStyle
                                                                        .bothCurve,
                                                                width: 0.08,
                                                                sizeUnit:
                                                                    GaugeSizeUnit
                                                                        .factor,
                                                              )
                                                            ],
                                                            annotations: <GaugeAnnotation>[
                                                              GaugeAnnotation(
                                                                horizontalAlignment:
                                                                    GaugeAlignment
                                                                        .center,
                                                                positionFactor:
                                                                    0.05,
                                                                angle: 0,
                                                                widget:
                                                                    Container(
                                                                  height: ResponsiveDesign
                                                                      .height(
                                                                          90,
                                                                          context),
                                                                  width: ResponsiveDesign
                                                                      .height(
                                                                          90,
                                                                          context),
                                                                  decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .black,
                                                                      shape: BoxShape
                                                                          .circle),
                                                                  child:
                                                                      InkWell(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100),
                                                                    onTap: () {
                                                                      sl<NavigationService>()
                                                                          .navigateTo(
                                                                        RoutePaths
                                                                            .viewProfile,
                                                                        nextScreen:
                                                                            ProfileScreen(
                                                                          userId:
                                                                              loginUser?.id.toString() ?? '',
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      child:
                                                                          CacheImage(
                                                                        imageUrl: values.item1.isNotEmpty
                                                                            ? values.item1[0]
                                                                            : '',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ])
                                                      ]);
                                                },
                                              ),
                                              Selector<LoginUserProvider,
                                                  Tuple2<List, int>>(
                                                builder:
                                                    (context, value, child) {
                                                  return Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 0.0),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 1),
                                                          decoration: BoxDecoration(
                                                              color: red,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Text(
                                                            '${value.item2}%'
                                                                .toUpperCase(),
                                                            style: context
                                                                .textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                                    color:
                                                                        white,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ),
                                                      ));
                                                },
                                                selector: (context, provider) =>
                                                    Tuple2(
                                                        // provider.user?.images ??
                                                        [],
                                                        provider
                                                            .profileCompletePercentage),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 0,
                                        ),
                                        ...[
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              //mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  // mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      maxLines: 2,
                                                      '${loginUserVal!.fname ?? ''} ${loginUserVal.lname ?? ''}, ${loginUserVal.age ?? ''}',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          fontSize:
                                                              ResponsiveDesign
                                                                  .fontSize(19,
                                                                      context)),
                                                    ),
                                                    if (loginUserVal
                                                                .isProfileVerified ==
                                                            '1' ||
                                                        loginUserVal
                                                                .isProfileVerifiedStatus ==
                                                            '1') ...[
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Image.asset(
                                                        color: red,
                                                        Assets.verified,
                                                        height: ResponsiveDesign
                                                            .height(
                                                                20, context),
                                                        width: ResponsiveDesign
                                                            .height(
                                                                20, context),
                                                      )
                                                    ] else if (loginUserVal
                                                            .isProfileVerifiedStatus ==
                                                        '0') ...[
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(80),
                                                        onTap: () {
                                                          Utils
                                                              .showPendingDialog(
                                                                  context);
                                                        },
                                                        child: Image.asset(
                                                          Assets.verified,
                                                          height:
                                                              ResponsiveDesign
                                                                  .height(20,
                                                                      context),
                                                          width:
                                                              ResponsiveDesign
                                                                  .height(20,
                                                                      context),
                                                        ),
                                                      )
                                                    ],
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      ResponsiveDesign.height(
                                                          3, context),
                                                ),
                                                loginUserVal.hometown != null
                                                    ? Text('${loginUserVal.hometown}',
                                                        style: TextStyle(
                                                            height:
                                                                ResponsiveDesign
                                                                    .height(0.7,
                                                                        context),
                                                            fontSize:
                                                                ResponsiveDesign
                                                                    .fontSize(
                                                                        14,
                                                                        context),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                    : const SizedBox.shrink(),
                                                Text('${loginUserVal.education}',
                                                    style: TextStyle(
                                                        height: ResponsiveDesign
                                                            .height(
                                                                1.3, context),
                                                        fontSize:
                                                            ResponsiveDesign
                                                                .fontSize(14,
                                                                    context),
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                loginUserVal
                                                        .occupation!.isNotEmpty
                                                    ? Text(
                                                        '${loginUserVal.occupation}',
                                                        style: TextStyle(
                                                            height:
                                                                ResponsiveDesign
                                                                    .height(1.2,
                                                                        context),
                                                            fontSize:
                                                                ResponsiveDesign
                                                                    .fontSize(
                                                                        14,
                                                                        context),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    : const SizedBox.shrink(),
                                                SizedBox(
                                                  height:
                                                      ResponsiveDesign.height(
                                                          5, context),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 0),
                                                  width: ResponsiveDesign.width(
                                                      75, context),
                                                  height:
                                                      ResponsiveDesign.height(
                                                          30, context),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: red),
                                                  child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: red,
                                                    elevation: 5,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      onTap: () {
                                                        sl<NavigationService>()
                                                            .navigateTo(
                                                          RoutePaths
                                                              .editProfile,
                                                          nextScreen:
                                                              const EditProfileScreen(),
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons.brush,
                                                            size: 17,
                                                            color: white,
                                                          ),
                                                          const SizedBox(
                                                            width: 3,
                                                          ),
                                                          Text("Edit",
                                                              style: TextStyle(
                                                                  fontSize: ResponsiveDesign
                                                                      .fontSize(
                                                                          17,
                                                                          context),
                                                                  color: white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    loginUserVal.about!.isNotEmpty
                                        ? Padding(
                                            padding: ResponsiveDesign.only(
                                                context,
                                                left: 25),
                                            child: titleDescription(
                                                "About:",
                                                loginUserVal.about ?? '',
                                                context),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  child: Container(
                                width: double.maxFinite,
                                //height: ResponsiveDesign.screenHeight(context) * 0.5,
                                color: white.toMaterialColor.shade600
                                    .withOpacity(0.9),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          AlertService.moreMessagePopUpService(
                                              context);
                                        },
                                        child: Container(
                                          height: ResponsiveDesign.height(
                                              90, context),
                                          width: ResponsiveDesign.width(
                                              375, context),
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              color: white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 2, color: black),
                                              image: const DecorationImage(
                                                  image: AssetImage(
                                                      Assets.moreMessage),
                                                  alignment:
                                                      Alignment.centerLeft)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    ResponsiveDesign.fromLTRB(
                                                        90, 10, 0, 0, context),
                                                child: Text(
                                                  Utils.addonsMessage(
                                                      ConstantList
                                                          .messageHeading),
                                                  style: TextStyle(
                                                      fontSize: ResponsiveDesign
                                                          .fontSize(
                                                              17, context),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    ResponsiveDesign.fromLTRB(
                                                        90, 0, 10, 0, context),
                                                child: Text(
                                                  Utils.addonsMessage(ConstantList
                                                      .messageHeadingCaption),
                                                  style: TextStyle(
                                                      fontSize: ResponsiveDesign
                                                          .fontSize(
                                                              12, context)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (loginUserVal
                                              .pastSubscription?.planId !=
                                          "3") ...[
                                        InkWell(
                                          onTap: () {
                                            AlertService
                                                .moreVisitorPopUpService(
                                                    context);
                                          },
                                          child: Container(
                                            height: ResponsiveDesign.height(
                                                90, context),
                                            width: ResponsiveDesign.width(
                                                375, context),
                                            decoration: BoxDecoration(
                                                color: white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 2, color: black),
                                                image: const DecorationImage(
                                                    image: AssetImage(
                                                        Assets.visitorIcon),
                                                    alignment:
                                                        Alignment.centerLeft)),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      ResponsiveDesign.fromLTRB(
                                                          90,
                                                          10,
                                                          0,
                                                          0,
                                                          context),
                                                  child: Text(
                                                    Utils.addonsMessage(
                                                        ConstantList
                                                            .visitorHeading),
                                                    style: TextStyle(
                                                        fontSize:
                                                            ResponsiveDesign
                                                                .fontSize(17,
                                                                    context),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      ResponsiveDesign.fromLTRB(
                                                          90,
                                                          0,
                                                          10,
                                                          0,
                                                          context),
                                                  child: Text(
                                                    Utils.addonsMessage(ConstantList
                                                        .messageHeadingCaption),
                                                    style: TextStyle(
                                                        fontSize:
                                                            ResponsiveDesign
                                                                .fontSize(12,
                                                                    context)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      SizedBox(
                                        height: ResponsiveDesign.height(
                                            10, context),
                                      ),
                                      if (loginUserVal
                                              .isProfileVerifiedStatus ==
                                          "-1") ...[
                                        Expanded(
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                Utils.showVerifiedNowDialog(
                                                    context);
                                              },
                                              child: Container(
                                                height: ResponsiveDesign.height(
                                                    250, context),
                                                width: ResponsiveDesign.width(
                                                    375, context),
                                                decoration: BoxDecoration(
                                                    image: const DecorationImage(
                                                        image: AssetImage(Assets
                                                            .dummyVerified),
                                                        fit: BoxFit.fill,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                Colors.white12,
                                                                BlendMode
                                                                    .darken)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              'Get Photo Verified on Meety',
                                                              style: context
                                                                  .textTheme
                                                                  .titleSmall
                                                                  ?.copyWith(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        5),
                                                            decoration: BoxDecoration(
                                                                color: red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Text(
                                                              'Verified Now',
                                                              style: context
                                                                  .textTheme
                                                                  .titleSmall
                                                                  ?.copyWith(
                                                                      color:
                                                                          white,
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ],
                                  ),
                                ),
                              )),
                              const SizedBox(
                                height: 50,
                              )
                            ],
                          );
                        }),
              );
            }));
  }

  Widget titleDescription(String title, String desc, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: context.textTheme.bodyLarge),
            const SizedBox(
              height: 1,
            ),
            ReadMoreText(
              desc,
              trimLines: 2,
              preDataTextStyle: const TextStyle(),
              style: context.textTheme.bodyMedium,
              moreStyle:
                  const TextStyle(fontWeight: FontWeight.normal, color: red),
              colorClickableText: red,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Read more',
              trimExpandedText: ' Show less',
            ),
          ],
        ));
  }

  void _onRefresh(BuildContext ctx) async {
    refreshController.resetNoData();
    await context.read<LoginUserProvider>().fetchLoginUser(refresh: true);
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await context
          .read<SubscriptionProvider>()
          .fetchSubscriptions(context.read<LoginUserProvider>());
      refreshController.refreshCompleted();
    });
  }
}
