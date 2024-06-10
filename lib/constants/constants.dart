// ignore_for_file: constant_identifier_names

import 'package:meety_dating_app/constants/ui_strings.dart';

class Constants {
  static const String firebaseServerNotiKey =
      'AAAAbbH8nYA:APA91bFWDnnKY9Q44wgbHsG0PdCOj462dgKh3uZ3wWtsERxol8yH1cBLPxxDCMbL2XD3sCUzwixwLkxR0PAFyg1TV7EiNYQsg8idXwC34cn72-OnAQNXMBJkyQn-MGLddOhyreCZE_df';
  static const String imageUrl =
      'https://meety-app.s3.ap-south-1.amazonaws.com';

  static const String punishableKey =
      'pk_test_51MhmEuSDLKc8inuYJKa6XNI0Qw0GXcQn25ZKG6johJHdplvLS0yhoLXjb1CMS5uw6pyogYbY2JYqhukuguwFxzns00tVmWPHMc';
  static const String stripeSecretKey =
      'sk_test_51MhmEuSDLKc8inuYp7l30F8JCcWYTf1Ie4DhUoQDqwHpjS5DvpUeREcTaE9VUWqDAyWxPUepSap5P5yzARollDf900eR9EFjB6';

  static String successPaymentRedirectURL = '/success';
  static String failurePaymentRedirectURL = '/cancel';
  static const double defaultMaximumDistance = 40;
  static const String defaultAgeRange = "18-40";
  static const int toShowInAgeRange = 0;

  static const normalLogin = '0';
  static const googleLogin = '1';
  static const facebookLogin = '2';
  static const appleLogin = '3';
  static const phoneNumberLogin = '4';

  static const woman = 'F';
  static const man = 'M';
  static const other = 'T';

  static const allNotification = '0';
  static const pushNotification = '1';
  static const emailAddress = '2';
  static const noneOfNotification = '3';

  static const visitNotificationType = '1';
  static const matchNotificationType = '2';
  static const chatNotificationType = '3';
  static const likeNotificationType = '4';
  static const profileNotificationType = '5';
  static const adminVerificationNotificationType = '6';
  static const adminNotificationType = '7';
  static const readAllMsgNotificationType = '8';
  static const readLastMessageNotificationType = '9';
  static const profileCompletingNotificationType = '10';

  static const openAppNotificationType = '11';
  static const premiumPlansNotificationType = '12';
  static const editProfileNotificationType = '13';
  static const sevenDaysAddonPlansNotificationType = '14';
  static const messageAddonPlansNotificationType = '15';
  static const signInPageNotificationType = '16';
  static const profileVerificationNotificationType = '17';

  static const homeTab = 0;
  static const likeTab = 1;
  static const chatTab = 2;
  static const profileTab = 3;

  static const noStatus = '0';
  static const visitor = '1';
  static const liked = '2';
  static const disliked = '3';
  static const visitedAndLike = '4';
  static const visitedAndDisliked = '5';
  static const matchStatus = '6';
  static const rewindStatus = '7';
  static const unmatchStatus = '-1';

  static const message = 'Message';

  static const String uriPrefix = 'https://meetymatchfinder.page.link';
  static const String linkPrefix = 'https://meety_match_finder.com/?';
  static const String androidPackageName = 'com.app.meety_dating_app';
  static const String iosBundleId = 'com.app.meetydatingapp';
  static const String iosAppStoreId = '123456789';

  // chat related constant
  static const channelCollection = "Channel";
  static const userCollection = "User";
  static const channelIdCollection = "ChannelId";

  // Read Status
  static const String unsent = '-1';
  static const String sent = '0';
  static const String delivered = '1';
  static const String msgRead = '2';
  static const String channelIdKey = 'channelIdOn';
  static const String lastOnlineAtKey = 'lastOnlineAt';
  static const String isOnlineKey = 'isOnline';
  static const String onlineTime = 'onlineTime';
  static const String notificationTypeKey = 'notificationType';
  static const String read = '1';
  static const String unRead = '0';

