import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/ui_strings.dart';
import '../../services/singleton_locator.dart';
import '../end_points.dart';
import '../network/api_helper.dart';

class BlockRepository {
  Future<Map<String, dynamic>> fetchedBlockedNumber() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_USER_BLOCK_API,
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

  Future<Map<String, dynamic>> blockUserNumber(
      Map<String, dynamic> data) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.POST_BLOCK_USER_NUMBER_API,
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

  Future<Map<String, dynamic>> unBlock(Map<String, dynamic> data) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.POST_UNBLOCK_API,
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
