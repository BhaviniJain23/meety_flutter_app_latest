// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/online_users_screen.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/requests_user_screen.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/widgets/ChatCardView.dart';
import 'package:meety_dating_app/screens/profile/view_profile.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tuple/tuple.dart';

import '../../../../config/routes_path.dart';
import '../../../../constants/size_config.dart';
import '../../../../services/navigation_service.dart';

class UsersChatTab extends StatefulWidget {
  const UsersChatTab({Key? key}) : super(key: key);

  @override
  State<UsersChatTab> createState() => _UsersChatTabState();
}

class _UsersChatTabState extends State<UsersChatTab> {
  final TextEditingController searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserChatListProvider>().fetchChats();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearchIconX(
        centerTitle: true,
        title: '',
        elevation: 0,
        textStyle: context.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
        height: ResponsiveDesign.height(45, context),
        leading: Padding(
          padding: ResponsiveDesign.only(context, left: 20, top: 0),
          child: Image.asset(
            "assets/logos/only-logo.png",
            //fit: BoxFit.fill,
            width: ResponsiveDesign.width(10, context),
            height: ResponsiveDesign.height(10, context),
          ),
        ),
        onSearchQueryChanged: (value) {
          // provider.searchChats(searchVal);
        },
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: const ClassicFooter(),
        onRefresh: () {
          _onRefresh(context);
        },
        onLoading: () {
          _onLoading(context);
        },
        child: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnlineUsersWidget(),
              MatchUsersWidget(),
              UserChatListWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _onRefresh(BuildContext ctx) async {
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      _refreshController.resetNoData();

      // ignore: use_build_context_synchronously
      await context.read<LikeListProvider>().fetchMatches(refresh: true);
      // ignore: use_build_context_synchronously
      await context.read<OnlineUserProvider>().getOnlineUsers(refresh: true);
      // ignore: use_build_context_synchronously
      await context.read<UserChatListProvider>().fetchChats();
      _refreshController.refreshCompleted();
    });
  }

  void _onLoading(BuildContext ctx) async {
    // on loading chats
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await context.read<UserChatListProvider>().getUserChatList();

      // ignore: use_build_context_synchronously
      final provider = context.read<UserChatListProvider>();
      if (provider.chatLoadingState == DataState.Fetched) {
        _refreshController.loadComplete();
      } else if (provider.chatLoadingState == DataState.No_More_Data) {
        _refreshController.loadNoData();
      }
    });
  }
}

