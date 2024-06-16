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
      receiveTimeout: const Duration(seconds: 15),
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
    log("error: ${err.toString()}");

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
