// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/providers/single_chats_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/screens/profile/view_profile.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/constants_list.dart';
import '../../../../../models/user.dart';
import '../../../../../providers/home_provider.dart';
import '../../../../../services/singleton_locator.dart';
import '../../../../../widgets/CacheImage.dart';
import '../../../../../widgets/core/bottomsheets.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserBasicInfo userRecord;
  User? loginUser;

  ChatAppBar({super.key, required this.userRecord, this.loginUser});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: ResponsiveDesign.width(50, context),
                // color: Colors.red,
                child: const BackBtnX(
                  padding: EdgeInsets.all(2),
                ),
              ),
              SizedBox(
                width: ResponsiveDesign.width(10, context),
              ),
              Container(
                height: ResponsiveDesign.width(50, context),
                width: ResponsiveDesign.width(50, context),
                margin: const EdgeInsets.only(right: 8),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle),
                child: InkWell(
                  borderRadius: BorderRadius.circular(90),
                  onTap: () {
                    sl<NavigationService>().navigateTo(RoutePaths.viewProfile,
                        nextScreen: ProfileScreen(userId: userRecord.id));
                  },
                  child: CacheImage(
                    imageUrl:userRecord.images !=
                        null
                        ? userRecord.images?.first ??
                        ''
                        : '',
                    height: ResponsiveDesign.width(75, context),
                    width: ResponsiveDesign.width(75, context),
                    radius: BorderRadius.circular(90),
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: userInfoWithOnlineStatus(context),
              ),
              moreButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget moreButton(BuildContext context) {
    return Consumer<SingleChatProvider>(
      builder: (context, singleChatProvider, child) {
        return InkWell(
          onTap: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 80, 60, 30, 0),
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
                const PopupMenuItem(
                  value: UiString.viewProfile,
                  child: Text(UiString.viewProfile),
                ),
              ],
              elevation: 8.0,
            ).then((value) {
              if (value == UiString.reportUser) {
                _onReportReviews(singleChatProvider, 'report', context);
              }
              if (value == UiString.blockText) {
                _onReportReviews(singleChatProvider, 'report', context);
              }
              if (value == UiString.viewProfile) {
                sl<NavigationService>().navigateTo(RoutePaths.viewProfile,
                    nextScreen: ProfileScreen(userId: userRecord.id));
              }
            });
          },
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onReportReviews(SingleChatProvider provider, String displayWidget1,
      BuildContext context) {
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
                          userId: provider.chatUser.userRecord?.id.toString() ??
                              '0',
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
      return Column(
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
                '${UiString.blockText} ${provider.chatUser.userRecord!.name ?? ''}',
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
                    '${UiString.blockText} ${provider.chatUser.userRecord!.name ?? ''}',
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
          // Padding(
          //   padding: const EdgeInsets.only(
          //     top: 12.0,
          //   ),
          //   child: ListTile(
          //     dense: true,
          //     leading: const Icon(Icons.group),
          //     title: Text(
          //       '${UiString.blockText} ${provider.user?.fname} ${provider.user?.lname ?? ''}',
          //     ),
          //   ),
          // ),
          const Spacer(),
          FillBtnX(
              onPressed: () async {
                final response = await provider.blockUser(
                  loginUserId: loginUser?.id.toString() ?? '0',
                  userId: provider.chatUser.userRecord?.id.toString() ?? '0',
                );

                response.fold((l) {
                  context.showSnackBar(l);
                }, (r) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);

                  try {
                    context.read<HomeProvider>().updateAllList(
                        isUpdateStatus: false,
                        userBasicInfo: provider.chatUser.userRecord!,
                        isBlock: true,
                      likeListProvider1: context.read<LikeListProvider>(),
                      userChatListProvider1: context.read<UserChatListProvider>(),
                      onlineUserProvider1: context.read<OnlineUserProvider>(),);
                  } on Exception catch (_) {}
                  sl<NavigationService>().pop();
                });

                // await provider
                //     .blockUser(
                //   loginUserId: loginUser?.id.toString() ?? '0',
                //   userId: widget.userId,
                // )
                //     .then((value) {
                //   provider
                //       .fetchUsers(userId: widget.userId, context: context)
                //       .then((value) {
                //     Navigator.pop(context);
                //   });
                //   context.showSnackBar(provider.message);
                //   Navigator.pop(context);
                // });
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

  Widget userInfoWithOnlineStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 2,
        ),
        InkWell(
          onTap: () {
            sl<NavigationService>().navigateTo(RoutePaths.viewProfile,
                nextScreen: ProfileScreen(userId: userRecord.id));
          },
          child: Text(
            userRecord.name ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, height: 0),
          ),
        ),
        Selector<SingleChatProvider, bool>(
          selector: (context, provider) => provider.isOnline,
          builder: (context, value, child) {
            if (value) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Assets.circleIcon,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    UiString.online,
                    style: TextStyle(fontSize: 14, color: grey),
                  )
                ],
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(56);
}