class OnlineUsersWidget extends StatelessWidget {
  const OnlineUsersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineUserProvider>(builder: (context, provider, child) {
      bool dataFetched = (provider.loadingDataState == DataState.Fetched ||
              provider.loadingDataState == DataState.No_More_Data) &&
          provider.onlineUsers.isNotEmpty;
      // ignore: unused_local_variable
      bool dataLoading =
          (provider.loadingDataState == DataState.Initial_Fetching ||
              provider.loadingDataState == DataState.More_Fetching);
      if (dataFetched) {
        return Container(
          padding: ResponsiveDesign.only(context, top: 5, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: ResponsiveDesign.only(
                  context,
                  left: 15,
                  right: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recently Active',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(20, context),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        sl<NavigationService>().navigateTo(
                          RoutePaths.onlineView,
                          nextScreen: const OnlineUsersScreen(),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "More",
                            style: context.textTheme.labelMedium
                                ?.copyWith(fontSize: 14),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveDesign.height(5, context),
              ),
              SizedBox(
                height: ResponsiveDesign.width(80, context),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: (provider.onlineUsers.length > 10
                      ? 10
                      : provider.onlineUsers.length),
                  padding: ResponsiveDesign.horizontal(15, context),
                  itemBuilder: (context, index) {
                    final onlineUser = provider.onlineUsers[index];

                    return Padding(
                      padding: ResponsiveDesign.only(context, right: 10.0),
                      child: InkWell(
                        onTap: () {
                          sl<NavigationService>().navigateTo(
                            RoutePaths.viewProfile,
                            nextScreen: ProfileScreen(
                              userId: onlineUser.userBasicInfo!.id.toString(),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: ResponsiveDesign.width(75, context),
                              width: ResponsiveDesign.width(75, context),
                              margin: const EdgeInsets.only(right: 8),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle),
                              child: CacheImage(
                                imageUrl: onlineUser.userBasicInfo?.images !=
                                        null
                                    ? onlineUser.userBasicInfo?.images?.first ??
                                        ''
                                    : '',
                                height: ResponsiveDesign.width(75, context),
                                width: ResponsiveDesign.width(75, context),
                                radius: BorderRadius.circular(70),
                                boxFit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                                bottom: ResponsiveDesign.width(10, context),
                                right: ResponsiveDesign.width(10, context),
                                child: Container(
                                  height: ResponsiveDesign.height(15, context),
                                  width: ResponsiveDesign.width(15, context),
                                  decoration: BoxDecoration(
                                      color: onlineUser.isOnline == '1'
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle),
                                ))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class MatchUsersWidget extends StatelessWidget {
  const MatchUsersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<LikeListProvider, Tuple2<DataState, List<UserBasicInfo>>>(
      selector: (context, provider) =>
          Tuple2(provider.matchLoadingState, provider.matchesList),
      builder: (context, value, child) {
        bool dataFetched = (value.item1 == DataState.Fetched ||
                value.item1 == DataState.No_More_Data) &&
            value.item2.isNotEmpty;
        bool dataLoading = (value.item1 == DataState.Initial_Fetching ||
            value.item1 == DataState.More_Fetching);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (dataFetched || dataLoading) ...[
            Padding(
              padding: ResponsiveDesign.only(context,
                  left: 15, right: 15, top: 5, bottom: 0),
              child: Text(
                'Matches',
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: ResponsiveDesign.fontSize(20, context),
                ),
              ),
            )
          ],
          if (dataFetched) ...[
            SizedBox(
              height: ResponsiveDesign.height(120, context),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: value.item2.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          ResponsiveDesign.only(context, top: 10, right: 25.0),
                      child: InkWell(
                        onTap: () {
                          sl<NavigationService>().navigateTo(
                            RoutePaths.viewProfile,
                            nextScreen: ProfileScreen(
                              userId: value.item2[index].id.toString(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: ResponsiveDesign.width(95, context),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5.0,
                                )
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: value.item2[index].images?.isNotEmpty ??
                                    false
                                ? CacheImage(
                                    imageUrl:
                                        value.item2[index].images?.first ?? '',
                                    boxFit: BoxFit.fill,
                                    radius: BorderRadius.circular(0),
                                  )
                                : Container(),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ] else if (dataLoading) ...[
            SizedBox(
                height: ResponsiveDesign.height(130, context),
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          height: ResponsiveDesign.height(135, context),
                          width: ResponsiveDesign.width(90, context),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    })),
          ] else ...[
            const SizedBox.shrink()
          ],
          if (dataFetched || dataLoading) ...[
            SizedBox(
              height: ResponsiveDesign.height(15, context),
            ),
            const Divider(
              height: 1,
              thickness: 0.2,
              color: grey1,
            ),
          ],
        ]);
      },
    );
  }
}

class UserChatListWidget extends StatelessWidget {
  const UserChatListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<UserChatListProvider, Tuple2<DataState, List<ChatUser1>>>(
      selector: (context, provider) =>
          Tuple2(provider.chatLoadingState, provider.chatUser1),
      builder: (context, value, child) {
        bool dataFetched = (value.item1 == DataState.Fetched ||
                value.item1 == DataState.No_More_Data) &&
            value.item2.isNotEmpty;
        bool dataLoading = (value.item1 == DataState.Initial_Fetching ||
            value.item1 == DataState.More_Fetching);

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: ResponsiveDesign.only(context,
                    left: 15, right: 15, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Messages',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(20, context),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        sl<NavigationService>().navigateTo(
                          RoutePaths.requestsView,
                          nextScreen: const RequestsUserScreen(),
                        );
                      },
                      child: Selector<UserChatListProvider, String>(
                        selector: (context, provider) =>
                            provider.totalCountForRequest,
                        builder: (context, value, child) {
                          return Row(
                            children: [
                              Text(
                                "Requests\t\t",
                                style: context.textTheme.labelMedium
                                    ?.copyWith(fontSize: 14),
                              ),
                              Text(
                                "$value\t",
                                style: context.textTheme.labelMedium?.copyWith(
                                    fontSize: 18,
                                    color: red,
                                    fontWeight: FontWeight.w500),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              )
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveDesign.height(5, context),
              ),
              if (dataFetched) ...[
                Flexible(
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: value.item2.length,
                      itemBuilder: (context, index) {
                        final chatUser = value.item2[index];
                        return ChatCardView(
                          user: chatUser,
                        );
                      }),
                ),
              ] else if (dataLoading) ...[
                ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return const ShimmerChatCard();
                  },
                  separatorBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Divider(
                          color: 0xffE8E6EA.toColor,
                          height: 1,
                          thickness: 1,
                          indent: 75,
                          endIndent: 15,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                ),
              ] else ...[
                const SizedBox.shrink()
              ],
              if (dataFetched || dataLoading) ...[
                SizedBox(
                  height: ResponsiveDesign.height(10, context),
                ),
              ],
            ]);
      },
    );
  }
}
