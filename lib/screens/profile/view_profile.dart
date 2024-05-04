import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/login_user_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/providers/user_provider.dart';
import 'package:meety_dating_app/screens/profile/widgets/bottom_buttons.dart';
import 'package:meety_dating_app/services/dynamic_link_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ValueNotifier<int> currentPage = ValueNotifier(0);
  final ValueNotifier<bool> viewProfileShow = ValueNotifier(false);
  final RefreshController _refreshController = RefreshController();

  BuildContext? dialogContext;
  User? loginUser;
  Timer? _timer;
  bool isFirstTime = true;

  @override
  void initState() {
    loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<LoginUserProvider>().fetchLoginUser();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onRefresh(BuildContext ctx) async {
    // on refreshing
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      final provider = ctx.read<LoginUserProvider>();
      _refreshController.resetNoData();

      if (viewProfileShow.value) {
        provider.fetchLoginUser(refresh: true);
      }
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return UserProvider()
          ..fetchUsers(userId: widget.userId, context: context);
      },
      child: Consumer2<UserProvider, LoginUserProvider>(
        builder: (context, userProvider1, loginProvider, child) {
          // ignore: prefer_typing_uninitialized_variables
          var userProvider;

          if (widget.userId == loginUser?.id.toString()) {
            userProvider = loginProvider;
          } else {
            userProvider = userProvider1;
          }
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
            ),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: true,
              body: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: false,
                header: const WaterDropHeader(),
                footer: const ClassicFooter(),
                physics: const BouncingScrollPhysics(),
                onRefresh: () {
                  _onRefresh(context);
                },
                child: Builder(builder: (context) {
                  if (userProvider.user != null) {
                    if ((userProvider is UserProvider) &&
                        userProvider.user?.visitedStatus.toString() == "0") {
                      startTimer(UserBasicInfo.fromUser(userProvider.user!));
                    }

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: PageView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    onPageChanged: (indexVal) {
                                      currentPage.value = indexVal;
                                    },
                                    itemCount:
                                        userProvider.user?.images?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      return ShaderMask(
                                        shaderCallback: (rect) {
                                          return const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.center,
                                            colors: [
                                              Colors.black54,
                                              Colors.transparent
                                            ],
                                          ).createShader(Rect.fromLTRB(
                                              0,
                                              (MediaQuery.of(context)
                                                      .padding
                                                      .top) +
                                                  10,
                                              0,
                                              rect.height + 50));
                                        },
                                        blendMode: BlendMode.darken,
                                        child: ImageWidget(
                                          imageUrl: userProvider
                                                  .user?.images?[index] ??
                                              '',
                                        ),
                                      );
                                    }),
                              ),
                              SizedBox(
                                height: ResponsiveDesign.screenHeight(context) *
                                    0.55,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: ResponsiveDesign.height(
                                            40, context),
                                      ),
                                      nameSection(userProvider.user),
                                      Flexible(
                                        child: SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if ((userProvider.user
                                                          ?.isSexOrientationShow ??
                                                      '1') ==
                                                  '1') ...[
                                                SizedBox(
                                                  height:
                                                      ResponsiveDesign.height(
                                                          10, context),
                                                ),
                                              ],
                                              if ((userProvider.user
                                                              ?.isSexOrientationShow ??
                                                          '1') ==
                                                      '1' ||
                                                  (userProvider.user
                                                              ?.isGenderShow ??
                                                          '1') ==
                                                      '1') ...[
                                                genderSection(userProvider.user)
                                              ],
                                              if ((userProvider.user?.education
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleDescription(
                                                    "Education",
                                                    userProvider
                                                            .user?.education ??
                                                        ''),
                                              ],
                                              if ((userProvider.user?.occupation
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleDescription(
                                                  "Occupation",
                                                  userProvider
                                                          .user?.occupation ??
                                                      '',
                                                )
                                              ],
                                              if ((userProvider.user?.about
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleDescription(
                                                  "About",
                                                  userProvider.user?.about ??
                                                      '',
                                                )
                                              ],
                                              if ((userProvider.user?.lookingFor
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleDescription(
                                                  UiString.matchPreferences,
                                                  userProvider
                                                          .user?.lookingFor ??
                                                      '',
                                                )
                                              ],
                                              if ((userProvider.user?.interest
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleListDescription(
                                                  "Hobbies & Interest",
                                                  userProvider.user?.interest
                                                          ?.split(",") ??
                                                      [],
                                                )
                                              ],
                                              if ((userProvider.user?.futurePlan
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleListDescription(
                                                  "Future Plan",
                                                  userProvider.user?.futurePlan
                                                          ?.split(",") ??
                                                      [],
                                                )
                                              ],
                                              if ((userProvider.user?.habit
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleListDescription(
                                                  "Habit",
                                                  userProvider.user?.habit
                                                          ?.split(",") ??
                                                      [],
                                                )
                                              ],
                                              if ((userProvider
                                                      .user
                                                      ?.languageKnown
                                                      ?.isNotEmpty ??
                                                  false)) ...[
                                                titleListDescription(
                                                  "Language Known",
                                                  userProvider
                                                          .user?.languageKnown
                                                          ?.split(",") ??
                                                      [],
                                                )
                                              ],
                                              if ((userProvider.user?.zodiac
                                                          ?.isNotEmpty ??
                                                      false) ||
                                                  (userProvider
                                                          .user
                                                          ?.covidVaccine
                                                          ?.isNotEmpty ??
                                                      false) ||
                                                  (userProvider
                                                          .user
                                                          ?.personalityType
                                                          ?.isNotEmpty ??
                                                      false)) ...[
                                                titleListDescription(
                                                  "More Info",
                                                  [
                                                    userProvider.user?.zodiac,
                                                    userProvider
                                                        .user?.covidVaccine,
                                                    userProvider
                                                        .user?.personalityType,
                                                  ],
                                                )
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: ResponsiveDesign.height(
                                            15, context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: (MediaQuery.of(context).padding.top),
                          right: 0,
                          left: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  sl<NavigationService>().pop();
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        MediaQuery.of(context).size.width - 80,
                                        60,
                                        30,
                                        0),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8.0),
                                        bottomRight: Radius.circular(8.0),
                                        topLeft: Radius.circular(8.0),
                                        topRight: Radius.circular(8.0),
                                      ),
                                    ),
                                    items: [
                                      const PopupMenuItem(
                                        value: UiString.reportUser,
                                        child: Text(UiString.reportUser),
                                      ),
                                      const PopupMenuItem(
                                        value: UiString.blockText,
                                        child: Text(UiString.blockText),
                                      ),
                                      if (userProvider.user is User &&
                                          (userProvider.user as User)
                                                  .visitedStatus ==
                                              Constants.matchStatus) ...[
                                        const PopupMenuItem(
                                          value: UiString.unMatch,
                                          child: Text(UiString.unMatch),
                                        ),
                                      ]
                                    ],
                                    elevation: 8.0,
                                  ).then((value) {
                                    if (value == UiString.reportUser) {
                                      _onReportReviews(userProvider, 'report');
                                    }
                                    if (value == UiString.blockText) {
                                      _onReportReviews(userProvider, 'block');
                                    }
                                    if (value == UiString.unMatch) {
                                      AlertService.showAlertMessageWithBtn(
                                          context: context,
                                          alertMsg:
                                              "Do you want to unmatch the profile ?",
                                          positiveText: "Unmatch It",
                                          negativeText: "Don't Want",
                                          yesTap: () async {
                                            final homeProvider =
                                                context.read<HomeProvider>();

                                            final v = await homeProvider
                                                .updateVisitAction(
                                              context,
                                              Constants.unmatchStatus,
                                              userBasicInfo:
                                                  UserBasicInfo.fromUser(
                                                      (userProvider
                                                              as UserProvider)
                                                          .user!),
                                            );

                                            if (v) {
                                              sl<NavigationService>().pop();
                                            }
                                          });
                                    }
                                  });
                                },
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (loginUser!.id != null) ...[
                          Positioned(
                              bottom: (ResponsiveDesign.screenHeight(context) *
                                      0.55) -
                                  35,
                              child: Container(
                                width: ResponsiveDesign.screenWidth(context),
                                alignment: Alignment.center,
                                child: ButtonsRow(
                                  userBasicInfo: UserBasicInfo.fromUser(
                                      userProvider.user!),
                                  isLikeShow:
                                      userProvider.user?.visitedStatus !=
                                              Constants.liked ||
                                          userProvider.user?.visitedStatus !=
                                              Constants.matchStatus,
                                  isDisLikeShow:
                                      userProvider.user?.visitedStatus !=
                                              Constants.disliked ||
                                          userProvider.user?.visitedStatus !=
                                              Constants.matchStatus,
                                  onLike: (isLikeUpdate) {
                                    if (isLikeUpdate) {
                                      sl<NavigationService>()
                                          .pop(result: Constants.liked);
                                    }
                                  },
                                  onDisLike: (isDisLikeUpdate) {
                                    if (isDisLikeUpdate) {
                                      sl<NavigationService>()
                                          .pop(result: Constants.disliked);
                                    }
                                  },
                                ),
                              ))
                        ] else ...[
                          Positioned(
                              bottom: (ResponsiveDesign.screenHeight(context) *
                                      0.55) -
                                  35,
                              child: Container(
                                width: ResponsiveDesign.screenWidth(context),
                                alignment: Alignment.center,
                                child: ButtonsRow(
                                  userBasicInfo: UserBasicInfo.fromUser(
                                      userProvider.user!),
                                  isLikeShow:
                                      userProvider.user?.visitedStatus !=
                                              Constants.liked ||
                                          userProvider.user?.visitedStatus !=
                                              Constants.matchStatus,
                                  isDisLikeShow:
                                      userProvider.user?.visitedStatus !=
                                              Constants.disliked ||
                                          userProvider.user?.visitedStatus !=
                                              Constants.matchStatus,
                                  onLike: (isLikeUpdate) {
                                    if (isLikeUpdate) {
                                      sl<NavigationService>()
                                          .pop(result: Constants.liked);
                                    }
                                  },
                                  onDisLike: (isDisLikeUpdate) {
                                    if (isDisLikeUpdate) {
                                      sl<NavigationService>()
                                          .pop(result: Constants.disliked);
                                    }
                                  },
                                ),
                              ))
                        ]
                      ],
                    );
                  }

                  return const Center(child: Loading());
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  void startTimer(UserBasicInfo userBasicInfo) {
    _timer = Timer(const Duration(seconds: 15), () async {
      await context.read<HomeProvider>().updateVisitAction(
          context, Constants.visitor,
          userBasicInfo: userBasicInfo);

      _timer?.cancel();
    });
  }

  Widget nameSection(User? user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "${user?.fname} ${user?.lname}${user?.age == '0' ? '' : ", ${user?.age}"}",
                    maxLines: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveDesign.fontSize(20, context)),
                  ),
                  if (user?.isProfileVerified == "1" ||
                      user?.isProfileVerifiedStatus == "1") ...[
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      color: red,
                      Assets.verified,
                      height: ResponsiveDesign.height(20, context),
                      width: ResponsiveDesign.height(20, context),
                    )
                  ] else if (user?.isProfileVerifiedStatus == '0') ...[
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(80),
                      onTap: () {
                        Utils.showPendingDialog(context);
                      },
                      child: Image.asset(
                        Assets.verified,
                        height: ResponsiveDesign.height(20, context),
                        width: ResponsiveDesign.height(20, context),
                      ),
                    )
                  ],
                ],
              ),
              user!.hometown != null
                  ? Text.rich(
                      TextSpan(children: [
                        const WidgetSpan(
                            child: SizedBox(
                          width: 5,
                        )),
                        TextSpan(
                          text: "🏘 ${user.hometown ?? ' '}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveDesign.fontSize(14, context),
                              color: grey1),
                        ),
                      ]),
                      maxLines: 1,
                    )
                  : const SizedBox.shrink(),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Image.asset(
                      Assets.distanceAway1,
                      width: ResponsiveDesign.width(20, context),
                      height: ResponsiveDesign.height(20, context),
                    ),
                  ),
                  Text(
                    " ${user.calDistance?.split(" ").first}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveDesign.fontSize(14, context),
                        color: grey1),
                  ),
                  Text(
                    "${user.calDistance}".split(" ").last.replaceAll(".", ""),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveDesign.fontSize(14, context),
                        color: grey1),
                  ),
                  Text(
                    " Away",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveDesign.fontSize(14, context),
                        color: grey1),
                  )
                ],
              )
            ],
          ),
        ),
        if ((user.isProfileSharable ?? '') == '1') ...[
          IconButton(
            onPressed: () async {
              Future.delayed(const Duration(milliseconds: 200), () {
                _showLoadingDialog(context, 'Sharing profile...');
              });
              await sl<DynamicLinkService>().generateDynamicShortLink(
                  widget.userId,
                  title:
                      "What you think about ${user.fname} ${user.lname ?? ''}?");
              _dismissLoadingDialog(); // Dismiss the dialog when the sign-in process is done
            },
            icon: const Icon(
              Icons.share_outlined,
              size: 30,
            ),
          )
        ]
      ],
    );
  }

  Widget genderSection(User? user) {
    return Card(
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(5)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (user?.isGenderShow ?? '1') == '1' ? (user?.gender ?? '') : '',
              style: TextStyle(
                  fontSize: ResponsiveDesign.fontSize(14, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(
              width: ResponsiveDesign.width(5, context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: ResponsiveDesign.height(0, context),
                ),
                Text(
                  user?.isSexOrientationShow == '1'
                      ? (user?.sexOrientation?.replaceAll(",", " -") ?? '')
                      : '',
                  style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(14, context),
                      color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget titleDescription(String title, String desc,
      {CrossAxisAlignment? crossAxisAlignment}) {
    return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5, top: 10),
        child: Column(
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveDesign.fontSize(13, context))),
            const SizedBox(
              height: 1,
            ),
            ReadMoreText(
              desc,
              trimLines: 3,
              preDataTextStyle:
                  const TextStyle(fontWeight: FontWeight.w800, color: grey1),
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: grey1,
                  fontSize: ResponsiveDesign.fontSize(15, context)),
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

  Widget titleListDescription(String title, List listVal) {
    return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveDesign.fontSize(13, context))),
            const SizedBox(
              height: 4,
            ),
            Wrap(
                spacing: 10,
                runSpacing: 10,
                children: listVal.map((e) {
                  if (e.toString().isNotEmpty) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.grey, width: 1.5),
                          borderRadius: BorderRadius.circular(5)),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: ResponsiveDesign.only(context,
                            left: 5, right: 5, top: 5, bottom: 5),
                        child: Text(
                          e,
                          style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              fontSize: ResponsiveDesign.fontSize(13, context)),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }).toList()),
          ],
        ));
  }

  Future<void> _showLoadingDialog(BuildContext context, String message) async {
    dialogContext = context; // Store the dialog context
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void _dismissLoadingDialog() {
    if (dialogContext != null) {
      Navigator.of(dialogContext!).pop();
      dialogContext = null; // Reset the dialog context
    }
  }

  void _onReportReviews(UserProvider provider, String displayWidget1) {
    final ValueNotifier<String> displayWidget = ValueNotifier(displayWidget1);
    Widget onReportHeading() {
      return Container(
        padding: ResponsiveDesign.only(context,
            top: 15,
            bottom:
                10) /*const EdgeInsets.only(
          top: 8.0,
          right: 8.0,
        )*/
        ,
        child: Column(
          children: [
            SizedBox(
              height: 35,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.keyboard_backspace),
                  ),
                  Expanded(
                      child: Center(
                          child: Text(
                    UiString.reportText,
                    style: TextStyle(
                        fontSize: ResponsiveDesign.fontSize(18, context),
                        fontWeight: FontWeight.bold),
                  ))),
                  const SizedBox(
                    width: 55,
                  )
                ],
              ),
            ),
            const Divider()
          ],
        ),
      );
    }

    Widget onReportBody() {
      List<String> reportList = ConstantList.reportList;

      return Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: ResponsiveDesign.only(context, left: 12.0),
              child: Text(
                UiString.reasonForReportUser,
                style: TextStyle(
                    fontSize: ResponsiveDesign.fontSize(14, context),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: reportList.length,
            padding: const EdgeInsets.only(top: 20),
            itemBuilder: (context, position) {
              return ListTile(
                dense: true,
                title: Text(
                  reportList[position],
                  style: TextStyle(
                    fontSize: ResponsiveDesign.fontSize(14, context),
                  ),
                ),
                onTap: () async {
                  // Navigator.pop(context);
                  await provider
                      .reportUser(
                          loginUserId: loginUser?.id.toString() ?? '0',
                          userId: widget.userId,
                          reason: reportList[position])
                      .then((value) {
                    // context.showSnackBar(provider.message);
                    displayWidget.value = 'thanking';
                  });
                },
              );
            },
          ),
        ],
      );
    }

    Widget onThankingHeading() {
      return const SizedBox(
        height: 20,
      );
    }

    Widget onThankingBody() {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          sl<NavigationService>().pop();
          return false;
        },
        child: Column(
          children: [
            SizedBox(
              height: 50,
              width: double.maxFinite,
              child: Image.asset(Assets.successImg),
            ),
            SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: ResponsiveDesign.only(context, top: 8.0, left: 12.0),
                child: Text(
                  UiString.thanksForReporting,
                  style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(16, context),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: ResponsiveDesign.only(context, top: 12.0, left: 12.0),
                child: Text(
                  UiString.thanksForReportingCaption,
                  style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(14, context),
                      color: grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: ResponsiveDesign.only(
                context,
                top: 12.0,
              ),
              child: ListTile(
                dense: true,
                title: Text(
                  '${UiString.blockText} ${provider.user?.fname} ${provider.user?.lname ?? ''}',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  displayWidget.value = 'block';
                },
              ),
            ),
            const Spacer(),
            FillBtnX(
                onPressed: () async {
                  Navigator.pop(context);
                  sl<NavigationService>().pop();
                },
                text: 'Ok'),
          ],
        ),
      );
    }

    Widget onBlockingHeading() {
      return Padding(
        padding: ResponsiveDesign.only(context, top: 15, bottom: 10),
        child: Column(
          children: [
            SizedBox(
              height: 35,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.keyboard_backspace),
                  ),
                  Expanded(
                      child: Center(
                          child: Text(
                    '${UiString.blockText} ${provider.user?.fname} ${provider.user?.lname ?? ''}',
                    style: TextStyle(
                        fontSize: ResponsiveDesign.fontSize(18, context),
                        fontWeight: FontWeight.bold),
                  ))),
                  const SizedBox(
                    width: 30,
                  )
                ],
              ),
            ),
            const Divider()
          ],
        ),
      );
    }

    Widget onBlockingBody() {
      return Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: ResponsiveDesign.only(context, top: 12.0, left: 12.0),
              child: Text(
                UiString.blockCaption,
                style: TextStyle(
                    fontSize: ResponsiveDesign.fontSize(14, context),
                    color: grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Spacer(),
          FillBtnX(
              onPressed: () async {
                final response = await provider.blockUser(
                  loginUserId: loginUser?.id.toString() ?? '0',
                  userId: widget.userId,
                );

                response.fold((l) {
                  context.showSnackBar(l);
                }, (r) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);

                  try {
                    context.read<HomeProvider>().updateAllList(
                          isUpdateStatus: false,
                          userBasicInfo: UserBasicInfo.fromUser(provider.user!),
                          isBlock: true,
                          likeListProvider1: context.read<LikeListProvider>(),
                          userChatListProvider1:
                              context.read<UserChatListProvider>(),
                          onlineUserProvider1:
                              context.read<OnlineUserProvider>(),
                        );
                  } on Exception catch (_) {}
                  sl<NavigationService>().pop();
                });
              },
              text: UiString.blockText),
          SizedBox(
            height: ResponsiveDesign.height(10, context),
          ),
        ],
      );
    }

    BottomSheetService.showBottomSheet(
      context: context,
      isDismissible: false,
      heading: ValueListenableBuilder(
          valueListenable: displayWidget,
          builder: (context, value, _) {
            if (value == 'thanking') {
              return onThankingHeading();
            } else if (value == 'block') {
              return onBlockingHeading();
            } else {
              return onReportHeading();
            }
          }),
      builder: (context, state) {
        return Container(
          height: context.height * 0.5,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: ValueListenableBuilder(
              valueListenable: displayWidget,
              builder: (context, value, _) {
                if (value == 'thanking') {
                  return onThankingBody();
                } else if (value == 'block') {
                  return onBlockingBody();
                } else {
                  return onReportBody();
                }
              }),
        );
      },
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final bool showShader;
  final BorderRadius? borderRadius;

  const ImageWidget(
      {super.key,
      required this.imageUrl,
      this.borderRadius,
      this.showShader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
          borderRadius: borderRadius ?? BorderRadius.circular(20)),
      child: CacheImage(
        imageUrl: imageUrl,
        boxFit: BoxFit.contain,
        radius: borderRadius ??
            const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
        showShadow: showShader,
      ),
    );
  }
}
