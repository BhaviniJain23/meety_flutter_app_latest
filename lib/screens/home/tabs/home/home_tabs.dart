// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/setting/setting_screen.dart';
import 'package:meety_dating_app/screens/home/widgets/swipe_cards.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/no_internet_connection_screen.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';

import '../../../../constants/utils.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  User? loginUser;
  ValueNotifier<bool> isInternet = ValueNotifier(true);
  final PageController _transformer = PageController();

  @override
  void initState() {
    super.initState();
    loginUser = sl<SharedPrefsManager>().getUserDataInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isInternet.value =
          await sl<InternetConnectionService>().hasInternetConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(
        centerTitle: true,
        title: '',
        elevation: 5,
        textStyle: context.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
        height: ResponsiveDesign.screenHeight(context) * 0.04,
        mobileBar: Container(
          height: ResponsiveDesign.height(80, context),
          //color: red,
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
                        if (loginUser != null) {
                          showBottomSheetOfDistance();
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: ResponsiveDesign.height(37, context),
                        width: ResponsiveDesign.width(37, context),
                        padding: ResponsiveDesign.only(context,
                            top: 5, bottom: 5, left: 5, right: 5),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: black)),
                        child: Padding(
                          padding: ResponsiveDesign.only(context,
                              bottom: 3, right: 2, left: 3, top: 3),
                          child: Image.asset(
                            Assets.filterIcon,
                            fit: BoxFit.fill,
                            height: ResponsiveDesign.height(30, context),
                            width: ResponsiveDesign.width(30, context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {
                        sl<NavigationService>()
                            .navigateTo(RoutePaths.notification);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: ResponsiveDesign.height(37, context),
                        width: ResponsiveDesign.width(37, context),
                        padding: ResponsiveDesign.only(context,
                            top: 5, bottom: 5, left: 5, right: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: black),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: ResponsiveDesign.only(context,
                              bottom: 3, right: 2, left: 3, top: 3),
                          child: Image.asset(
                            Assets.notificationIcon,
                            fit: BoxFit.fill,
                            height: ResponsiveDesign.height(30, context),
                            width: ResponsiveDesign.height(30, context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: ResponsiveDesign.screenHeight(context) * 0.85,
        color: Colors.white,
        child: ValueListenableBuilder(
            valueListenable: isInternet,
            builder: (context, internetVal, _) {
              return Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  // No internet Code
                  if (!internetVal) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: NoInternetScreen(
                        onTryAgainTap: () async {
                          bool checkInternet =
                              await sl<InternetConnectionService>()
                                  .hasInternetConnection();
                          if (checkInternet) {
                            context.read<HomeProvider>().fetchUsers(
                                  page: 0,
                                );
                          }
                          if (isInternet.value != checkInternet) {
                            isInternet.value = checkInternet;
                            setState(() {});
                          }
                        },
                      ),
                    );
                  } else {
                    if (provider.dataState == DataState.Uninitialized ||
                        provider.dataState == DataState.Initial_Fetching ||
                        provider.dataState == DataState.More_Fetching) {
                      return const Center(
                        child: Loading(),
                      );
                    } else {
                      if (provider.dataState == DataState.Fetched &&
                          provider.users.isNotEmpty) {
                        return PageView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _transformer,
                          scrollDirection: Axis.vertical,
                          // curve: Curves.easeInBack,
                          onPageChanged: (page) {
                            if ((page + 1) == provider.users.length - 2) {
                              provider.loadMoreData(
                                  (provider.users.length / provider.recordSize)
                                      .ceil());
                            }
                          },
                          // transformer: DepthPageTransformer(), // transformers[5],
                          itemCount: provider.users.length,
                          itemBuilder: (context, index) {
                            return CardWidget(
                              userBasicInfo: provider.users[index],
                              index: index,
                              onLike: (isLikeUpdate) {
                                if (isLikeUpdate) {
                                  provider.setCurrentIndex(index + 1);
                                  if (index + 1 < provider.users.length) {
                                    _transformer.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                  } else {
                                    provider.updateDataState(
                                        DataState.No_More_Data);
                                  }
                                }
                              },
                              onDisLike: (isDislikeUpdate) {
                                if (isDislikeUpdate) {
                                  provider.setCurrentIndex(index + 1);
                                  _transformer.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                }
                              },
                              onRewind: (isRewindUpdate) {
                                if (isRewindUpdate) {
                                  provider.setCurrentIndex(index - 1);

                                  _transformer.previousPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                }
                              },
                            );
                          },
                        );
                      }
                      return noMoreDataWidget();
                    }
                  }
                },
              );
            }),
      ),
    );
  }

  Widget noMoreDataWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 100, bottom: 5),
      child: Container(
        height: double.maxFinite,
        margin: const EdgeInsets.only(bottom: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Lottie.asset(Assets.runOfLoader),
              Image.asset(
                Assets.notDataFoundImg,
                height: 200,
              ),

              SizedBox(
                // height: height * 0.05,
                height: ResponsiveDesign.height(10, context),
              ),
              Column(
                children: [
                  Text(
                    UiString.noPeopleAroundYou,
                    style: context.textTheme.bodyMedium!
                        .copyWith(color: 0xff868D95.toColor, fontSize: 16),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    // height: height * 0.05,
                    height: ResponsiveDesign.height(10, context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: FillBtnX(
                        onPressed: () async {
                          sl<NavigationService>().navigateTo(
                              RoutePaths.settingScreen,
                              nextScreen: const SettingScreen());
                        },
                        color: red,
                        text: UiString.discoverSetting),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showBottomSheetOfDistance() {
    final editProvider = context.read<EditUserProvider>();
    String distance = editProvider.loginUser?.distance ??
        '${Constants.defaultMaximumDistance}';
    String age = editProvider.loginUser?.ageRange ?? Constants.defaultAgeRange;
    double tempDistance =
        double.tryParse(distance) ?? Constants.defaultMaximumDistance;
    RangeValues tempAge = RangeValues(
        double.parse(age.split("-").first), double.parse(age.split("-").last));

    BottomSheetService.showBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        UiString.distance,
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$tempDistance ${loginUser?.measure}',
                        style: context.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Slider(activeColor: red,
                  inactiveColor: whitesmoke.toMaterialColor.shade600,
                  value: tempDistance,
                  min: Constants.defaultMaximumDistance,
                  max: int.parse(tempDistance.round().toString()) > 100
                      ? tempDistance
                      : 100,
                  divisions: int.parse(tempDistance.round().toString()) > 100
                      ? int.parse(tempDistance.round().toString())
                      : 100,
                  label: tempDistance.round().toString(),
                  onChanged: (double value) {
                    state(() {
                      tempDistance = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        UiString.ageRange,
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${tempAge.start.round().toInt()}-${tempAge.end.round().toInt()}",
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                RangeSlider(activeColor: red,
                  inactiveColor: whitesmoke.toMaterialColor.shade600,
                  values: tempAge,
                  min: 18,
                  max: 100,
                  labels: RangeLabels(
                    tempAge.start.round().toString(),
                    tempAge.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      tempAge = values;
                    });
                    state(() {});
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                  child: Text(
                    "Only wants to see verified profiles",
                    style: context.textTheme.titleMedium,
                  ),
                ),
                Selector<EditUserProvider, String>(
                  selector: (context, provider) =>
                      provider.loginUser!.showVerifiedProfile.toString(),
                  builder: (context, profileVarifieds, child) {
                    return Card(
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: SwitchListTile(
                        activeColor: red,
                        title: Text(
                          UiString.profileVerified,
                          style: context.textTheme.bodyMedium
                              ?.copyWith(fontSize: 15, color: Colors.black),
                        ),
                        tileColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        value: profileVarifieds == "1" ? true : false,
                        onChanged: (newVal) {
                          final subscriptionPlan = sl<SharedPrefsManager>()
                              .getUserDataInfo()!
                              .pastSubscription;
                          if (subscriptionPlan?.planId == null) {
                            // AlertService.premiumPopUpService(context);
                            Utils.printingAllPremiumInfo(context,
                                isForProfileVerified: true);
                          } else {
                            Provider.of<EditUserProvider>(context,
                                    listen: false)
                                .updateShowProfileVerifiedStatus(
                                    context, newVal);
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Selector<EditUserProvider, String?>(
                  selector: (context, provider) {
                    return provider.loginUser?.isGlobal;
                  },
                  builder: (context, isGlobalVal, child) {
                    return Card(
                        elevation: 5,
                        shadowColor: Colors.grey.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: SwitchListTile(
                          title: Text(
                            UiString.global,
                            style: context.textTheme.bodyMedium
                                ?.copyWith(fontSize: 16),
                          ),
                          tileColor: white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          value: isGlobalVal == '1' ? true : false,
                          onChanged: (newVal) {
                            Provider.of<EditUserProvider>(context,
                                    listen: false)
                                .updateGlobalStatus(
                                    context, newVal ? '1' : '0');
                          },
                        ));
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Flexible(
                          child: SizedBox(
                        height: ResponsiveDesign.height(62, context),
                        child: OutLineBtnX(
                          onPressed: () async {
                            tempDistance = double.tryParse(distance) ??
                                Constants.defaultMaximumDistance;
                            tempAge = RangeValues(
                                int.parse(Constants.defaultAgeRange
                                        .split("-")
                                        .first)
                                    .toDouble(),
                                int.parse(Constants.defaultAgeRange
                                        .split("-")
                                        .last)
                                    .toDouble());
                            state(() {});
                          },
                          radius: 15,
                          color: red,
                          text: UiString.clearText,
                        ),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: FillBtnX(
                        onPressed: () async {
                          final newAgeRange =
                              "${tempAge.start.round().toInt()}-${tempAge.end.round().toInt()}";
                          if (sl<SharedPrefsManager>()
                              .getUserDataInfo()
                              ?.ageRange !=
                              newAgeRange) {
                            await editProvider.updateAgeRange(
                              context,
                              newAgeRange,
                            );
                            print(newAgeRange);
                          }
                          if (sl<SharedPrefsManager>()
                                  .getUserDataInfo()
                                  ?.measure !=
                              tempDistance.toString()) {
                            await editProvider.updateDistance(
                                context, tempDistance,
                                measure: sl<SharedPrefsManager>()
                                    .getUserDataInfo()
                                    ?.measure);
                          }
                          Navigator.pop(context);
                          context.read<HomeProvider>().fetchUsers();},
                        text: UiString.continueText,
                      ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          );
        });
  }

// Future<void> openChats(UserBasicInfo otherUser) async {
//   bool checkInternet =
//       await sl<InternetConnectionService>().hasInternetConnection();
//   if (checkInternet) {
//     Map<String, dynamic> apiResponse = await sl<ChatRepository>()
//         .getChatUserFromId(
//             loginUser?.id.toString() ?? '', otherUser.id.toString());
//     if (apiResponse[UiString.successText]) {
//       if (apiResponse[UiString.dataText] != null) {
//         ChatUser chatUser = ChatUser(
//           id: otherUser.id.toString(),
//           fname: otherUser.name.toString(),
//           lname: '',
//           profilePic: otherUser.images!.first.toString(),
//           unreadCount: '0',
//           channelName: apiResponse[UiString.dataText],
//           fcmToken: otherUser.fcmToken,
//         );
//
//         Future.delayed(Duration.zero, () async {
//           final provider = sl<UserChatListProvider>();
//
//           provider.updateUserListFromMessage(user: chatUser);
//           provider.visitChannelId = chatUser.channelName;
//
//           await sl<NavigationService>()
//               .navigateTo(RoutePaths.chatScreen,
//                   nextScreen: ChangeNotifierProvider(
//                     create: (BuildContext context) =>
//                         ChatProviders(userChatListPro: provider)
//                           ..init(chatUser.id, chatUser.channelName),
//                     child: ChatScreen(
//                         chatUser: chatUser,
//                         loginUser: loginUser?.id.toString() ?? ''),
//                   ))
//               .then((value) {
//             provider.visitChannelId = "";
//           });
//         });
//       }
//     } else {}
//   }
// }
}
