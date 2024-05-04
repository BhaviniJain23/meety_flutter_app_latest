import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/ui_strings.dart';
import '../../services/singleton_locator.dart';
import '../end_points.dart';
import '../network/api_helper.dart';

class NotificationRepository {
  Future<Map<String, dynamic>> getAllNotification(Map<String,dynamic> data) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_ALL_NOTIFICATION_API,
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
}
