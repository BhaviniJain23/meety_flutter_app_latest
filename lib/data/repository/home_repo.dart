import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class HomeRepository {
  Future<Map<String, dynamic>> fetchUsers(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.HOME_USER_LIST_API,
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

  Future<Map<String, dynamic>> fetchResetUserSetting() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.RESET_USER_SETTING_AFTER_SUBSCRIPTION_API,
        data: {},
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository fetchUsers catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> updateVisitorStatus(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.UPDATE_VISIT_STATUS_API,
        data: data,
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository updateVisitorStatus catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> updateRewindTime(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().putCallWithoutHeader(
        api: EndPoints.POST_UPDATE_REWIND_TIME_API,
        data: data,
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository updateVisitorStatus catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> addRewind(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.ADD_REWIND_API,
        data: data,
      );

      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository updateVisitorStatus catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> getTotalCountForLikes() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_TOTAL_COUNT_LIKES_API,
        data: {},
      );

      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository updateVisitorStatus catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> fetchLikes(
      {required Map<String, dynamic> data}) async {
    try {
      // print(data);
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.LIKE_USER_LIST_API,
        data: data,
      );

      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository fetchLikes catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> fetchLikesSent(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.LIKE_SENT_USER_LIST_API,
        data: data,
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        if (r != null) {
          return r.data;
        } else {
          return UiString.fixFailResponse();
        }
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository fetchLikesSent catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> fetchVisitors(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.VISITOR_USER_LIST_API,
        data: data,
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository fetchVisitors catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> fetchMatches(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.MATCH_USER_LIST_API,
        data: data,
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on HomeRepository fetchMatches catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }
// Future<Map<String, dynamic>> fetchOnlineUsers(
//     {required Map<String, dynamic> data}) async {
//   try {
//     Either<String,Response?> response = await sl<ApiHelper>().postCallWithoutHeader(
//       api: EndPoints.ONLINE_USER_LIST_API,
//       data: data,
//     );
//     return response.fold((l){
//       return UiString.fixFailResponse(errorMsg: l);
//     }, (r)  {
//       return r?.data as Map<String,dynamic>;
//     });
//   }  catch (e) {
//     if (kDebugMode) {
//       // print("on HomeRepository fetchMatches catch: $e");
//     }
//     return UiString.fixFailResponse();
//   }
// }
}
