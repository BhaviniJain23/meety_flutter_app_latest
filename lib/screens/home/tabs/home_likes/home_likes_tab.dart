import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/screens/home/widgets/user.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/no_internet_connection_screen.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tuple/tuple.dart';

class HomeLikesTab extends StatefulWidget {
  const HomeLikesTab({Key? key}) : super(key: key);

  @override
  State<HomeLikesTab> createState() => _HomeLikesTabState();
}

class _HomeLikesTabState extends State<HomeLikesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int count = 0;
  bool isInternet = true;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: ResponsiveDesign.height(50, context),
              padding: ResponsiveDesign.only(context,
                  top: 6.0, right: 10.0, left: 10.0, bottom: 3.0),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: whitesmoke,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    color: red),
                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (index) {
                  final provider = sl<LikeListProvider>();
                  if (index == 0 &&
                      provider.likeState == DataState.Uninitialized) {
                    provider.fetchLikes();
                  }
                  if (index == 1 &&
                      provider.likeSentState == DataState.Uninitialized) {
                    provider.fetchLikesSent();
                  }
                  if (index == 2 &&
                      provider.visitorState == DataState.Uninitialized) {
                    provider.fetchVisitors();
                  }
                },
                labelColor:Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Selector<LikeListProvider, int>(
                    selector: (context, provider) => provider.totalLikeCounts,
                    builder: (context, value, child) {
                      return Tab(
                        text:
                            '${value != 0 ? value : ''} ${UiString.likesText}',
                      );
                    },
                  ),
                  Tab(
                    text: UiString.likeSentText,
                  ),
                  Tab(
                    text: UiString.visitorText,
                  ),
                ],
              ),
            ),
            const Divider(
              color: whitesmoke,
              height: 2,
              thickness: 5,
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Selector<LikeListProvider,
                    Tuple3<List<UserBasicInfo>, DataState, bool>>(
                  selector: (context, provider) => Tuple3(provider.likeList,
                      provider.likeState, provider.isMyLikesListShow),
                  builder: (context, value, child) {
                    return TabberWidget(
                        title: 'This is a list of people who have liked you.',
                        list: value.item1,
                        state: value.item2,
                        isListShow: value.item3,
                        isInternet: isInternet,
                        tabIndex: 0);
                  },
                ),
                Selector<LikeListProvider,
                    Tuple3<List<UserBasicInfo>, DataState, bool>>(
                  selector: (context, provider) => Tuple3(provider.likeSentList,
                      provider.likeSentState, provider.isMySentLikesListShow),
                  builder: (context, value, child) {
                    return TabberWidget(
                        title: 'This is a list of people who you have liked.',
                        list: value.item1,
                        state: value.item2,
                        isListShow: value.item3,
                        isInternet: isInternet,
                        tabIndex: 1);
                  },
                ),
                Selector<LikeListProvider,
                    Tuple4<List<UserBasicInfo>, DataState, bool, String>>(
                  selector: (context, provider) => Tuple4(
                      provider.visitorList,
                      provider.visitorState,
                      provider.isMyVisitorListShow,
                      provider.visitorMessage),
                  builder: (context, value, child) {
                    return TabberWidget(
                        title: value.item4,
                        list: value.item1,
                        state: value.item2,
                        isListShow: value.item3,
                        isInternet: isInternet,
                        tabIndex: 2);
                  },
                ),
              ],
            )),
            SizedBox(
              height: ResponsiveDesign.height(40, context),
            ),
          ],
        ),
      ),
    );
  }
}

class TabberWidget extends StatelessWidget {
  TabberWidget(
      {Key? key,
      required this.title,
      required this.list,
      required this.isListShow,
      required this.state,
      required this.tabIndex,
      required bool isInternet})
      : super(key: key) {
    _isInternet.value = isInternet;
  }

