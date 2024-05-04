//
// // ignore_for_file: use_build_context_synchronously
//
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:meety_dating_app/config/routes_path.dart';
// import 'package:meety_dating_app/constants/assets.dart';
// import 'package:meety_dating_app/constants/colors.dart';
// import 'package:meety_dating_app/constants/constants.dart';
// import 'package:meety_dating_app/constants/enums.dart';
// import 'package:meety_dating_app/constants/size_config.dart';
// import 'package:meety_dating_app/constants/ui_strings.dart';
// import 'package:meety_dating_app/data/repository/chat_repo.dart';
// import 'package:meety_dating_app/models/chat_user.dart';
// import 'package:meety_dating_app/models/user.dart';
// import 'package:meety_dating_app/models/user_basic_info.dart';
// import 'package:meety_dating_app/providers/chat_provider.dart';
// import 'package:meety_dating_app/providers/home_provider.dart';
// import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
// import 'package:meety_dating_app/screens/home/tabs/chat/chats.dart';
// import 'package:meety_dating_app/screens/home/tabs/profile/setting/setting_screen.dart';
// import 'package:meety_dating_app/screens/home/widgets/swipe_card.dart';
// import 'package:meety_dating_app/services/internet_service.dart';
// import 'package:meety_dating_app/services/navigation_service.dart';
// import 'package:meety_dating_app/services/shared_pref_manager.dart';
// import 'package:meety_dating_app/services/singleton_locator.dart';
// import 'package:meety_dating_app/widgets/core/alerts.dart';
// import 'package:meety_dating_app/widgets/core/buttons.dart';
// import 'package:meety_dating_app/widgets/empty_widget.dart';
// import 'package:meety_dating_app/widgets/no_internet_connection_screen.dart';
// import 'package:meety_dating_app/widgets/utils/extensions.dart';
// import 'package:meety_dating_app/widgets/utils/material_color.dart';
// import 'package:provider/provider.dart';
// import 'package:swipable_stack/swipable_stack.dart';
//
// import '../../widgets/card_label.dart';
//
// class HomeTab extends StatefulWidget {
//   const HomeTab({Key? key}) : super(key: key);
//
//   @override
//   State<HomeTab> createState() => _HomeTabState();
// }
//
// class _HomeTabState extends State<HomeTab> {
//   User? loginUser;
//   bool isInternet = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loginUser = sl<SharedPrefsManager>().getUserDataInfo();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       isInternet =
//       await sl<InternetConnectionService>().hasInternetConnection();
//       context.read<HomeProvider>().setController(SwipableStackController());
//
//     });
//   }
//
//   @override
//   void dispose() {
//     context.read<HomeProvider>().disposeController();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Consumer<HomeProvider>(
//       builder: (context, provider, child) {
//         return Container(
//
//           height: ResponsiveDesign.screenHeight(context)*0.85,
//           color: Colors.white,
//           child: Padding(
//             padding:ResponsiveDesign.only(context,
//                 top: 15,
//                 left: 15, right: 15,
//                 bottom: 72),
//             child: Builder(
//               builder: (context) {
//                 if (isInternet) {
//                   if (provider.dataState == DataState.Uninitialized ||
//                       provider.dataState == DataState.Initial_Fetching ||
//                       provider.dataState == DataState.More_Fetching) {
//                     return const Center(
//                       child: Loading(),
//                     );
//                   } else {
//                     final bottomRow = BottomButtonRow(
//                         onSwipe: (direction) async {
//                           if (direction == SwipeDirection.right) {
//                             await context.read<HomeProvider>().updateVisitAction(
//                                 context, Constants.liked,
//                                 isDirectionUpdate: true);
//                           } else if (direction == SwipeDirection.left) {
//                             await context.read<HomeProvider>().updateVisitAction(
//                                 context, Constants.disliked,
//                                 isDirectionUpdate: true);
//                           }
//                         },
//                         onRewindTap: () async {
//                           await context
//                               .read<HomeProvider>()
//                               .updateVisitAction(
//                               context, Constants.rewindStatus,
//                               isDirectionUpdate: false);
//                         },
//                         canRewind: provider.controller.canRewind,
//                         onMessageTap: () {
//                           final temp =
//                           provider.users[provider.controller.currentIndex];
//                           openChats(temp);
//                         });
//                     if (provider.dataState == DataState.Fetched &&
//                         provider.users.isNotEmpty) {
//                       return Container(
//                         padding: const EdgeInsets.only(top: 5, bottom: 5),
//                         child: Stack(
//                           children: [
//                             Positioned.fill(
//                               child: SwipableStack(
//                                 detectableSwipeDirections: const {
//                                   SwipeDirection.right,
//                                   SwipeDirection.left,
//                                 },
//                                 swipeAssistDuration: const Duration(seconds: 1),
//                                 overlayBuilder: (context, properties) {
//                                   var takingVal = properties.swipeProgress;
//                                   if (takingVal < 1.5) {
//                                     takingVal = 0;
//                                   } else {
//                                     takingVal = takingVal * 0.2;
//                                   }
//                                   final opacity = min(takingVal, 1.0);
//                                   final isRight = properties.direction ==
//                                       SwipeDirection.right;
//                                   final isLeft =
//                                       properties.direction == SwipeDirection.left;
//                                   return Stack(
//                                     children: [
//                                       Opacity(
//                                         opacity: isRight ? opacity : 0,
//                                         child: CardLabel.right(),
//                                       ),
//                                       Opacity(
//                                         opacity: isLeft ? opacity : 0,
//                                         child: CardLabel.left(),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                                 viewFraction: 0,
//                                 controller: provider.controller,
//                                 onWillMoveNext: (index,direction){
//
//                                   final User? user = sl<SharedPrefsManager>().getUserDataInfo();
//                                   final getRemainingValue = user?.getRemainingValue ?? GetRemainingValue();
//                                   if(direction == SwipeDirection.left){
//                                     final remainingDisLikeVal = (getRemainingValue.remainingDisLikes ?? 0);
//
//                                     if(remainingDisLikeVal <= 0){
//                                       AlertService.showAlertMessage(context,
//                                           msg:
//                                           "Please Take Subscription to like Users");
//                                     }
//                                     return remainingDisLikeVal > 0;
//                                   }
//                                   else if(direction == SwipeDirection.right){
//                                     final remainingLikeVal = (getRemainingValue.remainingLikes ?? 0);
//
//                                     if(remainingLikeVal <= 0){
//                                       AlertService.showAlertMessage(context,
//                                           msg:
//                                           "Please Take Subscription to like Users");
//                                     }
//                                     return remainingLikeVal > 0;
//                                   }
//                                   return true;
//                                 },
//                                 onSwipeCompleted: (index, direction) async {
//                                   final temp = provider.users[index];
//
//                                   if (direction == SwipeDirection.left) {
//
//                                     await context
//                                         .read<HomeProvider>()
//                                         .updateVisitAction(
//                                       context, Constants.disliked,
//                                       userBasicInfo: temp,
//                                       isDirectionUpdate: false,);
//                                   } else if (direction == SwipeDirection.right) {
//
//                                     await context
//                                         .read<HomeProvider>()
//                                         .updateVisitAction(
//                                       context, Constants.liked,
//                                       userBasicInfo: temp,
//                                       isDirectionUpdate: false,);
//                                   }
//                                   if (index == provider.users.length - 2) {
//                                     bool checkInternet =
//                                     await sl<InternetConnectionService>()
//                                         .hasInternetConnection();
//                                     if (checkInternet) {
//                                       context.read<HomeProvider>().fetchUsers(
//                                           userIds: provider.users
//                                               .sublist(index + 1,
//                                               provider.users.length)
//                                               .map((e) => e.id.toString())
//                                               .toList()
//                                               .join(","));
//                                     }
//
//                                     if (isInternet != checkInternet) {
//                                       isInternet = checkInternet;
//                                       setState(() {});
//                                     }
//                                   }
//
//                                   if (index + 1 == (provider.users.length)) {
//                                     provider.controller.currentIndex =
//                                         provider.controller.currentIndex - 1;
//                                     context.read<HomeProvider>().dataState =
//                                         DataState.No_More_Data;
//                                   }
//                                 },
//                                 stackClipBehaviour: Clip.none,
//                                 // allowVerticalSwipe: false,
//                                 horizontalSwipeThreshold: 0.2,
//                                 verticalSwipeThreshold: 0.8,
//                                 itemCount: provider.users.length,
//                                 swipeAnchor: SwipeAnchor.bottom,
//                                 builder: (context, properties) {
//                                   var index = properties.index;
//                                   if (properties.index < 0) {
//                                     index = 0;
//                                   }
//                                   final user = provider.users[index];
//                                   return SwipeCardView(
//                                     onPreviousPageTap: () {
//                                       if (user.imageIndex > 0) {
//                                         user.imageIndex -= 1;
//                                         provider.updateImageIndexById(
//                                             properties.index, user.imageIndex);
//                                       }
//                                     },
//                                     onNextPageTap: () {
//                                       if (user.imageIndex <
//                                           user.images!.length - 1) {
//                                         user.imageIndex += 1;
//                                         provider.updateImageIndexById(
//                                             properties.index, user.imageIndex);
//                                       }
//                                     },
//                                     user: user,
//                                   );
//                                 },
//                               ),
//                             ),
//                             Align(
//                                 alignment: Alignment.bottomCenter,
//                                 child: bottomRow),
//                           ],
//                         ),
//                       );
//                     }
//                     else if (provider.dataState == DataState.No_More_Data) {
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 5, bottom: 5),
//                         child: Stack(
//                           children: [
//                             Positioned.fill(
//                               child: Container(
//                                 color: white,
//                                 child: Column(
//                                   children: [
//                                     Lottie.asset(Assets.runOfLoader),
//                                     Text(
//                                       UiString.noPeopleAroundYou,
//                                       style: context.textTheme.bodyMedium!
//                                           .copyWith(
//                                           color: 0xff868D95.toColor,
//                                           fontSize: 16),
//                                       softWrap: true,
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     SizedBox(
//                                       // height: height * 0.05,
//                                       height: ResponsiveDesign.height(10,context),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 30),
//                                       child: FillBtnX(
//                                           onPressed: () async {
//                                             sl<NavigationService>().navigateTo(
//                                                 RoutePaths.settingScreen,
//                                                 nextScreen:
//                                                 const SettingScreen());
//                                           },
//                                           color: red,
//                                           text: UiString.discoverSetting),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.bottomCenter,
//                               child: bottomRow,
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 5, bottom: 5),
//                       child: Container(
//                         height: double.maxFinite,
//                         margin: const EdgeInsets.only(bottom: 50),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.max,
//                           children: [
//                             // Lottie.asset(Assets.runOfLoader),
//                             Image.asset(
//                               Assets.notDataFoundImg,
//                               height: 200,
//                             ),
//
//                             SizedBox(
//                               // height: height * 0.05,
//                               height: ResponsiveDesign.height(10,context),
//                             ),
//                             Column(
//                               children: [
//                                 Text(
//                                   UiString.noPeopleAroundYou,
//                                   style: context.textTheme.bodyMedium!
//                                       .copyWith(
//                                       color: 0xff868D95.toColor,
//                                       fontSize: 16),
//                                   softWrap: true,
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 SizedBox(
//                                   // height: height * 0.05,
//                                   height: ResponsiveDesign.height(10,context),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 30),
//                                   child: FillBtnX(
//                                       onPressed: () async {
//                                         sl<NavigationService>().navigateTo(
//                                             RoutePaths.settingScreen,
//                                             nextScreen:
//                                             const SettingScreen());
//                                       },
//                                       color: red,
//                                       text: UiString.discoverSetting),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }
//                 }
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 15.0),
//                   child: NoInternetScreen(
//                     onTryAgainTap: () async {
//                       bool checkInternet = await sl<InternetConnectionService>()
//                           .hasInternetConnection();
//                       if (checkInternet) {
//                         context.read<HomeProvider>().fetchUsers(
//                           page: 0,
//                         );
//                       }
//                       if (isInternet != checkInternet) {
//                         isInternet = checkInternet;
//                         setState(() {});
//                       }
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> openChats(UserBasicInfo otherUser) async {
//     bool checkInternet =
//     await sl<InternetConnectionService>().hasInternetConnection();
//     if (checkInternet) {
//       Map<String, dynamic> apiResponse = await sl<ChatRepository>()
//           .getChatUserFromId(
//           loginUser?.id.toString() ?? '', otherUser.id.toString());
//       if (apiResponse[UiString.successText]) {
//         if (apiResponse[UiString.dataText] != null) {
//           ChatUser chatUser = ChatUser(
//             id: otherUser.id.toString(),
//             fname: otherUser.name.toString(),
//             lname: '',
//             profilePic: otherUser.images!.first.toString(),
//             unreadCount: '0',
//             channelName: apiResponse[UiString.dataText],
//             fcmToken: otherUser.fcmToken,
//           );
//
//           Future.delayed(Duration.zero, () async {
//             final provider = sl<UserChatListProvider>();
//
//             provider.updateUserListFromMessage(user: chatUser);
//             provider.visitChannelId = chatUser.channelName;
//
//             await sl<NavigationService>()
//                 .navigateTo(RoutePaths.chatScreen,
//                 nextScreen: ChangeNotifierProvider(
//                   create: (BuildContext context) =>
//                   ChatProviders(userChatListPro: provider)
//                     ..init(chatUser.id, chatUser.channelName),
//                   child: ChatScreen(
//                       chatUser: chatUser,
//                       loginUser: loginUser?.id.toString() ?? ''),
//                 ))
//                 .then((value) {
//               provider.visitChannelId = "";
//             });
//           });
//         }
//       } else {}
//     }
//   }
// }