  // Read Status
  static const String offlineState = '0';
  static const String onlineState = '1';

  static const String straight = UiString.straight;
  static const String homoSexual = UiString.homosexual;
  static const String bisexual = UiString.bisexual;
  static const String asexual = UiString.asexual;
  static const String demisexual = UiString.demisexual;
  static const String pansexual = UiString.pansexual;
  static const String queer = UiString.queer;
  static const String bicurious = UiString.bicurious;
  static const String notToSay = UiString.notToSay;

  static const String longtermPartner = '0';
  static const String longtermButShortPartner = '1';
  static const String shortTermButLongPartner = '3';
  static const String shortTerm = '4';
  static const String newFriends = '5';
  static const String figuringOut = '6';

  static const String openToOptions = '0';
  static const String longTermRelationship = '1';
  static const String marriageMinded = '2';
  static const String casualDating = '3';
  static const String friendship = '4';
  static const String meaningfulConversations = '5';
  static const String activityPartners = '6';
  static const String noStringsAttached = '7';
  static const String virtualConnections = '8';
  static const String travelCompanions = '9';
  static const String fitnessBuddies = '10';
  static const String gamingEnthusiasts = '11';

  static const String doctoralDeg = UiString.doctoralDeg;
  static const String professionalDeg = UiString.professionalDeg;
  static const String masterDeg = UiString.masterDeg;
  static const String bachelorDeg = UiString.bachelorDeg;
  static const String associateDeg = UiString.associateDeg;
  static const String someClgNoDeg = UiString.someClgNoDeg;
  static const String highSchool = UiString.highSchool;
  static const String diploma = UiString.diploma;
  static const String lifelongLearner = UiString.lifelongLearner;
  static const String collegeDropoutPassionPursuer =
      UiString.collegeDropoutPassionPursuer;
  static const String academicExplorer = UiString.academicExplorer;
  static const String creativeSelfTaught = UiString.creativeSelfTaught;
  static const String onlineCourseEnthusiast1 =
      UiString.onlineCourseEnthusiast1;
  static const String militaryServiceGraduate =
      UiString.militaryServiceGraduate;
  static const String parentingUniversity = UiString.parentingUniversity;
  static const String hybridEducationJourney = UiString.hybridEducationJourney;

  // static const String others = "16";

  static const homeScreenNotificationReceiver =
      'homeScreenNotificationReceiver';
  static const readMsgNotificationBroadcaster = '5';

  static const String startingAFamily = UiString.startingAFamily;
  static const String alreadyAParent = UiString.alreadyAParent;
  static const String childFreeByChoice = UiString.childFreeByChoice;
  static const String blendedFamily = UiString.blendedFamily;
  static const String petParent = UiString.petParent;
  static const String openToCoParenting = UiString.openToCoParenting;
  static const String parentingPartner = UiString.parentingPartner;
  static const String careerOverFamily = UiString.careerOverFamily;
  static const String travelAndAdventure = UiString.travelAndAdventure;
  static const String nurturingRelationships = UiString.nurturingRelationships;
  static const String elderCare = UiString.elderCare;
  static const String culturalTraditions = UiString.culturalTraditions;
  static const String undecided = UiString.undecided;

  static const reactivate = 0;
  static const delete = 1;
  static const deactivate = 2;

  static const String helpAndSupport = "";
  static const String privacyPolicy = "";

  static const String termsAndConditions = "";
  static const serverKey =
      "AAAAbbH8nYA:APA91bFWDnnKY9Q44wgbHsG0PdCOj462dgKh3uZ3wWtsERxol8yH1cBLPxxDCMbL2XD3sCUzwixwLkxR0PAFyg1TV7EiNYQsg8idXwC34cn72-OnAQNXMBJkyQn-MGLddOhyreCZE_df";
}
