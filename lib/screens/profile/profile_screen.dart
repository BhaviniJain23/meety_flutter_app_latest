//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:meety_dating_app/config/routes_path.dart';
// import 'package:meety_dating_app/constants/assets.dart';
// import 'package:meety_dating_app/constants/colors.dart';
// import 'package:meety_dating_app/constants/constants.dart';
// import 'package:meety_dating_app/constants/constants_list.dart';
// import 'package:meety_dating_app/constants/enums.dart';
// import 'package:meety_dating_app/constants/ui_strings.dart';
// import 'package:meety_dating_app/data/repository/chat_repo.dart';
// import 'package:meety_dating_app/models/chat_user.dart';
// import 'package:meety_dating_app/models/user.dart';
// import 'package:meety_dating_app/models/user_basic_info.dart';
// import 'package:meety_dating_app/providers/chat_provider.dart';
// import 'package:meety_dating_app/providers/home_provider.dart';
// import 'package:meety_dating_app/providers/login_user_provider.dart';
// import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
// import 'package:meety_dating_app/providers/user_provider.dart';
// import 'package:meety_dating_app/screens/home/tabs/chat/chats.dart';
// import 'package:meety_dating_app/screens/home/tabs/profile/profile/edit_profile.dart';
// import 'package:meety_dating_app/screens/profile/widgets/profile_image_widget.dart';
// import 'package:meety_dating_app/services/dynamic_link_service.dart';
// import 'package:meety_dating_app/services/internet_service.dart';
// import 'package:meety_dating_app/services/navigation_service.dart';
// import 'package:meety_dating_app/services/shared_pref_manager.dart';
// import 'package:meety_dating_app/services/singleton_locator.dart';
// import 'package:meety_dating_app/widgets/core/appbars.dart';
// import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
// import 'package:meety_dating_app/widgets/core/buttons.dart';
// import 'package:meety_dating_app/widgets/core/chips.dart';
// import 'package:meety_dating_app/widgets/empty_widget.dart';
// import 'package:meety_dating_app/widgets/no_internet_connection_screen.dart';
// import 'package:meety_dating_app/widgets/utils/extensions.dart';
// import 'package:meety_dating_app/widgets/utils/material_color.dart';
// import 'package:provider/provider.dart';
// import 'package:readmore/readmore.dart';
// import 'package:swipable_stack/swipable_stack.dart';
//
// class ProfileScreen extends StatefulWidget {
//   final String userId;
//   final Animation? animation;
//   const ProfileScreen({
//     super.key,
//     required this.userId,
//     this.animation,
//   });
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   Timer? _timer;
//   User? loginUser;
//   User? user;
//   bool isFirstTime = true;
//
//   @override
//   void initState() {
//     loginUser = sl<SharedPrefsManager>().getUserDataInfo();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//             create: (BuildContext context) => UserProvider()
//               ..fetchUsers(
//                   userId: widget.userId,context: context)),
//       ],
//       child: Consumer2<UserProvider, LoginUserProvider>(
//         builder: (context, userProvider, loginProvider, child) {
//           // ignore: prefer_typing_uninitialized_variables
//           var provider;
//
//           if (widget.userId == loginUser?.id.toString()) {
//             provider = loginProvider;
//           } else {
//             provider = userProvider;
//           }
//
//           return Scaffold(
//             extendBodyBehindAppBar: true,
//             backgroundColor: white,
//             appBar: AppBarX(
//               title: "",
//               bgColor: Colors.transparent,
//               leading: Container(),
//               mobileBar: Padding(
//                 padding: const EdgeInsets.only(
//                   top: 30,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const BackBtnX(
//                       padding: EdgeInsets.zero,
//                     ),
//                     if (widget.userId != loginUser?.id.toString()) ...[
//                       OutLineBtnX2(
//                         bgColor: white.withOpacity(0.8),
//                         onPressed: () {
//
//                           showMenu(
//                             context: context,
//                             position: RelativeRect.fromLTRB(
//                                 MediaQuery.of(context).size.width - 100,
//                                 100,
//                                 30,
//                                 0),
//                             shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(8.0),
//                                 bottomRight: Radius.circular(8.0),
//                                 topLeft: Radius.circular(8.0),
//                                 topRight: Radius.circular(8.0),
//                               ),
//                             ),
//                             items: [
//                               const PopupMenuItem(
//                                 value: UiString.shareProfile,
//                                 child: Text(UiString.shareProfile),
//                               ),
//                               const PopupMenuItem(
//                                 value: UiString.reportUser,
//                                 child: Text(UiString.reportUser),
//                               ),
//                             ],
//                             elevation: 8.0,
//                           ).then((value) async {
//                             if (value == UiString.shareProfile) {
//                               await sl<DynamicLinkService>()
//                                   .generateDynamicShortLink(widget.userId,
//                                   title:
//                                   "What you think about ${provider.user?.fname} ${provider.user?.lname ?? ''}?");
//                             }
//                             if (value == UiString.reportUser) {
//                               _onReportReviews(provider);
//                             }
//                           });
//                         },
//                         icon: Icons.more_vert,
//                       ),
//                     ]
//                   ],
//                 ),
//               ),
//               height: 60,
//             ),
//             body: Builder(
//               builder: (BuildContext context) {
//                 if (provider.profileState == LoadingState.NoInternet) {
//                   return Center(child: NoInternetScreen(
//                     onTryAgainTap: () async {
//                       context.read<UserProvider>().fetchUsers(
//                           userId: widget.userId,context: context);
//                     },
//                   ));
//                 } else if (provider.profileState == LoadingState.Failure) {
//                   return SizedBox(
//                     height: context.height - 60,
//                     child: const Center(
//                       child: EmptyWidget(),
//                     ),
//                   );
//                 } else if (provider.profileState == LoadingState.Success) {
//                   final userPro = provider.user;
//                   user = provider.user;
//                   if (isFirstTime) {
//                     startTimer();
//                     isFirstTime = false;
//                   }
//                   return Column(
//                     children: [
//                       SizedBox(
//                         height: context.height * 0.58,
//                         child: Stack(
//                           children: [
//                             ProfileImage(
//                                 images: userPro?.images ?? [],
//                                 height: ((context.height * 0.58) - 40)),
//                             Positioned(
//                               bottom: 0,
//                               right: 10,
//                               child: ProfileButtons(
//                                 onMessageTap: () {
//                                   if (userPro != null) {
//                                     openChats(userPro);
//                                   }
//                                 },
//                                 onLikeTap: userPro?.visitedStatus.toString() !=
//                                     Constants.matchStatus
//                                     ? () {
//                                   if (user?.visitedStatus !=
//                                       Constants.visitor ||
//                                       user?.visitedStatus !=
//                                           Constants.noStatus) {
//                                     Future.delayed(
//                                         const Duration(milliseconds: 500),
//                                             () {
//                                           Navigator.pop(context);
//
//                                           context.read<HomeProvider>().controller.next(
//                                               swipeDirection:
//                                               SwipeDirection.right);
//                                         });
//                                   }
//                                 }
//                                     : null,
//                                 onDislikeTap: userPro?.visitedStatus
//                                     .toString() !=
//                                     Constants.matchStatus
//                                     ? () {
//                                   if (user?.visitedStatus !=
//                                       Constants.visitor ||
//                                       user?.visitedStatus !=
//                                           Constants.noStatus) {
//                                     Future.delayed(
//                                         const Duration(milliseconds: 500),
//                                             () {
//                                           Navigator.pop(context);
//
//                                           context.read<HomeProvider>().controller.next(
//                                               swipeDirection:
//                                               SwipeDirection.left);
//                                         });
//                                   }
//                                 }
//                                     : null,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: SingleChildScrollView(
//                           physics: const BouncingScrollPhysics(),
//                           child: Padding(
//                             padding:
//                             const EdgeInsets.symmetric(horizontal: 25.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "${userPro?.fname ?? ''}"
//                                                 " ${userPro?.lname ?? ''}"
//                                                 ", ${userPro?.age.toString() ?? ''}"
//                                                 .toCamelCase(),
//                                             style: context
//                                                 .textTheme.headlineSmall
//                                                 ?.copyWith(fontSize: 20),
//                                           ),
//                                           if (userPro?.education != null &&
//                                               (userPro?.education
//                                                   .toString()
//                                                   .trim()
//                                                   .isNotEmpty ??
//                                                   false)) ...[
//                                             Text(
//                                               "${userPro?.education}",
//                                               style:
//                                               context.textTheme.titleMedium,
//                                             ),
//                                             if (userPro?.school != null &&
//                                                 (userPro?.school
//                                                     .toString()
//                                                     .trim()
//                                                     .isNotEmpty ??
//                                                     false)) ...[
//                                               Text(
//                                                 "${userPro?.school}",
//                                                 style: context
//                                                     .textTheme.titleSmall,
//                                               ),
//                                             ],
//                                           ] else if (userPro?.jobTitle !=
//                                               null &&
//                                               (userPro?.jobTitle
//                                                   .toString()
//                                                   .trim()
//                                                   .isNotEmpty ??
//                                                   false)) ...[
//                                             Text(
//                                               "${userPro?.jobTitle}",
//                                               style:
//                                               context.textTheme.titleMedium,
//                                             ),
//                                             if (userPro?.company != null &&
//                                                 (userPro?.company
//                                                     .toString()
//                                                     .trim()
//                                                     .isNotEmpty ??
//                                                     false)) ...[
//                                               Text(
//                                                 "${userPro?.company}",
//                                                 style: context
//                                                     .textTheme.titleSmall,
//                                               ),
//                                             ],
//                                           ],
//                                         ],
//                                       ),
//                                     ),
//
//                                     if (widget.userId ==
//                                         loginUser?.id.toString()) ...[
//                                       InkWell(
//                                         onTap: () {
//                                           sl<NavigationService>().navigateTo(
//                                             RoutePaths.editProfile,
//                                             nextScreen:
//                                             const EditProfileScreen(),
//                                           );
//                                         },
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             color: 0xffD76D77
//                                                 .toColor
//                                                 .withOpacity(0.1),
//                                             borderRadius:
//                                             BorderRadius.circular(8),
//                                           ),
//                                           padding: const EdgeInsets.all(10),
//                                           child: Text(
//                                             UiString.editProfile,
//                                             style: context.textTheme.labelLarge
//                                                 ?.copyWith(
//                                                 color: 0xffD76D77.toColor,
//                                                 fontSize: 12),
//                                           ),
//                                         ),
//                                       )
//                                     ]
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 if (widget.userId !=
//                                     loginUser?.id.toString()) ...[
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: 0xffD76D77
//                                           .toColor
//                                           .withOpacity(0.1),
//                                       borderRadius:
//                                       BorderRadius.circular(8),
//                                     ),
//                                     padding: const EdgeInsets.all(10),
//                                     child: Text.rich(TextSpan(children: [
//                                       WidgetSpan(
//                                           alignment:
//                                           PlaceholderAlignment.bottom,
//                                           child: Icon(
//                                             Icons.location_on_outlined,
//                                             color: 0xffD76D77.toColor,
//                                             size: 18,
//                                           )),
//                                       TextSpan(
//                                           text: userPro?.calDistance ?? '0',
//                                           style: context
//                                               .textTheme.labelLarge
//                                               ?.copyWith(
//                                               color: 0xffD76D77.toColor,
//                                               fontSize: 12))
//                                     ])),
//                                   )
//                                 ],
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 /// Location Section
//                                 if (userPro?.hometown != null &&
//                                     (userPro?.hometown
//                                         .toString()
//                                         .trim()
//                                         .isNotEmpty ??
//                                         false)) ...[
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Location",
//                                         style: context.textTheme.titleSmall
//                                             ?.copyWith(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             letterSpacing: 0.2),
//                                       ),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       Text(
//                                         "${userPro?.hometown}",
//                                         style: const TextStyle(
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 25,
//                                   ),
//                                 ],
//
//                                 /// About Section
//                                 if (userPro?.about != null &&
//                                     (userPro?.about
//                                         .toString()
//                                         .trim()
//                                         .isNotEmpty ??
//                                         false)) ...[
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "About",
//                                         style: context.textTheme.titleSmall
//                                             ?.copyWith(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             letterSpacing: 0.2),
//                                       ),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       ReadMoreText(
//                                         '${userPro?.about}',
//                                         trimLines: 3,
//                                         preDataTextStyle: const TextStyle(
//                                             fontWeight: FontWeight.w800,
//                                             color: Colors.black),
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.normal,
//                                             color: Colors.black),
//                                         colorClickableText: red,
//                                         trimMode: TrimMode.Line,
//                                         trimCollapsedText: 'Read more',
//                                         trimExpandedText: ' Show less',
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 25,
//                                   ),
//                                 ],
//
//                                 /// Interest Section
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Hobbies & Interests",
//                                       style: context.textTheme.titleSmall
//                                           ?.copyWith(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w600,
//                                           letterSpacing: 0.2),
//                                     ),
//                                     const SizedBox(
//                                       height: 5,
//                                     ),
//                                     interestList(
//                                         interests: userPro!.interest
//                                             .toString()
//                                             .split(","))
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 25,
//                                 ),
//
//                                 /// Basic Info Section
//                                 if ((userPro.zodiac != null &&
//                                     userPro.zodiac.isNotEmpty) ||
//                                     (userPro.habit != null &&
//                                         userPro.habit.isNotEmpty) ||
//                                     (userPro.futurePlan != null &&
//                                         userPro.futurePlan.isNotEmpty) ||
//                                     (userPro.covidVaccine != null &&
//                                         userPro.covidVaccine.isNotEmpty) ||
//                                     (userPro.company != null &&
//                                         userPro.company.isNotEmpty) ||
//                                     (userPro.education != null &&
//                                         userPro.education.isNotEmpty) ||
//                                     (userPro.school != null &&
//                                         userPro.school.isNotEmpty) ||
//                                     (userPro.jobTitle != null &&
//                                         userPro.jobTitle.isNotEmpty) ||
//                                     (userPro.personalityType != null &&
//                                         userPro
//                                             .personalityType.isNotEmpty)) ...[
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Basic Info",
//                                         style: context.textTheme.titleSmall
//                                             ?.copyWith(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             letterSpacing: 0.2),
//                                       ),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       basicInfo(userPro)
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 25,
//                                   ),
//                                 ],
//
//                                 /// Languages Know
//                                 if (userPro.languageKnown != null &&
//                                     userPro.languageKnown
//                                         .toString()
//                                         .trim()
//                                         .isNotEmpty) ...[
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Known Languages",
//                                         style: context.textTheme.titleSmall
//                                             ?.copyWith(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             letterSpacing: 0.2),
//                                       ),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       knownLanguages(
//                                           languages:
//                                           userPro.languageKnown.split(","))
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 25,
//                                   ),
//                                 ],
//
//                                 const SizedBox(
//                                   height: 35,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return SizedBox(
//                     height: context.height - 60,
//                     child: const Center(
//                       child: Loading(),
//                     ),
//                   );
//                 }
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget interestList({required List<String> interests}) {
//     return Wrap(
//       runSpacing: 5,
//       spacing: 5,
//       children: interests
//           .map((e) => ChipWidget(
//           label: Text(
//             e.toString(),
//           ),
//           selected: loginUser?.interest?.contains(e.toString()) ?? false))
//           .toList(),
//     );
//   }
//
//   Widget basicInfo(User user) {
//     return Wrap(
//       children: [
//         if (user.zodiac != null && user.zodiac.toString().isNotEmpty) ...[
//           ChipWidget(
//             label: Wrap(
//               direction: Axis.horizontal,
//               children: [
//                 const Icon(
//                   Icons.add,
//                   size: 20,
//                 ),
//                 const SizedBox(
//                   width: 4,
//                 ),
//                 Text(
//                   user.zodiac ?? '',
//                 ),
//               ],
//             ),
//           ),
//         ],
//         if (user.futurePlan != null &&
//             user.futurePlan.toString().isNotEmpty) ...[
//           ChipWidget(
//             label: Wrap(
//               direction: Axis.horizontal,
//               children: [
//                 const Icon(
//                   Icons.add,
//                   size: 20,
//                 ),
//                 const SizedBox(
//                   width: 4,
//                 ),
//                 Text(
//                   user.futurePlan ?? '',
//                 ),
//               ],
//             ),
//           ),
//         ],
//         if (user.personalityType != null &&
//             user.personalityType.toString().isNotEmpty) ...[
//           ChipWidget(
//             label: Wrap(
//               direction: Axis.horizontal,
//               children: [
//                 const Icon(
//                   Icons.add,
//                   size: 20,
//                 ),
//                 const SizedBox(
//                   width: 4,
//                 ),
//                 Text(
//                   user.personalityType ?? '',
//                 ),
//               ],
//             ),
//           ),
//         ],
//         if (user.covidVaccine != null &&
//             user.covidVaccine.toString().isNotEmpty) ...[
//           ChipWidget(
//             label: Wrap(
//               direction: Axis.horizontal,
//               children: [
//                 const Icon(
//                   Icons.add,
//                   size: 20,
//                 ),
//                 const SizedBox(
//                   width: 4,
//                 ),
//                 Text(
//                   user.covidVaccine ?? '',
//                 ),
//               ],
//             ),
//           ),
//         ],
//         if (user.habit != null && user.habit.toString().isNotEmpty) ...[
//           ChipWidget(
//             label: Wrap(
//               direction: Axis.horizontal,
//               children: [
//                 const Icon(
//                   Icons.add,
//                   size: 20,
//                 ),
//                 const SizedBox(
//                   width: 4,
//                 ),
//                 Text(
//                   "habit".toCamelCase(),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ],
//     );
//   }
//
//   Widget knownLanguages({required List<String> languages}) {
//     return Wrap(
//       children: languages
//           .map((e) => Padding(
//         padding: const EdgeInsets.only(right: 5.0),
//         child: Chip(
//           label: Text(
//             e.toString(),
//           ),
//           labelStyle: const TextStyle(fontSize: 12),
//           labelPadding:
//           const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           shape: RoundedRectangleBorder(
//               side: const BorderSide(color: Color(0xffe8e6ea)),
//               borderRadius: BorderRadius.circular(8)),
//           backgroundColor: white,
//         ),
//       ))
//           .toList(),
//     );
//   }
//
//   void startTimer() {
//     if (user?.visitedStatus == 0 && user != null) {
//       _timer = Timer(const Duration(seconds: 15), () {
//         final homeProvider = sl<HomeProvider>();
//         homeProvider.updateVisitAction(context,Constants.visitor,
//           userBasicInfo:UserBasicInfo.fromUser(user!), );
//         _timer?.cancel();
//       });
//     }
//   }
//
//   Future<void> openChats(User userPro) async {
//     bool checkInternet =
//     await sl<InternetConnectionService>().hasInternetConnection();
//     if (checkInternet) {
//       Map<String, dynamic> apiResponse = await sl<ChatRepository>()
//           .getChatUserFromId(loginUser?.id.toString() ?? '', widget.userId);
//       if (apiResponse[UiString.successText]) {
//         if (apiResponse[UiString.dataText] != null) {
//           ChatUser chatUser = ChatUser(
//               id: userPro.id.toString(),
//               fname: userPro.fname ?? '',
//               lname: userPro.lname,
//               profilePic: userPro.images![0].toString(),
//               unreadCount: '0',
//               channelName: apiResponse[UiString.dataText],
//               fcmToken: userPro.fcmToken ?? '');
//
//           Future.delayed(Duration.zero, () async {
//             final provider = sl<UserChatListProvider>();
//
//             provider.updateUserListFromMessage(user: chatUser);
//
//             provider.visitChannelId = chatUser.channelName;
//
//             await sl<NavigationService>()
//                 .customMaterialPageRoute(ChangeNotifierProvider(
//               create: (BuildContext context) =>
//               ChatProviders(userChatListPro: provider)
//                 ..init(chatUser.id, chatUser.channelName),
//               child: ChatScreen(
//                   chatUser: chatUser, loginUser: loginUser!.id.toString()),
//             ))
//                 .then((value) {
//               provider.visitChannelId = "";
//             });
//           });
//         }
//       } else {}
//     }
//   }
//
//   void _onReportReviews(UserProvider provider) {
//     final ValueNotifier<String> displayWidget = ValueNotifier('report');
//     Widget onReportHeading() {
//       return Padding(
//         padding: const EdgeInsets.only(
//           top: 8.0,
//           right: 8.0,
//         ),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 35,
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.keyboard_backspace),
//                   ),
//                   const Expanded(
//                       child: Center(
//                           child: Text(
//                             UiString.reportText,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ))),
//                   const SizedBox(
//                     width: 30,
//                   )
//                 ],
//               ),
//             ),
//             const Divider()
//           ],
//         ),
//       );
//     }
//
//     Widget onReportBody() {
//       List<String> reportList = ConstantList.reportList;
//
//       return Column(
//         children: [
//           const SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             width: double.maxFinite,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 12.0),
//               child: Text(
//                 UiString.reasonForReportUser,
//                 style:
//                 const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const BouncingScrollPhysics(),
//             itemCount: reportList.length,
//             padding: const EdgeInsets.only(top: 20),
//             itemBuilder: (context, position) {
//               return ListTile(
//                 dense: true,
//                 title: Text(
//                   reportList[position],
//                 ),
//                 onTap: () async {
//                   // Navigator.pop(context);
//                   await provider
//                       .reportUser(
//                       loginUserId: loginUser?.id.toString() ?? '0',
//                       userId: widget.userId,
//                       reason: reportList[position])
//                       .then((value) {
//                     // context.showSnackBar(provider.message);
//                     displayWidget.value = 'thanking';
//                   });
//                 },
//               );
//             },
//           ),
//         ],
//       );
//     }
//
//     Widget onThankingHeading() {
//       return const SizedBox(
//         height: 20,
//       );
//     }
//
//     Widget onThankingBody() {
//       return Column(
//         children: [
//           SizedBox(
//             height: 50,
//             width: double.maxFinite,
//             child: Image.asset(Assets.successImg),
//           ),
//           SizedBox(
//             width: double.maxFinite,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 5.0, left: 12.0),
//               child: Text(
//                 UiString.thanksForReporting,
//                 style:
//                 const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: double.maxFinite,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 12.0, left: 12.0),
//               child: Text(
//                 UiString.thanksForReportingCaption,
//                 style: const TextStyle(fontSize: 12, color: grey),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//               top: 12.0,
//             ),
//             child: ListTile(
//               dense: true,
//               title: Text(
//                 '${UiString.blockText} ${provider.user?.fname} ${provider.user?.lname ?? ''}',
//                 style: const TextStyle(color: Colors.red),
//               ),
//               onTap: () async {
//                 displayWidget.value = 'block';
//               },
//             ),
//           ),
//           const Spacer(),
//           FillBtnX(
//               onPressed: () async {
//                 Navigator.pop(context);
//               },
//               text: 'Ok'),
//         ],
//       );
//     }
//
//     Widget onBlockingHeading() {
//       return Padding(
//         padding: const EdgeInsets.only(
//           top: 8.0,
//           right: 8.0,
//         ),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 35,
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.keyboard_backspace),
//                   ),
//                   Expanded(
//                       child: Center(
//                           child: Text(
//                             '${UiString.blockText} ${provider.user?.fname} ${provider.user?.lname ?? ''}',
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ))),
//                   const SizedBox(
//                     width: 30,
//                   )
//                 ],
//               ),
//             ),
//             const Divider()
//           ],
//         ),
//       );
//     }
//
//     Widget onBlockingBody() {
//       return Column(
//         children: [
//           SizedBox(
//             width: double.maxFinite,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 12.0, left: 12.0),
//               child: Text(
//                 UiString.blockCaption,
//                 style: const TextStyle(fontSize: 12, color: grey),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(
//               top: 12.0,
//             ),
//             child: ListTile(
//               dense: true,
//               leading: const Icon(Icons.group),
//               title: Text(
//                 '${UiString.blockText} ${provider.user?.fname} ${provider.user?.lname ?? ''}',
//               ),
//             ),
//           ),
//           const Spacer(),
//           FillBtnX(
//               onPressed: () async {
//                 provider
//                     .blockUser(
//                   loginUserId: loginUser?.id.toString() ?? '0',
//                   userId: widget.userId,
//                 )
//                     .then((value) {
//                   context.showSnackBar(provider.message);
//                 });
//                 Navigator.pop(context);
//
//                 await Provider.of<HomeProvider>(context, listen: false)
//                     .fetchUsers(page: 1);
//               },
//               text: UiString.blockText),
//         ],
//       );
//     }
//
//     BottomSheetService.showBottomSheet(
//       context: context,
//       isDismissible: false,
//       heading: ValueListenableBuilder(
//           valueListenable: displayWidget,
//           builder: (context, value, _) {
//             if (value == 'thanking') {
//               return onThankingHeading();
//             } else if (value == 'block') {
//               return onBlockingHeading();
//             } else {
//               return onReportHeading();
//             }
//           }),
//       builder: (context, state) {
//         return Container(
//           height: context.height * 0.5,
//           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
//           child: ValueListenableBuilder(
//               valueListenable: displayWidget,
//               builder: (context, value, _) {
//                 if (value == 'thanking') {
//                   return onThankingBody();
//                 } else if (value == 'block') {
//                   return onBlockingBody();
//                 } else {
//                   return onReportBody();
//                 }
//               }),
//         );
//       },
//     );
//   }
// }
//
// class ProfileButtons extends StatelessWidget {
//   final VoidCallback? onMessageTap;
//   final VoidCallback? onLikeTap;
//   final VoidCallback? onDislikeTap;
//   const ProfileButtons(
//       {Key? key,
//         required this.onMessageTap,
//         required this.onLikeTap,
//         required this.onDislikeTap})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (onDislikeTap != null) ...[
//           DislikeWidget(
//               height: 50, width: 50, padding: 18, onTap: onDislikeTap!),
//           const SizedBox(
//             width: 10,
//           ),
//         ],
//         if (onMessageTap != null) ...[
//           MessageWidget(
//             height: 60,
//             width: 60,
//             padding: 18,
//             onTap: onMessageTap!,
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//         ],
//         if (onLikeTap != null) ...[
//           LikeWidget(height: 70, width: 70, padding: 18, onTap: onLikeTap!),
//         ]
//       ],
//     );
//   }
// }
//
// class LikeWidget extends StatelessWidget {
//   final double height;
//   final double width;
//   final double padding;
//   final GestureTapCallback onTap;
//
//   const LikeWidget(
//       {Key? key,
//         required this.height,
//         required this.width,
//         required this.padding,
//         required this.onTap})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: white, width: 3),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           width: width,
//           height: height,
//           padding: EdgeInsets.all(padding),
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: red.toMaterialColor.shade200,
//                 blurRadius: 5,
//                 offset: const Offset(0, 5),
//                 // color: Color.fromRGBO(233, 64, 87, 0.2),
//                 // blurRadius: 15,
//                 // offset: Offset(0, 10),
//               )
//             ],
//             color: red,
//             borderRadius: const BorderRadius.all(Radius.elliptical(78, 78)),
//           ),
//           child: Image.asset(
//             Assets.heartIcon,
//             color: white,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class DislikeWidget extends StatelessWidget {
//   final double height;
//   final double width;
//   final double padding;
//   final GestureTapCallback onTap;
//
//   const DislikeWidget(
//       {Key? key,
//         required this.height,
//         required this.width,
//         required this.padding,
//         required this.onTap})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: width,
//         height: height,
//         padding: EdgeInsets.all(padding),
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: black.toMaterialColor.shade50,
//               blurRadius: 5,
//               offset: const Offset(0, 5),
//               // color: Color.fromRGBO(0, 0, 0, 0.12),
//               // blurRadius: 20,
//               // offset: Offset(0, 10),
//             )
//           ],
//           color: white,
//           borderRadius: const BorderRadius.all(Radius.elliptical(78, 78)),
//         ),
//         child: SizedBox(
//           height: 80,
//           width: 80,
//           child: Image.asset(
//             Assets.dislikeIcon,
//             height: 60,
//             width: 60,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MessageWidget extends StatelessWidget {
//   final double height;
//   final double width;
//   final double padding;
//   final GestureTapCallback onTap;
//   const MessageWidget(
//       {Key? key,
//         required this.height,
//         required this.width,
//         required this.padding,
//         required this.onTap})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: height,
//         height: width,
//         padding: EdgeInsets.all(padding),
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: purple.toMaterialColor.shade50,
//               blurRadius: 5,
//               offset: const Offset(0, 5),
//             )
//           ],
//           color: lightPurple.toMaterialColor.shade500,
//           borderRadius: const BorderRadius.all(Radius.elliptical(78, 78)),
//         ),
//         child: SizedBox(
//           height: 80,
//           width: 80,
//           child: Image.asset(
//             Assets.messageIcon,
//             color: 0xff8A2387.toColor,
//           ),
//         ),
//       ),
//     );
//   }
// }