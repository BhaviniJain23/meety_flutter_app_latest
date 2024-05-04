import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/chat_provider.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/login_user_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/providers/photo_provider.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/services/dynamic_link_service.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/notification_function.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tzl;

import 'config/routes.dart';
import 'config/routes_path.dart';
import 'constants/constants.dart';
import 'providers/home_provider.dart';
import 'services/singleton_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  tzl.initializeTimeZones();
  await Firebase.initializeApp();
  //initialize get it
  await init();
  Stripe.publishableKey = Constants.punishableKey;

  // Initialize SharedPrefs instance.
  await sl<SharedPrefsManager>().init();
  sl<InternetConnectionService>().initialize();
  sl<DynamicLinkService>().handleDynamicLinks();
  //FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SHOW_WHEN_LOCKED);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: white,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
    Utils.configLoading();
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final User? user = sl<SharedPrefsManager>().getUserDataInfo();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return LoginUserProvider(loginUser: user);
        }),
        ChangeNotifierProvider(create: (_) {
          return PhotosProvider();
        }),
        ChangeNotifierProvider(
          create: (_) {
            return HomeProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) {
          return sl<LikeListProvider>();
        }),
        ChangeNotifierProvider(create: (_) {
          return OnlineUserProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return sl<UserChatListProvider>();
        }),
        ChangeNotifierProvider(create: (_) {
          return SubscriptionProvider();
        }),
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (_) {
            return SubscriptionProvider();
          },
        ),
        ChangeNotifierProxyProvider<UserChatListProvider, ChatProviders>(
          create: (_) {
            return ChatProviders(userChatListPro: sl<UserChatListProvider>());
          },
          update: (_, userProvider, userChatsProvider) {
            return userChatsProvider!..userChatListProvider = userProvider;
          },
        ),
        ChangeNotifierProxyProvider<LoginUserProvider, EditUserProvider>(
            create: (_) {
          return EditUserProvider(
              loginProvider: LoginUserProvider(loginUser: user));
        }, update: (_, userProvider, editUserProvider) {
          if (userProvider.user != null) {
            editUserProvider?.setUser(userProvider.user!);
          }
          return editUserProvider!..loginUserProvider = userProvider;
        }),
      ],
      child: MaterialApp(
        builder: EasyLoading.init(),
        navigatorKey: NavigationService.navigatorKey,
        color: Colors.transparent,
        title: 'Meety',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: white,
          primarySwatch: red.toMaterialColor,
          primaryColor: red,
          primaryColorLight: red,
          primaryColorDark: red,
          checkboxTheme: CheckboxThemeData(

            fillColor: MaterialStateProperty.resolveWith((states) =>
                states.contains(MaterialState.selected) ? red : white),
          ),
          dialogBackgroundColor: Colors.white,
          dialogTheme: const DialogTheme(backgroundColor: Colors.white),
          switchTheme: SwitchThemeData(
              trackColor: MaterialStateProperty.resolveWith((states) =>
                  states.contains(MaterialState.selected) ? red : white),
              thumbColor: MaterialStateProperty.resolveWith((states) =>
                  states.contains(MaterialState.selected) ? white : red),
              trackOutlineColor: MaterialStateProperty.all(red),
              trackOutlineWidth: MaterialStateProperty.all(0.8)),
          appBarTheme: AppBarTheme(
            color: 0x00FFFFFF.toColor.toMaterialColor,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            elevation: 0,
          ),
          fontFamily: 'Poppins',
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context) //
                .textTheme
                .copyWith(
                  headlineSmall: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ),
        localizationsDelegates: const [
          MonthYearPickerLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        initialRoute: initialRoutePath(),
        onGenerateRoute: Routers.generateRoute,
      ),
    );
  }

  String initialRoutePath() {
    final isSaveBoarding = sl<SharedPrefsManager>().getBoardingScreen();
    if (user != null) {
      if (user!.dob != null && user!.dob!.isNotEmpty) {
        if (user!.images != null && user!.images!.isNotEmpty) {
          return RoutePaths.enableLocation;
        } else {
          return RoutePaths.addPhotos;
        }
      } else {
        return RoutePaths.boardingProfile;
      }
    } else {
      if (isSaveBoarding == 'false') {
        return RoutePaths.onBoarding;
      } else {
        return RoutePaths.login;
      }
    }
  }
}
