import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/screens/profile/view_profile.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../config/routes_path.dart';
import '../../../../constants/enums.dart';
import '../../../../constants/size_config.dart';
import '../../../../constants/ui_strings.dart';
import '../../../../services/navigation_service.dart';
import '../../../../services/singleton_locator.dart';

class OnlineUsersScreen extends StatefulWidget {
  const OnlineUsersScreen({super.key});

  @override
  State<OnlineUsersScreen> createState() => _OnlineUsersScreenState();
}

class _OnlineUsersScreenState extends State<OnlineUsersScreen> {
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(
        title: UiString.online,
        elevation: 5,
        height: 56,
      ),
      body: Consumer<OnlineUserProvider>(builder: (context, provider, child) {
        bool dataFetched = (provider.loadingDataState == DataState.Fetched ||
                provider.loadingDataState == DataState.No_More_Data) &&
            provider.onlineUsers.isNotEmpty;
        bool dataLoading =
            (provider.loadingDataState == DataState.Initial_Fetching ||
                provider.loadingDataState == DataState.More_Fetching);
        if (dataFetched || dataLoading) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            footer: const ClassicFooter(),
            onRefresh: () {
              _onRefresh(provider, context);
            },
            onLoading: () {
              _onLoading(provider, context);
            },
            child: SingleChildScrollView(
              child: Container(
                padding: ResponsiveDesign.only(context, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.onlineUsers.length,
                      padding: ResponsiveDesign.horizontal(15, context),
                      itemBuilder: (context, index) {
                        final onlineUser = provider.onlineUsers[index];
                        return Padding(
                          padding: ResponsiveDesign.only(context, bottom: 20.0),
                          child: Row(
                            children: [
                              SizedBox(
                                height: ResponsiveDesign.screenHeight(context) *
                                    0.1,
                                width: ResponsiveDesign.screenHeight(context) *
                                    0.1,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: ResponsiveDesign.screenHeight(
                                              context) *
                                          0.1,
                                      width: ResponsiveDesign.screenHeight(
                                              context) *
                                          0.1,
                                      margin: const EdgeInsets.only(right: 8),
                                      alignment: Alignment.topCenter,
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(80),
                                        onTap: () {
                                          sl<NavigationService>().navigateTo(
                                            RoutePaths.viewProfile,
                                            nextScreen: ProfileScreen(
                                              userId: onlineUser
                                                  .userBasicInfo!.id
                                                  .toString(),
                                            ),
                                          );
                                        },
                                        child: CacheImage(
                                          imageUrl: onlineUser.userBasicInfo
                                                          ?.images !=
                                                      null &&
                                                  onlineUser.userBasicInfo!
                                                      .images!.isNotEmpty
                                              ? onlineUser.userBasicInfo?.images
                                                      ?.first ??
                                                  ''
                                              : '',
                                          height: ResponsiveDesign.height(
                                              85, context),
                                          width: ResponsiveDesign.width(
                                              85, context),
                                          radius: BorderRadius.circular(80),
                                          boxFit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: ResponsiveDesign.height(
                                            15, context),
                                        right: ResponsiveDesign.height(
                                            15, context),
                                        child: Container(
                                          height: ResponsiveDesign.height(
                                              15, context),
                                          width: ResponsiveDesign.width(
                                              15, context),
                                          decoration: BoxDecoration(
                                              color: onlineUser.isOnline == '0'
                                                  ? Colors.deepOrange
                                                  : Colors.green,
                                              shape: BoxShape.circle),
                                        ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveDesign.width(5, context),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        sl<NavigationService>().navigateTo(
                                          RoutePaths.viewProfile,
                                          nextScreen: ProfileScreen(
                                            userId: onlineUser.userBasicInfo!.id
                                                .toString(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "${onlineUser.userBasicInfo?.name},${onlineUser.userBasicInfo?.age}",
                                        style: context.textTheme.titleSmall
                                            ?.copyWith(
                                                fontSize:
                                                    ResponsiveDesign.fontSize(
                                                        18, context)),
                                        maxLines: 2,
                                      ),
                                    ),
                                    if (onlineUser.userBasicInfo?.hometown !=
                                        null) ...[
                                      Text(
                                        "${onlineUser.userBasicInfo?.hometown}",
                                        style: context.textTheme.displaySmall
                                            ?.copyWith(fontSize: 15),
                                      ),
                                    ],
                                    if (onlineUser.isOnline == "0") ...[
                                      const Text("Recently Active")
                                    ] else ...[
                                      const Text("Online Now")
                                    ]
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveDesign.width(10, context),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  height: ResponsiveDesign.height(40, context),
                                  width: ResponsiveDesign.width(110, context),
                                  child: OutLineBtnX(
                                    radius: 7,
                                    color:
                                        onlineUser.userBasicInfo?.canMsgSend ==
                                                    null ||
                                                (onlineUser.userBasicInfo
                                                        ?.canMsgSend ==
                                                    1)
                                            ? null
                                            : Colors.grey,
                                    fillColor:
                                        onlineUser.userBasicInfo?.canMsgSend ==
                                                    null ||
                                                (onlineUser.userBasicInfo
                                                        ?.canMsgSend ==
                                                    1)
                                            ? Colors.black12
                                            : null,
                                    onPressed: () {
                                      if (onlineUser
                                                  .userBasicInfo?.canMsgSend ==
                                              null ||
                                          (onlineUser
                                                  .userBasicInfo?.canMsgSend ==
                                              1)) {
                                        context
                                            .read<HomeProvider>()
                                            .updateVisitAction(
                                                context, Constants.message,
                                                userBasicInfo:
                                                    onlineUser.userBasicInfo!,
                                                isDirectionUpdate: false);
                                      }
                                    },
                                    child: Text(
                                      "Message",
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(fontSize: 13),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _onRefresh(OnlineUserProvider provider, context) async {
    // on refreshing
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.resetNoData();

    await provider.getOnlineUsers(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading(OnlineUserProvider provider, context) async {
    // on loading chats
    await Future.delayed(const Duration(milliseconds: 1000));
    await provider.getOnlineUsers();
    if (provider.loadingDataState == DataState.Fetched) {
      _refreshController.loadComplete();
    } else if (provider.loadingDataState == DataState.No_More_Data) {
      _refreshController.loadNoData();
    }
  }
}
