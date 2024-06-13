// ignore_for_file: constant_identifier_names, non_constant_identifier_names

class EndPoints {
  // static const Live_URL = "http://192.168.0.106:3000/api/v1";
  //static const Live_URL = "http://vps.socialbull.co:3002/api/v1";
  //static const Live_URL = "http://vps.socialbull.co:3001/api/v1";
  // static const Live_URL = "http://104.237.3.96:3001/api/v1";
  // static const Live_URL = "https://api1.meety.in/api/v1";
  static const Live_URL = "https://api1.meety.in/api/v1";

  //static const Live_URL = "http://192.168.0.141:3000/api/v1";
  static const LOGIN_API = "$Live_URL/login";
  static const SIGNUP_API = "$Live_URL/signUp";
  static const SIGN_IN_WITH_PHONE_API = "$Live_URL/signUpWithPhoneNumber";
  static const CHECK_USER_EXISTS_WITH_PHONE_API =
      "$Live_URL/checkUserExistWithPhoneNumber";
  static const FORGOT_PASSWORD_API = "$Live_URL/forgotPassword";
  static const RESET_PASSWORD_API = "$Live_URL/resetPassword";
  static const CHANGE_PASSWORD_API = "$Live_URL/changePassword";
  static const VERIFY_OTP_API = "$Live_URL/verifyEmailOTP";
  static const RESEND_OTP_API = "$Live_URL/resendEmailOTP";
  static const GET_ALL_INTEREST_NAME_API = "$Live_URL/getAllInterestName";
  static const SET_UP_PROFILE_API = "$Live_URL/user/setUpProfile";
  static const UPDATE_LOCATION_API = "$Live_URL/user/updateLocation";
  static const ADD_MULTI_PROFILE_API = "$Live_URL/user/addMultiProfilePic";
  static const DELETE_PROFILE_PIC_API = "$Live_URL/user/deleteProfilePic";
  static const UPDATE_PROFILE_PIC_API = "$Live_URL/user/updateProfilePic";
  static const GET_PROFILE_API = "$Live_URL/user/getUserProfile";
  static const GET_FCM_TOKEN_API = "$Live_URL/user/getUserFcmToken";
  static const POST_REPORT_USER_API = "$Live_URL/user/reportUser";
  static const POST_BLOCK_USER_API = "$Live_URL/user/blockUser";
  static const POST_UPDATE_REWIND_TIME_API = "$Live_URL/user/updateRewindTime";
  static const POST_SEND_EMAIL_OTP_FROM_SETTING_API =
      "$Live_URL/user/sendEmailOTPFromSetting";
  static const POST_UPDATE_EMAIL_ACCOUNT_SETTING_API =
      "$Live_URL/user/updateEmailAccountSetting";
  static const HOME_USER_LIST_API = "$Live_URL/home/listOfUserForHome";
  static const UPDATE_VISIT_STATUS_API = "$Live_URL/user/updateVisitStatus";
  static const LIKE_USER_LIST_API = "$Live_URL/user/getLikeList";
  static const LIKE_SENT_USER_LIST_API = "$Live_URL/user/getSentLikeList";
  static const MATCH_USER_LIST_API = "$Live_URL/user/getMatchList";
  static const VISITOR_USER_LIST_API = "$Live_URL/user/getVisitorsList";
  static const GET_TOTAL_COUNT_LIKES_API =
      "$Live_URL/user/getTotalCountForlikes";
  static const UPDATE_ACCOUNT_SETTING_API =
      "$Live_URL/user/updateAccountSetting";
  static const UPDATE_GLOBAL_STATUS_API = "$Live_URL/user/updateGlobalStatus";
  static const UPDATE_AGE_API = "$Live_URL/user/updateAgeRange";
  static const UPDATE_DISTANCE_API = "$Live_URL/user/updateDistanceRange";
  static const UPDATE_SHOW_ME_API = "$Live_URL/user/updateShowMe";
  static const UPDATE_NOTIFICATION_TYPE_API =
      // "$Live_URL/user/updateNotificationType";
      "$Live_URL/user/updateNotificationType";
  static const VERIFY_USER_API = "$Live_URL/user/verifyDeletingUser";
  static const DELETE_ACCOUNT_API = "$Live_URL/user/deleteAccount";
  static const SEARCH_CITY_API = "$Live_URL/city";
  static const USER_CHAT_LIST_API = "$Live_URL/chats/getUserChatList";
  static const USER_NAME_CHANNEL_API = "$Live_URL/chats/userChannelName";
  static const ADD_REWIND_API = "$Live_URL/user/addRewind";
  static const CHECK_USER_NAME_CHANNEL_API =
      "$Live_URL/chats/checkUserChannelName";
  static const checkUserCanSendMsgOrNotAPI =
      "$Live_URL/chats/checkUserCanSendMsgOrNot";

  // static const ONLINE_USER_LIST_API = '$BASE_URL/chats/onlineUsers';
  static const VERIFY_YOUR_ACCOUNT_API = '$Live_URL/user/verifyYourAccount';
  static const LOGOUT_API = '$Live_URL/user/logout';

  static const GET_ALL_SUBSCRIPTION_PLAN_API =
      '$Live_URL/subscription/getSubscriptionPlan';
  static const POST_CREATE_SETUP_INTENT_API =
      '$Live_URL/subscription/createPaymentIntent';
  static const GET_ALL_NOTIFICATION_API = "$Live_URL/user/getNotifications";
  static const GET_USER_BLOCK_API = "$Live_URL/user/getListOfBlockNumbers";
  static const POST_BLOCK_USER_NUMBER_API =
      "$Live_URL/user/blockUserFromNumber";
  static const POST_UNBLOCK_API = "$Live_URL/user/unblockNumber";

  static var GET_ONLINE_USERS_API = "$Live_URL/chats/getOnlineUsers";
  static var GET_MY_REQUESTS_LIST_API = "$Live_URL/chats/getMyRequestList";
  static var GET_MY_SENT_LIST_API = "$Live_URL/chats/getMySentList";
  static var AUTO_RENEW_API = "$Live_URL/usersetting/autoRenew";
  static var RESET_USER_SETTING_AFTER_SUBSCRIPTION_API =
      "$Live_URL/usersetting/resetUserSettingAfterSubscription";
  static var UPDATE_SHOW_PROFILE_AND_ONLINE_API =
      "$Live_URL/usersetting/updateShowProfileAndOnline";
  static var UPDATE_PROFILE_NOTIFICATION_AND_MAIL_API =
      "$Live_URL/usersetting/updateProfileNotificationAndMailSendSetting";
  static var GET_POLICY_DATA_API = "$Live_URL/info/getPolicyData";
  static var UPLOAD_CHAT_IMAGES_API = "$Live_URL/chats/uploadChatImage";
  static var GET_EDUCATION_API = "$Live_URL/getEducations";
  static var GET_OCCUPATION_API = "$Live_URL/getOccupations";
  static var TAKE_SUBSCRIPTION_API = "$Live_URL/subscription/takeSubscription";
  static var TAKE_ADDONS_API = "$Live_URL/subscription/takeAddOns";
  static var SEND_INVOICES_THROUGH_MAIL =
      "$Live_URL/subscription/sendInvoicesThroughMail";
  static var REFRESH_TOKEN_API = "$Live_URL/";
}
