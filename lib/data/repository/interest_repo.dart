import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class InterestRepository {
  Future<List<String>> getInterestNameList() async {
    try {
      Either<String,Response?> response = await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_ALL_INTEREST_NAME_API,
        data: {},
      );
      return response.fold((l){
        return ConstantList.interestList;
      }, (r)  {
        List<String> list = List.from(
            (r?.data['list'] as List<dynamic>).map((e) => e.toString()));
        if(list.isNotEmpty) {
          return list;
        }
        return ConstantList.interestList;

      });

    } on Exception catch (e) {
      return [];
    }
  }
}
