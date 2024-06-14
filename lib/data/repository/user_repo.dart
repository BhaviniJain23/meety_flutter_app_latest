import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants/constants.dart';
import '../../constants/ui_strings.dart';
import '../../services/singleton_locator.dart';
import '../end_points.dart';
import '../network/api_helper.dart';

class UserRepository {
  Future<Map<String, dynamic>> updateProfile(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.SET_UP_PROFILE_API,
        data: data,
      );
      // log("response: ${response.toString()}");
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> getPolicy() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_POLICY_DATA_API,
        data: {},
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

  Future<Map<String, dynamic>> updateLocation(
      {required String lat,
      required String long,
      required String isCurrent}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.UPDATE_LOCATION_API,
        data: {'lat': lat, 'long': long, 'is_current': isCurrent},
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

  Future<Map<String, dynamic>> addMultiProfilePic({
    required Map<String, dynamic> data,
    required List<dynamic> images,
  }) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithDioHeaderMultipart(
              EndPoints.ADD_MULTI_PROFILE_API, data, images);
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> deleteProfilePic({
    required String userId,
    required String filename,
  }) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.DELETE_PROFILE_PIC_API,
        data: {'user_id': userId, 'filename': filename},
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

  Future<Map<String, dynamic>> updateProfilePic(
      {required Map<String, dynamic> data,
      required List<String> images}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithDioHeaderMultipart(
              EndPoints.UPDATE_PROFILE_PIC_API, data, images);

      return response.fold((l) {
        if (kDebugMode) {
          print("on updateProfilePic response: $l");
        }

        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> verifyYourProfile({
    required Map<String, dynamic> data,
    required String images,
    OnUploadProgressCallback? onUploadProgress,
  }) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithDioHeaderMultipart(
              EndPoints.VERIFY_YOUR_ACCOUNT_API, data, [images],
              onUploadProgress: onUploadProgress);
      return response.fold((l) {
        if (kDebugMode) {
          // print("on verifyYourProfile response: $l");
        }
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> getUserProfile({required String userId}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .getCallWithoutHeader(
              api: EndPoints.GET_PROFILE_API, data: {"other_user_id": userId});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> getFcmTokenFromUserId(
      {required String userId}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .getCallWithoutHeader(
              api: EndPoints.GET_FCM_TOKEN_API, data: {"user_id": userId});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> reportUser(
      {required String userId, required String reason}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(
              api: EndPoints.POST_REPORT_USER_API,
              data: {"reported_user_id": userId, "report_reason": reason});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> blockUser(
      {required String userId, String? isBlock}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(
              api: EndPoints.POST_BLOCK_USER_API,
              data: {"block_user_id": userId, "is_block": isBlock ?? "1"});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> sendEmailOTPFromSetting(
      {required String email}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.POST_SEND_EMAIL_OTP_FROM_SETTING_API,
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

  Future<Map<String, dynamic>> updateEmailAccountSetting(
      {required String email, required String otp}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.POST_UPDATE_EMAIL_ACCOUNT_SETTING_API,
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

  Future<Map<String, dynamic>> updateAccountSetting(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.UPDATE_ACCOUNT_SETTING_API,
        data: data,
      );

      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> updateGlobalStatus(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.UPDATE_GLOBAL_STATUS_API,
        data: data,
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

  Future<Map<String, dynamic>> autoRenewAPICall(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.AUTO_RENEW_API,
        data: data,
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

  Future<Map<String, dynamic>> notificationAPICall(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.UPDATE_PROFILE_NOTIFICATION_AND_MAIL_API,
        data: data,
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

  Future<Map<String, dynamic>> fetchUpdateShowProfileAndOnline(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.UPDATE_SHOW_PROFILE_AND_ONLINE_API,
        data: data,
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

  Future<Map<String, dynamic>> updateAgeRange(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.UPDATE_AGE_API,
        data: data,
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

  Future<Map<String, dynamic>> updateMaximumDistance(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.UPDATE_DISTANCE_API,
        data: data,
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

  Future<Map<String, dynamic>> updateNotificationType(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.UPDATE_NOTIFICATION_TYPE_API,
        data: data,
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

  Future<Map<String, dynamic>> verifyUser(
      {String? password, String? email}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.VERIFY_USER_API,
        data: {'email': email, 'password': password},
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

  Future<Map<String, dynamic>> deactivateAccount(
      {String? password, String? email, String? days}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.DELETE_ACCOUNT_API,
        data: {'delete_status': Constants.deactivate, "days": days},
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

  Future<Map<String, dynamic>> deleteAccount(
      {String? password, String? email}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.DELETE_ACCOUNT_API,
        data: {'delete_status': Constants.delete},
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

  Future<Map<String, dynamic>> logout() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.LOGOUT_API,
        data: {},
      );
      // print(response);
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