  final String title;
  final bool isListShow;
  final List<UserBasicInfo> list;
  final DataState state;
  final int tabIndex;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ValueNotifier<bool> _isInternet = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      footer: const ClassicFooter(),
      controller: _refreshController,
      onRefresh: () {
        _onRefresh(context);
      },
      onLoading: () {
        _onLoading(context);
      },
      child: ValueListenableBuilder(
          valueListenable: _isInternet,
          builder: (context, value, _) {
            if (state == DataState.Refreshing ||
                state == DataState.Fetched ||
                state == DataState.Error ||
                state == DataState.No_More_Data) {
              if (!value) {
                return NoInternetScreen(
                  onTryAgainTap: () async {
                    bool checkInternet = await sl<InternetConnectionService>()
                        .hasInternetConnection();
                    if (checkInternet) {
                      final provider = sl<LikeListProvider>();
                      if (tabIndex == 0) {
                        await provider.fetchLikes();
                      } else if (tabIndex == 1) {
                        await provider.fetchLikesSent();
                      } else {
                        await provider.fetchVisitors();
                      }
                    }
                    if (value != checkInternet) {
                      _isInternet.value = checkInternet;
                    }
                  },
                );
              } else if (list.isEmpty) {

                return Padding(
                  padding:ResponsiveDesign.vertical(200, context),
                  child: Column(
                    children: [
                      Center(
                        child: Lottie.asset(
                            tabIndex == 0
                                ? Assets.noLike
                                : tabIndex == 1
                                ? Assets.noLikeSent
                                : Assets.noVisitors,
                            height: ResponsiveDesign.height(175, context)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          tabIndex == 0
                              ? UiString.emptyLikesTitle
                              : tabIndex == 1
                              ? UiString.emptyLikesSentTitle
                              : UiString.emptyVisitorsTitle,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: black,
                            fontSize: ResponsiveDesign.fontSize(18, context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          UiString.emptyLikesCaption,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: const Color(0xff002055),
                            fontSize: ResponsiveDesign.fontSize(14, context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        title,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 0.75,
                                    maxCrossAxisExtent: context.width * 0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            physics: const BouncingScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final userBasicInfo = list[index];

                              return UserCard(
                                userBasicInfo,
                                isImageBlur: !isListShow,
                                showLikeButton: (tabIndex == 0 &&
                                        !isListShow) ||
                                    !(userBasicInfo.visitStatus.toString() ==
                                            Constants.liked ||
                                        userBasicInfo.visitStatus.toString() ==
                                            Constants.visitedAndLike),
                                showDisLikeButton: (tabIndex == 0 &&
                                        !isListShow) ||
                                    !(userBasicInfo.visitStatus.toString() ==
                                            Constants.disliked ||
                                        userBasicInfo.visitStatus.toString() ==
                                            Constants.visitedAndDisliked),

                                  onBlurTap:(){
                                     if(!isListShow){
                                       switch(tabIndex){
                                         case 0:
                                           Utils.printingAllPremiumInfo(context, isForLikeList: true);
                                           break;
                                         case 1:
                                           Utils.printingAllPremiumInfo(context, isForLikeSentList: true);
                                           break;
                                         case 2:
                                           Utils.printingAllPremiumInfo(context, isForVisitorList: true);
                                           break;
                                       }
                                     }
                                  }
                              );
                            }),
                      ),
                    ),

                  ],
                ),
              );
            }

            return const Center(child: Loading());
          }),
    );
  }

  void _onRefresh(context) async {
    _refreshController.resetNoData();
    // monitor network fetch
    final provider = sl<LikeListProvider>();

    if (tabIndex == 0) {
      provider.likeState = DataState.Refreshing;
      provider.likePageNo = 1;
      await provider.fetchLikes();
    } else if (tabIndex == 1) {
      provider.likeSentState = DataState.Uninitialized;
      provider.likeSentPageNo = 1;

      await provider.fetchLikesSent();
    } else {
      provider.visitorState = DataState.Uninitialized;
      provider.visitorPageNo = 1;

      await provider.fetchVisitors();
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading(context) async {
    final provider = sl<LikeListProvider>();
    await provider.fetchingNextPage(tabIndex);

    if (tabIndex == 0) {
      if (provider.likeState == DataState.Fetched) {
        _refreshController.loadComplete();
      } else if (provider.likeState == DataState.No_More_Data) {
        _refreshController.loadNoData();
      }
    } else if (tabIndex == 1) {
      if (provider.likeSentState == DataState.Fetched) {
        _refreshController.loadComplete();
      } else if (provider.likeSentState == DataState.No_More_Data) {
        _refreshController.loadNoData();
      }
    } else {
      if (provider.visitorState == DataState.Fetched) {
        _refreshController.loadComplete();
      } else if (provider.visitorState == DataState.No_More_Data) {
        _refreshController.loadNoData();
      }
    }
  }
}
