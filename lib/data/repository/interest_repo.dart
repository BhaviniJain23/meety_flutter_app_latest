import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/models/interest.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class InterestRepository {
  Future<List<Interest>> getInterestNameList() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_ALL_INTEREST_NAME_API,
        data: {},
      );
      return response.fold((l) {
        // return ConstantList.interestList;
        List<Interest> list = List.from(
            (ConstantList.interestList).map((e) => Interest.fromJson(e)));
        return list;
      }, (r) {
        List<Interest> list = List.from((r?.data['list'] as List<dynamic>)
            .map((e) => Interest.fromJson(e)));
        if (list.isNotEmpty) {
          return list;
        }
        return List.from(
            (ConstantList.interestList).map((e) => Interest.fromJson(e)));
      });
    } on Exception catch (e) {
      return [];
    }
  }
}
