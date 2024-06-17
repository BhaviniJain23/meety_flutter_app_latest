// ignore_for_file: use_build_context_synchronously

import 'package:action_broadcast/action_broadcast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/login_user_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/providers/persistent_provider.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/users_chat.dart';
import 'package:meety_dating_app/screens/home/tabs/home/home_tabs.dart';
import 'package:meety_dating_app/screens/home/tabs/home_likes/home_likes_tab.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/profile_tab.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/notification_function.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutoCancelStreamMixin {
  final PersistentTabControllerService controllerService =
      sl<PersistentTabControllerService>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  User? loginUser;

  @override
  Iterable<StreamSubscription> get registerSubscriptions sync* {
    yield registerReceiver([Constants.homeScreenNotificationReceiver])
        .listen((intent) {
      switch (intent.action) {
        case Constants.homeScreenNotificationReceiver:
          if (intent.data is RemoteMessage) {
            handleMessage(context, intent.data);
          }
          break;
      }
    });
  }

  @override
  void initState() {
    controllerService.setController(PersistentTabController(initialIndex: 3));
    loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    startBackgroundTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LoginUserProvider>().fetchLoginUser();

      loginUser = sl<SharedPrefsManager>().getUserDataInfo();
      context.read<HomeProvider>().fetchUsers();
      sl<ChatRepository>().setUserOnlineStatus(
          userId: loginUser?.id,
          isOnline: Constants.onlineState,
          isChannelOn: sl<UserChatListProvider>().visitChannelId,
          isOnlineTimeUpdate: true);
      context.read<LikeListProvider>().fetchingInitialData();
      context.read<OnlineUserProvider>().getOnlineUsers(refresh: true);
      context.read<UserChatListProvider>().fetchChats();
      context.read<HomeProvider>().fetchResetUserSettingAfterSubscription();
      context
          .read<SubscriptionProvider>()
          .fetchSubscriptions(context.read<LoginUserProvider>());
      await notificationPermissions(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    final isBg = state == AppLifecycleState.paused;
    final isClosed = state == AppLifecycleState.detached;
    final isScreen = state == AppLifecycleState.resumed;

    if (isBg || isClosed) {
      stopBackgroundTimer();
      await sl<ChatRepository>().setUserOnlineStatus(
          isOnline: Constants.offlineState,
          isChannelOn: '',
          isOnlineTimeUpdate: true);
    } else if (isScreen) {
      startBackgroundTimer();

      await sl<ChatRepository>().setUserOnlineStatus(
          isOnline: Constants.onlineState,
          isChannelOn: sl<UserChatListProvider>().visitChannelId,
          isOnlineTimeUpdate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: PersistentTabView(
          context,
          controller: controllerService.controller,
          hideNavigationBarWhenKeyboardShows: false,
          resizeToAvoidBottomInset: false,
          screens: const [
            HomeTab(),
            HomeLikesTab(),
            UsersChatTab(),
            ProfileTab()
          ],
          onItemSelected: (selectedIndex) {
            if (controllerService.lastIndex != selectedIndex) {
              controllerService.setIndex(selectedIndex);
              if (selectedIndex == 2) {}
            }
          },
          items: _navBarsItems(),
          confineInSafeArea: true,
          handleAndroidBackButtonPress: true,
          stateManagement: true,
          navBarHeight: ResponsiveDesign.height(70, context),
          bottomScreenMargin: 0,
          backgroundColor: Colors.white,
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: const ItemAnimationProperties(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
            animateTabTransition: false,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style12,
        ));
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        contentPadding: 0,
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.homeFillIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
            ),
            const Text(
              'Home',
              style: TextStyle(color: red),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.homeTabIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
              color: Colors.black,
            ),
            const Text('Home')
          ],
        ),
      ),
      PersistentBottomNavBarItem(
        contentPadding: 0,
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.likeSvgFillIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
            ),
            const Text(
              'Likes',
              style: TextStyle(color: red),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.likeTabsIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
              color: Colors.black,
            ),
            const Text(
              'Likes',
            )
          ],
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.msgSvgFillIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
            ),
            const Text(
              'Messages',
              style: TextStyle(color: red),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.msgSvgIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
              color: Colors.black,
            ),
            const Text(
              'Messages',
            )
          ],
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.profileFillIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
            ),
            const Text(
              'Profile',
              style: TextStyle(color: red),
            )
          ],
        ),
        inactiveIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Assets.profileIcon,
              height: ResponsiveDesign.height(24, context),
              width: ResponsiveDesign.width(24, context),
              color: Colors.black,
            ),
            const Text(
              'Profile',
            )
          ],
        ),
      ),
    ];
  }

  void startBackgroundTimer() {
    sl<BackgroundTimer>().startTimer(() async {
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (checkInternet) {
        sl<ChatRepository>().setUserOnlineStatus(
            userId: loginUser?.id,
            isOnline: Constants.onlineState,
            isChannelOn: sl<UserChatListProvider>().visitChannelId);
      }
    }, false);
  }

  void stopBackgroundTimer() {
    sl<BackgroundTimer>().stopBackgroundTimer(false);
  }
}
