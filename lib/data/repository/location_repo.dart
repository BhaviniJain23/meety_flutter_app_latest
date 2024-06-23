import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/models/location.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

import '../end_points.dart';

class LocationRepo {
  Future<Either<String, List<Location>>> searchLocations(
      {required String cityName}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .getCallWithoutHeader(
              api: '${EndPoints.SEARCH_CITY_API}/$cityName', data: {});
      log('response: ${response.toString()}');
      return response.fold((l) {
        return Left(l);
      }, (r) {
        // if (r?.data is List) {
        final result = List<Location>.from(
            r?.data['data']?.map((e) => Location.fromJson(e)));
        return Right(result);
        // }
        // return const Right([]);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<Location>>> searchLocationsWithoutCity() async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .getCallWithoutHeader(api: EndPoints.SEARCH_CITY_API, data: {});
      return response.fold((l) {
        return Left(l);
      }, (r) {
        if (r?.data is List) {
          final result =
              List<Location>.from(r?.data?.map((e) => Location.fromJson(e)));

          /// save into local
          return Right(result);
        }
        return const Right([]);
      });
    } catch (e) {
      return Left(e.toString());
    }
  }
}
