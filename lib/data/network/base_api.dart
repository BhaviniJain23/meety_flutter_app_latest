import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import '../../services/shared_pref_manager.dart';
import '../../services/singleton_locator.dart';
import 'error_exceptions.dart';

/// This file contains the implementation of the BaseApi and ImageApi classes,
/// along with the AppInterceptors class which is an interceptor for Dio requests.
/// The BaseApi class provides a singleton instance of Dio with certain configurations,
/// while the ImageApi class provides a singleton instance of Dio with the same configurations.
/// The AppInterceptors class handles the interception of requests, responses, and errors for Dio.

class BaseApi {
  Dio dio() => createDio();

  BaseApi._internal();

  static final _singleton = BaseApi._internal();

  factory BaseApi() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(
      baseUrl: EndPoints.Live_URL,
      followRedirects: false,
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true,
    ));
    dio.interceptors.addAll({
      AppInterceptors(dio),
    });
    return dio;
  }
}

class AppInterceptors extends Interceptor {
  final Dio dio;

  bool _isRefreshing = false;

  AppInterceptors(this.dio) {
    _isRefreshing = false;
  }

  // when accessToken is expired & having multiple requests call
  // this variable to lock others request to make sure only trigger call refresh token 01 times
  // to prevent duplicate refresh call

  // when having multiple requests call at the same time, you need to store them in a list
  // then loop this list to retry every request later, after call refresh token success

  final _requestsNeedRetry =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final authToken = sl<SharedPrefsManager>().getToken();
    if (authToken.isNotEmpty && options.path != EndPoints.REFRESH_TOKEN_API) {
      options.headers['Authorization'] = "Bearer $authToken";
    }
    return handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    print("+++++++onResponse+++++++");
    print(response.data.runtimeType);
    print(response.data);

    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    print("+++++++onError+++++++");
    print(err.type);

    print(err.response?.data.runtimeType);
    print(err.response?.data);
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DeadlineExceededException(requestOptions: err.requestOptions);
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(
                requestOptions: err.requestOptions, response: err.response);
          case 404:
            throw NotFoundException(requestOptions: err.requestOptions);
          case 409:
            throw ConflictException(
                requestOptions: err.requestOptions, response: err.response);
          case 500:
            throw InternalServerErrorException(
                requestOptions: err.requestOptions);
        }
        break;
      default:
        throw InternalServerErrorException(requestOptions: err.requestOptions);
    }
    return handler.next(err);
  }
}

// Future<void> onError1(DioException err, ErrorInterceptorHandler handler) async {
//   final response = err.response;
//
//   log("err: ${err.toString()}");
//   print(err.type.toString());
//   print(err.response.toString());
//
//   if (response != null &&
//       response.data is Map &&
//       (response.data as Map).containsKey("message") &&
//       (response.data as Map)['message'].toString().toLowerCase() ==
//           "Invalid Authorization token".toLowerCase()) {
//     // throw UnauthorizedException(err.requestOptions, err.response);
//
//     final isRefreshUrlPath = response.requestOptions.path;
//
//     if (isRefreshUrlPath != EndPoints.REFRESH_TOKEN_API) {
//       if (!_isRefreshing) {
//         _isRefreshing = true;
//
//         // add request (requestOptions and handler) to queue and wait to retry later
//         _requestsNeedRetry
//             .add((options: response.requestOptions, handler: handler));
//
//         // call api refresh token
//         final isRefreshSuccess = await _refreshToken();
//
//         if (isRefreshSuccess) {
//           // refresh success, loop requests need retry
//           for (var requestNeedRetry in _requestsNeedRetry) {
//             // won't use await because this loop will take longer -> maybe throw: Unhandled Exception: Concurrent modification during iteration
//             // because method _requestsNeedRetry.add() is called at the same time
//             // final response = await dio.fetch(requestNeedRetry.options);
//             // requestNeedRetry.handler.resolve(response);
//             dio.fetch(requestNeedRetry.options).then((response) {
//               requestNeedRetry.handler.resolve(response);
//             }).catchError((_) {});
//           }
//
//           _requestsNeedRetry.clear();
//           _isRefreshing = false;
//         } else {
//           _requestsNeedRetry.clear();
//           // if refresh fail, force logout user here
//
//           sl<SharedPrefsManager>().logoutUser(null);
//           // sharedPreferenceController.clearAllPreferences();
//           // get_lib.Get.offAllNamed(Routes.ONBOARDING);
//         }
//       } else {
//         // if refresh flow is processing, add this request to queue and wait to retry later
//         _requestsNeedRetry
//             .add((options: response.requestOptions, handler: handler));
//       }
//     } else {
//       // if refresh token throw force logout here
//       _requestsNeedRetry.clear();
//       // sharedPreferenceController.clearAllPreferences();
//       sl<SharedPrefsManager>().logoutUser(null);
//       // get_lib.Get.offAllNamed(Routes.ONBOARDING);
//     }
//   } else {
//     log("err: ${err.toString()}");
//     print(err.type.toString());
//     print(err.response.toString());
//     switch (err.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         throw DeadlineExceededException(requestOptions: err.requestOptions);
//       case DioExceptionType.badResponse:
//         switch (err.response?.statusCode) {
//           case 400:
//             throw BadRequestException(
//                 requestOptions: err.requestOptions, response: err.response);
//           case 401:
//             throw UnauthorizedException(
//                 requestOptions: err.requestOptions, response: err.response);
//           case 404:
//             throw NotFoundException(requestOptions: err.requestOptions);
//           case 409:
//             throw ConflictException(
//                 requestOptions: err.requestOptions, response: err.response);
//           case 500:
//             throw InternalServerErrorException(
//                 requestOptions: err.requestOptions);
//         }
//         break;
//       case DioExceptionType.cancel:
//         break;
//       case DioExceptionType.unknown:
//         throw NoInternetConnectionException(requestOptions: err.requestOptions);
//       default:
//         break;
//     }
//     return handler.next(err);
//   }
// }
//
// Future<bool> _refreshToken() async {
//   return false;
//   // try {
//   //   final refreshToken = sl<SharedPrefsManager>().getToken();
//   //   final response = await ApiHelper().postCallWithoutHeader(
//   //       api: EndPoints.REFRESH_TOKEN_API,
//   //       data: {"refreshToken": refreshToken});
//   //
//   //
//   //   log('response: ${response.toString()}');
//   //   if (response.toString().isNotEmpty) {
//   //     if (response.toString().isNotEmpty && response is Response) {
//   //       Map<String, dynamic> data = response.;
//   //       sl<SharedPrefsManager>().saveToken(response['accessToken']);
//   //       // await sharedPreferenceController.setAccessToken({...response});
//   //
//   //       if (sl<SharedPrefsManager>().getToken().isNotEmpty) {
//   //         return true;
//   //       }
//   //
//   //       return false;
//   //     } else {
//   //       // showAppSnackBar(
//   //       //     message: "Session Expired.Please login again.",
//   //       //     toastType: ToastType.error);
//   //
//   //       return false;
//   //     }
//   //   } else {
//   //     return false;
//   //   }
//   // } on Exception catch (error) {
//   //   print("refresh token fail $error");
//   //   return false;
//   // }
// }
