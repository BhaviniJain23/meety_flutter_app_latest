import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/models/interest.dart';
import 'package:meety_dating_app/services/image_compress_service.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

import 'base_api.dart';

typedef OnUploadProgressCallback = void Function(int percentage);

class ApiHelper {
  // late final Dio _dio;

  // static final _dio = BaseApi().dio();
  static final _dio = BaseApi().dio();

  ApiHelper() {
    BaseOptions baseOptions = BaseOptions(
      baseUrl: EndPoints.Live_URL,
      followRedirects: false,
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true,
    );
    // _dio = Dio(baseOptions);
  }

  // Private method to send HTTP requests
  static Future<Either<String, Response?>> _sendRequest(
    String method,
    String url,
    dynamic body, {
    Map<String, dynamic>? headers,
    bool isToken = true,
  }) async {
    try {
      // Check internet connectivity
      bool isInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      // String authToken =  sl<SharedPrefsManager>().getToken();

      print(isInternet);
      if (isInternet) {
        // Prepare headers
        Response<Map<String, dynamic>>? response;
        Map<String, dynamic> headersVal = {"Content-Type": "application/json"};

        if (isToken) {
          String? token = sl<SharedPrefsManager>().getToken();
          // headersMap["Authorization"] = token;
          headersVal["Authorization"] = "Bearer $token";
        }

        log("put method !!!!!");
        log("data: ${body.toString()}");
        log("headersVal: ${headersVal.toString()}");

        // Send HTTP request based on the method
        if (method == 'get') {
          response = await _dio.get(
            url,
            options: Options(
              headers: headersVal,
            ),
          );
        } else if (method == 'put') {
          response = await _dio.put(
            url,
            data: body,
            options: Options(
              headers: headersVal,
            ),
          );
        } else if (method == 'delete') {
          response = await _dio.delete(
            url,
            data: body,
            options: Options(
              headers: headersVal,
            ),
          );
        } else {
          response = await _dio.post(
            url,
            data: body,
            options: Options(
              headers: headersVal,
            ),
          );
        }

        // Return the response data and success status
        if (response.statusCode == 200) {
          return Right(response);
        } else {
          return Left(
            response.data!['message'].toString() ?? '',
          );
        }
      } else {
        return const Left(
          "No Internet",
        );
      }
    } on DioException catch (e) {
      return Left(
        e.toString(),
      );
    }
  }

  Future<Either<String, Response?>> getCallWithoutHeader(
      {required String api,
      required Map<String, dynamic> data,
      bool headers = true}) async {
    return await _sendRequest('get', api, data, isToken: headers);
  }

  Future<Either<String, Response?>> postCallWithoutHeader(
      {required String api,
      required Map<String, dynamic> data,
      bool headers = true}) async {
    return await _sendRequest('post', api, data, isToken: headers);
  }

  Future<Either<String, Response?>> putCallWithoutHeader(
      {required String api,
      required Map<String, dynamic> data,
      bool headers = true}) async {
    return await _sendRequest('put', api, data, isToken: headers);
  }

  Future<Either<String, Response?>> postCallWithDioHeaderMultipart(
      String api, Map<String, dynamic> data, List<dynamic> images,
      {OnUploadProgressCallback? onUploadProgress, bool headers = true}) async {
    Map<String, String> headersMap = {};
    if (headers) {
      String? token = sl<SharedPrefsManager>().getToken();
      // headersMap["Authorization"] = token;
      headersMap["Authorization"] = "Bearer $token";
    }
    var dio = Dio();
    try {
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (checkInternet) {
        FormData formData = FormData.fromMap(data);

        for (int i = 0; i < images.length; i++) {
          File imageFile;

          if (!images[i].toString().startsWith('http') &&
              images[i].toString().startsWith('/')) {
            if (Utils.getFileType(images[i]) == FileTypes.IMAGE) {
              ImageCompressService imageCompressService = ImageCompressService(
                file: File(images[i]),
              );
              imageFile = (await imageCompressService.exec())!;
            } else if (Utils.getFileType(images[i]) == FileTypes.VIDEO) {
              ImageCompressService imageCompressService = ImageCompressService(
                file: File(images[i]),
              );
              imageFile = (await imageCompressService.execVideo(
                  onUploadProgress: (percentage) {
                if (onUploadProgress != null) {
                  onUploadProgress(percentage ~/ 2);
                }
              }))!;
            } else {
              imageFile = File(images[i]);
            }

            MultipartFile multipartFile = await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            );
            formData.files.add(MapEntry('image', multipartFile));
          }
        }

        log("response: ${formData.fields.toString()}");
        log("response: ${formData.files.toString()}");
        Response response = await dio.post(
          api,
          data: formData,
          onSendProgress: (received, total) {
            if (total != -1) {
              // // // print((received / total * 100).toStringAsFixed(0) + '%');
              if (onUploadProgress != null) {
                var percentage = (received / total * 100);
                onUploadProgress(int.parse((images.isNotEmpty &&
                            Utils.getFileType(images[0]) == FileTypes.VIDEO
                        ? (percentage / 2)
                        : percentage)
                    .toStringAsFixed(0)));
              }
            }
          },
          options: Options(
            headers: headersMap,
            followRedirects: false,
            validateStatus: (status) => true,
          ),
        );

        log("response: ${response.toString()}");
        if (response.statusCode == 200) {
          return Right(response);
        } else {
          return Left(
            response.data!['message'].toString(),
          );
        }
      } else {
        return const Left(UiString.noInternet);
      }
    } on DioError catch (e) {
      if (DioErrorType.receiveTimeout == e.type ||
          DioErrorType.connectionTimeout == e.type) {
        return Left(UiString.timeOutError);
      } else if (e.message?.contains('SocketException') ?? false) {
        return left(UiString.noInternet);
      } else if (e.response != null && e.response!.data != null) {
        return left(
          e.response?.data.toString() ?? e.message ?? UiString.error,
        );
      }
      return left(
        e.message ?? UiString.error,
      );
    } catch (e) {
      return left(
        e.toString(),
      );
    }
  }
}
