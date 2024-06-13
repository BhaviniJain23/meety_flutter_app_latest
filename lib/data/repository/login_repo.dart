import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../constants/ui_strings.dart';
import '../../services/singleton_locator.dart';
import '../end_points.dart';
import '../network/api_helper.dart';

class AuthRepository {
  Future<Map<String, dynamic>> userLoggedIn(
      {required String email,
      required String? password,
      required String loginType,
      required String socialId,
      String? fname,
      String? lname}) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      String deviceId;
      if (Platform.isIOS) {
        deviceId = (await DeviceInfoPlugin().iosInfo).identifierForVendor ?? '';
      } else {
        deviceId = (await DeviceInfoPlugin().androidInfo).id ?? '';
      }
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
              api: EndPoints.LOGIN_API,
              data: {
                'email': email,
                'password': password,
                'login_type': loginType, //for normal,
                'is_ios': Platform.isIOS ? '1' : '0',
                'device_id': deviceId,
                'social_id': socialId,
                'fcm_token': fcmToken ?? '',
                'fname': fname ?? '',
                'lname': lname ?? ''
              },
              headers: false);

      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        print("on AuthRepository userLoggedIn catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> userSignedUp(
      {required String email, required String password}) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      String deviceId;
      if (Platform.isIOS) {
        deviceId = (await DeviceInfoPlugin().iosInfo).identifierForVendor ?? '';
      } else {
        deviceId = (await DeviceInfoPlugin().androidInfo).id ?? '';
      }
      Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'login_type': 0, //for normal,
        'is_ios': Platform.isIOS ? '1' : '0',
        'social_id': '',
        'device_id': deviceId,
        'phone': '',
        'fcm_token': fcmToken ?? ''
      };
      log("data: ${data.toString()}");
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(
              api: EndPoints.SIGNUP_API, data: data, headers: false);
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> checkUserExistWithPhoneNumber(
      {required String phone}) async {
    try {
      String? deviceId = await FirebaseMessaging.instance.getToken();

      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
              api: EndPoints.CHECK_USER_EXISTS_WITH_PHONE_API,
              data: {
                'phone': phone,
                'is_ios': Platform.isIOS ? '1' : '0',
                'fcm_token': deviceId ?? '',
              },
              headers: false);
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> userSignedInWithPhone(
      {required String phone}) async {
    try {
      String? deviceId = await FirebaseMessaging.instance.getToken();

      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.SIGN_IN_WITH_PHONE_API,
        data: {
          'phone': phone,
          'is_ios': Platform.isIOS ? '1' : '0',
          'fcm_token': deviceId ?? '',
        },
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(
              api: EndPoints.FORGOT_PASSWORD_API,
              data: {'email': email},
              headers: false);
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      {required String userId, required String newPassword}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.RESET_PASSWORD_API,
        data: {
          'user_id': userId,
          'new_pass': newPassword,
        },
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> verifyEmailOTP(
      {required String email, required String otp}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.VERIFY_OTP_API,
        data: {'email': email, 'otp': otp},
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> resendEmailOTP({required String email}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.RESEND_OTP_API,
        data: {'email': email},
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }
}
