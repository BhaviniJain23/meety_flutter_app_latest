// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/widgets/ChatCardView.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tuple/tuple.dart';

import '../../../../constants/enums.dart';
import '../../../../constants/size_config.dart';
import '../../../../constants/utils.dart';
import '../../../../models/chat_user.dart';
import '../../../../providers/user_chat_list_provider.dart';
import '../../../../services/singleton_locator.dart';
import '../../../../widgets/core/buttons.dart';

class RequestsUserScreen extends StatefulWidget {
  const RequestsUserScreen({super.key});

  @override
  State<RequestsUserScreen> createState() => _RequestsUserScreenState();
}

class _RequestsUserScreenState extends State<RequestsUserScreen> {
  final RefreshController _refreshController = RefreshController();
  final ValueNotifier<bool> isSentListShow = ValueNotifier(false);
  bool isSentVals = true;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (isSentVals) {
          isSentListShow.value = !isSentListShow.value;
          isSentVals = false;
        } else {
          sl<NavigationService>().pop();
        }
        return false;
      },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: ValueListenableBuilder(
                valueListenable: isSentListShow,
                builder: (context, isSentVal, _) {
                  return AppBarX(
                    title: isSentVal ? "Sent Requests" : "Message Requests",
                    elevation: 5,
                    height: 56,
                    leading: BackBtnX(
                      onPressed: () {
                        if (isSentVal) {
                          isSentListShow.value = !isSentListShow.value;
                        } else {
                          sl<NavigationService>().pop();
                        }
                      },
                      padding: const EdgeInsets.all(5),
                    ),
                  );
                }),
          ),
          body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            footer: const ClassicFooter(),
            physics: const BouncingScrollPhysics(),
            onLoading: () {
              _onLoading(context);
            },
            onRefresh: () {
              _onRefresh(context);
            },
            child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ValueListenableBuilder(
                  valueListenable: isSentListShow,
                  builder: (context, isSentVal, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: isSentVal
                          ? UserSentRequestsList()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    isSentListShow.value =
                                        !isSentListShow.value;
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        child: Text(
                                          "Sent Requests",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          children: [
                                            Selector<UserChatListProvider,
                                                String>(
                                              selector: (context, provider) =>
                                                  provider.totalCountForSent,
                                              builder: (context, value, child) {
                                                return Text(
                                                  value,
                                                  style: context
                                                      .textTheme.labelMedium
                                                      ?.copyWith(
                                                          fontSize: 18,
                                                          color: red,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              width: ResponsiveDesign.width(
                                                  15, context),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: grey1.withOpacity(0.2),
                                ),
                                const Flexible(child: UserRequestsList()),
                              ],
                            ),
                    );
                  },
                )),
          )),
    );
  }

  void _onRefresh(BuildContext ctx) async {
    // on refreshing
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      final provider = ctx.read<UserChatListProvider>();
      _refreshController.resetNoData();
      if (isSentListShow.value) {
        await provider.getUserSentList(refresh: true);
      } else {
        await provider.getUserRequestList(refresh: true);
      }
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading(BuildContext ctx) async {
    // on loading chats
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      final provider = ctx.read<UserChatListProvider>();
      if (isSentListShow.value) {
        await provider.getUserSentList();
        // await provider.fetchChats();
        if (provider.sentLoadingState == DataState.Fetched) {
          _refreshController.loadComplete();
        } else if (provider.sentLoadingState == DataState.No_More_Data) {
          _refreshController.loadNoData();
        }
      } else {
        await provider.getUserRequestList();
        // await provider.fetchChats();
        if (provider.requestLoadingState == DataState.Fetched) {
          _refreshController.loadComplete();
        } else if (provider.requestLoadingState == DataState.No_More_Data) {
          _refreshController.loadNoData();
        }
      }
    });
  }
}

class UserRequestsList extends StatelessWidget {
  const UserRequestsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<UserChatListProvider,
        Tuple3<DataState, List<ChatUser1>, String>>(
      selector: (context, provider) => Tuple3(provider.requestLoadingState,
          provider.requestsUser, provider.totalCountForSent),
      builder: (context, value, child) {
        if (value.item2.isNotEmpty) {
          return Padding(
            padding: ResponsiveDesign.only(context, top: 10, bottom: 20),
            child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: value.item2.length,
                itemBuilder: (context, index) {
                  value.item2[index].isBothRead == 0;
                  final requestsUser =
                      value.item2[index].copyWith(totalUnreadMessage: 1);
                  return ChatCardView(user: requestsUser);
                }),
          );
        } else {
          return Padding(
              padding: ResponsiveDesign.only(context, top: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(Assets.noRequestsSent,
                      width: ResponsiveDesign.width(160, context),
                      height: ResponsiveDesign.height(160, context)),
                  SizedBox(
                    height: ResponsiveDesign.height(15, context),
                  ),
                  Text(
                    "No Message Requests",
                    style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(14, context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveDesign.height(5, context),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    "You don't have any message\n requests.",
                    style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(15, context),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ));
        }
      },
    );
  }
}

class UserSentRequestsList extends StatelessWidget {
  const UserSentRequestsList({super.key});

  @override
  Widget build(BuildContext context) {

    final subCaption =
    Utils.getSentRequestsCaption(ConstantList.sentRequestsHeadingCaption);
    final caption = Utils.getSentRequests(ConstantList.sentRequestsHeading);
    return Selector<UserChatListProvider, Tuple2<DataState, List<ChatUser1>>>(
      selector: (context, provider) =>
          Tuple2(provider.sentLoadingState, provider.sentUser),
      builder: (context, value, child) {
        return Container(
          padding: ResponsiveDesign.only(context, top: 20, bottom: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (value.item2.isNotEmpty) ...[
              ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: value.item2.length,
                  itemBuilder: (context, index) {
                    final requestsUser = value.item2[index];
                    return ChatCardView(user: requestsUser);
                  }),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: ResponsiveDesign.height(130, context),
                  ),
                  Lottie.asset(Assets.noSentRequests,
                      width: ResponsiveDesign.width(120, context),
                      height: ResponsiveDesign.height(120, context)),
                  SizedBox(
                    height: ResponsiveDesign.height(15, context),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    caption,
                    style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(14, context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveDesign.height(5, context),
                  ),
                  Padding(
                    padding: ResponsiveDesign.horizontal(30, context),
                    child: Text(
                      textAlign: TextAlign.center,
                      subCaption,
                      style: TextStyle(
                        fontSize: ResponsiveDesign.fontSize(15, context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              )
            ]
          ]),
        );
      },
    );
  }
}
