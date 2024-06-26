import 'package:flutter/cupertino.dart';

import '../constants/constants.dart';
import '../models/interest_model.dart';
import '../screens/auth/forget_pass.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onborading.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/phone_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/match_screen.dart';
import '../screens/home/tabs/explore/explore_users.dart';
import '../screens/home/tabs/profile/image_preview.dart';
import '../screens/home/tabs/profile/profile/edit_profile.dart';
import '../screens/home/tabs/profile/profile/interest_screen_old.dart';
import '../screens/home/tabs/profile/setting/block_contact_tab.dart';
import '../screens/locations/enable_location.dart';
import '../screens/locations/search_location.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/profile/add_photos.dart';
import '../screens/profile/profile_setup_screen.dart';
import '../screens/subscriptions/subscription_list.dart';
import '../screens/subscriptions/subscription_purchase.dart';
import 'routes_path.dart';

class Routers {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.login:
        return CupertinoPageRoute(builder: (_) => const LoginScreen());
      case RoutePaths.register:
        return CupertinoPageRoute(builder: (_) => const RegisterScreen());
      case RoutePaths.phoneLogin:
        return CupertinoPageRoute(builder: (_) => const PhoneLoginScreen());
      case RoutePaths.forgotPassword:
        return CupertinoPageRoute(builder: (_) => const ForgotPassScreen());
      case RoutePaths.otpVerification:
        Map<String, dynamic> argSenderStr =
            settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
            builder: (_) => OTPVerificationScreen(
                  sender: argSenderStr['email'],
                  isFromForgotPassword: argSenderStr['isFromForgotPassword'],
                  isFromAccountSetting:
                      argSenderStr.containsKey("isFromAccountSetting")
                          ? argSenderStr['isFromAccountSetting']
                          : false,
                ));
      case RoutePaths.resetPassword:
        String? userId = settings.arguments as String?;

        return CupertinoPageRoute(
            builder: (_) => ResetPassword(userId: userId.toString()));

      case RoutePaths.enableLocation:
        bool? isFirst = settings.arguments as bool?;
        return CupertinoPageRoute(
            builder: (_) => EnableLocation(
                  isFirst: isFirst ?? false,
                ));
      case RoutePaths.home:
        return CupertinoPageRoute(builder: (_) => const HomeScreen());
      case RoutePaths.addPhotos:
        return CupertinoPageRoute(builder: (_) => const AddPhotos());
      case RoutePaths.exploreUser:
        InterestModel interestModel = settings.arguments as InterestModel;
        return CupertinoPageRoute(
            builder: (_) => ExploreUsersScreen(interestModel: interestModel));
      case RoutePaths.editProfile:
        // InterestModel interestModel = settings.arguments as InterestModel;
        return CupertinoPageRoute(builder: (_) => const EditProfileScreen());
      case RoutePaths.boardingProfile:
        // String argSenderStr = settings.arguments as String;
        return CupertinoPageRoute(builder: (_) => const ProfileSetUpScreen());
      case RoutePaths.allInterest:
        List<String> argSenderStr = settings.arguments as List<String>;
        return CupertinoPageRoute(
            builder: (_) => InterestScreenOld(
                  givenList: argSenderStr,
                ));
      case RoutePaths.matchScreen:
        Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;

        return CupertinoPageRoute(
            builder: (_) => MatchScreen(
                  loginUser: args['loginUser'],
                  otherUser: args['otherUser'],
                  message: args['message'],
                ));

      case RoutePaths.subscriptionScreen:
        return CupertinoPageRoute(
            builder: (_) => const SubscriptionListScreen());
      case RoutePaths.onBoarding:
        return CupertinoPageRoute(builder: (_) => const Onboarding());
      case RoutePaths.notification:
        return CupertinoPageRoute(
          builder: (_) => const NotificationScreen(),
        );
      case RoutePaths.blockContactTab:
        return CupertinoPageRoute(
          builder: (_) => const BlockTabScreen(),
        );
      case RoutePaths.imageCropPreviewScreen:
        Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (_) => ImageCropPreview(
            imagePath: args['imagePath'],
            channelId: args['channelId'],
            singleChatProvider: args['singleChatProvider'],
          ),
        );
      case RoutePaths.searchLocation:
        return CupertinoPageRoute(
          builder: (_) => const SearchLocation(),
        );
      case RoutePaths.subscriptionPurchase:
        return CupertinoPageRoute(
          builder: (_) => SubscriptionPurchaseScreen(
            paymentLink: Constants.successPaymentRedirectURL,
          ),
        );
      default:
        return null;
    }
  }
}
